const express = require('express');
const requireRole = require('../middleware/requireRole');
const {
  getUserNotifications,
  markAsRead,
  markAllAsRead,
  createNotification
} = require('../controllers/notificationController');

const router = express.Router();
router.use(requireRole());

router.get('/', getUserNotifications);
router.post('/', createNotification);
router.put('/read-all', markAllAsRead);
router.put('/:id/read', markAsRead);

module.exports = router;
