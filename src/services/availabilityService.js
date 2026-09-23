// Date-based availability engine — the single source of truth for service / package availability.
//
// capacity(service, date):
//   assignable services (numbered units)  -> units with status 'Available' that are not blocked on that date
//   quantity-based services               -> capacity_limits.daily_capacity | service_inventory.total_quantity | services.total_capacity
// demand(service, date):
//   sum of quantities from every ACTIVE booking on that date (pending, confirmed, paid, checked in, using, walk-ins),
//   including package bookings expanded through package_items.
// status: manual admin status wins (OUT_OF_STOCK / UNAVAILABLE / MAINTENANCE / INACTIVE), otherwise
//   OUT_OF_STOCK (no stock at all) -> FULLY_BOOKED (0 left for the date) -> LOW_STOCK (<= threshold) -> AVAILABLE.
const db = require('../config/database');

const INACTIVE_BOOKING_PATTERNS = ['cancel', 'reject', 'void', 'complete', 'checked out', 'checkout', 'done'];
const MANUAL_STATUSES = ['OUT_OF_STOCK', 'UNAVAILABLE', 'MAINTENANCE'];
const BLOCKING_STATUSES = ['OUT_OF_STOCK', 'UNAVAILABLE', 'MAINTENANCE', 'INACTIVE', 'FULLY_BOOKED'];

const isActiveBookingStatus = (status) => {
  const s = String(status || '').toLowerCase();
  return !INACTIVE_BOOKING_PATTERNS.some((p) => s.includes(p));
};

const toDateStr = (d) => {
  if (!d) return null;
  if (typeof d === 'string') return d.slice(0, 10);
  const dt = new Date(d);
  return `${dt.getFullYear()}-${String(dt.getMonth() + 1).padStart(2, '0')}-${String(dt.getDate()).padStart(2, '0')}`;
};

const todayPH = () => {
  const parts = new Intl.DateTimeFormat('en-CA', { timeZone: 'Asia/Manila', year: 'numeric', month: '2-digit', day: '2-digit' }).format(new Date());
  return parts;
};

const norm = (v) => String(v || '').toLowerCase().trim();

const loadCatalog = async (conn = db) => {
  const [services] = await conn.query('SELECT * FROM services WHERE deleted_at IS NULL');
  const [packages] = await conn.query('SELECT * FROM packages WHERE deleted_at IS NULL');
  const [packageItems] = await conn.query('SELECT package_id, service_id, quantity FROM package_items');
  const [limits] = await conn.query('SELECT service_id, daily_capacity FROM capacity_limits');
  const [inventory] = await conn.query('SELECT service_id, total_quantity FROM service_inventory');
  const [settings] = await conn.query("SELECT setting_value FROM settings WHERE setting_key = 'low_stock_threshold_pct'");
  return {
    services,
    packages,
    packageItems,
    limits: new Map(limits.map((l) => [l.service_id, parseInt(l.daily_capacity, 10)])),
    inventory: new Map(inventory.map((i) => [i.service_id, parseInt(i.total_quantity, 10)])),
    lowStockPct: parseFloat(settings[0]?.setting_value || 20),
  };
};

// Resolve an id / code / name coming from the frontend to a service row
const findService = (catalog, ref) => {
  if (ref === undefined || ref === null || ref === '') return null;
  const r = norm(ref);
  return catalog.services.find((s) =>
    String(s.service_id) === String(ref) || norm(s.service_code) === r || norm(s.service_name) === r
  ) || null;
};

const findPackage = (catalog, ref) => {
  if (ref === undefined || ref === null || ref === '') return null;
  const r = norm(ref).replace(/^pkg-/, '');
  return catalog.packages.find((p) =>
    String(p.id) === r || norm(p.package_code) === norm(ref) || norm(p.package_name) === norm(ref)
  ) || null;
};

// Map a booking line item (by name) to a service. Entrance tickets of any type map to the Entrance service.
const resolveItemService = (catalog, item) => {
  const name = norm(item.serviceName || item.service_name || item.name);
  if (!name) return null;
  if (name.includes('environmental fee')) return null;
  if (catalog.packages.some((p) => norm(p.package_name) === name)) return null;
  if (name.includes('entrance')) {
    return catalog.services.find((s) => norm(s.category) === 'entrance') || null;
  }
  return catalog.services.find((s) => norm(s.service_name) === name)
    || catalog.services.find((s) => name.includes(norm(s.service_name)) || norm(s.service_name).includes(name))
    || null;
};

