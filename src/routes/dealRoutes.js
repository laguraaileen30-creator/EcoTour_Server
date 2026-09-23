const express = require('express');
const requireRole = require('../middleware/requireRole');
const { getDeals, getActivePromotions, createDeal, updateDeal, updateDealStatus, deleteDeal } = require('../controllers/dealController');

// Mounted at /api/v1/deals
const router = express.Router();
router.get('/', getDeals);
router.post('/', requireRole('admin'), createDeal);
router.put('/:id', requireRole('admin'), updateDeal);
router.patch('/:id/status', requireRole('admin'), updateDealStatus);
router.delete('/:id', requireRole('admin'), deleteDeal);

// Mounted at /api/v1/promotions (currently running deals)
const promotionRouter = express.Router();
promotionRouter.get('/', getActivePromotions);

module.exports = { dealRouter: router, promotionRouter };
