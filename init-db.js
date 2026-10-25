require("dotenv").config();
const mysql = require("mysql2/promise");
const bcrypt = require("bcryptjs");

async function initDatabase() {
  let connection;
  try {
    if (process.env.NODE_ENV === "production") {
      throw new Error("Refusing to run init-db.js in production because it drops and recreates tables.");
    }

    const requiredConfig = ["DB_HOST", "DB_PORT", "DB_USER", "DB_PASSWORD", "DB_NAME"];
    const missingConfig = requiredConfig.filter((key) => !process.env[key]);
    if (missingConfig.length > 0) {
      throw new Error(`Missing database configuration: ${missingConfig.join(", ")}`);
    }

    connection = await mysql.createConnection({
      host: process.env.DB_HOST,
      port: Number(process.env.DB_PORT),
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME,
    });

    console.log("Connected to MySQL server.");

    await connection.query("SET FOREIGN_KEY_CHECKS = 0");

    // 1. TABLE: USERS
    const [userTables] = await connection.query("SHOW TABLES LIKE 'users'");
    if (userTables.length > 0) {
      const [columns] = await connection.query("SHOW COLUMNS FROM users");
      const colNames = columns.map(c => c.Field);
      if (!colNames.includes("user_number")) {
        await connection.query("ALTER TABLE users ADD COLUMN user_number VARCHAR(30) UNIQUE AFTER user_id");
      }
      if (!colNames.includes("client_no")) {
        await connection.query("ALTER TABLE users ADD COLUMN client_no VARCHAR(30) NULL AFTER user_number");
      }
      if (!colNames.includes("account_status")) {
        await connection.query("ALTER TABLE users ADD COLUMN account_status ENUM('Active', 'Inactive') NOT NULL DEFAULT 'Inactive' AFTER status");
      }
      if (!colNames.includes("created_by")) {
        await connection.query("ALTER TABLE users ADD COLUMN created_by VARCHAR(100) NULL DEFAULT 'Self-Registered' AFTER account_status");
      }
      if (!colNames.includes("approved_by")) {
        await connection.query("ALTER TABLE users ADD COLUMN approved_by VARCHAR(100) NULL");
      }
      if (!colNames.includes("approved_at")) {
        await connection.query("ALTER TABLE users ADD COLUMN approved_at DATETIME NULL");
      }
      if (!colNames.includes("rejection_reason")) {
        await connection.query("ALTER TABLE users ADD COLUMN rejection_reason TEXT NULL");
      }
      if (!colNames.includes("profile_pic")) {
        await connection.query("ALTER TABLE users ADD COLUMN profile_pic LONGTEXT NULL AFTER image_url");
      }
      if (colNames.includes("username")) {
        await connection.query("ALTER TABLE users MODIFY COLUMN username VARCHAR(100) NULL DEFAULT NULL");
      }
      await connection.query("ALTER TABLE users MODIFY COLUMN status ENUM('Pending', 'Approved', 'Rejected', 'Suspended') NOT NULL DEFAULT 'Pending'");
    } else {
      await connection.query(`
        CREATE TABLE users (
          user_id INT AUTO_INCREMENT PRIMARY KEY,
          user_number VARCHAR(30) UNIQUE NOT NULL COMMENT 'Format: CLT-YYYY-000001 or STF-YYYY-000001',
          client_no VARCHAR(30) NULL,
          lname VARCHAR(50) NOT NULL,
          fname VARCHAR(50) NOT NULL,
          mname VARCHAR(50) NULL,
          contact_no VARCHAR(20) NOT NULL,
          address TEXT NOT NULL,
          gender ENUM('Male', 'Female') NOT NULL,
          role ENUM('admin', 'staff', 'client') NOT NULL DEFAULT 'client',
          email VARCHAR(100) UNIQUE NOT NULL,
          password VARCHAR(255) NOT NULL,
          status ENUM('Pending', 'Approved', 'Rejected', 'Suspended') NOT NULL DEFAULT 'Pending',
          account_status ENUM('Active', 'Inactive') NOT NULL DEFAULT 'Inactive',
          created_by VARCHAR(100) NULL DEFAULT 'Self-Registered',
          approved_by VARCHAR(100) NULL,
          approved_at DATETIME NULL,
          rejection_reason TEXT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
      `);
    }

    // 2. TABLE: SERVICES
    await connection.query("DROP TABLE IF EXISTS services");
    await connection.query(`
      CREATE TABLE services (
        service_id INT AUTO_INCREMENT PRIMARY KEY,
        service_code VARCHAR(20) UNIQUE NOT NULL,
        service_name VARCHAR(100) NOT NULL,
        category VARCHAR(50) NOT NULL,
        description TEXT,
        price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
        unit VARCHAR(30) DEFAULT 'unit',
        total_capacity INT DEFAULT 10,
        available_qty INT DEFAULT 10,
        image_url VARCHAR(255),
        status ENUM('Active', 'Inactive') DEFAULT 'Active',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    `);

    // 3. TABLE: BOOKINGS
    const [bookingTables] = await connection.query("SHOW TABLES LIKE 'bookings'");
    if (bookingTables.length > 0) {
      await connection.query("ALTER TABLE bookings MODIFY COLUMN status VARCHAR(50) NOT NULL DEFAULT 'Pending'");
      await connection.query("ALTER TABLE bookings MODIFY COLUMN payment_status VARCHAR(50) NOT NULL DEFAULT 'Unpaid'");
      const [cols] = await connection.query("SHOW COLUMNS FROM bookings LIKE 'updated_at'");
      if (cols.length === 0) {
        await connection.query("ALTER TABLE bookings ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP");
      }
    } else {
      await connection.query(`
        CREATE TABLE bookings (
          id INT AUTO_INCREMENT PRIMARY KEY,
          booking_number VARCHAR(30) UNIQUE NOT NULL,
          user_id INT NULL,
          client_name VARCHAR(100) NOT NULL,
          client_email VARCHAR(100),
          client_phone VARCHAR(20),
          booking_date DATE NOT NULL,
          arrival_time VARCHAR(20),
          pax INT DEFAULT 1,
          total_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
          payment_method VARCHAR(30) DEFAULT 'Cash',
          status VARCHAR(50) NOT NULL DEFAULT 'Pending',
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
      `);
    }

    // 4. TABLE: BOOKING_ITEMS
    await connection.query(`
      CREATE TABLE IF NOT EXISTS booking_items (
        id INT AUTO_INCREMENT PRIMARY KEY,
        booking_id INT NOT NULL,
        service_id INT NOT NULL,
        service_name VARCHAR(100) NOT NULL,
        unit_price DECIMAL(10,2) NOT NULL,
        quantity INT DEFAULT 1,
        subtotal DECIMAL(10,2) NOT NULL,
        FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    `);

    // 5. TABLE: PAYMENTS
    const [paymentTables] = await connection.query("SHOW TABLES LIKE 'payments'");
    if (paymentTables.length > 0) {
      const [columns] = await connection.query("SHOW COLUMNS FROM payments");
      const colNames = columns.map(c => c.Field);
      if (!colNames.includes("total_amount")) {
        await connection.query("DROP TABLE IF EXISTS payments");
      }
    }
    await connection.query(`
      CREATE TABLE IF NOT EXISTS payments (
        id INT AUTO_INCREMENT PRIMARY KEY,
        payment_ref VARCHAR(30) UNIQUE NOT NULL,
        booking_id INT NULL,
        client_name VARCHAR(100) NOT NULL,
        staff_id INT NULL,
        staff_name VARCHAR(100),
        total_amount DECIMAL(10,2) NOT NULL,
        cash_received DECIMAL(10,2) NOT NULL,
        change_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
        payment_method VARCHAR(30) DEFAULT 'Cash',
        status ENUM('Paid', 'Refunded', 'Cancelled') DEFAULT 'Paid',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    `);

    // 6. TABLE: REVENUE_SHARES
    await connection.query(`
      CREATE TABLE IF NOT EXISTS revenue_shares (
        id INT AUTO_INCREMENT PRIMARY KEY,
        payment_id INT NOT NULL,
        gross_amount DECIMAL(10,2) NOT NULL,
        park_share DECIMAL(10,2) NOT NULL,
        barangay_share DECIMAL(10,2) NOT NULL,
        guide_share DECIMAL(10,2) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    `);

    // 7. TABLE: SETTINGS
    await connection.query(`
      CREATE TABLE IF NOT EXISTS settings (
        id INT AUTO_INCREMENT PRIMARY KEY,
        setting_key VARCHAR(50) UNIQUE NOT NULL,
        setting_value TEXT NOT NULL,
        description VARCHAR(255),
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    `);

    console.log("✅ Database tables initialized (users, services, bookings, booking_items, payments, revenue_shares, settings).");

    // Seed default settings
    const defaultSettings = [
      { key: "resort_name", val: "Duangon Cold Spring", desc: "Official Resort Name" },
      { key: "location", val: "Bilar, Bohol, Philippines", desc: "Resort Address" },
      { key: "max_daily_capacity", val: "300", desc: "Maximum daily visitor capacity" },
      { key: "park_share_pct", val: "70", desc: "Resort/Park Revenue Share Percentage" },
      { key: "barangay_share_pct", val: "20", desc: "Barangay Revenue Share Percentage" },
      { key: "guide_share_pct", val: "10", desc: "Guide Association Share Percentage" },
    ];

    for (const s of defaultSettings) {
      await connection.query(
        "INSERT INTO settings (setting_key, setting_value, description) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value)",
        [s.key, s.val, s.desc]
      );
    }

    // Seed Duangon Cold Spring Services linked with 11 service images
    const defaultServices = [
      { code: "DSVC-001", name: "Cold Spring Pool Entrance Ticket", category: "Entrance", desc: "Day pass access to natural cold spring pool", price: 100.00, unit: "head", cap: 300, img: "/src/assets/images/services/swimming.png" },
      { code: "DSVC-002", name: "Standard Open Cottage", category: "Cottage", desc: "Shaded native open cottage near pool", price: 600.00, unit: "day", cap: 10, img: "/src/assets/images/services/cottage.png" },
      { code: "DSVC-003", name: "Resort Table & Chairs Set", category: "Rental", desc: "1 Table + 4 monoblock chairs", price: 250.00, unit: "day", cap: 15, img: "/src/assets/images/services/table.png" },
      { code: "DSVC-004", name: "Life Vest / Safety Gear", category: "Safety", desc: "Adult & Kid safety flotation vest", price: 50.00, unit: "head", cap: 30, img: "/src/assets/images/services/lifevest.png" },
      { code: "DSVC-005", name: "Videoke Karaoke System", category: "Entertainment", desc: "Heavy-duty Videoke sound system", price: 500.00, unit: "day", cap: 4, img: "/src/assets/images/services/videoke.png" },
      { code: "DSVC-006", name: "Kayak / Floating Pad Rental", category: "Water Activity", desc: "1-hour kayak & water pad rental", price: 300.00, unit: "hour", cap: 5, img: "/src/assets/images/services/floating.png" },
      { code: "DSVC-007", name: "Camping Pitch & Tent", category: "Accommodation", desc: "Overnight camping slot & tent", price: 450.00, unit: "night", cap: 8, img: "/src/assets/images/services/tent.png" },
      { code: "DSVC-008", name: "Aircon Kubo Guest Room", category: "Accommodation", desc: "Private aircon room with bed & bath", price: 1500.00, unit: "night", cap: 4, img: "/src/assets/images/services/room.png" },
      { code: "DSVC-009", name: "Private Event Pavilion", category: "Event", desc: "Private pavilion for family gatherings & events", price: 3500.00, unit: "event", cap: 2, img: "/src/assets/images/services/event.png" },
      { code: "DSVC-010", name: "Buffet & Catering Station", category: "Food", desc: "Native buffet catering package", price: 450.00, unit: "head", cap: 50, img: "/src/assets/images/services/buffet.png" },
      { code: "DSVC-011", name: "Secured Resort Parking Slot", category: "Parking", desc: "Safe vehicle parking for cars & vans", price: 50.00, unit: "vehicle", cap: 40, img: "/src/assets/images/services/parking.png" },
    ];

    for (const s of defaultServices) {
      await connection.query(
        `INSERT INTO services (service_code, service_name, category, description, price, unit, total_capacity, available_qty, image_url, status)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'Active')
         ON DUPLICATE KEY UPDATE service_name=VALUES(service_name), price=VALUES(price), image_url=VALUES(image_url)`,
        [s.code, s.name, s.category, s.desc, s.price, s.unit, s.cap, s.cap, s.img]
      );
    }

    console.log("✅ Seeded 11 Duangon Cold Spring services linked with image assets.");

    // Seed Default Active & Approved Accounts (Admin, Staff, Client)
    const defaultAccounts = [
      {
        user_number: "ADM-2026-000001",
        client_no: "ADM-2026-000001",
        fname: "System",
        mname: "EcoTour",
        lname: "Admin",
        contact_no: "09170000001",
        address: "Bilar, Bohol, Philippines",
        gender: "Male",
        role: "admin",
        email: "admin@ecotourvista.com",
        alt_email: "admin@ecoutourvisa.com",
        pass: "admin123",
        status: "Approved",
        account_status: "Active",
      },
      {
        user_number: "STF-2026-000001",
        client_no: "STF-2026-000001",
        fname: "Staff",
        mname: "Resort",
        lname: "Member",
        contact_no: "09170000002",
        address: "Bilar, Bohol, Philippines",
        gender: "Female",
        role: "staff",
        email: "staff@ecotourvista.com",
        alt_email: "staff@ecoutourvisa.com",
        pass: "staff123",
        status: "Approved",
        account_status: "Active",
      },
      {
        user_number: "CLT-2026-000001",
        client_no: "CLT-2026-000001",
        fname: "Guest",
        mname: "Sample",
        lname: "Client",
        contact_no: "09170000003",
        address: "Tagbilaran City, Bohol",
        gender: "Male",
        role: "client",
        email: "client@ecotourvista.com",
        alt_email: "client@ecoutourvisa.com",
        pass: "client123",
        status: "Approved",
        account_status: "Active",
      },
    ];

    for (const acc of defaultAccounts) {
      const hashedPass = await bcrypt.hash(acc.pass, 10);
      const emailsToInsert = [acc.email];
      if (acc.alt_email && acc.alt_email !== acc.email) {
        emailsToInsert.push(acc.alt_email);
      }

      for (const mail of emailsToInsert) {
        const [existing] = await connection.query("SELECT * FROM users WHERE email = ?", [mail]);
        if (existing.length === 0) {
          const userNum = mail === acc.alt_email ? `${acc.user_number}-ALT` : acc.user_number;
          await connection.query(`
            INSERT INTO users (user_number, client_no, fname, mname, lname, contact_no, address, gender, role, email, password, status, account_status, created_by, approved_by, approved_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'System', 'System Initializer', NOW())
          `, [
            userNum,
            userNum,
            acc.fname,
            acc.mname,
            acc.lname,
            acc.contact_no,
            acc.address,
            acc.gender,
            acc.role,
            mail,
            hashedPass,
            acc.status,
            acc.account_status
          ]);
        } else {
          // Update password & status to ensure active & approved
          await connection.query(`
            UPDATE users SET password = ?, status = 'Approved', account_status = 'Active' WHERE email = ?
          `, [hashedPass, mail]);
        }
      }
    }

    console.log("✅ Seeded default Active & Approved accounts: Admin (admin@ecotourvista.com / admin123), Staff (staff@ecotourvista.com / staff123), Client (client@ecotourvista.com / client123).");

    await connection.query("SET FOREIGN_KEY_CHECKS = 1");
    await connection.end();
  } catch (err) {
    console.error("❌ Database Initialization Error:", err.message);
    process.exitCode = 1;
    if (connection) await connection.end();
  }
}

initDatabase();
