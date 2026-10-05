const db = require('../config/database');
const A = require('../services/availabilityService');

const ACTIVE_ASSIGNMENT = ['Held', 'Reserved', 'In Use'];

const dateParam = (req) => A.toDateStr(req.query.date || req.body?.date) || A.todayPH();

// GET /api/v1/availability?date=&serviceId=&packageId=&quantity=
// Without serviceId/packageId it returns every service and package for the date.
exports.checkAvailability = async (req, res) => {
  try {
    const date = dateParam(req);
    const availability = await A.getServicesAvailability(date);
    const { serviceId, packageId } = req.query;
    const quantity = Math.max(1, parseInt(req.query.quantity || 1, 10));

    if (packageId) {
      const pkg = A.findPackage(availability.catalog, packageId);
      if (!pkg) return res.status(404).json({ success: false, message: 'Package not found' });
      const pa = A.packageAvailability(availability, pkg);
      return res.json({
        success: true,
        data: {
          date,
          packageId: pkg.id,
          packageName: pkg.package_name,
          status: pa.unavailable.length ? 'FULLY_BOOKED' : pa.status === 'LOW_STOCK' ? 'ALMOST_FULL' : 'AVAILABLE',
          packageStatus: pa.status,
          items: pa.items,
          unavailable: pa.unavailable,
          message: pa.unavailable.length ? `${pkg.package_name} is unavailable: ${A.describeUnavailable(pa.unavailable, date)}` : null,
        },
      });
    }

    if (serviceId) {
      const svc = A.findService(availability.catalog, serviceId);
      if (!svc) return res.status(404).json({ success: false, message: 'Service not found' });
      const result = A.checkDemand(availability, [{ serviceId: svc.service_id, quantity }]);
      return res.json({
        success: true,
        data: { date, ...result, message: result.unavailable.length ? A.describeUnavailable(result.unavailable, date) : null },
      });
    }

    const services = Array.from(availability.byId.values());
    const packages = availability.catalog.packages.map((p) => {
      const pa = A.packageAvailability(availability, p);
      return { packageId: p.id, packageName: p.package_name, status: pa.status, unavailable: pa.unavailable };
    });
    res.json({ success: true, data: { date, services, packages } });
  } catch (error) {
    console.error('Availability check error:', error);
    res.status(500).json({ success: false, message: 'Could not check availability', error: error.message });
  }
};

// GET /api/v1/availability/calendar?serviceId=|packageId=&from=YYYY-MM-DD&days=14
exports.availabilityCalendar = async (req, res) => {
  try {
    const from = A.toDateStr(req.query.from) || A.todayPH();
    const days = Math.min(60, Math.max(1, parseInt(req.query.days || 14, 10)));
    const catalog = await A.loadCatalog();
    const out = [];
    for (let i = 0; i < days; i++) {
      const d = new Date(`${from}T00:00:00`);
      d.setDate(d.getDate() + i);
      const date = A.toDateStr(d);
      const availability = await A.getServicesAvailability(date, { catalog });
      if (req.query.packageId) {
        const pkg = A.findPackage(catalog, req.query.packageId);
        if (!pkg) return res.status(404).json({ success: false, message: 'Package not found' });
        const pa = A.packageAvailability(availability, pkg);
        out.push({ date, status: pa.status, unavailable: pa.unavailable.map((u) => u.serviceName) });
      } else {
        const svc = A.findService(catalog, req.query.serviceId);
        if (!svc) return res.status(404).json({ success: false, message: 'Service not found' });
        const a = availability.byId.get(svc.service_id);
        out.push({ date, status: a.status, available: a.available, total: a.total, reserved: a.reserved });
      }
    }
    res.json({ success: true, data: out });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Could not load availability calendar', error: error.message });
  }
};

