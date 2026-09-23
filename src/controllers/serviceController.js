const db = require("../config/database");
const A = require("../services/availabilityService");
const { syncServiceCapacity } = require("./availabilityController");

const SERVICE_MANUAL_STATUSES = ["OUT_OF_STOCK", "UNAVAILABLE", "MAINTENANCE"];

const parseList = (value) => {
  if (!value) return [];
  if (Array.isArray(value)) return value;
  try {
    const parsed = JSON.parse(value);
    return Array.isArray(parsed) ? parsed : [];
  } catch (e) {
    return String(value).split("\n").map((v) => v.trim()).filter(Boolean);
  }
};
const toJsonList = (value) => (value === undefined ? undefined : JSON.stringify(parseList(value)));
const slugify = (s) => String(s || "").toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-+|-+$/g, "").slice(0, 120);
const bool = (v) => (v === undefined ? undefined : (v === true || v === 1 || v === "1" || v === "true" ? 1 : 0));

// Shape a DB row + its availability for a date into the API format (keeps legacy field names)
const formatService = (s, avail) => ({
  ...s,
  id: s.service_id,
  name: s.service_name,
  title: s.service_name,
  price: parseFloat(s.price),
  gallery: parseList(s.gallery),
  inclusions: parseList(s.inclusions),
  exclusions: parseList(s.exclusions),
  is_featured: !!s.is_featured,
  show_on_landing: !!s.show_on_landing,
  is_assignable: !!s.is_assignable,
  availability_date: avail?.date || null,
  capacity_for_date: avail ? avail.total : s.total_capacity,
  booked_for_date: avail ? avail.reserved : 0,
  available_for_date: avail ? avail.available : s.total_capacity,
  // legacy fields used across the UI now carry the real remaining quantity for the date
  available_qty: avail ? avail.available : s.available_qty,
  available_quantity: avail ? avail.available : s.available_qty,
  availability_status: avail ? avail.status : (s.manual_status || "AVAILABLE"),
});

// GET /api/v1/services?date=YYYY-MM-DD&all=1&landing=1
exports.getAllServices = async (req, res, next) => {
  try {
    const date = A.toDateStr(req.query.date) || A.todayPH();
    const availability = await A.getServicesAvailability(date);
    let rows = availability.catalog.services;
    if (!req.query.all) rows = rows.filter((s) => s.status === "Active");
    if (req.query.landing) rows = rows.filter((s) => s.show_on_landing);
    const services = rows
      .map((s) => formatService(s, { ...availability.byId.get(s.service_id), date }))
      .sort((a, b) => (b.is_featured - a.is_featured) || a.service_id - b.service_id);
    res.status(200).json({ success: true, date, services, data: services });
  } catch (err) {
    next(err);
  }
};

// GET /api/v1/services/:id?date=
exports.getServiceById = async (req, res, next) => {
  try {
    const date = A.toDateStr(req.query.date) || A.todayPH();
    const availability = await A.getServicesAvailability(date);
    const svc = A.findService(availability.catalog, req.params.id)
      || availability.catalog.services.find((s) => s.slug === req.params.id);
    if (!svc) return res.status(404).json({ success: false, message: "Service not found" });
    res.json({ success: true, data: formatService(svc, { ...availability.byId.get(svc.service_id), date }) });
  } catch (err) {
    next(err);
  }
};

