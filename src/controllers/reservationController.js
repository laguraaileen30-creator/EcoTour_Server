const db = require('../config/database');
const { createSystemNotification } = require('./notificationController');
const A = require('../services/availabilityService');
const Pricing = require('../services/pricingService');
const { syncAssignmentsForBookingStatus } = require('./availabilityController');
const { getScope, ownsBooking } = require('../services/accessScope');
const { getSettings: getLifecycleSettings } = require('./reservationLifecycleController');

// Only client online bookings owe a reservation fee (downpayment) and get the 24-hour confirmation email.
// Walk-ins registered by staff at the POS never do — paid on the spot or held as pending, they are settled at the counter.
const feeFor = (total, status, feePct, isWalkIn) => {
  const alreadyPaid = /paid|using|complete/i.test(String(status || ''));
  if (isWalkIn || alreadyPaid) {
    return { reservationFee: 0, feeStatus: 'NOT_REQUIRED', amountPaid: alreadyPaid ? total : 0 };
  }
  return { reservationFee: Math.round(total * feePct) / 100, feeStatus: 'UNPAID', amountPaid: 0 };
};

// Find a booking by numeric id, booking number, or the REF-/BK- variant of its number
const resolveBooking = async (idOrRef) => {
  const ref = String(idOrRef || '').trim();
  if (!ref) return null;
  const numericId = /^\d+$/.test(ref) ? Number(ref) : null;
  const [rows] = await db.query(
    `SELECT * FROM bookings
     WHERE (? IS NOT NULL AND id = ?)
        OR booking_number = ?
        OR booking_number = REPLACE(?, 'REF-', 'BK-')
        OR booking_number = REPLACE(?, 'BK-', 'REF-')
     LIMIT 1`,
    [numericId, numericId, ref, ref, ref]
  );
  return rows[0] || null;
};
exports.resolveBooking = resolveBooking;

