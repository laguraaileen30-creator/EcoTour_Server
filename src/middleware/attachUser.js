const jwt = require('jsonwebtoken');

// Decodes a Bearer token when present and exposes it as req.user (never rejects the request).
// Routes that require a login use requireRole(); this only makes the caller's identity available.
const attachUser = (req, res, next) => {
  const authHeader = req.headers.authorization;
  const token = authHeader && authHeader.startsWith('Bearer ') ? authHeader.split(' ')[1] : null;
  if (token) {
    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET || 'secret');
      req.user = { ...decoded, user_id: decoded.user_id || decoded.id, role: String(decoded.role || '').toLowerCase() };
    } catch (e) {
      req.authError = e.name === 'TokenExpiredError' ? 'expired' : 'invalid';
    }
  }
  next();
};

module.exports = attachUser;