const pickServiceFields = (body) => {
  const f = {
    service_name: body.service_name ?? body.title,
    category: body.category,
    short_description: body.short_description,
    description: body.description ?? body.full_description,
    price: body.price !== undefined ? parseFloat(body.price) : undefined,
    unit: body.unit ?? body.price_unit,
    total_capacity: body.total_capacity !== undefined ? parseInt(body.total_capacity, 10) : (body.available_quantity !== undefined ? parseInt(body.available_quantity, 10) : undefined),
    capacity_persons: body.capacity_persons !== undefined ? (body.capacity_persons === "" || body.capacity_persons === null ? null : parseInt(body.capacity_persons, 10)) : undefined,
    minimum_quantity: body.minimum_quantity !== undefined ? Math.max(1, parseInt(body.minimum_quantity, 10) || 1) : undefined,
    image_url: body.image_url,
    gallery: toJsonList(body.gallery),
    inclusions: toJsonList(body.inclusions),
    exclusions: toJsonList(body.exclusions),
    terms: body.terms,
    is_featured: bool(body.is_featured),
    show_on_landing: bool(body.show_on_landing),
    is_assignable: bool(body.is_assignable),
    status: body.status === "Inactive" || body.status === "INACTIVE" ? "Inactive" : (body.status ? "Active" : undefined),
    manual_status: body.manual_status !== undefined ? (SERVICE_MANUAL_STATUSES.includes(body.manual_status) ? body.manual_status : null) : undefined,
  };
  if (f.service_name) f.slug = slugify(f.service_name);
  Object.keys(f).forEach((k) => f[k] === undefined && delete f[k]);
  return f;
};

// POST /api/v1/services  (admin)
exports.createService = async (req, res, next) => {
  try {
    const fields = pickServiceFields(req.body || {});
    if (!fields.service_name || !(fields.price >= 0)) {
      return res.status(400).json({ success: false, message: "Service title and price are required." });
    }
    const [[dup]] = await db.query("SELECT service_id FROM services WHERE LOWER(service_name) = LOWER(?) AND deleted_at IS NULL", [fields.service_name]);
    if (dup) return res.status(409).json({ success: false, message: "A service with this title already exists." });

    fields.service_code = req.body.service_code || `DSVC-${Date.now().toString().slice(-6)}`;
    fields.category = fields.category || "Rental";
    fields.unit = fields.unit || "unit";
    fields.total_capacity = fields.total_capacity ?? 10;
    fields.available_qty = fields.total_capacity;
    fields.status = fields.status || "Active";

    const cols = Object.keys(fields);
    const [ins] = await db.query(
      `INSERT INTO services (${cols.map((c) => `\`${c}\``).join(",")}) VALUES (${cols.map(() => "?").join(",")})`,
      cols.map((c) => fields[c])
    );

    // Numbered services get one unit per quantity (Cottage 01, Cottage 02, ...)
    if (fields.is_assignable) {
      for (let n = 1; n <= fields.total_capacity; n++) {
        await db.query("INSERT INTO service_resources (service_id, resource_name, status) VALUES (?, ?, 'Available')", [
          ins.insertId, `${fields.service_name} ${String(n).padStart(2, "0")}`,
        ]);
      }
    }
    await db.query("INSERT INTO audit_logs (action, description) VALUES (?, ?)", ["SERVICE_CREATED", `Service "${fields.service_name}" created`]);
    res.status(201).json({ success: true, message: "Service created successfully", service_id: ins.insertId });
  } catch (err) {
    next(err);
  }
};

// PUT /api/v1/services/:id  (admin)
exports.updateService = async (req, res, next) => {
  try {
    const { id } = req.params;
    const fields = pickServiceFields(req.body || {});
    if (Object.keys(fields).length === 0) return res.status(400).json({ success: false, message: "Nothing to update" });
    const [[existing]] = await db.query("SELECT * FROM services WHERE service_id = ? AND deleted_at IS NULL", [id]);
    if (!existing) return res.status(404).json({ success: false, message: "Service not found" });

    const cols = Object.keys(fields);
    await db.query(`UPDATE services SET ${cols.map((c) => `\`${c}\` = ?`).join(", ")} WHERE service_id = ?`, [...cols.map((c) => fields[c]), id]);

    // Growing a numbered service adds units; shrinking is done by removing specific units in Facilities
    const isAssignable = fields.is_assignable ?? existing.is_assignable;
    if (isAssignable && fields.total_capacity !== undefined) {
      const [[{ cnt }]] = await db.query("SELECT COUNT(*) AS cnt FROM service_resources WHERE service_id = ?", [id]);
      const name = fields.service_name || existing.service_name;
      for (let n = cnt + 1; n <= fields.total_capacity; n++) {
        await db.query("INSERT INTO service_resources (service_id, resource_name, status) VALUES (?, ?, 'Available')", [id, `${name} ${String(n).padStart(2, "0")}`]);
      }
      await syncServiceCapacity(id);
    }
    res.status(200).json({ success: true, message: "Service updated successfully" });
  } catch (err) {
    next(err);
  }
};

// PATCH /api/v1/services/:id/status  (admin) { manual_status: 'OUT_OF_STOCK'|'UNAVAILABLE'|'MAINTENANCE'|null, status?, show_on_landing? }
exports.updateServiceStatus = async (req, res, next) => {
  try {
    const { id } = req.params;
    const body = req.body || {};
    const updates = {};
    if (body.manual_status !== undefined) {
      if (body.manual_status && !SERVICE_MANUAL_STATUSES.includes(body.manual_status)) {
        return res.status(400).json({ success: false, message: "Invalid status" });
      }
      updates.manual_status = body.manual_status || null;
    }
    if (body.status !== undefined) updates.status = body.status === "Inactive" ? "Inactive" : "Active";
    if (body.show_on_landing !== undefined) updates.show_on_landing = bool(body.show_on_landing);
    if (body.is_featured !== undefined) updates.is_featured = bool(body.is_featured);
    const cols = Object.keys(updates);
    if (!cols.length) return res.status(400).json({ success: false, message: "Nothing to update" });
    const [r] = await db.query(`UPDATE services SET ${cols.map((c) => `\`${c}\` = ?`).join(", ")} WHERE service_id = ? AND deleted_at IS NULL`, [...cols.map((c) => updates[c]), id]);
    if (!r.affectedRows) return res.status(404).json({ success: false, message: "Service not found" });
    await db.query("INSERT INTO audit_logs (action, description) VALUES (?, ?)", ["SERVICE_STATUS_CHANGED", `Service #${id} status updated: ${JSON.stringify(updates)}`]);
    res.json({ success: true, message: "Service status updated" });
  } catch (err) {
    next(err);
  }
};

