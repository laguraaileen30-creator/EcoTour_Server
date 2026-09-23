const express = require("express");
const requireRole = require("../middleware/requireRole");
const {
  getAllServices,
  getServiceById,
  createService,
  updateService,
  updateServiceStatus,
  getUpcomingReservations,
  deleteService,
} = require("../controllers/serviceController");
const { availabilityCalendar } = require("../controllers/availabilityController");

const router = express.Router();

router.get("/", getAllServices);
router.get("/:id", getServiceById);
router.get("/:id/availability", (req, res) => {
  req.query.serviceId = req.params.id;
  if (req.query.date && !req.query.from) { req.query.from = req.query.date; req.query.days = req.query.days || 1; }
  return availabilityCalendar(req, res);
});
router.get("/:id/upcoming", requireRole("admin", "staff"), getUpcomingReservations);

router.post("/", requireRole("admin"), createService);
router.put("/:id", requireRole("admin"), updateService);
router.patch("/:id/status", requireRole("admin"), updateServiceStatus);
router.delete("/:id", requireRole("admin"), deleteService);

module.exports = router;
