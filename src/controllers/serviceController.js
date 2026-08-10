const db = require("../config/database");

// GET ALL SERVICES
exports.getAllServices = async (req, res, next) => {
  try {
    const [rows] = await db.query("SELECT * FROM services ORDER BY service_code ASC");
    res.status(200).json({
      success: true,
      services: rows,
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
      `INSERT INTO services (service_code, service_name, category, description, price, unit, total_capacity, available_qty, image_url, status)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [code, service_name, category || "Rental", description || "", price, unit || "unit", cap, cap, image_url || "/src/assets/images/services/cottage.png", status || "Active"]
    );

    res.status(201).json({
      success: true,
      message: "Service created successfully",
      service_id: result.insertId,
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
      `UPDATE services SET service_name=?, category=?, description=?, price=?, unit=?, total_capacity=?, available_qty=?, status=?
       WHERE service_id=? OR id=?`,
      [service_name, category, description, price, unit, total_capacity, available_qty, status, id, id]
    );

    if (result.affectedRows === 0) {
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
    await db.query("DELETE FROM services WHERE service_id=? OR id=?", [id, id]);
    res.status(200).json({ success: true, message: "Service deleted successfully" });
  } catch (err) {
    next(err);
  }
};
