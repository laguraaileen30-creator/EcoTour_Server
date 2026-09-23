const express = require('express');
const requireRole = require('../middleware/requireRole');
const announcementController = require('../controllers/announcementController');

const router = express.Router();

router.get('/', announcementController.getAnnouncements);
router.post('/', requireRole('admin', 'staff'), announcementController.createAnnouncement);
router.delete('/:id', requireRole('admin', 'staff'), announcementController.deleteAnnouncement);

module.exports = router;
