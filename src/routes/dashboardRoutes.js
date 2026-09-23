const express = require('express');
const requireRole = require('../middleware/requireRole');
const { getDashboard } = require('../controllers/dashboardController');

const router = express.Router();

router.get('/', requireRole('admin', 'staff'), getDashboard);
router.get('/summary', requireRole('admin', 'staff'), getDashboard);

module.exports = router;
