const jwt = require('jsonwebtoken');
const db = require('../config/database');

const authMiddleware = async (req, res, next) => {
  const authHeader = req.headers.authorization;
  const token = authHeader && authHeader.startsWith('Bearer ') ? authHeader.split(' ')[1] : null;

  if (!token) {
    return res.status(401).json({ success: false, code: 'AUTH_REQUIRED', message: 'Please log in to continue.' });
  }

  let decoded;
  try {
    decoded = jwt.verify(token, process.env.JWT_SECRET || 'secret');
  } catch (error) {
    return res.status(401).json({ success: false, code: 'TOKEN_INVALID', message: 'Your session has expired. Please log in again.' });
  }

  const userId = decoded.user_id || decoded.id;
  if (!userId) {
    return res.status(401).json({ success: false, code: 'TOKEN_INVALID', message: 'Your session is invalid. Please log in again.' });
  }

  try {
    const [rows] = await db.query(
      'SELECT user_id, fname, lname, role FROM users WHERE user_id = ? LIMIT 1',
      [userId]
    );
    if (rows.length === 0) {
      return res.status(401).json({ success: false, code: 'ACCOUNT_NOT_FOUND', message: 'This account no longer exists. Please contact an administrator.' });
    }

    const user = rows[0];
    const fname = user.fname || decoded.fname || '';
    const lname = user.lname || decoded.lname || '';
    req.user = {
      ...decoded,
      user_id: user.user_id,
      role: String(user.role || '').toLowerCase(),
      fname,
      lname,
      name: decoded.name || `${fname} ${lname}`.trim() || decoded.user_number || 'Staff'
    };
    next();
  } catch (error) {
    next(error);
  }
};

module.exports = authMiddleware;
