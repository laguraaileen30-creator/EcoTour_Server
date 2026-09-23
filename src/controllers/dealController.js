// Deals are stored in the existing `promotions` table (+ promotion_packages / promotion_services).
const db = require('../config/database');

const bool = (v) => (v === undefined ? undefined : (v === true || v === 1 || v === '1' || v === 'true' ? 1 : 0));
const DISCOUNT_TYPES = ['Percentage', 'Fixed', 'Special Price', 'Bundle'];

const dealState = (d, now = new Date()) => {
  if (d.status !== 'Active') return 'INACTIVE';
  if (d.usage_limit && d.used_count >= d.usage_limit) return 'EXPIRED';
  if (new Date(d.start_at) > now) return 'SCHEDULED';
  if (new Date(d.end_at) < now) return 'EXPIRED';
  return 'ACTIVE';
};

const loadDeals = async () => {
  const [deals] = await db.query('SELECT * FROM promotions WHERE deleted_at IS NULL ORDER BY priority ASC, start_at DESC');
  const [pp] = await db.query('SELECT pp.*, p.package_name FROM promotion_packages pp JOIN packages p ON p.id = pp.package_id');
  const [ps] = await db.query('SELECT ps.promotion_id, ps.service_id, s.service_name FROM promotion_services ps JOIN services s ON s.service_id = ps.service_id');
  return deals.map((d) => ({
    ...d,
    title: d.promo_name,
    discount_value: parseFloat(d.discount_value || 0),
    original_price: d.original_price !== null ? parseFloat(d.original_price) : null,
    discounted_price: d.discounted_price !== null ? parseFloat(d.discounted_price) : null,
    is_featured: !!d.is_featured,
    show_on_landing: !!d.show_on_landing,
    state: dealState(d),
    packages: pp.filter((x) => x.promotion_id === d.id).map((x) => ({
      package_id: x.package_id,
      package_name: x.package_name,
      discount_type: x.discount_type || d.discount_type,
      discount_value: parseFloat(x.discount_value ?? d.discount_value),
    })),
    services: ps.filter((x) => x.promotion_id === d.id).map((x) => ({ service_id: x.service_id, service_name: x.service_name })),
  }));
};

// GET /api/v1/promotions — currently running deals (public; used by landing page & booking)
exports.getActivePromotions = async (req, res) => {
  try {
    let deals = (await loadDeals()).filter((d) => d.state === 'ACTIVE');
    if (req.query.landing) deals = deals.filter((d) => d.show_on_landing);
    res.json({ success: true, data: deals });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Could not load promotions', error: error.message });
  }
};

// GET /api/v1/deals — all deals with ACTIVE / SCHEDULED / EXPIRED / INACTIVE state (admin + public listing)
exports.getDeals = async (req, res) => {
  try {
    let deals = await loadDeals();
    if (req.query.state) deals = deals.filter((d) => d.state === String(req.query.state).toUpperCase());
    if (req.query.landing) deals = deals.filter((d) => d.show_on_landing);
    const summary = {
      active: deals.filter((d) => d.state === 'ACTIVE').length,
      scheduled: deals.filter((d) => d.state === 'SCHEDULED').length,
      expired: deals.filter((d) => d.state === 'EXPIRED').length,
      inactive: deals.filter((d) => d.state === 'INACTIVE').length,
    };
    res.json({ success: true, data: deals, summary });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Could not load deals', error: error.message });
  }
};

const pickDealFields = (b) => {
  const f = {
    promo_name: b.promo_name ?? b.title,
    description: b.description,
    image_url: b.image_url,
    discount_type: DISCOUNT_TYPES.includes(b.discount_type) ? b.discount_type : undefined,
    promo_type: b.promo_type,
    discount_value: b.discount_value !== undefined ? parseFloat(b.discount_value) : undefined,
    original_price: b.original_price === '' ? null : (b.original_price !== undefined ? parseFloat(b.original_price) : undefined),
    discounted_price: b.discounted_price === '' ? null : (b.discounted_price !== undefined ? parseFloat(b.discounted_price) : undefined),
    start_at: b.start_at ?? b.start_date,
    end_at: b.end_at ?? b.end_date,
    usage_limit: b.usage_limit === '' ? null : (b.usage_limit ?? b.maximum_usage),
    priority: b.priority,
    status: b.status === 'Inactive' ? 'Inactive' : (b.status ? 'Active' : undefined),
    is_featured: bool(b.is_featured),
    show_on_landing: bool(b.show_on_landing),
  };
  // Compute the discounted price for a priced deal when not given
  if (f.discounted_price === undefined && f.original_price && f.discount_value !== undefined) {
    if (f.discount_type === 'Percentage') f.discounted_price = Math.round(f.original_price * (1 - f.discount_value / 100));
    else if (f.discount_type === 'Fixed') f.discounted_price = Math.max(0, f.original_price - f.discount_value);
    else if (f.discount_type === 'Special Price') f.discounted_price = f.discount_value;
  }
  Object.keys(f).forEach((k) => f[k] === undefined && delete f[k]);
  return f;
};

