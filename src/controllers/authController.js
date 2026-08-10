const jwt = require("jsonwebtoken");
const bcrypt = require("bcryptjs");
const db = require("../config/database");

// ================= LOGIN =================

exports.login = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: "Email and password are required",
      });
    }

    // Find user by email
    const [rows] = await db.query(
      "SELECT * FROM users WHERE email = ?",
      [email]
    );

    if (rows.length === 0) {
      return res.status(401).json({
        success: false,
        message: "Invalid email or password",
      });
    }

    const user = rows[0];

    // Secure password verification
    let isMatch = false;
    let needsHashUpgrade = false;

    if (user.password && (user.password.startsWith("$2a$") || user.password.startsWith("$2b$"))) {
      isMatch = await bcrypt.compare(password, user.password);
    } else {
      isMatch = password === user.password;
      needsHashUpgrade = isMatch;
    }

    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: "Invalid email or password",
      });
    }

    // Auto-upgrade legacy plaintext password to bcrypt hash in DB
    if (needsHashUpgrade) {
      try {
        const newHashed = await bcrypt.hash(password, 10);
        await db.query("UPDATE users SET password = ? WHERE user_id = ?", [newHashed, user.user_id]);
      } catch (upgErr) {
        console.warn("Failed to auto-upgrade legacy password hash:", upgErr.message);
      }
    }

    // Validate account approval and active status
    const normalizedStatus = (user.status || "").toLowerCase();
    const normalizedAccStatus = (user.account_status || "").toLowerCase();

    if (normalizedStatus === "pending") {
      return res.status(403).json({
        success: false,
        message: "Your account is waiting for administrator approval. Please check your email for updates.",
      });
    }

    if (normalizedStatus === "rejected") {
      const reasonMsg = user.rejection_reason ? ` Reason: "${user.rejection_reason}"` : "";
      return res.status(403).json({
        success: false,
        message: `Your account registration was denied by the administrator.${reasonMsg}`,
      });
    }

    if (normalizedStatus === "suspended") {
      return res.status(403).json({
        success: false,
        message: "Your account has been suspended. Please contact management.",
      });
    }

    if (normalizedStatus !== "approved" || (normalizedAccStatus && normalizedAccStatus !== "active")) {
      return res.status(403).json({
        success: false,
        message: "Account status is inactive or not approved for login.",
      });
    }

    const token = jwt.sign(
      {
        id: user.user_id,
        role: user.role,
        user_number: user.user_number || user.client_no,
      },
      process.env.JWT_SECRET || "secret",
      {
        expiresIn: process.env.JWT_EXPIRES_IN || "7d",
      }
    );

    res.status(200).json({
      success: true,
      token,
      user: {
        user_id: user.user_id,
        user_number: user.user_number || user.client_no,
        fname: user.fname,
        mname: user.mname,
        lname: user.lname,
        email: user.email,
        contact_no: user.contact_no,
        address: user.address,
        gender: user.gender,
        role: user.role,
        status: user.status,
        account_status: user.account_status || "Active",
        created_by: user.created_by || "Self-Registered",
      },
    });
  } catch (err) {
    next(err);
  }
};

// ================= REGISTER (PERSONAL PROFILING) =================

exports.register = async (req, res, next) => {
  try {
    const {
      user_number,
      client_no,
      fname,
      mname,
      lname,
      contact_no,
      address,
      gender,
      role = "client",
      email,
      password,
      status,
      created_by,
    } = req.body;

    if (!fname || !lname || !email || !contact_no || !address || !gender) {
      return res.status(400).json({
        success: false,
        message: "Please fill in all required personal profiling fields.",
      });
    }

    const [exist] = await db.query(
      "SELECT * FROM users WHERE email=?",
      [email]
    );

    if (exist.length > 0) {
      return res.status(400).json({
        success: false,
        message: "Email address is already registered in the system.",
      });
    }

    // Auto-generate User Number if not provided
    const currentYear = new Date().getFullYear();
    const prefix = role.toLowerCase() === "staff" ? "STF" : role.toLowerCase() === "admin" ? "ADM" : "CLT";
    
    let finalUserNumber = user_number || client_no;
    if (!finalUserNumber) {
      const [countRow] = await db.query("SELECT COUNT(*) AS total FROM users WHERE role = ?", [role]);
      const seq = (countRow[0].total + 1).toString().padStart(6, "0");
      finalUserNumber = `${prefix}-${currentYear}-${seq}`;
    }

    // Auto-generate default password: lastname + firstname + 123 in lowercase
    const rawPassword = password || `${(lname || "").trim()}${(fname || "").trim()}123`.toLowerCase().replace(/\s+/g, "");
    
    // Hash password securely with bcrypt
    const hashedPassword = await bcrypt.hash(rawPassword, 10);

    // Initial status: Client self-register defaults to 'Pending' & 'Inactive'. Admin creation defaults to 'Approved' & 'Active'.
    const finalStatus = status ? status : (role.toLowerCase() === "client" ? "Pending" : "Approved");
    const finalAccountStatus = finalStatus === "Approved" ? "Active" : "Inactive";
    const finalCreatedBy = created_by || "Self-Registered";

    // Insert user into database
    const [cols] = await db.query("SHOW COLUMNS FROM users LIKE 'created_by'");
    const hasCreatedBy = cols.length > 0;

    if (hasCreatedBy) {
      await db.query(
        `INSERT INTO users
        (user_number, client_no, fname, mname, lname, contact_no, address, gender, role, email, password, status, account_status, created_by)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          finalUserNumber,
          finalUserNumber,
          fname,
          mname || "",
          lname,
          contact_no,
          address,
          gender,
          role,
          email,
          hashedPassword,
          finalStatus,
          finalAccountStatus,
          finalCreatedBy,
        ]
      );
    } else {
      await db.query(
        `INSERT INTO users
        (user_number, client_no, fname, mname, lname, contact_no, address, gender, role, email, password, status)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          finalUserNumber,
          finalUserNumber,
          fname,
          mname || "",
          lname,
          contact_no,
          address,
          gender,
          role,
          email,
          hashedPassword,
          finalStatus,
        ]
      );
    }

    res.status(201).json({
      success: true,
      message: `Personal profiling registration submitted successfully. Account status is ${finalStatus}.`,
      user_number: finalUserNumber,
      client_no: finalUserNumber,
      status: finalStatus,
      account_status: finalAccountStatus,
      created_by: finalCreatedBy,
      generatedPassword: rawPassword,
    });
  } catch (err) {
    next(err);
  }
};

// ================= LOGOUT =================

exports.logout = (req, res) => {
  res.json({
    success: true,
    message: "Logout successful",
  });
};