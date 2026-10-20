const db = require("../config/database");

exports.getDailyRevenue = async (req, res, next) => {
  try {
    const [rows] = await db.query("CALL sp_get_daily_revenue_report()");
    res.status(200).json({ success: true, daily_reports: rows[0] || [] });
  } catch (err) {
    next(err);
  }
};

exports.getMonthlyRevenue = async (req, res, next) => {
  try {
    const [rows] = await db.query("CALL sp_get_monthly_revenue_report()");
    res.status(200).json({ success: true, monthly_reports: rows[0] || [] });
  } catch (err) {
    next(err);
  }
};

exports.getCategoryBreakdown = async (req, res, next) => {
  try {
    const [rows] = await db.query(
      `SELECT category, COUNT(*) as total_services, SUM(price) as total_value 
       FROM services 
       GROUP BY category`
    );
    res.status(200).json({ success: true, categories: rows });
  } catch (err) {
    next(err);
  }
};

// Ensure daily_cash_history table exists & save daily tally log
exports.saveDailyHistory = async (req, res, next) => {
  try {
    const {
      date,
      total_visitors = 0,
      entrance_revenue = 0,
      service_revenue = 0,
      total_cash_revenue = 0,
      park_share = 0,
      barangay_share = 0,
      municipal_share = 0,
      saved_by = "Staff Cashier",
      cashier_name = null,
      notes = "",
      status = "Submitted to Admin",
      total_transactions = 0
    } = req.body;

    const recordDate = date || new Date().toISOString().split("T")[0];
    const user = req.user;
    const author = cashier_name || (user?.fname ? `${user.fname} ${user.lname || ''}`.trim() : null) || saved_by || "Staff Cashier";

    // Ensure columns exist
    try {
      await db.query(`ALTER TABLE daily_cash_history ADD COLUMN IF NOT EXISTS notes TEXT NULL`);
      await db.query(`ALTER TABLE daily_cash_history ADD COLUMN IF NOT EXISTS cashier_name VARCHAR(100) NULL`);
      await db.query(`ALTER TABLE daily_cash_history ADD COLUMN IF NOT EXISTS total_transactions INT DEFAULT 0`);
    } catch (_) {}

    await db.query(`
      INSERT INTO daily_cash_history 
      (date, total_visitors, entrance_revenue, service_revenue, total_cash_revenue, park_share, barangay_share, municipal_share, saved_by, cashier_name, notes, status, total_transactions)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ON DUPLICATE KEY UPDATE
      total_visitors = VALUES(total_visitors),
      entrance_revenue = VALUES(entrance_revenue),
      service_revenue = VALUES(service_revenue),
      total_cash_revenue = VALUES(total_cash_revenue),
      park_share = VALUES(park_share),
      barangay_share = VALUES(barangay_share),
      municipal_share = VALUES(municipal_share),
      saved_by = VALUES(saved_by),
      cashier_name = VALUES(cashier_name),
      notes = VALUES(notes),
      status = VALUES(status),
      total_transactions = VALUES(total_transactions)
    `, [recordDate, total_visitors, entrance_revenue, service_revenue, total_cash_revenue, park_share, barangay_share, municipal_share, author, author, notes, status, total_transactions]);

    // Record audit log via SP
    try {
      await db.query(
        "CALL sp_create_audit_log(?, ?, ?)",
        [user?.user_id || user?.id || null, 'DAILY_TALLY_SUBMITTED', `Staff Cashier (${author}) submitted Daily Sales Tally for ${recordDate} - Total Cash: ₱${total_cash_revenue} (${total_visitors} visitors)`]
      );
    } catch (auditErr) {
      console.warn("Audit log note:", auditErr.message);
    }

    res.status(200).json({
      success: true,
      message: `Daily sales tally for ${recordDate} submitted successfully to Admin.`,
      data: {
        date: recordDate,
        total_visitors,
        total_cash_revenue,
        saved_by: author,
        cashier_name: author,
        notes,
        status
      }
    });
  } catch (err) {
    console.error("Error saving daily cash history:", err);
    res.status(500).json({ success: false, message: "Failed to save daily cash history", error: err.message });
  }
};

// Fetch all saved daily cash computation history records
exports.getSavedDailyHistory = async (req, res, next) => {
  try {
    const [rows] = await db.query(`SELECT * FROM daily_cash_history ORDER BY date DESC, created_at DESC`);
    res.status(200).json({ success: true, history: rows });
  } catch (err) {
    console.error("Error fetching saved daily cash history:", err);
    res.status(500).json({ success: false, message: "Failed to fetch saved daily cash history", error: err.message });
  }
};

// Admin acknowledges / verifies staff daily tally
exports.acknowledgeDailyHistory = async (req, res, next) => {
  try {
    const { id, date } = req.body;
    const user = req.user;
    const adminName = user?.fname ? `${user.fname} ${user.lname || ''}`.trim() : (user?.name || 'Admin');

    await db.query(
      `UPDATE daily_cash_history 
       SET status = 'Verified & Acknowledged',
           saved_by = CONCAT(saved_by, ' (Verified by ', ?, ')')
       WHERE id = ? OR date = ?`,
      [adminName, id || 0, date || '']
    );

    // Record audit log
    try {
      await db.query(
        "CALL sp_create_audit_log(?, ?, ?)",
        [user?.user_id || user?.id || null, 'DAILY_TALLY_ACKNOWLEDGED', `Admin (${adminName}) acknowledged & verified Daily Sales Tally for ${date || id}`]
      );
    } catch (e) {}

    res.status(200).json({
      success: true,
      message: `Daily sales tally for ${date || id} verified and acknowledged by ${adminName}.`
    });
  } catch (err) {
    console.error("Error acknowledging daily history:", err);
    res.status(500).json({ success: false, message: "Failed to acknowledge daily tally", error: err.message });
  }
};
