const express = require('express');
const router = express.Router();
const inspectionController = require('../controllers/inspectionController');
const requireRole = require('../middleware/requireRole');

router.post('/', requireRole('admin', 'staff'), inspectionController.createInspection);
router.get('/', requireRole('admin', 'staff'), inspectionController.getAllInspections);
router.get('/booking/:bookingId', requireRole('admin', 'staff'), inspectionController.getInspectionsByBooking);

module.exports = router;
