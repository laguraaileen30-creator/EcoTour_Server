const authMiddleware = require('./authMiddleware');
const roleMiddleware = require('./roleMiddleware');

// Usage: router.post('/', requireRole('admin'), handler)
const requireRole = (...roles) => [authMiddleware, roleMiddleware(roles)];

module.exports = requireRole;
