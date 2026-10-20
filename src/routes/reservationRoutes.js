const express = require('express');
const requireRole = require('../middleware/requireRole');
const {
  createReservation,
  getReservations,
  getReservationById,
  updateReservationStatus,
  addServicesToReservation,
  quoteReservation,
  getPricing,
  caterReservation,
  uncaterReservation,
} = require('../controllers/reservationController');
const { requestConfirmation, respondByToken, clientDecision, recordPayment } = require('../controllers/reservationLifecycleController');

const router = express.Router();

// Public: pricing, quotes and new reservations (landing page / client portal)
router.get('/pricing', getPricing);
router.post('/quote', quoteReservation);
router.post('/', createReservation);
// One-time Continue / Cancel link from the confirmation email (the token is the credential)
router.get('/confirm/:token', respondByToken);

// Listing contains personal data: staff/admin see all, clients see only their own (filtered in the controller)
router.get('/', requireRole(), getReservations);
router.get('/:id', requireRole(), getReservationById);
router.patch('/:id/status', requireRole(), updateReservationStatus);
router.post('/:id/addons', requireRole('admin', 'staff'), addServicesToReservation);
// Reservation fee + 24-hour confirmation
router.post('/:id/request-confirmation', requireRole('admin', 'staff'), requestConfirmation);
router.post('/:id/decision', requireRole(), clientDecision);
router.post('/:id/payments', requireRole('admin', 'staff'), recordPayment);
router.post('/:id/cater', requireRole('admin', 'staff'), caterReservation);
router.post('/:id/uncater', requireRole('admin', 'staff'), uncaterReservation);

module.exports = router;