// Units of a service (or all) with their state on a date
const loadUnits = async (date, serviceId = null, conn = db) => {
  // Today, a unit whose guest from an earlier day is still 'In Use' (not checked out) is occupied
  const carry = date === A.todayPH() ? 1 : 0;
  const params = [date, date, date, carry, date];
  let where = 'WHERE s.deleted_at IS NULL';
  if (serviceId) { where += ' AND r.service_id = ?'; params.push(serviceId); }
  const [rows] = await conn.query(
    `SELECT r.id, r.service_id, r.resource_name, r.status AS unit_status,
            s.service_name, s.category, s.capacity_persons,
            (SELECT rb.reason FROM resource_blocks rb WHERE rb.service_resource_id = r.id AND DATE(rb.start_time) <= ? AND DATE(rb.end_time) >= ? LIMIT 1) AS block_reason,
            ra.id AS assignment_id, ra.status AS assignment_status, ra.booking_id,
            b.booking_number, b.client_name, b.status AS booking_status
     FROM service_resources r
     JOIN services s ON s.service_id = r.service_id
     LEFT JOIN resource_assignments ra ON ra.service_resource_id = r.id
          AND ra.status IN ('Held','Reserved','In Use')
          AND (DATE(ra.start_time) = ? OR (? = 1 AND ra.status = 'In Use' AND DATE(ra.start_time) < ?))
     LEFT JOIN bookings b ON b.id = ra.booking_id
     ${where}
     ORDER BY s.service_name, r.resource_name, (ra.status = 'In Use') DESC`,
    params
  );
  // one row per unit (an 'In Use' carry-over wins over a later reservation of the same unit)
  const seen = new Set();
  return rows.filter((r) => (seen.has(r.id) ? false : seen.add(r.id))).map((r) => {
    let state = 'AVAILABLE';
    if (r.unit_status !== 'Available' || r.block_reason) state = 'MAINTENANCE';
    else if (r.assignment_id) state = r.assignment_status === 'In Use' ? 'OCCUPIED' : 'RESERVED';
    return {
      id: r.id,
      resource_name: r.resource_name,
      resourceName: r.resource_name,
      serviceId: r.service_id,
      serviceName: r.service_name,
      category: r.category,
      capacityPersons: r.capacity_persons,
      unitStatus: r.unit_status,
      blockReason: r.block_reason,
      state,
      assignmentId: r.assignment_id,
      bookingId: r.booking_id,
      bookingRef: r.booking_number,
      clientName: r.client_name,
      status: state === 'AVAILABLE' ? 'Available' : state === 'MAINTENANCE' ? 'Maintenance' : state === 'OCCUPIED' ? 'Occupied' : 'Reserved',
    };
  });
};

// GET /api/v1/availability/resources?serviceId=&date=&bookingId=
exports.listResources = async (req, res) => {
  try {
    const date = dateParam(req);
    const catalog = await A.loadCatalog();
    const svc = A.findService(catalog, req.query.serviceId);
    if (!svc) return res.status(404).json({ success: false, message: 'Service not found' });
    const units = await loadUnits(date, svc.service_id);
    // For the assignment picker: free units plus units already assigned to this booking
    const bookingId = req.query.bookingId;
    const data = req.query.all ? units : units.filter((u) => u.state === 'AVAILABLE' || (bookingId && String(u.bookingId) === String(bookingId)));
    res.json({ success: true, data });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Could not load facilities', error: error.message });
  }
};

// GET /api/v1/availability/facilities?date=  — facility map for staff/admin
exports.facilityMap = async (req, res) => {
  try {
    const date = dateParam(req);
    const units = await loadUnits(date);
    res.json({ success: true, date, data: units });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Could not load facility map', error: error.message });
  }
};

const loadBooking = async (conn, idOrRef, lock = false) => {
  const [rows] = await conn.query(
    `SELECT * FROM bookings WHERE id = ? OR booking_number = ? LIMIT 1 ${lock ? 'FOR UPDATE' : ''}`,
    // numeric refs match the id; text refs match the booking number only (no implicit INT casts)
    [/^\d+$/.test(String(idOrRef)) ? Number(idOrRef) : 0, String(idOrRef)]
  );
  return rows[0] || null;
};