const packageDemand = (catalog, packageId, multiplier = 1) =>
  catalog.packageItems
    .filter((pi) => String(pi.package_id) === String(packageId))
    .map((pi) => ({ serviceId: pi.service_id, quantity: (parseInt(pi.quantity, 10) || 1) * multiplier }));

// Turn a booking payload (items + packageId) into [{serviceId, quantity}] aggregated per service
const demandFromRequest = (catalog, { items = [], packageId = null, extra = [] }) => {
  const totals = new Map();
  const add = (serviceId, qty) => {
    if (!serviceId || !(qty > 0)) return;
    totals.set(serviceId, (totals.get(serviceId) || 0) + qty);
  };
  const pkg = findPackage(catalog, packageId);
  if (pkg) packageDemand(catalog, pkg.id).forEach((d) => add(d.serviceId, d.quantity));
  (items || []).forEach((it) => {
    const name = norm(it.serviceName || it.service_name || it.name);
    // A package line without packageId (older clients) — expand by name
    const namedPkg = !pkg && catalog.packages.find((p) => norm(p.package_name) === name);
    if (namedPkg) {
      packageDemand(catalog, namedPkg.id, parseInt(it.quantity, 10) || 1).forEach((d) => add(d.serviceId, d.quantity));
      return;
    }
    // Names are authoritative (legacy booking_items.service_id values are row indexes, not service ids)
    const resolved = name
      ? resolveItemService(catalog, it)
      : findService(catalog, it.serviceId || it.service_id);
    if (resolved) add(resolved.service_id, parseInt(it.quantity, 10) || 1);
  });
  (extra || []).forEach((d) => add(d.serviceId, d.quantity));
  return Array.from(totals.entries()).map(([serviceId, quantity]) => ({ serviceId, quantity }));
};

// Reserved quantities per service for a date, from every active booking
const reservedForDate = async (catalog, date, { conn = db, excludeBookingId = null } = {}) => {
  const [bookings] = await conn.query(
    'SELECT id, package_id, status FROM bookings WHERE booking_date = ?',
    [date]
  );
  const active = bookings.filter((b) => isActiveBookingStatus(b.status) && String(b.id) !== String(excludeBookingId));
  const reserved = new Map();
  if (active.length === 0) return reserved;
  const [items] = await conn.query(
    `SELECT booking_id, service_id, service_name, quantity FROM booking_items WHERE booking_id IN (${active.map(() => '?').join(',')})`,
    active.map((b) => b.id)
  );
  const itemsByBooking = new Map();
  items.forEach((i) => {
    if (!itemsByBooking.has(i.booking_id)) itemsByBooking.set(i.booking_id, []);
    itemsByBooking.get(i.booking_id).push({ name: i.service_name, quantity: i.quantity });
  });
  active.forEach((b) => {
    demandFromRequest(catalog, { items: itemsByBooking.get(b.id) || [], packageId: b.package_id }).forEach((d) => {
      reserved.set(d.serviceId, (reserved.get(d.serviceId) || 0) + d.quantity);
    });
  });
  return reserved;
};

const unitCounts = async (date, conn = db) => {
  const [units] = await conn.query(
    `SELECT r.id, r.service_id, r.status,
       EXISTS (SELECT 1 FROM resource_blocks rb WHERE rb.service_resource_id = r.id AND DATE(rb.start_time) <= ? AND DATE(rb.end_time) >= ?) AS blocked
     FROM service_resources r`,
    [date, date]
  );
  const counts = new Map();
  units.forEach((u) => {
    const c = counts.get(u.service_id) || { total: 0, usable: 0 };
    c.total += 1;
    if (u.status === 'Available' && !u.blocked) c.usable += 1;
    counts.set(u.service_id, c);
  });
  return counts;
};

const capacityFor = (catalog, service, units) => {
  if (service.is_assignable && units.has(service.service_id)) return units.get(service.service_id).usable;
  return catalog.limits.get(service.service_id)
    ?? catalog.inventory.get(service.service_id)
    ?? (parseInt(service.total_capacity, 10) || 0);
};