const saveLinks = async (conn, dealId, body) => {
  if (Array.isArray(body.package_ids)) {
    await conn.query('DELETE FROM promotion_packages WHERE promotion_id = ?', [dealId]);
    const rows = body.package_ids.map((id) => [dealId, parseInt(id, 10)]).filter((r) => r[1] > 0);
    if (rows.length) await conn.query('INSERT INTO promotion_packages (promotion_id, package_id) VALUES ?', [rows]);
  }
  if (Array.isArray(body.service_ids)) {
    await conn.query('DELETE FROM promotion_services WHERE promotion_id = ?', [dealId]);
    const rows = body.service_ids.map((id) => [dealId, parseInt(id, 10)]).filter((r) => r[1] > 0);
    if (rows.length) await conn.query('INSERT INTO promotion_services (promotion_id, service_id) VALUES ?', [rows]);
  }
};

exports.createDeal = async (req, res) => {
  const conn = await db.getConnection();
  try {
    const f = pickDealFields(req.body || {});
    if (!f.promo_name || !f.start_at || !f.end_at) {
      return res.status(400).json({ success: false, message: 'Deal title, start date and end date are required.' });
    }
    if (new Date(f.end_at) < new Date(f.start_at)) return res.status(400).json({ success: false, message: 'End date must be after start date.' });
    f.promo_code = req.body.promo_code || `DEAL-${Date.now().toString().slice(-6)}`;
    f.discount_type = f.discount_type || 'Percentage';
    f.discount_value = f.discount_value ?? 0;
    f.status = f.status || 'Active';
    await conn.beginTransaction();
    const cols = Object.keys(f);
    const [ins] = await conn.query(`INSERT INTO promotions (${cols.map((c) => `\`${c}\``).join(',')}) VALUES (${cols.map(() => '?').join(',')})`, cols.map((c) => f[c]));
    await saveLinks(conn, ins.insertId, req.body);
    await conn.commit();
    res.status(201).json({ success: true, message: 'Deal created', id: ins.insertId });
  } catch (error) {
    await conn.rollback().catch(() => {});
    res.status(500).json({ success: false, message: 'Could not create deal', error: error.message });
  } finally {
    conn.release();
  }
};

exports.updateDeal = async (req, res) => {
  const conn = await db.getConnection();
  try {
    const f = pickDealFields(req.body || {});
    await conn.beginTransaction();
    const cols = Object.keys(f);
    if (cols.length) {
      const [r] = await conn.query(`UPDATE promotions SET ${cols.map((c) => `\`${c}\` = ?`).join(', ')} WHERE id = ? AND deleted_at IS NULL`, [...cols.map((c) => f[c]), req.params.id]);
      if (!r.affectedRows) { await conn.rollback(); return res.status(404).json({ success: false, message: 'Deal not found' }); }
    }
    await saveLinks(conn, req.params.id, req.body || {});
    await conn.commit();
    res.json({ success: true, message: 'Deal updated' });
  } catch (error) {
    await conn.rollback().catch(() => {});
    res.status(500).json({ success: false, message: 'Could not update deal', error: error.message });
  } finally {
    conn.release();
  }
};

exports.updateDealStatus = async (req, res) => {
  try {
    const b = req.body || {};
    const updates = {};
    if (b.status !== undefined) updates.status = b.status === 'Inactive' ? 'Inactive' : 'Active';
    if (b.show_on_landing !== undefined) updates.show_on_landing = bool(b.show_on_landing);
    if (b.is_featured !== undefined) updates.is_featured = bool(b.is_featured);
    const cols = Object.keys(updates);
    if (!cols.length) return res.status(400).json({ success: false, message: 'Nothing to update' });
    const [r] = await db.query(`UPDATE promotions SET ${cols.map((c) => `\`${c}\` = ?`).join(', ')} WHERE id = ? AND deleted_at IS NULL`, [...cols.map((c) => updates[c]), req.params.id]);
    if (!r.affectedRows) return res.status(404).json({ success: false, message: 'Deal not found' });
    res.json({ success: true, message: 'Deal status updated' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Could not update deal', error: error.message });
  }
};

exports.deleteDeal = async (req, res) => {
  try {
    const [r] = await db.query("UPDATE promotions SET deleted_at = NOW(), status = 'Inactive' WHERE id = ? AND deleted_at IS NULL", [req.params.id]);
    if (!r.affectedRows) return res.status(404).json({ success: false, message: 'Deal not found' });
    res.json({ success: true, message: 'Deal archived' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Could not delete deal', error: error.message });
  }
};
