const express = require('express');
const {
  createReservation,
  getReservations,
  getReservationById,
  updateReservationStatus,
} = require('../controllers/reservationController');

const router = express.Router();

router.post('/', createReservation);
router.get('/', getReservations);
router.get('/:id', getReservationById);
router.patch('/:id/status', updateReservationStatus);

module.exports = router;

