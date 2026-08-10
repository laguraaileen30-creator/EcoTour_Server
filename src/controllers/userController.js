const db = require("../config/database");
const bcrypt = require("bcryptjs");
const emailService = require("../services/emailService");

exports.getProfile = async (req, res) => {
  res.status(200).json({
    message: 'Profile endpoint ready',
    user: req.user,
  });
};

exports.updateProfile = async (req, res) => {
  res.status(200).json({ message: 'Profile update endpoint ready' });
};

// GET ALL USERS (Admin / List API with search & filter)
exports.getAllUsers = async (req, res, next) => {
  try {
    const { status, role, search } = req.query;
    let query = "SELECT user_id, user_number, client_no, fname, mname, lname, contact_no, address, gender, role, email, status, account_status, created_by, approved_by, approved_at, rejection_reason, created_at FROM users";
    const params = [];
    const conditions = [];

    if (status) {
      conditions.push("LOWER(status) = LOWER(?)");
      params.push(status);
    }
    if (role) {
      conditions.push("LOWER(role) = LOWER(?)");
      params.push(role);
    }
    if (search) {
      conditions.push("(user_number LIKE ? OR client_no LIKE ? OR fname LIKE ? OR lname LIKE ? OR email LIKE ? OR contact_no LIKE ?)");
      const term = `%${search}%`;
      params.push(term, term, term, term, term, term);
    }

    if (conditions.length > 0) {
      query += " WHERE " + conditions.join(" AND ");
    }

    query += " ORDER BY created_at DESC";

    const [rows] = await db.query(query, params);
    res.status(200).json({
      success: true,
      users: rows,
    });
  } catch (err) {
    next(err);
  }
};

// UPDATE USER STATUS (Approve with Auto-Generated Password, Decline with Reason & Email Notification)
exports.updateUserStatus = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { status, reason, approved_by = "Admin" } = req.body; // 'Approved', 'Rejected', 'Suspended', 'Pending'

    const validStatuses = ["pending", "approved", "rejected", "suspended"];
    const targetStatus = (status || "").trim();

    if (!validStatuses.includes(targetStatus.toLowerCase())) {
      return res.status(400).json({
        success: false,
        message: "Invalid status value. Allowed: Pending, Approved, Rejected, Suspended.",
      });
    }

    const formattedStatus = targetStatus.charAt(0).toUpperCase() + targetStatus.slice(1).toLowerCase();

    // Fetch existing user record first
    const [userRows] = await db.query("SELECT * FROM users WHERE user_id = ? OR user_number = ?", [id, id]);

    if (userRows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "User account not found.",
      });
    }

    const user = userRows[0];
    let generatedPassword = null;

    if (formattedStatus === "Approved") {
      // Auto-generate default password: lastname + firstname + 123 (lowercase, no spaces)
      const fnameStr = (user.fname || "").trim();
      const lnameStr = (user.lname || "").trim();
      generatedPassword = (lnameStr + fnameStr + "123").toLowerCase().replace(/\s+/g, "");

      // Hash password using bcrypt
      const hashedPassword = await bcrypt.hash(generatedPassword, 10);

      await db.query(
        "UPDATE users SET status = ?, account_status = 'Active', password = ?, approved_by = ?, approved_at = NOW() WHERE user_id = ?",
        [formattedStatus, hashedPassword, approved_by, user.user_id]
      );

      // Dispatch Approval Email Notification
      try {
        await emailService.sendApprovalEmail({
          email: user.email,
          name: `${user.fname} ${user.lname}`.trim(),
          userNumber: user.user_number || user.client_no || `CLT-${user.user_id}`,
          password: generatedPassword,
        });
      } catch (eErr) {
        console.warn("Failed to dispatch approval email:", eErr.message);
      }

      return res.status(200).json({
        success: true,
        message: `Account approved successfully. Default password (${generatedPassword}) has been emailed to ${user.email}.`,
        status: formattedStatus,
        account_status: "Active",
        generatedPassword,
      });
    } else if (formattedStatus === "Rejected") {
      const declineReason = reason || "Information provided did not meet verification criteria.";

      await db.query(
        "UPDATE users SET status = ?, account_status = 'Inactive', rejection_reason = ? WHERE user_id = ?",
        [formattedStatus, declineReason, user.user_id]
      );

      // Dispatch Decline Email Notification
      try {
        await emailService.sendDeclineEmail({
          email: user.email,
          name: `${user.fname} ${user.lname}`.trim(),
          reason: declineReason,
        });
      } catch (eErr) {
        console.warn("Failed to dispatch decline email:", eErr.message);
      }

      return res.status(200).json({
        success: true,
        message: `Account declined. Notification email sent to ${user.email}.`,
        status: formattedStatus,
        account_status: "Inactive",
        reason: declineReason,
      });
    } else {
      const accStatus = formattedStatus === "Pending" ? "Inactive" : "Inactive";
      await db.query("UPDATE users SET status = ?, account_status = ? WHERE user_id = ?", [formattedStatus, accStatus, user.user_id]);

      return res.status(200).json({
        success: true,
        message: `Account status updated to ${formattedStatus}.`,
        status: formattedStatus,
        account_status: accStatus,
      });
    }
  } catch (err) {
    next(err);
  }
};