// GET all reservations with booking items
exports.getReservations = async (req, res) => {
  try {
    // Fetch all bookings via SP
    const scope = await getScope(req);
    const [allBookings] = await db.query(
      `SELECT b.*, u.user_number, p.package_name FROM bookings b
       LEFT JOIN users u ON b.user_id = u.user_id
       LEFT JOIN packages p ON p.id = b.package_id
       ORDER BY b.created_at DESC`
    );
    // Staff/admin see every reservation; clients only their own
    const bookings = allBookings.filter((b) => ownsBooking(scope, b));

    if (bookings.length === 0) {
      return res.status(200).json({ success: true, count: 0, data: [] });
    }

    // Fetch all booking items for these bookings in one SP call
    const bookingIds = bookings.map(b => b.id).join(',');
    const [itemRows] = await db.query('CALL sp_get_booking_items_bulk(?)', [bookingIds]);
    const items = itemRows[0] || [];

    // Assigned numbered facility units (Cottage 05, Videoke 02, ...)
    const [assignRows] = await db.query(
      `SELECT ra.id, ra.booking_id, ra.status, r.id AS resource_id, r.resource_name, s.service_id, s.service_name
       FROM resource_assignments ra
       JOIN service_resources r ON r.id = ra.service_resource_id
       JOIN services s ON s.service_id = r.service_id
       WHERE ra.status IN ('Held','Reserved','In Use','Returned')`
    );
    const assignMap = {};
    assignRows.forEach(a => {
      if (!assignMap[a.booking_id]) assignMap[a.booking_id] = [];
      assignMap[a.booking_id].push({ assignmentId: a.id, resourceId: a.resource_id, facilityName: a.resource_name, serviceId: a.service_id, serviceName: a.service_name, status: a.status });
    });

    // Group items by booking_id
    const itemsMap = {};
    items.forEach(item => {
      if (!itemsMap[item.booking_id]) itemsMap[item.booking_id] = [];
      itemsMap[item.booking_id].push({
        id: item.id,
        serviceId: item.service_id,
        serviceName: item.service_name,
        name: item.service_name,
        itemType: item.item_type || null,
        unitPrice: parseFloat(item.unit_price),
        quantity: item.quantity,
        subtotal: parseFloat(item.subtotal),
      });
    });

    const formatDateStr = (d) => {
      if (!d) return '';
      if (typeof d === 'string') return d.split('T')[0];
      const dt = new Date(d);
      return `${dt.getFullYear()}-${String(dt.getMonth() + 1).padStart(2, '0')}-${String(dt.getDate()).padStart(2, '0')}`;
    };

    const formatted = bookings.map(b => {
      const bItems = itemsMap[b.id] || [];
      const mainService = b.package_name || (bItems.length > 0 ? bItems[0].serviceName : 'Resort Day Pass');
      const assigned = assignMap[b.id] || [];

      return {
        id: b.id,
        bookingRef: b.booking_number,
        bookingNumber: b.booking_number,
        userId: b.user_id,
        userNumber: b.user_number || `CLT-${new Date().getFullYear()}-${b.id + 1000}`,
        clientName: b.client_name,
        fullName: b.client_name,
        touristName: b.client_name,
        clientEmail: b.client_email || 'guest@ecotour.com',
        email: b.client_email || 'guest@ecotour.com',
        touristEmail: b.client_email || 'guest@ecotour.com',
        contactNumber: b.client_phone || '',
        bookingDate: formatDateStr(b.booking_date),
        reservationDate: formatDateStr(b.booking_date),
        arrivalTime: b.arrival_time || '09:00 AM',
        timeSlot: b.arrival_time || '09:00 AM',
        totalVisitors: b.pax || 1,
        quantity: b.pax || 1,
        totalPrice: parseFloat(b.total_amount || 0),
        grandTotal: parseFloat(b.total_amount || 0),
        estimatedTotal: parseFloat(b.total_amount || 0),
        packageId: b.package_id || null,
        bookingType: b.booking_type || null,
        reservationFee: parseFloat(b.reservation_fee || 0),
        amountPaid: parseFloat(b.amount_paid || 0),
        balanceDue: Math.max(0, parseFloat(b.total_amount || 0) - parseFloat(b.amount_paid || 0)),
        feeStatus: b.fee_status || null,
        confirmationStatus: b.confirmation_status || null,
        confirmationSentAt: b.confirmation_sent_at || null,
        confirmationDeadline: b.confirmation_deadline || null,
        discountAmount: parseFloat(b.discount_amount || 0),
        appliedPromoName: b.applied_promo_name || null,
        assignedFacilities: assigned,
        assignmentStatus: assigned.length ? 'Assigned' : 'Unassigned',
        paymentMethod: b.payment_method || 'Cash',
        paymentStatus: b.payment_status || (parseFloat(b.amount_paid || 0) >= parseFloat(b.total_amount || 0) ? 'Paid' : (b.fee_status === 'PAID' ? '50% Paid' : 'Unpaid')),
        status: b.status || 'Pending',
        cateredBy: b.catered_by || null,
        cateredAt: b.catered_at || null,
        createdAt: b.created_at,
        serviceName: bItems.length > 1 ? `${mainService} (+${bItems.length - 1} extra)` : mainService,
        packageName: mainService,
        items: bItems
      };
    });

    res.status(200).json({ success: true, count: formatted.length, data: formatted });
  } catch (error) {
    console.error('Error fetching reservations:', error);
    res.status(500).json({ success: false, message: 'Server error fetching reservations', error: error.message });
  }
};

// GET single reservation by ID or booking_number
exports.getReservationById = async (req, res) => {
  try {
    const { id } = req.params;

    const [bookingRows] = await db.query('CALL sp_get_booking_by_id(?)', [id]);
    const bookingResult = bookingRows[0] || [];

    if (bookingResult.length === 0) {
      return res.status(404).json({ success: false, message: 'Reservation not found' });
    }

    const b = bookingResult[0];
    const [[ownerRow]] = await db.query('SELECT user_id, client_email, total_amount, amount_paid, fee_status, reservation_fee FROM bookings WHERE id = ?', [b.id]);
    if (!ownsBooking(await getScope(req), ownerRow)) {
      return res.status(404).json({ success: false, message: 'Reservation not found' });
    }

    const [itemRows] = await db.query('CALL sp_get_booking_items(?)', [b.id]);
    const items = itemRows[0] || [];

    const formatted = {
      id: b.id,
      bookingRef: b.booking_number,
      bookingNumber: b.booking_number,
      clientName: b.client_name,
      clientEmail: b.client_email,
      contactNumber: b.client_phone,
      bookingDate: b.booking_date,
      arrivalTime: b.arrival_time,
      totalVisitors: b.pax,
      totalPrice: parseFloat(b.total_amount || 0),
      amountPaid: parseFloat(ownerRow.amount_paid || 0),
      balanceDue: Math.max(0, parseFloat(ownerRow.total_amount || 0) - parseFloat(ownerRow.amount_paid || 0)),
      feeStatus: ownerRow.fee_status,
      reservationFee: parseFloat(ownerRow.reservation_fee || 0),
      paymentMethod: b.payment_method,
      status: b.status,
      items: items.map(i => ({
        serviceId: i.service_id,
        serviceName: i.service_name,
        unitPrice: parseFloat(i.unit_price),
        quantity: i.quantity,
        subtotal: parseFloat(i.subtotal)
      }))
    };

    res.status(200).json({ success: true, data: formatted });
  } catch (error) {
    console.error('Error fetching reservation by ID:', error);
    res.status(500).json({ success: false, message: 'Server error', error: error.message });
  }
};

