const express = require('express');
const requireRole = require('../middleware/requireRole');
const { createPayment, getPayments, getPaymentById } = require('../controllers/paymentController');

const router = express.Router();

// Recording money is a cashier (staff/admin) action; reading requires a login
router.post('/', requireRole('admin', 'staff'), createPayment);
router.get('/', requireRole(), getPayments);
router.get('/:id', requireRole(), getPaymentById);

module.exports = router;
