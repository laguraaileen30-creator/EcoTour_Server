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
// NOTE: sp_save_daily_history intentionally NOT created as SP (dynamic table creation
// and the daily_cash_history table is not in the base schema — kept as inline SQL)
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
      saved_by = "Admin"
    } = req.body;

    const recordDate = date || new Date().toISOString().split("T")[0];

    // Ensure table exists
    await db.query(`
      CREATE TABLE IF NOT EXISTS daily_cash_history (
        id INT AUTO_INCREMENT PRIMARY KEY,
        date VARCHAR(20) UNIQUE NOT NULL,
        total_visitors INT DEFAULT 0,
        entrance_revenue DECIMAL(10,2) DEFAULT 0.00,
        service_revenue DECIMAL(10,2) DEFAULT 0.00,
        total_cash_revenue DECIMAL(10,2) DEFAULT 0.00,
        park_share DECIMAL(10,2) DEFAULT 0.00,
        barangay_share DECIMAL(10,2) DEFAULT 0.00,
        municipal_share DECIMAL(10,2) DEFAULT 0.00,
        saved_by VARCHAR(100) DEFAULT 'Admin',
        status VARCHAR(30) DEFAULT 'Frozen & Saved',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    `);

    await db.query(`
      INSERT INTO daily_cash_history 
      (date, total_visitors, entrance_revenue, service_revenue, total_cash_revenue, park_share, barangay_share, municipal_share, saved_by)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
      ON DUPLICATE KEY UPDATE
      total_visitors = VALUES(total_visitors),
      entrance_revenue = VALUES(entrance_revenue),
      service_revenue = VALUES(service_revenue),
      total_cash_revenue = VALUES(total_cash_revenue),
      park_share = VALUES(park_share),
      barangay_share = VALUES(barangay_share),
      municipal_share = VALUES(municipal_share),
      saved_by = VALUES(saved_by)
    `, [recordDate, total_visitors, entrance_revenue, service_revenue, total_cash_revenue, park_share, barangay_share, municipal_share, saved_by]);

    // Record audit log via SP
    await db.query(
      "CALL sp_create_audit_log(?, ?, ?)",
      [null, 'DAILY_CASH_SAVED', `Admin (${saved_by}) saved & froze official Daily Cash Computation for ${recordDate} - Total Cash: ${total_cash_revenue}`]
    );

    res.status(200).json({
      success: true,
      message: `Daily cash computation history for ${recordDate} saved & frozen in database successfully.`,
      data: {
        date: recordDate,
        total_visitors,
        total_cash_revenue,
        saved_by
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
    await db.query(`
      CREATE TABLE IF NOT EXISTS daily_cash_history (
        id INT AUTO_INCREMENT PRIMARY KEY,
        date VARCHAR(20) UNIQUE NOT NULL,
        total_visitors INT DEFAULT 0,
        entrance_revenue DECIMAL(10,2) DEFAULT 0.00,
        service_revenue DECIMAL(10,2) DEFAULT 0.00,
        total_cash_revenue DECIMAL(10,2) DEFAULT 0.00,
        park_share DECIMAL(10,2) DEFAULT 0.00,
        barangay_share DECIMAL(10,2) DEFAULT 0.00,
        municipal_share DECIMAL(10,2) DEFAULT 0.00,
        saved_by VARCHAR(100) DEFAULT 'Admin',
        status VARCHAR(30) DEFAULT 'Frozen & Saved',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    `);

    const [rows] = await db.query(`SELECT * FROM daily_cash_history ORDER BY date DESC`);
    res.status(200).json({ success: true, history: rows });
  } catch (err) {
    console.error("Error fetching saved daily cash history:", err);
    res.status(500).json({ success: false, message: "Failed to fetch saved daily cash history", error: err.message });
  }
};
