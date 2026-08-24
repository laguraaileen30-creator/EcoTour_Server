const db = require('../config/database');

/**
 * GET /api/v1/notifications
 * Fetches notifications for current user/role
 */
exports.getUserNotifications = async (req, res, next) => {
  try {
    const userId = req.query.user_id || req.user?.user_id || req.user?.id || 0;
    const role = (req.query.role || req.user?.role || 'client').toLowerCase();

    // Call stored procedure
    const [results] = await db.query('CALL sp_get_user_notifications(?, ?)', [userId, role]);

    const notifications = results[0] || [];
    const unreadCount = results[1] && results[1][0] ? results[1][0].unread_count : 0;

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
      'CALL sp_mark_notification_as_read(NULL, ?, ?, 1)',
      [userId, role]
    );

    res.status(200).json({
      success: true,
      message: 'All notifications marked as read',
      affectedRows: result[0]?.[0]?.affected_rows || 0,
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
