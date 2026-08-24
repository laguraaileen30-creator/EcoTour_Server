const db = require('../config/database');

exports.getTouristSpots = async (req, res, next) => {
  try {
    const [rows] = await db.query('SELECT * FROM tourist_spots ORDER BY spot_id ASC');
    res.status(200).json({ success: true, spots: rows });
  } catch (err) {
    next(err);
  }
};

exports.getTouristSpotById = async (req, res, next) => {
  try {
    const { id } = req.params;
    const [rows] = await db.query('SELECT * FROM tourist_spots WHERE spot_id = ?', [id]);
    if (rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Tourist spot not found' });
    }
    res.status(200).json({ success: true, spot: rows[0] });
  } catch (err) {
    next(err);
  }
};

exports.createTouristSpot = async (req, res, next) => {
  try {
    const { spot_name, description, location, entrance_local, entrance_foreign, image, status = 'active' } = req.body;
    const [result] = await db.query(
      'INSERT INTO tourist_spots (spot_name, description, location, entrance_local, entrance_foreign, image, status) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [spot_name, description, location, entrance_local || 0, entrance_foreign || 0, image, status]
    );
    res.status(201).json({ success: true, id: result.insertId, message: 'Tourist spot created' });
  } catch (err) {
    next(err);
  }
};

exports.updateTouristSpot = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { spot_name, description, location, entrance_local, entrance_foreign, image, status } = req.body;
    await db.query(
      'UPDATE tourist_spots SET spot_name = ?, description = ?, location = ?, entrance_local = ?, entrance_foreign = ?, image = ?, status = ? WHERE spot_id = ?',
      [spot_name, description, location, entrance_local, entrance_foreign, image, status, id]
    );
    res.status(200).json({ success: true, message: 'Tourist spot updated' });
  } catch (err) {
    next(err);
  }
};

exports.deleteTouristSpot = async (req, res, next) => {
  try {
    const { id } = req.params;
    await db.query('DELETE FROM tourist_spots WHERE spot_id = ?', [id]);
    res.status(200).json({ success: true, message: 'Tourist spot deleted' });
  } catch (err) {
    next(err);
  }
};