// CREATE new reservation from landing page, client portal or POS walk-in.
// Availability is re-checked on the server inside a transaction: the services involved are row-locked
// (SELECT ... FOR UPDATE) so two clients cannot both take the last cottage for the same date.
exports.createReservation = async (req, res) => {
  const body = req.body || {};
  const conn = await db.getConnection();
  try {
    const bookingNumber = body.bookingRef || body.bookingNumber || `BK-${new Date().getFullYear()}-${Math.floor(100000 + Math.random() * 900000)}`;
    const clientName = body.clientName || body.fullName || body.touristName || 'Guest User';
    const clientEmail = body.clientEmail || body.email || body.touristEmail || null;
    const clientPhone = body.contactNumber || body.phone || null;
    const bookingDate = A.toDateStr(body.bookingDate || body.reservationDate) || A.todayPH();
    const arrivalTime = body.arrivalTime || body.timeSlot || '09:00 AM';
    const clientTotal = parseFloat(body.totalPrice || body.grandTotal || body.total_amount || 0);
    const paymentMethod = body.paymentMethod || 'Cash';
    const status = body.status || 'Pending';
    const userId = body.userId || (req.user ? req.user.user_id : null);
    const items = Array.isArray(body.items) ? body.items : [];

    if (bookingDate < A.todayPH()) {
      return res.status(400).json({ success: false, code: 'PAST_DATE', message: 'The visit date cannot be in the past.' });
    }

    await conn.query('SET TRANSACTION ISOLATION LEVEL READ COMMITTED');
    await conn.beginTransaction();

    // Same booking number posted twice (retry / double click) -> return the existing reservation, never a duplicate
    const [[existing]] = await conn.query('SELECT id, status FROM bookings WHERE booking_number = ?', [bookingNumber]);
    if (existing) {
      await conn.rollback();
      return res.status(200).json({ success: true, duplicate: true, message: 'Reservation already exists', data: { id: existing.id, bookingRef: bookingNumber, bookingNumber, status: existing.status } });
    }

    // --- Client Pending Booking Rule ---
    // If the client has an unpaid pending reservation, they must pay first before creating another booking.
    const scope = await getScope(req);
    const isStaffAction = scope.isStaff || body.source === 'Walk-In POS' || ['staff', 'admin'].includes(String(req.user?.role || '').toLowerCase());
    if (userId && !isStaffAction) {
      const [pendingBookings] = await conn.query(
        `SELECT id, booking_number, total_amount, reservation_fee, fee_status, amount_paid, status, payment_status
         FROM bookings
         WHERE user_id = ?
           AND status NOT IN ('Cancelled', 'Rejected', 'Completed')
           AND (fee_status IS NULL OR fee_status != 'PAID')
           AND (payment_status IS NULL OR payment_status = 'Unpaid' OR amount_paid = 0 OR status = 'Pending')
         LIMIT 1`,
        [userId]
      );
      if (pendingBookings.length > 0) {
        await conn.rollback();
        const pendingRef = pendingBookings[0].booking_number;
        return res.status(400).json({ 
          success: false, 
          code: 'PENDING_BOOKING_EXISTS',
          message: `You currently have an unpaid pending reservation (${pendingRef}). You must pay first before you can create another booking.`
        });
      }
    }
    // ----------------------------------

    const catalog = await A.loadCatalog(conn);
    const pricingCtx = await Pricing.loadPricingContext(conn);
    let priced;
    try {
      priced = Pricing.priceBooking(catalog, pricingCtx, body);
    } catch (priceErr) {
      await conn.rollback();
      return res.status(400).json({ success: false, code: priceErr.code || 'INVALID_BOOKING', message: priceErr.message });
    }
    const pkg = priced.pkg;
    if (pkg && (pkg.status !== 'Active' || ['OUT_OF_STOCK', 'UNAVAILABLE', 'MAINTENANCE'].includes(pkg.manual_status))) {
      await conn.rollback();
      return res.status(409).json({ success: false, code: 'FULLY_BOOKED', message: `${pkg.package_name} is currently unavailable.`, unavailable: [] });
    }
    const demand = priced.demand;

    // Lock the service rows involved so concurrent bookings for the same services are serialized
    if (demand.length) {
      await conn.query(
        `SELECT service_id FROM services WHERE service_id IN (${demand.map(() => '?').join(',')}) FOR UPDATE`,
        demand.map((d) => d.serviceId)
      );
      const availability = await A.getServicesAvailability(bookingDate, { conn, catalog });
      const check = A.checkDemand(availability, demand);
      if (check.unavailable.length) {
        await conn.rollback();
        return res.status(409).json({
          success: false,
          code: 'FULLY_BOOKED',
          date: bookingDate,
          message: pkg
            ? `${pkg.package_name} cannot be booked on ${bookingDate}: ${A.describeUnavailable(check.unavailable, bookingDate)}`
            : `Sorry, this was just fully booked. ${A.describeUnavailable(check.unavailable, bookingDate)} Please select another service or date.`,
          unavailable: check.unavailable,
        });
      }
    }

    const pax = parseInt(body.totalVisitors || body.pax || 0, 10) || priced.pax;
    const [ins] = await conn.query(
      `INSERT INTO bookings (booking_number, user_id, package_id, promotion_id, applied_promo_name, client_name, client_email, client_phone,
         booking_date, arrival_time, pax, original_value, base_package_price, total_amount, discount_amount, payment_method, status)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [bookingNumber, userId || null, pkg ? pkg.id : null, priced.appliedDeal ? priced.appliedDeal.id : null, priced.appliedDeal ? priced.appliedDeal.promo_name : null,
       clientName, clientEmail, clientPhone, bookingDate, arrivalTime, pax,
       priced.originalValue, priced.basePackagePrice, priced.total, priced.discount,
       paymentMethod, status]
    );
    const { feePct } = await getLifecycleSettings(conn);
    const isWalkIn = body.source === 'Walk-In POS' || ['staff', 'admin'].includes(String(req.user?.role || '').toLowerCase());
    const fee = feeFor(priced.total, status, feePct, isWalkIn);
    await conn.query(
      'UPDATE bookings SET booking_type = ?, reservation_fee = ?, fee_status = ?, amount_paid = ? WHERE id = ?',
      [priced.bookingType, fee.reservationFee, fee.feeStatus, fee.amountPaid, ins.insertId]
    );
    const bookingId = ins.insertId;
    const totalAmount = priced.total;

    const savedItems = priced.lines.map((l) => ({ ...l, serviceName: l.name, category: l.itemType === 'PACKAGE' ? 'Package' : l.itemType === 'TICKET' || l.itemType === 'FEE' ? 'Entrance' : 'Add-on' }));
    await conn.query(
      'INSERT INTO booking_items (booking_id, service_id, service_name, unit_price, quantity, subtotal, item_type) VALUES ?',
      [priced.lines.map((l) => [bookingId, l.serviceId || 0, l.name, l.unitPrice, l.quantity, l.subtotal, l.itemType])]
    );

    await conn.commit();

    const createdBooking = {
      id: bookingId,
      bookingRef: bookingNumber,
      bookingNumber,
      userId,
      userNumber: body.userNumber || `CLT-${new Date().getFullYear()}-${1000 + (bookingId || 0)}`,
      clientName,
      fullName: clientName,
      touristName: clientName,
      clientEmail,
      email: clientEmail,
      touristEmail: clientEmail,
      contactNumber: clientPhone,
      bookingDate,
      reservationDate: bookingDate,
      arrivalTime,
      timeSlot: arrivalTime,
      totalVisitors: pax,
      quantity: pax,
      totalPrice: totalAmount,
      grandTotal: totalAmount,
      estimatedTotal: totalAmount,
      paymentMethod,
      status,
      packageId: pkg ? pkg.id : null,
      packageName: pkg ? pkg.package_name : body.packageName,
      assignmentStatus: 'Unassigned',
      bookingType: priced.bookingType,
      reservationFee: fee.reservationFee,
      reservationFeePct: feePct,
      feeStatus: fee.feeStatus,
      amountPaid: fee.amountPaid,
      balanceDue: Math.max(0, totalAmount - fee.amountPaid),
      discountAmount: priced.discount,
      appliedPromoName: priced.appliedDeal ? priced.appliedDeal.promo_name : null,
      priceAdjusted: Math.abs(clientTotal - totalAmount) > 0.009,
      assignedFacilities: [],
      serviceName: body.serviceName || body.packageName || 'Resort Entrance & Reservation Pass',
      items: savedItems,
    };

    createSystemNotification({
      roleTarget: 'staff',
      title: `New Reservation (${bookingNumber})`,
      message: `${clientName} booked ${pkg ? pkg.package_name : (body.serviceName || 'Resort Reservation')} for ${bookingDate} (${pax} guests). Total: ₱${totalAmount}`,
      type: 'booking',
      referenceId: bookingNumber
    });

    res.status(201).json({ success: true, message: 'Reservation created and saved to database successfully', data: createdBooking });
  } catch (error) {
    await conn.rollback().catch(() => {});
    console.error('Error creating reservation:', error);
    require('fs').writeFileSync('res_err.txt', error.stack || error.message);
    res.status(500).json({ success: false, message: 'Failed to create reservation in database', error: error.message });
  } finally {
    conn.release();
  }
};

// UPDATE reservation status (Admin / Staff / Client action)
exports.updateReservationStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    if (!status) {
      return res.status(400).json({ success: false, message: 'Status is required' });
    }

    const scope = await getScope(req);
    if (!scope.isStaff) {
      const booking = await resolveBooking(id);
      if (!booking || !ownsBooking(scope, booking)) {
        return res.status(404).json({ success: false, message: 'Reservation not found' });
      }
      if (!/cancel/i.test(status)) {
        return res.status(403).json({ success: false, code: 'FORBIDDEN', message: 'Only resort staff can change this reservation status.' });
      }
      if (!/pending|unpaid|waiting|counter/i.test(String(booking.status || 'Pending'))) {
        return res.status(400).json({ success: false, message: 'This reservation is already paid or in progress. Please contact the resort front desk to cancel.' });
      }
    }

    // Resolve the booking first (by numeric id or booking number, REF-/BK- variants), then update by id.
    // Comparing the INT id column with a text reference inside an UPDATE fails under MySQL strict mode.
    const bookingRow = await resolveBooking(id);
    if (!bookingRow) {
      return res.status(404).json({ success: false, message: 'Reservation not found' });
    }
    const checkoutRequested = /complete|checked out|checkout|done/i.test(String(status));
    const [updated] = await db.query(
      `UPDATE bookings SET status = ?, updated_at = NOW()
       WHERE id = ?${checkoutRequested ? ' AND COALESCE(amount_paid, 0) >= COALESCE(total_amount, 0) - 0.009' : ''}`,
      [status, bookingRow.id]
    );
    if (checkoutRequested && updated.affectedRows === 0) {
      const [[paymentState]] = await db.query(
        'SELECT total_amount, amount_paid FROM bookings WHERE id = ?',
        [bookingRow.id]
      );
      const balanceDue = Math.max(0, Number(paymentState?.total_amount || 0) - Number(paymentState?.amount_paid || 0));
      return res.status(409).json({
        success: false,
        code: 'BALANCE_DUE',
        balanceDue,
        message: `Collect the remaining balance of ₱${balanceDue.toFixed(2)} before checking out this reservation.`,
      });
    }

    // Keep numbered facility assignments in step with the reservation lifecycle
    try {
      await syncAssignmentsForBookingStatus(bookingRow.id, status);
    } catch (syncErr) {
      console.warn('Assignment sync:', syncErr.message);
    }

    // Also call stored procedure
    try {
      await db.query('CALL sp_update_booking_status(?, ?)', [bookingRow.id, status]);
    } catch (spErr) {
      // SP fallback
    }

    // Record audit trail in database for complete history
    try {
      await db.query('CALL sp_create_audit_log(?, ?, ?)', [
        req.user ? req.user.user_id : null,
        'UPDATE_RESERVATION_STATUS',
        `Reservation ${id} status updated to "${status}" at ${new Date().toISOString()}`
      ]);
    } catch (auditErr) {
      // Non-blocking audit log
    }

    // Trigger notification for the client / staff / admin
    createSystemNotification({
      roleTarget: 'all',
      title: `Reservation #${id} Status Updated`,
      message: `Reservation ${id} has moved to "${status}".`,
      type: 'booking',
      referenceId: String(id)
    });

    res.status(200).json({ success: true, message: `Reservation status updated to ${status}` });
  } catch (error) {
    console.error('Error updating reservation status:', error);
    res.status(500).json({ success: false, message: 'Server error updating status', error: error.message });
  }
};

