const jwt = require('jsonwebtoken');

const authMiddleware = (req, res, next) => {
  const authHeader = req.headers.authorization;
  const token = authHeader && authHeader.startsWith('Bearer ') ? authHeader.split(' ')[1] : null;

  if (!token) {
    return res.status(401).json({ success: false, code: 'AUTH_REQUIRED', message: 'Please log in to continue.' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'secret');
    req.user = { ...decoded, user_id: decoded.user_id || decoded.id, role: String(decoded.role || '').toLowerCase() };
    next();
  } catch (error) {
    return res.status(401).json({ success: false, code: 'TOKEN_INVALID', message: 'Your session has expired. Please log in again.' });
  }
};

module.exports = authMiddleware;
