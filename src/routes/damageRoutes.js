const express = require('express');
const router = express.Router();
const damageController = require('../controllers/damageController');
const requireRole = require('../middleware/requireRole');

router.post('/', requireRole('admin', 'staff'), damageController.createDamageReport);
router.get('/', requireRole('admin', 'staff'), damageController.getDamageReports);
router.put('/:id/review', requireRole('admin'), damageController.reviewDamageReport);

module.exports = router;
