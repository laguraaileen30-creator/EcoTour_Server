const db = require('../config/database');

exports.getSettings = async (req, res, next) => {
  try {
    const [rows] = await db.query('SELECT setting_key, setting_value, description FROM settings');
    const settingsMap = {};
    rows.forEach(r => { settingsMap[r.setting_key] = r.setting_value; });
    res.status(200).json({ success: true, settings: settingsMap, list: rows });
  } catch (err) {
    next(err);
  }
};

exports.updateSettings = async (req, res, next) => {
  try {
    const settingsObj = req.body;
    for (const [key, val] of Object.entries(settingsObj)) {
      if (key && val !== undefined) {
        await db.query(
          'INSERT INTO settings (setting_key, setting_value) VALUES (?, ?) ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value)',
          [key, String(val)]
        );
      }
    }
    res.status(200).json({ success: true, message: 'Settings saved successfully' });
  } catch (err) {
    next(err);
  }
};
