const express = require('express');
const requireRole = require('../middleware/requireRole');
const { getGallery, createGalleryItem } = require('../controllers/galleryController');

const router = express.Router();

router.get('/', getGallery);
router.post('/', requireRole('admin', 'staff'), createGalleryItem);

module.exports = router;