// Idempotency keys for add-on payments already processed (guards against double-submit / double charge)
const processedAddonRequests = new Map();
const ADDON_REQUEST_TTL_MS = 60 * 60 * 1000;

// ADD SERVICES to an already-paid reservation.
// Only the NEW items are charged: they are appended to booking_items, the booking total grows by the
// add-on amount, and a separate payment is recorded for the add-on amount only. The booking status is
// left untouched.
exports.addServicesToReservation = async (req, res) => {
  const { id } = req.params;
  const {
    items = [],
    cash_received,
    payment_mode = 'pay_now',
    staff_name = 'Duty Cashier',
    staff_id = null,
    request_id
  } = req.body || {};
  const paymentMode = payment_mode === 'pay_later' ? 'pay_later' : 'pay_now';

  const now = Date.now();
  for (const [key, ts] of processedAddonRequests) {
    if (now - ts > ADDON_REQUEST_TTL_MS) processedAddonRequests.delete(key);
  }
  if (request_id && processedAddonRequests.has(request_id)) {
    return res.status(409).json({ success: false, duplicate: true, message: 'This add-on payment was already recorded.' });
  }

  const cleanItems = (Array.isArray(items) ? items : [])
    .map(it => ({
      serviceId: parseInt(it.serviceId || it.service_id, 10) || 0,
      name: String(it.serviceName || it.name || 'Resort Service').slice(0, 100),
      quantity: parseInt(it.quantity || 0, 10)
    }))
    .filter(it => it.quantity > 0);

  if (cleanItems.length === 0) {
    return res.status(400).json({ success: false, message: 'No new services to add.' });
  }

  if (request_id) processedAddonRequests.set(request_id, now);

  const conn = await db.getConnection();
  try {
    await conn.beginTransaction();

    const [bookingRows] = await conn.query(
      'SELECT id, booking_number, client_name, total_amount, amount_paid, status, booking_date FROM bookings WHERE id = ? OR booking_number = ? LIMIT 1 FOR UPDATE',
      [/^\d+$/.test(String(id)) ? Number(id) : 0, String(id)]
    );
    const booking = bookingRows[0];
    if (!booking) {
      await conn.rollback();
      if (request_id) processedAddonRequests.delete(request_id);
      return res.status(404).json({ success: false, message: 'Reservation not found' });
    }
    const status = String(booking.status || '').toLowerCase();
    if (status.includes('cancel') || status.includes('reject') || status.includes('void')) {
      await conn.rollback();
      if (request_id) processedAddonRequests.delete(request_id);
      return res.status(400).json({ success: false, message: 'Cannot add services to a cancelled reservation.' });
    }

    // Price the NEW items on the server (client prices are ignored)
    const catalog = await A.loadCatalog(conn);
    const pricingCtx = await Pricing.loadPricingContext(conn);
    let priced;
    try {
      priced = Pricing.priceBooking(catalog, pricingCtx, { items: cleanItems });
    } catch (priceErr) {
      await conn.rollback();
      if (request_id) processedAddonRequests.delete(request_id);
      return res.status(400).json({ success: false, message: priceErr.message });
    }
    const addonAmount = priced.total;
    const cashRec = paymentMode === 'pay_now' ? parseFloat(cash_received ?? addonAmount) : 0;
    if (paymentMode === 'pay_now' && !(cashRec >= addonAmount)) {
      await conn.rollback();
      if (request_id) processedAddonRequests.delete(request_id);
      return res.status(400).json({ success: false, code: 'INSUFFICIENT_CASH', addonAmount, message: `Insufficient cash. Add-on amount due is ₱${addonAmount}.` });
    }
    const changeAmt = paymentMode === 'pay_now' ? Math.max(0, cashRec - addonAmount) : 0;

    // The added services must still be available on the booking's date
    const bookingDate = A.toDateStr(booking.booking_date);
    const demand = priced.demand;
    if (demand.length) {
      await conn.query(
        `SELECT service_id FROM services WHERE service_id IN (${demand.map(() => '?').join(',')}) FOR UPDATE`,
        demand.map((d) => d.serviceId)
      );
      const availability = await A.getServicesAvailability(bookingDate, { conn, catalog });
      const check = A.checkDemand(availability, demand);
      if (check.unavailable.length) {
        await conn.rollback();
        if (request_id) processedAddonRequests.delete(request_id);
        return res.status(409).json({ success: false, code: 'FULLY_BOOKED', message: `Cannot add: ${A.describeUnavailable(check.unavailable, bookingDate)} Nothing was charged.`, unavailable: check.unavailable });
      }
    }

    await conn.query(
      'INSERT INTO booking_items (booking_id, service_id, service_name, unit_price, quantity, subtotal, item_type) VALUES ?',
      [priced.lines.map((l) => [booking.id, l.serviceId || 0, l.name, l.unitPrice, l.quantity, l.subtotal, l.itemType])]
    );
    const previousTotal = parseFloat(booking.total_amount || 0);
    const previousPaid = parseFloat(booking.amount_paid || 0);
    const newTotal = Math.round((previousTotal + addonAmount) * 100) / 100;
    const newPaid = Math.round((previousPaid + (paymentMode === 'pay_now' ? addonAmount : 0)) * 100) / 100;
    const balanceDue = Math.max(0, Math.round((newTotal - newPaid) * 100) / 100);
    const paymentStatus = balanceDue <= 0.009 ? 'Paid' : (newPaid > 0 ? 'Partially Paid' : 'Unpaid');
    await conn.query(
      'UPDATE bookings SET total_amount = ?, amount_paid = ?, payment_status = ? WHERE id = ?',
      [newTotal, newPaid, paymentStatus, booking.id]
    );

    let payment_ref = null;
    let payResult = null;
    let parkShare = 0;
    let barangayShare = 0;
    let guideShare = 0;
    if (paymentMode === 'pay_now') {
      const [countResult] = await conn.query('SELECT COUNT(*) AS cnt FROM payments');
      payment_ref = `OR-${new Date().getFullYear()}-${String((countResult[0]?.cnt || 0) + 1).padStart(6, '0')}`;

      [payResult] = await conn.query(
        `INSERT INTO payments (payment_ref, booking_id, client_name, staff_id, staff_name, total_amount, cash_received, change_amount, payment_method, status)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'Cash', 'Paid')`,
        [payment_ref, booking.id, booking.client_name, staff_id || req.user?.user_id || null, staff_name, addonAmount, cashRec, changeAmt]
      );

      const [settingRows] = await conn.query(
        "SELECT setting_key, setting_value FROM settings WHERE setting_key IN ('park_share_pct','barangay_share_pct','guide_share_pct')"
      );
      const pct = { park_share_pct: 70, barangay_share_pct: 20, guide_share_pct: 10 };
      settingRows.forEach(r => { pct[r.setting_key] = parseFloat(r.setting_value) || pct[r.setting_key]; });
      const round2 = (n) => Math.round(n * 100) / 100;
      parkShare = round2(addonAmount * pct.park_share_pct / 100);
      barangayShare = round2(addonAmount * pct.barangay_share_pct / 100);
      guideShare = round2(addonAmount * pct.guide_share_pct / 100);

      await conn.query(
        'INSERT INTO revenue_shares (payment_id, gross_amount, park_share, barangay_share, guide_share) VALUES (?, ?, ?, ?, ?)',
        [payResult.insertId, addonAmount, parkShare, barangayShare, guideShare]
      );
    }

    await conn.query(
      'INSERT INTO audit_logs (action, description) VALUES (?, ?)',
      [
        paymentMode === 'pay_now' ? 'RESERVATION_ADDON_PAID' : 'RESERVATION_ADDON_ADDED_TO_BALANCE',
        `${staff_name} added services to ${booking.booking_number} (${booking.client_name}) - Add-on amount: ${addonAmount}; payment mode: ${paymentMode}; new balance: ${balanceDue}`
      ]
    );

    await conn.commit();

    res.status(201).json({
      success: true,
      message: paymentMode === 'pay_now'
        ? 'Add-on services recorded and paid.'
        : 'Add-on services recorded and added to the reservation balance.',
      paymentMode,
      previousTotal,
      previousAmountPaid: previousPaid,
      addonAmount,
      newTotal,
      amountPaid: newPaid,
      balanceDue,
      items: priced.lines,
      receipt: paymentMode === 'pay_now' ? {
        id: payResult.insertId,
        payment_ref,
        receiptNo: payment_ref,
        booking_id: booking.id,
        bookingRef: booking.booking_number,
        client_name: booking.client_name,
        staff_name,
        total_amount: addonAmount,
        grandTotal: addonAmount,
        cash_received: cashRec,
        cashReceived: cashRec,
        change_amount: changeAmt,
        change: changeAmt,
        status: 'Paid',
        parkShare,
        barangayShare,
        guideShare,
        municipalShare: guideShare,
        items: priced.lines,
        created_at: new Date().toISOString()
      } : null
    });
  } catch (error) {
    await conn.rollback().catch(() => {});
    if (request_id) processedAddonRequests.delete(request_id);
    console.error('Error adding services to reservation:', error);
    res.status(500).json({ success: false, message: 'Failed to add services', error: error.message });
  } finally {
    conn.release();
  }
};

