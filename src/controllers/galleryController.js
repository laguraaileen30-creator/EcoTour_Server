const db = require('../config/database');

exports.getGallery = async (req, res, next) => {
  try {
    const [rows] = await db.query('SELECT image_id as id, title, image as imageUrl, category, uploaded_at FROM gallery ORDER BY image_id ASC');
    res.status(200).json({ success: true, gallery: rows });
  } catch (err) {
    next(err);
  }
};

exports.createGalleryItem = async (req, res, next) => {
  try {
    const { title, image, category = 'Resort' } = req.body;
    const [result] = await db.query('INSERT INTO gallery (title, image, category) VALUES (?, ?, ?)', [title, image, category]);
    res.status(201).json({ success: true, id: result.insertId, message: 'Gallery item stored in database' });
  } catch (err) {
    next(err);
  }
};

exports.deleteGalleryItem = async (req, res, next) => {
  try {
    const { id } = req.params;
    await db.query('DELETE FROM gallery WHERE image_id = ?', [id]);
    res.status(200).json({ success: true, message: 'Gallery item removed from database' });
  } catch (err) {
    next(err);
  }
};