const computeStatus = (service, total, reserved, lowStockPct) => {
  if (service.status === 'Inactive') return 'INACTIVE';
  if (MANUAL_STATUSES.includes(service.manual_status)) return service.manual_status;
  const available = Math.max(0, total - reserved);
  if (total <= 0) return 'OUT_OF_STOCK';
  if (available <= 0) return 'FULLY_BOOKED';
  const threshold = Math.max(1, Math.ceil(total * (lowStockPct / 100)));
  if (available <= threshold) return 'LOW_STOCK';
  return 'AVAILABLE';
};

// Availability of every service for a date
const getServicesAvailability = async (date, { conn = db, excludeBookingId = null, catalog: preloaded = null } = {}) => {
  const catalog = preloaded || await loadCatalog(conn);
  const [reserved, units] = await Promise.all([
    reservedForDate(catalog, date, { conn, excludeBookingId }),
    unitCounts(date, conn),
  ]);
  const byId = new Map();
  catalog.services.forEach((s) => {
    const total = capacityFor(catalog, s, units);
    const booked = reserved.get(s.service_id) || 0;
    byId.set(s.service_id, {
      serviceId: s.service_id,
      serviceCode: s.service_code,
      serviceName: s.service_name,
      category: s.category,
      isAssignable: !!s.is_assignable,
      total,
      reserved: booked,
      available: Math.max(0, total - booked),
      status: computeStatus(s, total, booked, catalog.lowStockPct),
      manualStatus: s.manual_status || null,
    });
  });
  return { catalog, byId, date };
};

// Check a set of requested quantities; returns items + unavailable list
const checkDemand = (availability, demand) => {
  const items = demand.map((d) => {
    const a = availability.byId.get(d.serviceId);
    if (!a) return null;
    const enough = a.available >= d.quantity;
    const blockedManually = ['OUT_OF_STOCK', 'UNAVAILABLE', 'MAINTENANCE', 'INACTIVE'].includes(a.status);
    return {
      ...a,
      requested: d.quantity,
      ok: enough && !blockedManually,
      // status of this service for THIS request
      status: blockedManually ? a.status : (!enough ? (a.total <= 0 ? 'OUT_OF_STOCK' : 'FULLY_BOOKED') : a.status),
    };
  }).filter(Boolean);
  const unavailable = items.filter((i) => !i.ok);
  const status = unavailable.length > 0 ? 'FULLY_BOOKED' : items.some((i) => i.status === 'LOW_STOCK') ? 'ALMOST_FULL' : 'AVAILABLE';
  return { status, items, unavailable };
};

const describeUnavailable = (unavailable, date) => {
  if (!unavailable.length) return '';
  const parts = unavailable.map((u) => {
    if (u.status === 'OUT_OF_STOCK') return `${u.serviceName} is OUT OF STOCK`;
    if (u.status === 'UNAVAILABLE' || u.status === 'INACTIVE') return `${u.serviceName} is UNAVAILABLE`;
    if (u.status === 'MAINTENANCE') return `${u.serviceName} is under MAINTENANCE`;
    if (u.available > 0) return `Only ${u.available} × ${u.serviceName} available (you requested ${u.requested})`;
    return `${u.serviceName} is FULLY BOOKED (${u.reserved}/${u.total} reserved)`;
  });
  return `${parts.join('; ')} for ${date}.`;
};

// Package availability summary for a date
const packageAvailability = (availability, packageRow) => {
  const demand = packageDemand(availability.catalog, packageRow.id);
  const result = checkDemand(availability, demand);
  let status = result.status === 'FULLY_BOOKED' ? 'UNAVAILABLE' : result.status === 'ALMOST_FULL' ? 'LOW_STOCK' : 'AVAILABLE';
  if (packageRow.status === 'Inactive') status = 'INACTIVE';
  if (MANUAL_STATUSES.includes(packageRow.manual_status)) status = packageRow.manual_status;
  return { status, items: result.items, unavailable: result.unavailable };
};

module.exports = {
  BLOCKING_STATUSES,
  MANUAL_STATUSES,
  isActiveBookingStatus,
  toDateStr,
  todayPH,
  loadCatalog,
  findService,
  findPackage,
  resolveItemService,
  demandFromRequest,
  packageDemand,
  getServicesAvailability,
  checkDemand,
  describeUnavailable,
  packageAvailability,
};