// Numbered-unit requirements of a booking (e.g. 1 × Large Family Cottage) and what has been assigned
const bookingRequirements = async (conn, booking) => {
  const catalog = await A.loadCatalog(conn);
  const [items] = await conn.query('SELECT service_name, quantity FROM booking_items WHERE booking_id = ?', [booking.id]);
  const demand = A.demandFromRequest(catalog, {
    items: items.map((i) => ({ name: i.service_name, quantity: i.quantity })),
    packageId: booking.package_id,
  });
  const [assigned] = await conn.query(
    `SELECT ra.id, ra.status, ra.service_resource_id, r.resource_name, r.service_id
     FROM resource_assignments ra JOIN service_resources r ON r.id = ra.service_resource_id
     WHERE ra.booking_id = ? AND ra.status IN ('Held','Reserved','In Use')`,
    [booking.id]
  );
  const requirements = demand
    .map((d) => ({ d, svc: catalog.services.find((s) => s.service_id === d.serviceId) }))
    .filter(({ svc }) => svc && svc.is_assignable)
    .map(({ d, svc }) => {
      const mine = assigned.filter((a) => a.service_id === svc.service_id);
      return {
        serviceId: svc.service_id,
        serviceName: svc.service_name,
        category: svc.category,
        required: d.quantity,
        assigned: mine.map((a) => ({ assignmentId: a.id, resourceId: a.service_resource_id, resourceName: a.resource_name, status: a.status })),
      };
    });
  return { requirements, assigned };
};

const assignmentStatusOf = (requirements) => {
  if (requirements.length === 0) return 'Not Required';
  const need = requirements.reduce((s, r) => s + r.required, 0);
  const have = requirements.reduce((s, r) => s + Math.min(r.required, r.assigned.length), 0);
  if (have === 0) return 'Unassigned';
  return have >= need ? 'Assigned' : 'Partially Assigned';
};
exports.assignmentStatusOf = assignmentStatusOf;
exports.bookingRequirements = bookingRequirements;

// GET /api/v1/availability/requirements/:bookingId
exports.getRequirements = async (req, res) => {
  try {
    const booking = await loadBooking(db, req.params.bookingId);
    if (!booking) return res.status(404).json({ success: false, message: 'Reservation not found' });
    const date = A.toDateStr(booking.booking_date);
    const { requirements } = await bookingRequirements(db, booking);
    const units = await loadUnits(date);
    const data = requirements.map((r) => ({
      ...r,
      candidates: units.filter((u) => u.serviceId === r.serviceId),
    }));
    res.json({ success: true, data: { bookingId: booking.id, bookingRef: booking.booking_number, date, assignmentStatus: assignmentStatusOf(requirements), requirements: data } });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Could not load requirements', error: error.message });
  }
};

