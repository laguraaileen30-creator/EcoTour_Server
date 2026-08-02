const express = require('express');
const { getDailyRevenue, getMonthlyRevenue } = require('../controllers/reportController');
const authMiddleware = require('../middleware/authMiddleware');

const router = express.Router();

router.get('/daily-revenue', authMiddleware, getDailyRevenue);
router.get('/monthly-revenue', authMiddleware, getMonthlyRevenue);

module.exports = router;
