const express = require('express');
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
router.post('/', createTouristSpot);
router.put('/:id', updateTouristSpot);
router.delete('/:id', deleteTouristSpot);

module.exports = router;
