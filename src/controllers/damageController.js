const db = require('../config/database');

exports.createDamageReport = async (req, res, next) => {
  try {
    const {
      booking_id, inspection_id, item_name, damage_type, description,
      evidence_url, repair_cost, labor_cost, recommended_fee
    } = req.body;
    
    const reported_by = (req.user?.user_id || req.user?.id || 1);

    if (!booking_id || !item_name || !damage_type || !description) {
      return res.status(400).json({ success: false, message: 'Missing required damage report fields' });
    }

    // Ensure valid integer booking_id
    let validBookingId = parseInt(booking_id, 10);
    if (!validBookingId || isNaN(validBookingId)) {
      const [bRows] = await db.query("SELECT id FROM bookings WHERE booking_number = ? LIMIT 1", [String(booking_id)]);
      if (bRows.length > 0) validBookingId = bRows[0].id;
      else validBookingId = 1;
    }

    // Ensure valid inspection_id exists in facility_inspections for foreign key
    let validInspectionId = inspection_id ? parseInt(inspection_id, 10) : null;
    if (validInspectionId) {
      const [checkIns] = await db.query("SELECT id FROM facility_inspections WHERE id = ?", [validInspectionId]);
      if (checkIns.length === 0) validInspectionId = null;
    }

    if (!validInspectionId) {
      // Automatically create an inspection record for this booking so FK is always satisfied
      const [newIns] = await db.query(
        "INSERT INTO facility_inspections (booking_id, type, status, inspected_by) VALUES (?, 'Checkout', 'Damage Found', ?)",
        [validBookingId, reported_by]
      );
      validInspectionId = newIns.insertId;
      try {
        await db.query(
          "INSERT INTO inspection_items (inspection_id, item_name, `condition`, notes) VALUES (?, ?, 'Damaged', ?)",
          [validInspectionId, item_name, `${damage_type}: ${description}`]
        );
      } catch (_) {}
    }

    const [result] = await db.query(
      `INSERT INTO damage_reports 
       (booking_id, inspection_id, item_name, damage_type, description, evidence_url, repair_cost, labor_cost, recommended_fee, reported_by)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        validBookingId, validInspectionId, item_name, damage_type, description, evidence_url || null,
        repair_cost || 0, labor_cost || 0, recommended_fee || 0, reported_by
      ]
    );

    res.status(201).json({
      success: true,
      message: 'Damage report submitted and is pending review',
      report_id: result.insertId,
      inspection_id: validInspectionId
    });
  } catch (err) {
    next(err);
  }
};

exports.getDamageReports = async (req, res, next) => {
  try {
    const [reports] = await db.query(
      `SELECT dr.*, b.booking_number, b.client_name, 
              COALESCE(CONCAT(u.fname, ' ', u.lname), u.username, 'Staff Cashier') as staff_fname,
              '' as staff_lname,
              COALESCE(CONCAT(adm.fname, ' ', adm.lname), adm.username, 'Admin Management') as approver_name
       FROM damage_reports dr
       LEFT JOIN bookings b ON dr.booking_id = b.id
       LEFT JOIN users u ON dr.reported_by = u.user_id
       LEFT JOIN users adm ON dr.approved_by = adm.user_id
       ORDER BY dr.created_at DESC`
    );

    res.status(200).json({ success: true, reports });
  } catch (err) {
    next(err);
  }
};

exports.reviewDamageReport = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { status, final_fee } = req.body;
    const approved_by = (req.user?.user_id || req.user?.id || 1);

    if (!['Approved', 'Rejected', 'Waived'].includes(status)) {
      return res.status(400).json({ success: false, message: 'Invalid status' });
    }

    const [reportRows] = await db.query("SELECT * FROM damage_reports WHERE id = ?", [id]);
    if (reportRows.length === 0) return res.status(404).json({ success: false, message: 'Report not found' });
    
    const report = reportRows[0];
    if (report.status !== 'Pending') {
      return res.status(400).json({ success: false, message: 'Report is already reviewed' });
    }

    const feeToCharge = status === 'Approved' ? (final_fee !== undefined ? final_fee : report.recommended_fee) : 0;

    await db.query(
      "UPDATE damage_reports SET status = ?, final_fee = ?, approved_by = ? WHERE id = ?",
      [status, feeToCharge, approved_by, id]
    );

    // If approved and there's a fee, add to booking
    if (status === 'Approved' && feeToCharge > 0) {
      // Add a line item to booking_items
      await db.query(
        `INSERT INTO booking_items (booking_id, service_id, service_name, unit_price, quantity, subtotal, item_type)
         VALUES (?, 0, ?, ?, 1, ?, 'DAMAGE_FEE')`,
        [report.booking_id, `Damage Fee - ${report.item_name}`, feeToCharge, feeToCharge]
      );

      // Update total_amount in bookings
      await db.query(
        "UPDATE bookings SET total_amount = total_amount + ? WHERE id = ?",
        [feeToCharge, report.booking_id]
      );
    }

    res.status(200).json({
      success: true,
      message: `Damage report ${status.toLowerCase()} successfully`,
      fee_charged: feeToCharge
    });
  } catch (err) {
    next(err);
  }
};
