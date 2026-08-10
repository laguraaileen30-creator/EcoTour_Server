const express = require("express");
const { getAllServices, createService, updateService, deleteService } = require("../controllers/serviceController");

const router = express.Router();

router.get("/", getAllServices);
router.post("/", createService);
router.put("/:id", updateService);
router.delete("/:id", deleteService);

module.exports = router;