// GET /api/v1/services/:id/upcoming — upcoming active reservations that use this service (warning before OUT OF STOCK)
exports.getUpcomingReservations = async (req, res, next) => {
  try {
    const catalog = await A.loadCatalog();
    const svc = A.findService(catalog, req.params.id);
    if (!svc) return res.status(404).json({ success: false, message: "Service not found" });
    const [bookings] = await db.query("SELECT id, booking_number, client_name, booking_date, status, package_id FROM bookings WHERE booking_date >= ? ORDER BY booking_date", [A.todayPH()]);
    const active = bookings.filter((b) => A.isActiveBookingStatus(b.status));
    const result = [];
    for (const b of active) {
      const [items] = await db.query("SELECT service_name AS name, quantity FROM booking_items WHERE booking_id = ?", [b.id]);
      const demand = A.demandFromRequest(catalog, { items, packageId: b.package_id });
      const d = demand.find((x) => x.serviceId === svc.service_id);
      if (d) result.push({ bookingId: b.id, bookingRef: b.booking_number, clientName: b.client_name, date: A.toDateStr(b.booking_date), status: b.status, quantity: d.quantity });
    }
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
};

// DELETE /api/v1/services/:id  (admin) — soft delete, reservations and packages keep their history
exports.deleteService = async (req, res, next) => {
  try {
    const { id } = req.params;
    const [r] = await db.query("UPDATE services SET deleted_at = NOW(), status = 'Inactive', show_on_landing = 0 WHERE service_id = ? AND deleted_at IS NULL", [id]);
    if (!r.affectedRows) return res.status(404).json({ success: false, message: "Service not found" });
    await db.query("INSERT INTO audit_logs (action, description) VALUES (?, ?)", ["SERVICE_DELETED", `Service #${id} archived (soft delete)`]);
    res.status(200).json({ success: true, message: "Service archived. Existing reservations are unchanged." });
  } catch (err) {
    next(err);
  }
};

exports.formatService = formatService;
exports.parseList = parseList;
