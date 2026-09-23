const express = require('express');
const requireRole = require('../middleware/requireRole');
const settingController = require('../controllers/settingController');

const router = express.Router();

router.get('/', settingController.getSettings);
router.put('/', requireRole('admin'), settingController.updateSettings);

module.exports = router;
