const express = require('express');
const requireRole = require('../middleware/requireRole');
const { getPackages, getPackageById, createPackage, updatePackage, updatePackageStatus, deletePackage } = require('../controllers/packageController');

const router = express.Router();

router.get('/', getPackages);
router.get('/:id', getPackageById);
router.post('/', requireRole('admin'), createPackage);
router.put('/:id', requireRole('admin'), updatePackage);
router.patch('/:id/status', requireRole('admin'), updatePackageStatus);
router.delete('/:id', requireRole('admin'), deletePackage);

module.exports = router;
