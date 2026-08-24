const db = require("../config/database");

// GET ALL SERVICES
exports.getAllServices = async (req, res, next) => {
  try {
    const [rows] = await db.query("CALL sp_get_all_services()");
    res.status(200).json({
      success: true,
      services: rows[0] || [],
    });
  } catch (err) {
    next(err);
  }
};

// CREATE SERVICE
exports.createService = async (req, res, next) => {
  try {
    const { service_code, service_name, category, description, price, unit, total_capacity, image_url, status } = req.body;

    if (!service_name || !price) {
      return res.status(400).json({ success: false, message: "Service name and price are required." });
    }

    const code = service_code || `DSVC-${Math.floor(100 + Math.random() * 900)}`;
    const cap = parseInt(total_capacity || 10, 10);

    const [result] = await db.query(
      "CALL sp_create_service(?, ?, ?, ?, ?, ?, ?, ?, ?)",
      [code, service_name, category || "Rental", description || "", price, unit || "unit", cap, image_url || "/src/assets/images/services/cottage.png", status || "Active"]
    );

    const insertId = result[0] && result[0][0] ? result[0][0].service_id : null;

    res.status(201).json({
      success: true,
      message: "Service created successfully",
      service_id: insertId,
    });
  } catch (err) {
    next(err);
  }
};

// UPDATE SERVICE
exports.updateService = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { service_name, category, description, price, unit, total_capacity, available_qty, status } = req.body;

    const [result] = await db.query(
      "CALL sp_update_service(?, ?, ?, ?, ?, ?, ?, ?, ?)",
      [id, service_name || null, category || null, description || null, price || null, unit || null, total_capacity || null, available_qty || null, status || null]
    );

    const affectedRows = result[0] && result[0][0] ? result[0][0].affected_rows : 0;

    if (affectedRows === 0) {
      return res.status(404).json({ success: false, message: "Service not found" });
    }

    res.status(200).json({ success: true, message: "Service updated successfully" });
  } catch (err) {
    next(err);
  }
};

// DELETE SERVICE
exports.deleteService = async (req, res, next) => {
  try {
    const { id } = req.params;
    await db.query("CALL sp_delete_service(?)", [id]);
    res.status(200).json({ success: true, message: "Service deleted successfully" });
  } catch (err) {
    next(err);
  }
};
