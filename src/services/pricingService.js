// Server-side pricing — the total sent by the browser is never trusted.
// TOTAL = package price (with running deal) + ticket total + environmental fee (per ticketed guest) + add-on total (with running deals)
const A = require('./availabilityService');

const TICKET_TYPES = [
  { key: 'adults', setting: 'ticket_price_adult', label: 'Adult Entrance Ticket', match: ['adult'] },
  { key: 'children', setting: 'ticket_price_child', label: 'Child Entrance Ticket', match: ['child'] },
  { key: 'students', setting: 'ticket_price_student', label: 'Student Entrance Ticket', match: ['student'] },
  { key: 'seniors', setting: 'ticket_price_senior', label: 'Senior / PWD Entrance Ticket', match: ['senior', 'pwd'] },
];

const norm = (v) => String(v || '').toLowerCase().trim();

const loadPricingContext = async (conn) => {
  const [settings] = await conn.query("SELECT setting_key, setting_value FROM settings WHERE setting_key LIKE 'ticket_price_%' OR setting_key = 'environmental_fee_per_head'");
  const cfg = Object.fromEntries(settings.map((s) => [s.setting_key, parseFloat(s.setting_value)]));
  const [deals] = await conn.query(
    "SELECT * FROM promotions WHERE deleted_at IS NULL AND status = 'Active' AND start_at <= NOW() AND end_at >= NOW() AND (usage_limit IS NULL OR used_count < usage_limit)"
  );
  const [dealPackages] = await conn.query('SELECT * FROM promotion_packages');
  const [dealServices] = await conn.query('SELECT * FROM promotion_services');
  return {
    ticketPrice: {
      adults: cfg.ticket_price_adult ?? 100,
      children: cfg.ticket_price_child ?? 40,
      students: cfg.ticket_price_student ?? 70,
      seniors: cfg.ticket_price_senior ?? 80,
    },
    envFee: cfg.environmental_fee_per_head ?? 30,
    deals,
    dealPackages,
    dealServices,
  };
};

const applyDiscount = (base, type, value) => {
  const v = parseFloat(value || 0);
  if (type === 'Percentage') return Math.max(0, Math.round(base * (1 - v / 100) * 100) / 100);
  if (type === 'Fixed') return Math.max(0, base - v);
  if (type === 'Special Price') return Math.max(0, v);
  return base;
};

// Best running deal price for a package
const packagePrice = (ctx, pkg) => {
  const regular = parseFloat(pkg.regular_value || 0);
  let best = parseFloat(pkg.promo_price || 0) || regular;
  let deal = null;
  ctx.dealPackages.filter((dp) => dp.package_id === pkg.id).forEach((dp) => {
    const d = ctx.deals.find((x) => x.id === dp.promotion_id);
    if (!d) return;
    const price = applyDiscount(regular, dp.discount_type || d.discount_type, dp.discount_value ?? d.discount_value);
    if (price < best) { best = price; deal = d; }
  });
  return { regular, price: best, deal };
};

const servicePrice = (ctx, svc) => {
  const base = parseFloat(svc.price || 0);
  let best = base;
  let deal = null;
  ctx.dealServices.filter((ds) => ds.service_id === svc.service_id).forEach((ds) => {
    const d = ctx.deals.find((x) => x.id === ds.promotion_id);
    if (!d) return;
    const price = applyDiscount(base, d.discount_type, d.discount_value);
    if (price < best) { best = price; deal = d; }
  });
  return { base, price: best, deal };
};

// Normalise either the structured payload ({packageId, tickets, addons}) or a legacy item list into one shape
const normaliseRequest = (catalog, body) => {
  const out = { packageId: body.packageId || null, tickets: { adults: 0, children: 0, students: 0, seniors: 0 }, addons: [] };
  const structured = body.tickets || body.addons;
  if (structured) {
    TICKET_TYPES.forEach((t) => { out.tickets[t.key] = Math.max(0, parseInt(body.tickets?.[t.key] || 0, 10)); });
    (body.addons || []).forEach((a) => {
      const svc = A.findService(catalog, a.serviceId ?? a.service_id ?? a.name);
      const qty = parseInt(a.quantity, 10) || 0;
      if (svc && qty > 0) out.addons.push({ svc, quantity: qty });
    });
    return out;
  }
  (body.items || []).forEach((it) => {
    const name = norm(it.serviceName || it.service_name || it.name);
    const qty = parseInt(it.quantity, 10) || 0;
    if (!name || qty <= 0) return;
    if (name.includes('environmental fee')) return; // recomputed from tickets
    const pkg = catalog.packages.find((p) => norm(p.package_name) === name);
    if (pkg) { out.packageId = out.packageId || pkg.id; return; }
    const ticket = TICKET_TYPES.find((t) => name.includes('entrance') && t.match.some((m) => name.includes(m)));
    if (ticket) { out.tickets[ticket.key] += qty; return; }
    const svc = A.resolveItemService(catalog, it);
    if (svc && norm(svc.category) === 'entrance') { out.tickets.adults += qty; return; }
    if (svc) out.addons.push({ svc, quantity: qty });
  });
  return out;
};