// POST /api/v1/availability/assign { bookingId, resourceId }
// Transaction + row locks: two cashiers cannot assign the same unit for the same date.
exports.assignResource = async (req, res) => {
  const { bookingId, resourceId } = req.body || {};
  if (!bookingId || !resourceId) return res.status(400).json({ success: false, message: 'bookingId and resourceId are required' });
  const conn = await db.getConnection();
  try {
    await conn.query('SET TRANSACTION ISOLATION LEVEL READ COMMITTED');
    await conn.beginTransaction();
    const booking = await loadBooking(conn, bookingId, true);
    if (!booking) { await conn.rollback(); return res.status(404).json({ success: false, message: 'Reservation not found' }); }
    if (!A.isActiveBookingStatus(booking.status)) {
      await conn.rollback();
      return res.status(400).json({ success: false, message: `Cannot assign facilities to a ${booking.status} reservation.` });
    }
    const date = A.toDateStr(booking.booking_date);

    const [unitRows] = await conn.query(
      'SELECT r.*, s.service_name FROM service_resources r JOIN services s ON s.service_id = r.service_id WHERE r.id = ? FOR UPDATE',
      [resourceId]
    );
    const unit = unitRows[0];
    if (!unit) { await conn.rollback(); return res.status(404).json({ success: false, message: 'Facility unit not found' }); }
    if (unit.status !== 'Available') {
      await conn.rollback();
      return res.status(409).json({ success: false, code: 'UNIT_UNAVAILABLE', message: `${unit.resource_name} is under ${unit.status}.` });
    }
    const [blocks] = await conn.query(
      'SELECT reason FROM resource_blocks WHERE service_resource_id = ? AND DATE(start_time) <= ? AND DATE(end_time) >= ?',
      [unit.id, date, date]
    );
    if (blocks.length) {
      await conn.rollback();
      return res.status(409).json({ success: false, code: 'UNIT_UNAVAILABLE', message: `${unit.resource_name} is blocked on ${date} (${blocks[0].reason || 'maintenance'}).` });
    }
    const [taken] = await conn.query(
      `SELECT ra.booking_id, b.booking_number FROM resource_assignments ra JOIN bookings b ON b.id = ra.booking_id
       WHERE ra.service_resource_id = ? AND ra.status IN ('Held','Reserved','In Use')
         AND (DATE(ra.start_time) = ? OR (? = 1 AND ra.status = 'In Use' AND DATE(ra.start_time) < ?))`,
      [unit.id, date, date === A.todayPH() ? 1 : 0, date]
    );
    if (taken.length) {
      await conn.rollback();
      const same = String(taken[0].booking_id) === String(booking.id);
      return res.status(409).json({
        success: false,
        code: same ? 'ALREADY_ASSIGNED' : 'UNIT_TAKEN',
        message: same ? `${unit.resource_name} is already assigned to this reservation.` : `${unit.resource_name} is no longer available — already assigned to ${taken[0].booking_number} on ${date}.`,
      });
    }

    const { requirements } = await bookingRequirements(conn, booking);
    const req_ = requirements.find((r) => r.serviceId === unit.service_id);
    if (!req_) {
      await conn.rollback();
      return res.status(400).json({ success: false, message: `This reservation does not include ${unit.service_name}.` });
    }
    if (req_.assigned.length >= req_.required) {
      await conn.rollback();
      return res.status(400).json({ success: false, message: `All ${req_.required} × ${unit.service_name} are already assigned for this reservation.` });
    }

    const status = /using|checked in|in use/i.test(booking.status) ? 'In Use' : 'Reserved';
    const [ins] = await conn.query(
      'INSERT INTO resource_assignments (booking_id, service_resource_id, start_time, end_time, status) VALUES (?, ?, ?, ?, ?)',
      [booking.id, unit.id, `${date} 00:00:00`, `${date} 23:59:59`, status]
    );
    await conn.query('INSERT INTO audit_logs (action, description) VALUES (?, ?)', [
      'FACILITY_ASSIGNED', `${unit.resource_name} assigned to ${booking.booking_number} (${booking.client_name}) for ${date}`,
    ]);
    await conn.commit();
    res.status(201).json({ success: true, data: { id: ins.insertId, resource_name: unit.resource_name, resourceName: unit.resource_name, bookingId: booking.id, date, status } });
  } catch (error) {
    await conn.rollback().catch(() => {});
    console.error('Assign facility error:', error);
    res.status(500).json({ success: false, message: 'Facility assignment failed', error: error.message });
  } finally {
    conn.release();
  }
};

