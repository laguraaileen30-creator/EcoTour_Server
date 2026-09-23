const db = require('../config/database');
const A = require('../services/availabilityService');
const Pricing = require('../services/pricingService');

const bool = (v) => (v === undefined ? undefined : (v === true || v === 1 || v === '1' || v === 'true' ? 1 : 0));
const PACKAGE_MANUAL_STATUSES = ['OUT_OF_STOCK', 'UNAVAILABLE', 'MAINTENANCE'];

const isWithinValidity = (p, date) => {
  const d = new Date(`${date}T12:00:00`);
  if (p.valid_from && new Date(p.valid_from) > d) return false;
  if (p.valid_until && new Date(p.valid_until) < d) return false;
  return true;
};

const formatPackage = (p, availability, pricingCtx = null) => {
  const catalog = availability.catalog;
  const items = catalog.packageItems
    .filter((pi) => pi.package_id === p.id)
    .map((pi) => {
      const s = catalog.services.find((x) => x.service_id === pi.service_id) || {};
      return {
        service_id: pi.service_id,
        serviceId: pi.service_id,
        service_name: s.service_name,
        serviceName: s.service_name,
        name: s.service_name,
        category: s.category,
        quantity: pi.quantity,
        price: parseFloat(s.price || 0),
        unit: s.unit,
        image_url: s.image_url,
      };
    });
  const pa = A.packageAvailability(availability, p);
  let status = pa.status;
  if (!isWithinValidity(p, availability.date)) status = 'UNAVAILABLE';
  const regular = parseFloat(p.regular_value || 0);
  // Running deals linked to this package are applied here, same as at checkout
  const dealPrice = pricingCtx ? Pricing.packagePrice(pricingCtx, p) : null;
  const finalPrice = dealPrice ? dealPrice.price : (parseFloat(p.promo_price || 0) || regular);
  return {
    ...p,
    regular_value: regular,
    original_price: regular,
    base_promo_price: parseFloat(p.promo_price || 0) || regular,
    promo_price: finalPrice,
    final_price: finalPrice,
    discount_percent: parseFloat(p.discount_percent || 0),
    discount_amount: Math.max(0, regular - finalPrice),
    active_deal: dealPrice && dealPrice.deal ? { id: dealPrice.deal.id, name: dealPrice.deal.promo_name, end_at: dealPrice.deal.end_at } : null,
    max_guests: p.included_guests,
    is_featured: !!p.is_featured,
    show_on_landing: !!p.show_on_landing,
    included_services: p.package_type === 'UNLIMITED' ? 'ALL' : undefined,
    items,
    availability_date: availability.date,
    availability_status: status,
    unavailable_services: pa.unavailable.map((u) => ({ serviceId: u.serviceId, serviceName: u.serviceName, status: u.status, available: u.available, total: u.total })),
  };
};

// GET /api/v1/packages?date=&all=1&landing=1
exports.getPackages = async (req, res) => {
  try {
    const date = A.toDateStr(req.query.date) || A.todayPH();
    const availability = await A.getServicesAvailability(date);
    const pricingCtx = await Pricing.loadPricingContext(db);
    let rows = availability.catalog.packages;
    if (!req.query.all) rows = rows.filter((p) => p.status === 'Active');
    if (req.query.landing) rows = rows.filter((p) => p.show_on_landing);
    const data = rows
      .map((p) => formatPackage(p, availability, pricingCtx))
      .sort((a, b) => (b.is_featured - a.is_featured) || a.id - b.id);
    res.json({ success: true, date, data });
  } catch (error) {
    console.error('Get packages error:', error);
    res.status(500).json({ success: false, message: 'Could not load packages', error: error.message });
  }
};

// GET /api/v1/packages/:id?date=
exports.getPackageById = async (req, res) => {
  try {
    const date = A.toDateStr(req.query.date) || A.todayPH();
    const availability = await A.getServicesAvailability(date);
    const pricingCtx = await Pricing.loadPricingContext(db);
    const pkg = A.findPackage(availability.catalog, req.params.id);
    if (!pkg) return res.status(404).json({ success: false, message: 'Package not found' });
    res.json({ success: true, data: formatPackage(pkg, availability, pricingCtx) });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Could not load package', error: error.message });
  }
};

const pickPackageFields = (body) => {
  const regular = body.regular_value ?? body.original_price;
  const f = {
    package_name: body.package_name ?? body.name,
    description: body.description,
    image_url: body.image_url,
    regular_value: regular !== undefined ? parseFloat(regular) : undefined,
    discount_type: body.discount_type,
    discount_percent: body.discount_percent !== undefined ? parseFloat(body.discount_percent) : undefined,
    promo_price: body.promo_price !== undefined ? parseFloat(body.promo_price) : (body.final_price !== undefined ? parseFloat(body.final_price) : undefined),
    included_guests: body.included_guests !== undefined ? parseInt(body.included_guests, 10) : (body.max_guests !== undefined ? parseInt(body.max_guests, 10) : undefined),
    badge: body.badge,
    package_type: body.package_type,
    valid_from: body.valid_from === '' ? null : body.valid_from ?? body.start_date,
    valid_until: body.valid_until === '' ? null : body.valid_until ?? body.end_date,
    status: body.status === 'Inactive' ? 'Inactive' : (body.status ? 'Active' : undefined),
    manual_status: body.manual_status !== undefined ? (PACKAGE_MANUAL_STATUSES.includes(body.manual_status) ? body.manual_status : null) : undefined,
    is_featured: bool(body.is_featured),
    show_on_landing: bool(body.show_on_landing),
  };
  // Derive the final price from the discount when only a discount is given
  if (f.promo_price === undefined && f.regular_value !== undefined && f.discount_percent !== undefined) {
    f.promo_price = f.discount_type === 'Fixed'
      ? Math.max(0, f.regular_value - f.discount_percent)
      : Math.round(f.regular_value * (1 - f.discount_percent / 100));
  }
  if (f.valid_from === '') f.valid_from = null;
  if (f.valid_until === '') f.valid_until = null;
  Object.keys(f).forEach((k) => f[k] === undefined && delete f[k]);
  return f;
};

