const express = require('express');
const requireRole = require('../middleware/requireRole');
const {
  getDailyRevenue,
  getMonthlyRevenue,
  getCategoryBreakdown,
  saveDailyHistory,
  getSavedDailyHistory,
  acknowledgeDailyHistory
} = require('../controllers/reportController');

const router = express.Router();
router.use(requireRole('admin', 'staff'));

router.get('/', getDailyRevenue);
router.get('/daily-revenue', getDailyRevenue);
router.get('/monthly-revenue', getMonthlyRevenue);
router.get('/categories', getCategoryBreakdown);
router.post('/save-daily-history', saveDailyHistory);
router.get('/saved-daily-history', getSavedDailyHistory);
router.post('/acknowledge-daily-history', requireRole('admin'), acknowledgeDailyHistory);

module.exports = router;
