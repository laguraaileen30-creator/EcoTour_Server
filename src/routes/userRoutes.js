const express = require('express');
const { getProfile, updateProfile, getAllUsers, updateUserStatus, sendUserCredentialsEmail } = require('../controllers/userController');
const { register } = require('../controllers/authController');

const router = express.Router();

router.get('/', getAllUsers);
router.post('/', register);
router.post('/:id/send-credentials', sendUserCredentialsEmail);
router.patch('/:id/status', updateUserStatus);
router.put('/:id/status', updateUserStatus);
router.put('/profile', updateProfile);
router.put('/:id/profile', updateProfile);
router.put('/:id', updateProfile);

module.exports = router;
