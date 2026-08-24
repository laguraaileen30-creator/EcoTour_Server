const db = require('../config/database');
const { createSystemNotification } = require('./notificationController');

exports.getAnnouncements = async (req, res, next) => {
  try {
    const [rows] = await db.query('CALL sp_get_announcements()');
    res.status(200).json({ success: true, announcements: rows[0] || [] });
  } catch (err) {
    next(err);
  }
};

exports.createAnnouncement = async (req, res, next) => {
  try {
    const { title, description, category, created_by = 1 } = req.body;
    const [result] = await db.query(
      'CALL sp_create_announcement(?, ?, ?)',
      [title, description || category || 'General', created_by]
    );
    const insertId = result[0] && result[0][0] ? result[0][0].announcement_id : null;

    // Broadcast notification to all portals
    createSystemNotification({
      roleTarget: 'all',
      title: `Announcement: ${title}`,
      message: description || 'A new resort announcement has been posted.',
      type: 'announcement',
      referenceId: String(insertId || '')
    });

    res.status(201).json({ success: true, id: insertId, message: 'Announcement created' });
  } catch (err) {
    next(err);
  }
};

exports.deleteAnnouncement = async (req, res, next) => {
  try {
    const { id } = req.params;
    await db.query('CALL sp_delete_announcement(?)', [id]);
    res.status(200).json({ success: true, message: 'Announcement deleted' });
  } catch (err) {
    next(err);
  }
};
