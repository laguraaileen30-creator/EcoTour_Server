const express = require('express');
const path = require('path');
const fs = require('fs');
const multer = require('multer');
const requireRole = require('../middleware/requireRole');

const UPLOAD_DIR = path.join(__dirname, '..', '..', 'uploads');
fs.mkdirSync(UPLOAD_DIR, { recursive: true });

const ALLOWED = { 'image/png': '.png', 'image/jpeg': '.jpg', 'image/webp': '.webp', 'image/gif': '.gif' };

const upload = multer({
  storage: multer.diskStorage({
    destination: UPLOAD_DIR,
    filename: (req, file, cb) => cb(null, `${Date.now()}-${Math.round(Math.random() * 1e6)}${ALLOWED[file.mimetype]}`),
  }),
  limits: { fileSize: 5 * 1024 * 1024, files: 10 },
  fileFilter: (req, file, cb) => cb(ALLOWED[file.mimetype] ? null : new Error('Only PNG, JPG, WEBP or GIF images are allowed'), !!ALLOWED[file.mimetype]),
});

const router = express.Router();

// POST /api/v1/uploads (admin) multipart field "images" (1-10 files) -> [{ url }]
router.post('/', requireRole('admin'), (req, res) => {
  upload.array('images', 10)(req, res, (err) => {
    if (err) return res.status(400).json({ success: false, message: err.message });
    const files = (req.files || []).map((f) => ({ url: `/uploads/${f.filename}`, name: f.originalname, size: f.size }));
    if (!files.length) return res.status(400).json({ success: false, message: 'No image uploaded' });
    res.status(201).json({ success: true, data: files });
  });
});

module.exports = { uploadRouter: router, UPLOAD_DIR };
