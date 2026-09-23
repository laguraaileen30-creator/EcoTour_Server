const { getScope, ownsBooking } = require('../services/accessScope');
const db = require('../config/database');

// Create / Save Receipt Payment Record to Database
exports.createPayment = async (req, res) => {
  try {
    const {
      booking_id,
      client_name,
      staff_id = null,
      staff_name = 'Duty Cashier',
      total_amount,
      cash_received,
      payment_method = 'Cash',
      items = []
    } = req.body;

    const totalAmt = parseFloat(total_amount || 0);
    const cashRec = parseFloat(cash_received || totalAmt);
    const changeAmt = Math.max(0, cashRec - totalAmt);

    // Generate OR Number (e.g., OR-2026-000089)
    const [countResult] = await db.query('SELECT COUNT(*) as cnt FROM payments');
    const nextSeq = (countResult[0]?.cnt || 0) + 1;
    const payment_ref = `OR-2026-${String(nextSeq).padStart(6, '0')}`;

    // Create payment via SP (handles payment insert + revenue_shares + booking update + audit log in one transaction)
    const [spRows] = await db.query(
      'CALL sp_create_payment(?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        payment_ref,
        booking_id || null,
        client_name || 'Walk-In Guest',
        staff_id || null,
        staff_name,
        totalAmt,
        cashRec,
        changeAmt,
        payment_method
      ]
    );

    const spResult = spRows[0] && spRows[0][0];
    const paymentId = spResult ? spResult.id : null;
    const parkShare = spResult ? spResult.park_share : (totalAmt * 0.70).toFixed(2);
    const barangayShare = spResult ? spResult.barangay_share : (totalAmt * 0.20).toFixed(2);
    const guideShare = spResult ? spResult.guide_share : (totalAmt * 0.10).toFixed(2);

    res.status(201).json({
      success: true,
      message: 'Official Receipt payment stored successfully in database',
      receipt: {
        id: paymentId,
        payment_ref,
        receiptNo: payment_ref,
        booking_id,
        client_name,
        clientName: client_name,
        staff_name,
        staffName: staff_name,
        total_amount: totalAmt,
        grandTotal: totalAmt,
        cash_received: cashRec,
        cashReceived: cashRec,
        change_amount: changeAmt,
        change: changeAmt,
        payment_method,
        paymentMethod: payment_method,
        status: 'Paid',
        parkShare,
        barangayShare,
        // Expose as both guideShare and municipalShare for frontend compatibility
        guideShare,
        municipalShare: guideShare,
        items,
        created_at: new Date().toISOString()
      }
    });
  } catch (error) {
    console.error('Error creating payment receipt:', error);
    res.status(500).json({ success: false, message: 'Failed to record receipt in database', error: error.message });
  }
};

// Fetch All Official Receipts / Payments from Database
exports.getPayments = async (req, res) => {
  try {
    const [rows] = await db.query('CALL sp_get_all_payments()');
    let payments = rows[0] || [];
    const scope = await getScope(req);
    if (!scope.isStaff) {
      const [own] = await db.query('SELECT id, user_id, client_email FROM bookings');
      const ownIds = new Set(own.filter((b) => ownsBooking(scope, b)).map((b) => b.id));
      payments = payments.filter((p) => p.booking_id && ownIds.has(p.booking_id));
    }

    const formatDateStr = (d) => {
      if (!d) return '';
      if (typeof d === 'string') return d.split('T')[0];
      const dt = new Date(d);
      return `${dt.getFullYear()}-${String(dt.getMonth() + 1).padStart(2, '0')}-${String(dt.getDate()).padStart(2, '0')}`;
    };

    res.status(200).json({
      success: true,
      count: payments.length,
      receipts: payments.map(p => ({
        id: p.id,
        payment_ref: p.payment_ref,
        receiptNo: p.payment_ref,
        booking_id: p.booking_id,
        client_name: p.client_name,
        clientName: p.client_name,
        staff_name: p.staff_name,
        staffName: p.staff_name,
        total_amount: parseFloat(p.total_amount),
        grandTotal: parseFloat(p.total_amount),
        cash_received: parseFloat(p.cash_received),
        cashReceived: parseFloat(p.cash_received),
        change_amount: parseFloat(p.change_amount),
        change: parseFloat(p.change_amount),
        payment_method: p.payment_method,
        paymentMethod: p.payment_method,
        status: p.status,
        parkShare: p.park_share,
        barangayShare: p.barangay_share,
        guideShare: p.guide_share,
        municipalShare: p.guide_share,  // alias for frontend compatibility
        date: formatDateStr(p.created_at),
        time: p.created_at ? new Date(p.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) : new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
        created_at: p.created_at
      }))
    });
  } catch (error) {
    console.error('Error fetching payments:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch receipts from database', error: error.message });
  }
};

// Fetch Single Receipt by ID or OR Number
exports.getPaymentById = async (req, res) => {
  try {
    const { id } = req.params;

    const [rows] = await db.query('CALL sp_get_payment_by_id(?)', [id]);
    const payments = rows[0] || [];

    if (payments.length === 0) {
      return res.status(404).json({ success: false, message: 'Receipt not found' });
    }

    const formatDateStr = (d) => {
      if (!d) return '';
      if (typeof d === 'string') return d.split('T')[0];
      const dt = new Date(d);
      return `${dt.getFullYear()}-${String(dt.getMonth() + 1).padStart(2, '0')}-${String(dt.getDate()).padStart(2, '0')}`;
    };

    const p = payments[0];
    res.status(200).json({
      success: true,
      receipt: {
        id: p.id,
        payment_ref: p.payment_ref,
        receiptNo: p.payment_ref,
        booking_id: p.booking_id,
        client_name: p.client_name,
        clientName: p.client_name,
        staff_name: p.staff_name,
        staffName: p.staff_name,
        total_amount: parseFloat(p.total_amount),
        grandTotal: parseFloat(p.total_amount),
        cash_received: parseFloat(p.cash_received),
        cashReceived: parseFloat(p.cash_received),
        change_amount: parseFloat(p.change_amount),
        change: parseFloat(p.change_amount),
        payment_method: p.payment_method,
        paymentMethod: p.payment_method,
        status: p.status,
        parkShare: p.park_share,
        barangayShare: p.barangay_share,
        guideShare: p.guide_share,
        municipalShare: p.guide_share,  // alias for frontend compatibility
        date: formatDateStr(p.created_at),
        time: p.created_at ? new Date(p.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) : new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
        created_at: p.created_at
      }
    });
  } catch (error) {
    console.error('Error fetching receipt details:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch receipt details', error: error.message });
  }
};
