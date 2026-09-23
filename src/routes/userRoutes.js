const express = require('express');
const requireRole = require('../middleware/requireRole');
const { getProfile, updateProfile, getAllUsers, updateUserStatus, sendUserCredentialsEmail } = require('../controllers/userController');
const { register } = require('../controllers/authController');

const router = express.Router();

// User management is admin/staff only; profile updates are limited to the owner (or admin) in the controller
router.get('/', requireRole('admin', 'staff'), getAllUsers);
router.post('/', requireRole('admin'), register);
router.post('/:id/send-credentials', requireRole('admin'), sendUserCredentialsEmail);
router.patch('/:id/status', requireRole('admin'), updateUserStatus);
router.put('/:id/status', requireRole('admin'), updateUserStatus);
router.put('/profile', requireRole(), updateProfile);
router.put('/:id/profile', requireRole(), updateProfile);
router.put('/:id', requireRole(), updateProfile);

module.exports = router;