const bookingTypeOf = (hasPackage, hasTickets, hasAddons) => {
  if (hasPackage) {
    if (hasTickets && hasAddons) return 'PACKAGE_WITH_TICKETS_AND_ADDONS';
    if (hasTickets) return 'PACKAGE_WITH_TICKETS';
    if (hasAddons) return 'PACKAGE_WITH_ADDONS';
    return 'PACKAGE_ONLY';
  }
  if (hasTickets && hasAddons) return 'TICKETS_WITH_ADDONS';
  if (hasTickets) return 'TICKETS_ONLY';
  return 'ADDONS_ONLY';
};

// Returns priced lines + totals + availability demand. Throws { code, message } on invalid input.
const priceBooking = (catalog, ctx, body) => {
  const req = normaliseRequest(catalog, body);
  const lines = [];
  const pkg = req.packageId ? A.findPackage(catalog, req.packageId) : null;
  if (req.packageId && !pkg) throw Object.assign(new Error('The selected package no longer exists.'), { code: 'PACKAGE_NOT_FOUND' });

  let originalValue = 0;
  let discount = 0;
  let appliedDeal = null;
  if (pkg) {
    const pp = packagePrice(ctx, pkg);
    originalValue += pp.regular;
    discount += Math.max(0, pp.regular - pp.price);
    appliedDeal = pp.deal;
    lines.push({ itemType: 'PACKAGE', serviceId: 0, name: pkg.package_name, quantity: 1, unitPrice: pp.price, subtotal: pp.price });
  }

  const ticketHeads = TICKET_TYPES.reduce((sum, t) => sum + req.tickets[t.key], 0);
  TICKET_TYPES.forEach((t) => {
    const qty = req.tickets[t.key];
    if (qty > 0) {
      const unit = ctx.ticketPrice[t.key];
      lines.push({ itemType: 'TICKET', serviceId: 0, name: t.label, quantity: qty, unitPrice: unit, subtotal: unit * qty });
      originalValue += unit * qty;
    }
  });
  if (ticketHeads > 0 && ctx.envFee > 0) {
    lines.push({ itemType: 'FEE', serviceId: 0, name: 'Barangay Environmental Fee', quantity: ticketHeads, unitPrice: ctx.envFee, subtotal: ctx.envFee * ticketHeads });
    originalValue += ctx.envFee * ticketHeads;
  }

  req.addons.forEach(({ svc, quantity }) => {
    const minQty = parseInt(svc.minimum_quantity || 1, 10);
    if (quantity < minQty) throw Object.assign(new Error(`${svc.service_name} requires at least ${minQty}.`), { code: 'MIN_QUANTITY' });
    const sp = servicePrice(ctx, svc);
    const includedInPackage = pkg && catalog.packageItems.some((pi) => pi.package_id === pkg.id && pi.service_id === svc.service_id);
    lines.push({
      itemType: 'ADDON',
      serviceId: svc.service_id,
      name: includedInPackage ? `Extra ${svc.service_name}` : svc.service_name,
      quantity,
      unitPrice: sp.price,
      subtotal: sp.price * quantity,
    });
    originalValue += sp.base * quantity;
    discount += (sp.base - sp.price) * quantity;
    if (!appliedDeal && sp.deal) appliedDeal = sp.deal;
  });

  if (lines.length === 0) {
    throw Object.assign(new Error('Please select a package, entrance tickets, or at least one service.'), { code: 'EMPTY_BOOKING' });
  }

  const total = Math.round(lines.reduce((s, l) => s + l.subtotal, 0) * 100) / 100;

  // Availability demand: package components + ticketed guests (entrance) + add-ons
  const extra = [];
  const entrance = catalog.services.find((s) => norm(s.category) === 'entrance');
  if (entrance && ticketHeads > 0) extra.push({ serviceId: entrance.service_id, quantity: ticketHeads });
  req.addons.forEach(({ svc, quantity }) => extra.push({ serviceId: svc.service_id, quantity }));
  const demand = A.demandFromRequest(catalog, { items: [], packageId: pkg?.id, extra });

  return {
    pkg,
    lines,
    total,
    originalValue,
    discount: Math.round(discount * 100) / 100,
    basePackagePrice: pkg ? lines[0].unitPrice : 0,
    appliedDeal,
    pax: Math.max(1, (pkg ? parseInt(pkg.included_guests || 0, 10) : 0) + ticketHeads),
    ticketHeads,
    bookingType: bookingTypeOf(!!pkg, ticketHeads > 0, req.addons.length > 0),
    demand,
  };
};

module.exports = { loadPricingContext, priceBooking, packagePrice, servicePrice, TICKET_TYPES };
