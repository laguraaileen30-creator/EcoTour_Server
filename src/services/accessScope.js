// Who is calling and what they may see: staff/admin see everything, clients only their own records.
const db = require('../config/database');

const STAFF_ROLES = ['admin', 'staff'];

const getScope = async (req) => {
  const role = String(req.user?.role || '').toLowerCase();
  const userId = req.user?.user_id || req.user?.id || null;
  if (STAFF_ROLES.includes(role)) return { isStaff: true, role, userId, email: null };
  let email = null;
  if (userId) {
    const [rows] = await db.query('SELECT email FROM users WHERE user_id = ?', [userId]);
    email = rows[0]?.email ? String(rows[0].email).toLowerCase() : null;
  }
  return { isStaff: false, role, userId, email };
};

// A booking belongs to a client when it was made with their account or their email
const ownsBooking = (scope, booking) => {
  if (scope.isStaff) return true;
  if (!booking) return false;
  if (scope.userId && booking.user_id && String(booking.user_id) === String(scope.userId)) return true;
  if (scope.email && booking.client_email && String(booking.client_email).toLowerCase() === scope.email) return true;
  return false;
};

module.exports = { getScope, ownsBooking, STAFF_ROLES };
