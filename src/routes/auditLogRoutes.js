const express = require('express');
const requireRole = require('../middleware/requireRole');
const auditLogController = require('../controllers/auditLogController');

const router = express.Router();

router.get('/', requireRole('admin', 'staff'), auditLogController.getAuditLogs);
router.post('/', requireRole(), auditLogController.createAuditLog);

module.exports = router;
