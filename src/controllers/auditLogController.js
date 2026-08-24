const db = require('../config/database');

exports.getAuditLogs = async (req, res, next) => {
  try {
    const [rows] = await db.query('CALL sp_get_audit_logs()');
    res.status(200).json({ success: true, logs: rows[0] || [] });
  } catch (err) {
    next(err);
  }
};

exports.createAuditLog = async (req, res, next) => {
  try {
    const { user_id, action, description } = req.body;
    const [result] = await db.query(
      'CALL sp_create_audit_log(?, ?, ?)',
      [user_id || null, action, description]
    );
    const logId = result[0] && result[0][0] ? result[0][0].log_id : null;
    res.status(201).json({ success: true, log_id: logId });
  } catch (err) {
    next(err);
  }
};
