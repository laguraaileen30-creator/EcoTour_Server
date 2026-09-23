const roleMiddleware = (allowedRoles = []) => {
  const allowed = allowedRoles.map((r) => String(r).toLowerCase());
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ success: false, code: 'AUTH_REQUIRED', message: 'Please log in to continue.' });
    }
    if (allowed.length && !allowed.includes(String(req.user.role || '').toLowerCase())) {
      return res.status(403).json({ success: false, code: 'FORBIDDEN', message: 'You do not have permission to do this.' });
    }
    next();
  };
};

module.exports = roleMiddleware;
