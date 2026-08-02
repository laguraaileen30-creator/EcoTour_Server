const express = require('express');
const {
  createReservation,
  getReservations,
  getReservationById,
} = require('../controllers/reservationController');
const authMiddleware = require('../middleware/authMiddleware');

const router = express.Router();

router.post('/', authMiddleware, createReservation);
router.get('/', authMiddleware, getReservations);
router.get('/:id', authMiddleware, getReservationById);

module.exports = router;
