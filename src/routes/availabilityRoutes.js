const express = require('express');
const requireRole = require('../middleware/requireRole');
const {
  checkAvailability,
  checkCart,
  availabilityCalendar,
  listResources,
  facilityMap,
  getRequirements,
  assignResource,
  releaseAssignment,
  createUnit,
  updateUnit,
  deleteUnit,
} = require('../controllers/availabilityController');

const router = express.Router();

// Public: date-based availability (landing page, client booking, services pages)
router.get('/', checkAvailability);
router.get('/calendar', availabilityCalendar);
router.post('/check', checkCart);

// Staff / admin: numbered facility units and assignment
router.get('/resources', requireRole('staff', 'admin'), listResources);
router.get('/facilities', requireRole('staff', 'admin'), facilityMap);
router.get('/requirements/:bookingId', requireRole('staff', 'admin'), getRequirements);
router.post('/assign', requireRole('staff', 'admin'), assignResource);
router.delete('/assign/:assignmentId', requireRole('staff', 'admin'), releaseAssignment);

// Admin only: manage facility units
router.post('/facilities', requireRole('admin'), createUnit);
router.put('/facilities/:id', requireRole('admin'), updateUnit);
router.delete('/facilities/:id', requireRole('admin'), deleteUnit);

module.exports = router;