// POST /api/v1/reservations/quote — server price + availability for the review step (nothing is saved)
exports.quoteReservation = async (req, res) => {
  try {
    const body = req.body || {};
    const date = A.toDateStr(body.bookingDate || body.reservationDate) || A.todayPH();
    const catalog = await A.loadCatalog();
    const ctx = await Pricing.loadPricingContext(db);
    let priced;
    try {
      priced = Pricing.priceBooking(catalog, ctx, body);
    } catch (priceErr) {
      return res.status(400).json({ success: false, code: priceErr.code || 'INVALID_BOOKING', message: priceErr.message });
    }
    const availability = await A.getServicesAvailability(date, { catalog });
    const check = A.checkDemand(availability, priced.demand);
    res.json({
      success: true,
      data: {
        date,
        bookingType: priced.bookingType,
        lines: priced.lines,
        total: priced.total,
        originalValue: priced.originalValue,
        discount: priced.discount,
        appliedDeal: priced.appliedDeal ? { id: priced.appliedDeal.id, name: priced.appliedDeal.promo_name } : null,
        pax: priced.pax,
        reservationFeePct: (await getLifecycleSettings()).feePct,
        reservationFee: Math.round(priced.total * (await getLifecycleSettings()).feePct) / 100,
        availability: { status: check.status, items: check.items, unavailable: check.unavailable, message: check.unavailable.length ? A.describeUnavailable(check.unavailable, date) : null },
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Could not price reservation', error: error.message });
  }
};

// GET /api/v1/reservations/pricing — public ticket prices & fees used by the booking forms
exports.getPricing = async (req, res) => {
  try {
    const ctx = await Pricing.loadPricingContext(db);
    res.json({ success: true, data: { tickets: ctx.ticketPrice, environmentalFeePerHead: ctx.envFee } });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Could not load pricing', error: error.message });
  }
};

// POST /api/v1/reservations/:id/cater
// Claims a client booking for a staff member to prevent multiple staff simultaneously catering
exports.caterReservation = async (req, res) => {
  try {
    const { id } = req.params;
    const booking = await resolveBooking(id);
    if (!booking) {
      return res.status(404).json({ success: false, message: 'Reservation not found' });
    }

    const staffName = (req.body?.staff_name || req.user?.name || `${req.user?.fname || ''} ${req.user?.lname || ''}`.trim() || 'Staff').trim();

    // Check if another staff member has claimed this booking within the last 3 minutes (180s)
    if (booking.catered_by && booking.catered_by.toLowerCase() !== staffName.toLowerCase() && booking.catered_at) {
      const elapsedSeconds = (Date.now() - new Date(booking.catered_at).getTime()) / 1000;
      if (elapsedSeconds < 180) {
        return res.status(409).json({
          success: false,
          conflict: true,
          lockedBy: booking.catered_by,
          message: `This client is currently being assisted by ${booking.catered_by}. Please select another client to avoid duplicate service.`
        });
      }
    }

    // Set lock
    await db.query(
      `UPDATE bookings SET catered_by = ?, catered_at = NOW() WHERE id = ?`,
      [staffName, booking.id]
    );

    return res.status(200).json({
      success: true,
      message: `You are now assisting ${booking.client_name || 'Client'}.`,
      cateredBy: staffName,
      bookingId: booking.id
    });
  } catch (error) {
    console.error('Error claiming booking:', error);
    return res.status(500).json({ success: false, message: 'Server error claiming booking', error: error.message });
  }
};

// POST /api/v1/reservations/:id/uncater
// Releases claim when payment modal is cancelled or transaction aborted
exports.uncaterReservation = async (req, res) => {
  try {
    const { id } = req.params;
    const booking = await resolveBooking(id);
    if (!booking) {
      return res.status(404).json({ success: false, message: 'Reservation not found' });
    }

    const staffName = (req.body?.staff_name || req.user?.name || `${req.user?.fname || ''} ${req.user?.lname || ''}`.trim() || '').trim();

    // Only clear if matching staff or force requested
    if (staffName && booking.catered_by && booking.catered_by.toLowerCase() !== staffName.toLowerCase() && !req.body?.force) {
      return res.status(200).json({ success: true, message: 'Claim held by someone else, not released.' });
    }

    await db.query(
      `UPDATE bookings SET catered_by = NULL, catered_at = NULL WHERE id = ?`,
      [booking.id]
    );

    return res.status(200).json({
      success: true,
      message: 'Booking released successfully. Another staff member may now assist this client.'
    });
  } catch (error) {
    console.error('Error releasing booking:', error);
    return res.status(500).json({ success: false, message: 'Server error releasing booking', error: error.message });
  }
};