const saveItems = async (conn, packageId, items) => {
  if (!Array.isArray(items)) return;
  await conn.query('DELETE FROM package_items WHERE package_id = ?', [packageId]);
  const rows = items
    .map((it) => [packageId, parseInt(it.service_id ?? it.serviceId, 10), Math.max(1, parseInt(it.quantity, 10) || 1)])
    .filter((r) => r[1] > 0);
  if (rows.length) await conn.query('INSERT INTO package_items (package_id, service_id, quantity) VALUES ?', [rows]);
};

// POST /api/v1/packages (admin) { ...fields, items: [{service_id, quantity}], include_all_services }
exports.createPackage = async (req, res) => {
  const conn = await db.getConnection();
  try {
    const fields = pickPackageFields(req.body || {});
    if (!fields.package_name || !(fields.regular_value >= 0)) {
      return res.status(400).json({ success: false, message: 'Package name and original price are required.' });
    }
    fields.package_code = req.body.package_code || `PKG-${Date.now().toString().slice(-6)}`;
    fields.promo_price = fields.promo_price ?? fields.regular_value;
    fields.status = fields.status || 'Active';
    await conn.beginTransaction();
    const cols = Object.keys(fields);
    const [ins] = await conn.query(
      `INSERT INTO packages (${cols.map((c) => `\`${c}\``).join(',')}) VALUES (${cols.map(() => '?').join(',')})`,
      cols.map((c) => fields[c])
    );
    let items = req.body.items;
    if (req.body.include_all_services) {
      const [svcs] = await conn.query("SELECT service_id, category FROM services WHERE status = 'Active' AND deleted_at IS NULL");
      items = svcs.map((s) => ({ service_id: s.service_id, quantity: String(s.category).toLowerCase() === 'entrance' ? (fields.included_guests || 1) : 1 }));
    }
    await saveItems(conn, ins.insertId, items);
    await conn.query('INSERT INTO audit_logs (action, description) VALUES (?, ?)', ['PACKAGE_CREATED', `Package "${fields.package_name}" created`]);
    await conn.commit();
    res.status(201).json({ success: true, message: 'Package created', id: ins.insertId });
  } catch (error) {
    await conn.rollback().catch(() => {});
    res.status(500).json({ success: false, message: 'Could not create package', error: error.message });
  } finally {
    conn.release();
  }
};

// PUT /api/v1/packages/:id (admin)
exports.updatePackage = async (req, res) => {
  const conn = await db.getConnection();
  try {
    const fields = pickPackageFields(req.body || {});
    await conn.beginTransaction();
    const [[existing]] = await conn.query('SELECT id FROM packages WHERE id = ? AND deleted_at IS NULL', [req.params.id]);
    if (!existing) { await conn.rollback(); return res.status(404).json({ success: false, message: 'Package not found' }); }
    const cols = Object.keys(fields);
    if (cols.length) {
      await conn.query(`UPDATE packages SET ${cols.map((c) => `\`${c}\` = ?`).join(', ')} WHERE id = ?`, [...cols.map((c) => fields[c]), req.params.id]);
    }
    await saveItems(conn, req.params.id, req.body.items);
    await conn.commit();
    res.json({ success: true, message: 'Package updated' });
  } catch (error) {
    await conn.rollback().catch(() => {});
    res.status(500).json({ success: false, message: 'Could not update package', error: error.message });
  } finally {
    conn.release();
  }
};

// PATCH /api/v1/packages/:id/status (admin) { status?, manual_status?, show_on_landing?, is_featured? }
exports.updatePackageStatus = async (req, res) => {
  try {
    const b = req.body || {};
    const updates = {};
    if (b.status !== undefined) updates.status = b.status === 'Inactive' ? 'Inactive' : 'Active';
    if (b.manual_status !== undefined) updates.manual_status = PACKAGE_MANUAL_STATUSES.includes(b.manual_status) ? b.manual_status : null;
    if (b.show_on_landing !== undefined) updates.show_on_landing = bool(b.show_on_landing);
    if (b.is_featured !== undefined) updates.is_featured = bool(b.is_featured);
    const cols = Object.keys(updates);
    if (!cols.length) return res.status(400).json({ success: false, message: 'Nothing to update' });
    const [r] = await db.query(`UPDATE packages SET ${cols.map((c) => `\`${c}\` = ?`).join(', ')} WHERE id = ? AND deleted_at IS NULL`, [...cols.map((c) => updates[c]), req.params.id]);
    if (!r.affectedRows) return res.status(404).json({ success: false, message: 'Package not found' });
    res.json({ success: true, message: 'Package status updated' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Could not update package status', error: error.message });
  }
};

// DELETE /api/v1/packages/:id (admin) — soft delete, bookings keep their package reference
exports.deletePackage = async (req, res) => {
  try {
    const [r] = await db.query("UPDATE packages SET deleted_at = NOW(), status = 'Inactive', show_on_landing = 0 WHERE id = ? AND deleted_at IS NULL", [req.params.id]);
    if (!r.affectedRows) return res.status(404).json({ success: false, message: 'Package not found' });
    res.json({ success: true, message: 'Package archived. Existing reservations are unchanged.' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Could not delete package', error: error.message });
  }
};
