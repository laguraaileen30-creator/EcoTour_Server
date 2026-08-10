const express = require('express');
const { getProfile, updateProfile, getAllUsers, updateUserStatus } = require('../controllers/userController');
const { register } = require('../controllers/authController');
const authMiddleware = require('../middleware/authMiddleware');

const router = express.Router();

router.get('/', getAllUsers);
router.post('/', register);
router.patch('/:id/status', updateUserStatus);
router.put('/:id/status', updateUserStatus);
router.get('/me', authMiddleware, getProfile);
router.put('/me', authMiddleware, updateProfile);

module.exports = router;