// DELETE /api/v1/availability/assign/:assignmentId — release a unit
exports.releaseAssignment = async (req, res) => {
  try {
    const [r] = await db.query("UPDATE resource_assignments SET status = 'Released' WHERE id = ? AND status IN ('Held','Reserved','In Use')", [req.params.assignmentId]);
    if (!r.affectedRows) return res.status(404).json({ success: false, message: 'Assignment not found or already released' });
    res.json({ success: true, message: 'Facility released' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Could not release facility', error: error.message });
  }
};

// Keep unit assignments in step with the reservation lifecycle
exports.syncAssignmentsForBookingStatus = async (bookingIdOrRef, status) => {
  const s = String(status || '').toLowerCase();
  let next = null;
  if (s.includes('cancel') || s.includes('reject') || s.includes('void')) next = 'Released';
  else if (s.includes('complete') || s.includes('checked out') || s.includes('checkout')) next = 'Returned';
  else if (s.includes('using') || s.includes('checked in') || s.includes('check-in')) next = 'In Use';
  if (!next) return;
  await db.query(
    `UPDATE resource_assignments ra JOIN bookings b ON b.id = ra.booking_id
     SET ra.status = ?
     WHERE (b.id = ? OR b.booking_number = ?) AND ra.status IN ('Held','Reserved','In Use')`,
    [next, /^\d+$/.test(String(bookingIdOrRef)) ? Number(bookingIdOrRef) : 0, String(bookingIdOrRef)]
  );
};

// ── Admin: manage numbered units ──
// POST /api/v1/availability/facilities { serviceId, resourceName, status, count }
exports.createUnit = async (req, res) => {
  try {
    const { serviceId, resourceName, status = 'Available', count = 1 } = req.body || {};
    const catalog = await A.loadCatalog();
    const svc = A.findService(catalog, serviceId);
    if (!svc) return res.status(404).json({ success: false, message: 'Service not found' });
    const n = Math.min(100, Math.max(1, parseInt(count, 10) || 1));
    const [[{ cnt }]] = await db.query('SELECT COUNT(*) AS cnt FROM service_resources WHERE service_id = ?', [svc.service_id]);
    const created = [];
    for (let i = 0; i < n; i++) {
      const name = n === 1 && resourceName ? resourceName : `${resourceName || svc.service_name} ${String(cnt + i + 1).padStart(2, '0')}`;
      const [ins] = await db.query('INSERT INTO service_resources (service_id, resource_name, status) VALUES (?, ?, ?)', [svc.service_id, name, status]);
      created.push({ id: ins.insertId, resource_name: name });
    }
    await db.query('UPDATE services SET is_assignable = 1 WHERE service_id = ?', [svc.service_id]);
    await syncServiceCapacity(svc.service_id);
    res.status(201).json({ success: true, data: created });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Could not add facility unit', error: error.message });
  }
};

// PUT /api/v1/availability/facilities/:id { resourceName, status }
exports.updateUnit = async (req, res) => {
  try {
    const { resourceName, status } = req.body || {};
    if (status && !['Available', 'Maintenance', 'Out of Order'].includes(status)) {
      return res.status(400).json({ success: false, message: 'Invalid unit status' });
    }
    const [r] = await db.query(
      'UPDATE service_resources SET resource_name = COALESCE(?, resource_name), status = COALESCE(?, status) WHERE id = ?',
      [resourceName || null, status || null, req.params.id]
    );
    if (!r.affectedRows) return res.status(404).json({ success: false, message: 'Facility unit not found' });
    const [[unit]] = await db.query('SELECT service_id FROM service_resources WHERE id = ?', [req.params.id]);
    await syncServiceCapacity(unit.service_id);
    res.json({ success: true, message: 'Facility unit updated' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Could not update facility unit', error: error.message });
  }
};

// DELETE /api/v1/availability/facilities/:id — only when no upcoming assignment
exports.deleteUnit = async (req, res) => {
  try {
    const [upcoming] = await db.query(
      "SELECT 1 FROM resource_assignments WHERE service_resource_id = ? AND status IN ('Held','Reserved','In Use') AND DATE(start_time) >= CURDATE() LIMIT 1",
      [req.params.id]
    );
    if (upcoming.length) {
      return res.status(409).json({ success: false, message: 'This unit has upcoming reservations. Set it to Maintenance instead, or release the reservations first.' });
    }
    const [[unit]] = await db.query('SELECT service_id FROM service_resources WHERE id = ?', [req.params.id]);
    if (!unit) return res.status(404).json({ success: false, message: 'Facility unit not found' });
    await db.query('DELETE FROM service_resources WHERE id = ?', [req.params.id]);
    await syncServiceCapacity(unit.service_id);
    res.json({ success: true, message: 'Facility unit removed' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Could not remove facility unit', error: error.message });
  }
};

// For numbered services the quantity shown to admins mirrors the number of units
const syncServiceCapacity = async (serviceId) => {
  await db.query(
    `UPDATE services s SET total_capacity = (SELECT COUNT(*) FROM service_resources r WHERE r.service_id = s.service_id)
     WHERE s.service_id = ? AND s.is_assignable = 1`,
    [serviceId]
  );
};
exports.syncServiceCapacity = syncServiceCapacity;

// POST /api/v1/availability/check { date, items: [{name, quantity}], packageId } — validate a whole cart
exports.checkCart = async (req, res) => {
  try {
    const date = dateParam(req);
    const availability = await A.getServicesAvailability(date);
    const pkg = A.findPackage(availability.catalog, req.body?.packageId);
    const demand = A.demandFromRequest(availability.catalog, { items: req.body?.items || [], packageId: pkg?.id });
    const result = A.checkDemand(availability, demand);
    res.json({
      success: true,
      data: { date, ...result, message: result.unavailable.length ? A.describeUnavailable(result.unavailable, date) : null },
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Could not check availability', error: error.message });
  }
};
