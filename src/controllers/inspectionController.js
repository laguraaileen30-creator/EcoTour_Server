const db = require('../config/database');

exports.createInspection = async (req, res, next) => {
  try {
    const { booking_id, type, status, items } = req.body;
    const inspected_by = (req.user.user_id || req.user.id);

    if (!booking_id || !type || !items || !Array.isArray(items)) {
      return res.status(400).json({ success: false, message: 'Invalid inspection data' });
    }

    // Insert inspection
    const [insResult] = await db.query(
      "INSERT INTO facility_inspections (booking_id, type, status, inspected_by) VALUES (?, ?, ?, ?)",
      [booking_id, type, status || 'Clear', inspected_by]
    );
    const inspection_id = insResult.insertId;

    // Insert items
    for (let item of items) {
      await db.query(
        "INSERT INTO inspection_items (inspection_id, item_name, `condition`, notes) VALUES (?, ?, ?, ?)",
        [inspection_id, item.item_name, item.condition, item.notes || '']
      );
    }

    res.status(201).json({
      success: true,
      message: 'Inspection recorded successfully',
      inspection_id
    });
  } catch (err) {
    next(err);
  }
};

exports.getInspectionsByBooking = async (req, res, next) => {
  try {
    const { bookingId } = req.params;

    const [inspections] = await db.query(
      `SELECT fi.*, u.fname, u.lname 
       FROM facility_inspections fi
       JOIN users u ON fi.inspected_by = u.user_id
       WHERE fi.booking_id = ?
       ORDER BY fi.created_at DESC`,
      [bookingId]
    );

    for (let ins of inspections) {
      const [items] = await db.query("SELECT * FROM inspection_items WHERE inspection_id = ?", [ins.id]);
      ins.items = items;
    }

    res.status(200).json({
      success: true,
      inspections
    });
  } catch (err) {
    next(err);
  }
};
