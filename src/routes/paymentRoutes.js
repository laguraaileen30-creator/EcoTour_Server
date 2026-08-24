const express = require('express');
const { createPayment, getPayments, getPaymentById } = require('../controllers/paymentController');

const router = express.Router();

router.post('/', createPayment);
router.get('/', getPayments);
router.get('/:id', getPaymentById);

module.exports = router;
