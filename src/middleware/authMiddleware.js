const jwt = require('jsonwebtoken');
const db = require('../config/database');

const authMiddleware = async (req, res, next) => {
  const authHeader = req.headers.authorization;
  const token = authHeader && authHeader.startsWith('Bearer ') ? authHeader.split(' ')[1] : null;

  if (!token) {
    return res.status(401).json({ success: false, code: 'AUTH_REQUIRED', message: 'Please log in to continue.' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'secret');
    const userId = decoded.user_id || decoded.id;
    let name = decoded.name || '';
    let fname = decoded.fname || '';
    let lname = decoded.lname || '';

    if (userId && (!name || !fname)) {
      try {
        const [rows] = await db.query('SELECT fname, lname FROM users WHERE user_id = ?', [userId]);
        if (rows && rows.length > 0) {
          fname = rows[0].fname || '';
          lname = rows[0].lname || '';
          name = `${fname} ${lname}`.trim();
        }
      } catch (dbErr) {
        // non-blocking
      }
    }

    req.user = {
      ...decoded,
      user_id: userId,
      role: String(decoded.role || '').toLowerCase(),
      fname,
      lname,
      name: name || `${fname} ${lname}`.trim() || decoded.user_number || 'Staff'
    };
    next();
  } catch (error) {
    return res.status(401).json({ success: false, code: 'TOKEN_INVALID', message: 'Your session has expired. Please log in again.' });
  }
};

module.exports = authMiddleware;
