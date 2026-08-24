const express = require('express');
const router = express.Router();
const {
  getUserNotifications,
  markAsRead,
  markAllAsRead,
  createNotification
} = require('../controllers/notificationController');

router.get('/', getUserNotifications);
router.post('/', createNotification);
router.put('/read-all', markAllAsRead);
router.put('/:id/read', markAsRead);

module.exports = router;
