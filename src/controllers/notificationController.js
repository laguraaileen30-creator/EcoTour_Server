const db = require('../config/database');

const notificationScopeSql = `(
  user_id = ?
  OR (
    user_id IS NULL
    AND (
      CONVERT(role_target USING utf8mb4) COLLATE utf8mb4_unicode_ci =
        _utf8mb4'all' COLLATE utf8mb4_unicode_ci
      OR LOWER(CONVERT(role_target USING utf8mb4)) COLLATE utf8mb4_unicode_ci =
        LOWER(CONVERT(? USING utf8mb4)) COLLATE utf8mb4_unicode_ci
    )
  )
)`;

/**
 * GET /api/v1/notifications
 * Fetches notifications for current user/role
 */
exports.getUserNotifications = async (req, res, next) => {
  try {
    // Notifications are always read for the logged-in user; only admins may inspect another user/role
    const isAdmin = String(req.user?.role || '').toLowerCase() === 'admin';
    const userId = (isAdmin && req.query.user_id) || req.user?.user_id || req.user?.id || 0;
    const role = ((isAdmin && req.query.role) || req.user?.role || 'client').toLowerCase();

    const [[notifications], [countRows]] = await Promise.all([
      db.query(
        `SELECT id, user_id, role_target, title, message, type,
                reference_id, is_read, created_at
         FROM notifications
         WHERE ${notificationScopeSql}
         ORDER BY is_read ASC, created_at DESC
         LIMIT 50`,
        [userId, role]
      ),
      db.query(
        `SELECT COUNT(*) AS unread_count
         FROM notifications
         WHERE is_read = 0 AND ${notificationScopeSql}`,
        [userId, role]
      ),
    ]);
    const unreadCount = countRows[0]?.unread_count || 0;

    res.status(200).json({
      success: true,
      unreadCount,
      notifications,
    });
  } catch (err) {
    next(err);
  }
};

/**
 * PUT /api/v1/notifications/:id/read
 * Mark single notification as read
 */
exports.markAsRead = async (req, res, next) => {
  try {
    const { id } = req.params;
    const userId = req.body.user_id || req.user?.user_id || req.user?.id || 0;
    const role = (req.body.role || req.user?.role || 'client').toLowerCase();

    const [result] = await db.query(
      'CALL sp_mark_notification_as_read(?, ?, ?, 0)',
      [id, userId, role]
    );

    res.status(200).json({
      success: true,
      message: 'Notification marked as read',
      affectedRows: result[0]?.[0]?.affected_rows || 0,
    });
  } catch (err) {
    next(err);
  }
};

/**
 * PUT /api/v1/notifications/read-all
 * Mark all notifications as read for this user/role
 */
exports.markAllAsRead = async (req, res, next) => {
  try {
    const userId = req.body.user_id || req.user?.user_id || req.user?.id || 0;
    const role = (req.body.role || req.user?.role || 'client').toLowerCase();

    const [result] = await db.query(
      `UPDATE notifications
       SET is_read = 1
       WHERE is_read = 0 AND ${notificationScopeSql}`,
      [userId, role]
    );

    res.status(200).json({
      success: true,
      message: 'All notifications marked as read',
      affectedRows: result.affectedRows || 0,
    });
  } catch (err) {
    next(err);
  }
};

/**
 * POST /api/v1/notifications
 * Create a new notification (API route or internal helper)
 */
exports.createNotification = async (req, res, next) => {
  try {
    const { user_id = null, role_target = 'all', title, message, type = 'general', reference_id = null } = req.body;

    if (!title || !message) {
      return res.status(400).json({ success: false, message: 'Title and message are required' });
    }

    const [result] = await db.query(
      'CALL sp_create_notification(?, ?, ?, ?, ?, ?)',
      [user_id, role_target, title, message, type, reference_id]
    );

    const notificationId = result[0]?.[0]?.notification_id || null;

    res.status(201).json({
      success: true,
      message: 'Notification created successfully',
      notification_id: notificationId,
    });
  } catch (err) {
    next(err);
  }
};

/**
 * Helper to dispatch notification internally from other controllers
 */
exports.createSystemNotification = async ({ userId = null, roleTarget = 'all', title, message, type = 'general', referenceId = null }) => {
  try {
    await db.query(
      'CALL sp_create_notification(?, ?, ?, ?, ?, ?)',
      [userId, roleTarget, title, message, type, referenceId]
    );
  } catch (err) {
    console.warn('[Notification] Failed to create notification:', err.message);
  }
};
