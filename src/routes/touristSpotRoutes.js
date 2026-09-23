const express = require('express');
const requireRole = require('../middleware/requireRole');
const {
  getTouristSpots,
  getTouristSpotById,
  createTouristSpot,
  updateTouristSpot,
  deleteTouristSpot
} = require('../controllers/touristSpotController');

const router = express.Router();

router.get('/', getTouristSpots);
router.get('/:id', getTouristSpotById);
router.post('/', requireRole('admin'), createTouristSpot);
router.put('/:id', requireRole('admin'), updateTouristSpot);
router.delete('/:id', requireRole('admin'), deleteTouristSpot);

module.exports = router;
