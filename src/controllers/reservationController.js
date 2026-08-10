const db = require('../config/database');

// GET all reservations with booking items
exports.getReservations = async (req, res) => {
  try {
    const [bookings] = await db.query(
      `SELECT b.*, u.user_number 
       FROM bookings b 
       LEFT JOIN users u ON b.user_id = u.user_id 
       ORDER BY b.created_at DESC`
    );

    if (bookings.length === 0) {
      return res.status(200).json({ success: true, count: 0, data: [] });
    }

    const bookingIds = bookings.map(b => b.id);
    const [items] = await db.query(
      `SELECT * FROM booking_items WHERE booking_id IN (?)`,
      [bookingIds]
    );

    // Group items by booking_id
    const itemsMap = {};
    items.forEach(item => {
      if (!itemsMap[item.booking_id]) itemsMap[item.booking_id] = [];
      itemsMap[item.booking_id].push({
        id: item.id,
        serviceId: item.service_id,
        serviceName: item.service_name,
        unitPrice: parseFloat(item.unit_price),
        quantity: item.quantity,
        subtotal: parseFloat(item.subtotal),
      });
    });

    const formatted = bookings.map(b => {
      const bItems = itemsMap[b.id] || [];
      const mainService = bItems.length > 0 ? bItems[0].serviceName : 'Resort Day Pass';

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
        bookingDate: b.booking_date ? new Date(b.booking_date).toISOString().split('T')[0] : '',
        reservationDate: b.booking_date ? new Date(b.booking_date).toISOString().split('T')[0] : '',
        arrivalTime: b.arrival_time || '09:00 AM',
        timeSlot: b.arrival_time || '09:00 AM',
        totalVisitors: b.pax || 1,
        quantity: b.pax || 1,
        totalPrice: parseFloat(b.total_amount || 0),
        grandTotal: parseFloat(b.total_amount || 0),
        paymentMethod: b.payment_method || 'Cash',
        status: b.status || 'Pending',
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
    const [rows] = await db.query(
      `SELECT * FROM bookings WHERE id = ? OR booking_number = ?`,
      [id, id]
    );

    if (rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Reservation not found' });
    }

    const b = rows[0];
    const [items] = await db.query(`SELECT * FROM booking_items WHERE booking_id = ?`, [b.id]);

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

// CREATE new reservation from landing page or client portal
exports.createReservation = async (req, res) => {
  try {
    const body = req.body || {};
    const bookingNumber = body.bookingRef || body.bookingNumber || `BK-${new Date().getFullYear()}-${Math.floor(100000 + Math.random() * 900000)}`;
    const clientName = body.clientName || body.fullName || body.touristName || 'Guest User';
    const clientEmail = body.clientEmail || body.email || body.touristEmail || null;
    const clientPhone = body.contactNumber || body.phone || null;
    const bookingDate = body.bookingDate || body.reservationDate || new Date().toISOString().split('T')[0];
    const arrivalTime = body.arrivalTime || body.timeSlot || '09:00 AM';
    const pax = parseInt(body.totalVisitors || body.quantity || body.pax || 1, 10);
    const totalAmount = parseFloat(body.totalPrice || body.grandTotal || body.total_amount || 0);
    const paymentMethod = body.paymentMethod || 'Cash';
    const status = body.status || 'Pending';
    const userId = body.userId || (req.user ? req.user.user_id : null);

    const [result] = await db.query(
      `INSERT INTO bookings 
        (booking_number, user_id, client_name, client_email, client_phone, booking_date, arrival_time, pax, total_amount, payment_method, status) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [bookingNumber, userId, clientName, clientEmail, clientPhone, bookingDate, arrivalTime, pax, totalAmount, paymentMethod, status]
    );

    const bookingId = result.insertId;

    // Insert items if provided
    const items = Array.isArray(body.items) ? body.items : [];
    if (items.length > 0) {
      const itemValues = items.map((item, idx) => [
        bookingId,
        item.serviceId || item.service_id || (idx + 1),
        item.serviceName || item.name || 'Resort Service',
        parseFloat(item.unitPrice || item.price || 0),
        parseInt(item.quantity || 1, 10),
        parseFloat(item.subtotal || (parseFloat(item.unitPrice || item.price || 0) * parseInt(item.quantity || 1, 10)))
      ]);

      await db.query(
        `INSERT INTO booking_items (booking_id, service_id, service_name, unit_price, quantity, subtotal) VALUES ?`,
        [itemValues]
      );
    } else {
      // Create a default entrance item
      await db.query(
        `INSERT INTO booking_items (booking_id, service_id, service_name, unit_price, quantity, subtotal) VALUES (?, ?, ?, ?, ?, ?)`,
        [bookingId, 1, body.serviceName || body.packageName || 'Resort Entrance & Reservation Pass', totalAmount, 1, totalAmount]
      );
    }

    const createdBooking = {
      id: bookingId,
      bookingRef: bookingNumber,
      bookingNumber,
      userId,
      userNumber: body.userNumber || `CLT-${new Date().getFullYear()}-${1000 + bookingId}`,
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
      paymentMethod,
      status,
      serviceName: body.serviceName || body.packageName || 'Resort Entrance & Reservation Pass',
      items: items.length > 0 ? items : [{ name: body.serviceName || 'Resort Day Pass', quantity: 1, unitPrice: totalAmount, subtotal: totalAmount }]
    };

    res.status(201).json({
      success: true,
      message: 'Reservation created and saved to database successfully',
      data: createdBooking
    });
  } catch (error) {
    console.error('Error creating reservation:', error);
    res.status(500).json({ success: false, message: 'Failed to create reservation in database', error: error.message });
  }
};

// UPDATE reservation status (Admin / Staff action)
exports.updateReservationStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    if (!status) {
      return res.status(400).json({ success: false, message: 'Status is required' });
    }

    const [result] = await db.query(
      `UPDATE bookings SET status = ? WHERE id = ? OR booking_number = ?`,
      [status, id, id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ success: false, message: 'Reservation not found' });
    }

    res.status(200).json({ success: true, message: `Reservation status updated to ${status}` });
  } catch (error) {
    console.error('Error updating reservation status:', error);
    res.status(500).json({ success: false, message: 'Server error updating status', error: error.message });
  }
};

