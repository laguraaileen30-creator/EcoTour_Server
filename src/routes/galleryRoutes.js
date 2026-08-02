const express = require('express');
const { getGallery, createGalleryItem } = require('../controllers/galleryController');
const authMiddleware = require('../middleware/authMiddleware');

const router = express.Router();

router.get('/', getGallery);
router.post('/', authMiddleware, createGalleryItem);

module.exports = router;
