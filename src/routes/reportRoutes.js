const express = require('express');
const {
  getDailyRevenue,
  getMonthlyRevenue,
  getCategoryBreakdown,
  saveDailyHistory,
  getSavedDailyHistory
} = require('../controllers/reportController');

const router = express.Router();

router.get('/', getDailyRevenue);
router.get('/daily-revenue', getDailyRevenue);
router.get('/monthly-revenue', getMonthlyRevenue);
router.get('/categories', getCategoryBreakdown);
router.post('/save-daily-history', saveDailyHistory);
router.get('/saved-daily-history', getSavedDailyHistory);

module.exports = router;
