-- SUPERSEDED: this file is out of date. Use src/database/ecotour_schema.sql, ecotour_procedures.sql and ecotour_seed.sql
-- (regenerate with `npm run db:export`, apply upgrades with `npm run migrate`).

/*
  ╔══════════════════════════════════════════════════════════════════════════════╗
  ║          ECOTOUR — MySQL 8.0.46 Stored Procedures                           ║
  ║          Database: ecotour_db                                                ║
  ║          Generated: 2026-08-21                                               ║
  ║                                                                              ║
  ║  Instructions:                                                               ║
  ║    Run this script in MySQL Workbench / phpMyAdmin / CLI once:               ║
  ║      mysql -u root -p ecotour_db < ECOTOUR_STORED_PROCEDURES.sql            ║
  ║    It is safe to re-run — all procedures use DROP IF EXISTS first.           ║
  ╚══════════════════════════════════════════════════════════════════════════════╝
*/

USE `ecotour_db`;

DELIMITER $$

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 1: USER / AUTH OPERATIONS
-- ═══════════════════════════════════════════════════════════════════════════════

-- 1. Lookup user by email (used by login flow; password check stays in Node.js)
DROP PROCEDURE IF EXISTS `sp_get_user_by_email`$$
CREATE PROCEDURE `sp_get_user_by_email`(
  IN p_email VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci
)
BEGIN
  SELECT
    user_id, user_number, fname, mname, lname,
    gender, birthdate, address, contact_no,
    email, username, password, role, status,
    approved_by, approved_at, created_at, updated_at
  FROM users
  WHERE email = p_email
  LIMIT 1;
END$$

-- 2. Lookup user by numeric user_id or user_number string
DROP PROCEDURE IF EXISTS `sp_get_user_by_id`$$
CREATE PROCEDURE `sp_get_user_by_id`(
  IN p_id VARCHAR(50)
)
BEGIN
  SELECT
    user_id, user_number, fname, mname, lname,
    gender, birthdate, address, contact_no,
    email, username, role, status,
    approved_by, approved_at, created_at, updated_at
  FROM users
  WHERE user_id = p_id OR user_number = p_id
  LIMIT 1;
END$$

-- 3. List all users with optional role / status filters
DROP PROCEDURE IF EXISTS `sp_get_all_users`$$
CREATE PROCEDURE `sp_get_all_users`(
  IN p_status   VARCHAR(30),
  IN p_role     VARCHAR(20)
)
BEGIN
  SELECT
    user_id, user_number, fname, mname, lname,
    contact_no, address, gender, role, email, status,
    approved_by, approved_at, created_at
  FROM users
  WHERE
    (p_status IS NULL OR LOWER(status) = LOWER(p_status))
    AND
    (p_role IS NULL OR LOWER(role) = LOWER(p_role))
  ORDER BY created_at DESC;
END$$

-- 4. Full-text search across user fields
DROP PROCEDURE IF EXISTS `sp_search_users`$$
CREATE PROCEDURE `sp_search_users`(
  IN p_term VARCHAR(100)
)
BEGIN
  DECLARE v_like VARCHAR(102);
  SET v_like = CONCAT('%', p_term, '%');
  SELECT
    user_id, user_number, fname, mname, lname,
    contact_no, address, gender, role, email, status,
    approved_by, approved_at, created_at
  FROM users
  WHERE
    user_number LIKE v_like
    OR fname      LIKE v_like
    OR lname      LIKE v_like
    OR email      LIKE v_like
    OR contact_no LIKE v_like
  ORDER BY created_at DESC;
END$$

-- 5. Insert a new user record (hashing & number generation happen in Node.js)
DROP PROCEDURE IF EXISTS `sp_register_user`$$
CREATE PROCEDURE `sp_register_user`(
  IN p_user_number   VARCHAR(30),
  IN p_fname         VARCHAR(50),
  IN p_mname         VARCHAR(50),
  IN p_lname         VARCHAR(50),
  IN p_contact_no    VARCHAR(20),
  IN p_address       VARCHAR(255),
  IN p_gender        VARCHAR(10),
  IN p_role          VARCHAR(20),
  IN p_email         VARCHAR(100),
  IN p_password_hash VARCHAR(255),
  IN p_status        VARCHAR(30)
)
BEGIN
  INSERT INTO users
    (user_number, fname, mname, lname, contact_no, address, gender,
     role, email, password, status)
  VALUES
    (p_user_number, p_fname, p_mname, p_lname, p_contact_no, p_address,
     p_gender, p_role, p_email, p_password_hash, p_status);

  SELECT LAST_INSERT_ID() AS new_user_id;
END$$

-- 6. Update user profile fields
DROP PROCEDURE IF EXISTS `sp_update_user_profile`$$
CREATE PROCEDURE `sp_update_user_profile`(
  IN p_user_id    INT,
  IN p_fname      VARCHAR(50),
  IN p_mname      VARCHAR(50),
  IN p_lname      VARCHAR(50),
  IN p_email      VARCHAR(100),
  IN p_contact_no VARCHAR(20),
  IN p_address    VARCHAR(255),
  IN p_gender     VARCHAR(10)
)
BEGIN
  UPDATE users SET
    fname      = COALESCE(NULLIF(p_fname,      ''), fname),
    mname      = COALESCE(NULLIF(p_mname,      ''), mname),
    lname      = COALESCE(NULLIF(p_lname,      ''), lname),
    email      = COALESCE(NULLIF(p_email,      ''), email),
    contact_no = COALESCE(NULLIF(p_contact_no, ''), contact_no),
    address    = COALESCE(NULLIF(p_address,    ''), address),
    gender     = COALESCE(NULLIF(p_gender,     ''), gender),
    updated_at = NOW()
  WHERE user_id = p_user_id;

  SELECT ROW_COUNT() AS affected_rows;
END$$

-- 7. Update password only (hash provided by Node.js)
DROP PROCEDURE IF EXISTS `sp_update_user_password`$$
CREATE PROCEDURE `sp_update_user_password`(
  IN p_user_id       INT,
  IN p_password_hash VARCHAR(255)
)
BEGIN
  UPDATE users
  SET password = p_password_hash, updated_at = NOW()
  WHERE user_id = p_user_id;

  INSERT INTO audit_logs (user_id, action, description)
  VALUES (p_user_id, 'USER_PASSWORD_CHANGED',
          CONCAT('User ID ', p_user_id, ' changed their password via profile settings.'));
END$$

-- 8. Update user approval / status
DROP PROCEDURE IF EXISTS `sp_update_user_status`$$
CREATE PROCEDURE `sp_update_user_status`(
  IN p_user_id          INT,
  IN p_status           VARCHAR(30),
  IN p_approved_by      VARCHAR(100),
  IN p_rejection_reason TEXT,
  IN p_password_hash    VARCHAR(255)
)
BEGIN
  DECLARE v_account_status VARCHAR(20);
  SET v_account_status = IF(LOWER(p_status) = 'approved', 'Active', 'Inactive');

  IF LOWER(p_status) = 'approved' THEN
    UPDATE users SET
      status      = p_status,
      password    = COALESCE(p_password_hash, password),
      approved_by = p_approved_by,
      approved_at = NOW(),
      updated_at  = NOW()
    WHERE user_id = p_user_id;

  ELSEIF LOWER(p_status) = 'rejected' THEN
    UPDATE users SET
      status     = p_status,
      updated_at = NOW()
    WHERE user_id = p_user_id;

  ELSE
    UPDATE users SET
      status     = p_status,
      updated_at = NOW()
    WHERE user_id = p_user_id;
  END IF;

  SELECT ROW_COUNT() AS affected_rows, v_account_status AS account_status;
END$$

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 2: BOOKING / RESERVATION OPERATIONS
-- ═══════════════════════════════════════════════════════════════════════════════

-- 9. Get all bookings with user_number
DROP PROCEDURE IF EXISTS `sp_get_all_bookings`$$
CREATE PROCEDURE `sp_get_all_bookings`()
BEGIN
  SELECT
    b.id, b.booking_number, b.user_id, b.client_name,
    b.client_email, b.client_phone, b.booking_date,
    b.arrival_time, b.pax, b.total_amount,
    b.payment_method, b.status, b.created_at,
    u.user_number
  FROM bookings b
  LEFT JOIN users u ON b.user_id = u.user_id
  ORDER BY b.created_at DESC;
END$$

-- 10. Get booking items for a bulk set of booking IDs (dynamic IN clause)
DROP PROCEDURE IF EXISTS `sp_get_booking_items_bulk`$$
CREATE PROCEDURE `sp_get_booking_items_bulk`(
  IN p_booking_ids TEXT
)
BEGIN
  SET @sql = CONCAT(
    'SELECT id, booking_id, service_id, service_name, unit_price, quantity, subtotal, item_type '
    'FROM booking_items WHERE booking_id IN (', p_booking_ids, ')'
  );
  PREPARE stmt FROM @sql;
  EXECUTE stmt;
  DEALLOCATE PREPARE stmt;
END$$

-- 11. Get single booking by id or booking_number
DROP PROCEDURE IF EXISTS `sp_get_booking_by_id`$$
CREATE PROCEDURE `sp_get_booking_by_id`(
  IN p_id VARCHAR(50)
)
BEGIN
  SELECT
    b.id, b.booking_number, b.user_id, b.client_name,
    b.client_email, b.client_phone, b.booking_date,
    b.arrival_time, b.pax, b.total_amount,
    b.payment_method, b.status, b.created_at
  FROM bookings b
  WHERE b.id = p_id OR b.booking_number = p_id
  LIMIT 1;
END$$

-- 11b. Get items for a single booking
DROP PROCEDURE IF EXISTS `sp_get_booking_items`$$
CREATE PROCEDURE `sp_get_booking_items`(
  IN p_booking_id INT
)
BEGIN
  SELECT id, booking_id, service_id, service_name,
         unit_price, quantity, subtotal
  FROM booking_items
  WHERE booking_id = p_booking_id;
END$$

-- 12. Create booking header (items inserted separately in Node.js)
DROP PROCEDURE IF EXISTS `sp_create_booking`$$
CREATE PROCEDURE `sp_create_booking`(
  IN p_booking_number VARCHAR(30),
  IN p_user_id        INT,
  IN p_client_name    VARCHAR(100),
  IN p_client_email   VARCHAR(100),
  IN p_client_phone   VARCHAR(20),
  IN p_booking_date   DATE,
  IN p_arrival_time   VARCHAR(20),
  IN p_pax            INT,
  IN p_total_amount   DECIMAL(10,2),
  IN p_payment_method VARCHAR(30),
  IN p_status         VARCHAR(30)
)
BEGIN
  DECLARE v_booking_id INT;

  START TRANSACTION;

  INSERT INTO bookings
    (booking_number, user_id, client_name, client_email, client_phone,
     booking_date, arrival_time, pax, total_amount, payment_method, status)
  VALUES
    (p_booking_number, p_user_id, p_client_name, p_client_email, p_client_phone,
     p_booking_date, p_arrival_time, p_pax, p_total_amount, p_payment_method, p_status);

  SET v_booking_id = LAST_INSERT_ID();

  COMMIT;

  SELECT v_booking_id AS booking_id, p_booking_number AS booking_number;
END$$

-- 13. Update booking status
DROP PROCEDURE IF EXISTS `sp_update_booking_status`$$
CREATE PROCEDURE `sp_update_booking_status`(
  IN p_id     VARCHAR(50),
  IN p_status VARCHAR(30)
)
BEGIN
  UPDATE bookings
  SET status = p_status
  WHERE id = p_id OR booking_number = p_id;

  SELECT ROW_COUNT() AS affected_rows;
END$$

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 3: PAYMENT / RECEIPT OPERATIONS
-- ═══════════════════════════════════════════════════════════════════════════════

-- 14. Create payment with revenue shares, booking update, and audit log
DROP PROCEDURE IF EXISTS `sp_create_payment`$$
CREATE PROCEDURE `sp_create_payment`(
  IN p_payment_ref    VARCHAR(30),
  IN p_booking_id     INT,
  IN p_client_name    VARCHAR(100),
  IN p_staff_id       INT,
  IN p_staff_name     VARCHAR(100),
  IN p_total_amount   DECIMAL(10,2),
  IN p_cash_received  DECIMAL(10,2),
  IN p_change_amount  DECIMAL(10,2),
  IN p_payment_method VARCHAR(30)
)
BEGIN
  DECLARE v_payment_id   INT;
  DECLARE v_park_share   DECIMAL(10,2);
  DECLARE v_barangay     DECIMAL(10,2);
  DECLARE v_guide        DECIMAL(10,2);
  DECLARE v_park_pct     DECIMAL(5,2) DEFAULT 70.00;
  DECLARE v_bgy_pct      DECIMAL(5,2) DEFAULT 20.00;
  DECLARE v_guide_pct    DECIMAL(5,2) DEFAULT 10.00;

  SELECT
    IFNULL(MAX(CASE WHEN setting_key='park_share_pct'     THEN CAST(setting_value AS DECIMAL(5,2)) END), 70.00),
    IFNULL(MAX(CASE WHEN setting_key='barangay_share_pct' THEN CAST(setting_value AS DECIMAL(5,2)) END), 20.00),
    IFNULL(MAX(CASE WHEN setting_key='guide_share_pct'    THEN CAST(setting_value AS DECIMAL(5,2)) END), 10.00)
  INTO v_park_pct, v_bgy_pct, v_guide_pct
  FROM settings
  WHERE setting_key IN ('park_share_pct','barangay_share_pct','guide_share_pct');

  SET v_park_share = ROUND(p_total_amount * v_park_pct  / 100, 2);
  SET v_barangay   = ROUND(p_total_amount * v_bgy_pct   / 100, 2);
  SET v_guide      = ROUND(p_total_amount * v_guide_pct / 100, 2);

  START TRANSACTION;

  INSERT INTO payments
    (payment_ref, booking_id, client_name, staff_id, staff_name,
     total_amount, cash_received, change_amount, payment_method, status)
  VALUES
    (p_payment_ref, NULLIF(p_booking_id, 0), p_client_name, p_staff_id, p_staff_name,
     p_total_amount, p_cash_received, p_change_amount, p_payment_method, 'Paid');

  SET v_payment_id = LAST_INSERT_ID();

  -- NOTE: column is guide_share (not municipal_share) per actual schema
  INSERT INTO revenue_shares
    (payment_id, gross_amount, park_share, barangay_share, guide_share)
  VALUES
    (v_payment_id, p_total_amount, v_park_share, v_barangay, v_guide);

  -- Booking status is managed by the reservation workflow, not by payments

  INSERT INTO audit_logs (action, description)
  VALUES (
    'RECEIPT_GENERATED',
    CONCAT('Generated Official Receipt #', p_payment_ref,
           ' for ', p_client_name, ' - Amount: ', p_total_amount)
  );

  COMMIT;

  SELECT
    v_payment_id  AS id,
    p_payment_ref AS payment_ref,
    p_total_amount AS total_amount,
    v_park_share  AS park_share,
    v_barangay    AS barangay_share,
    v_guide       AS guide_share;
END$$

-- 15. Get all payments with revenue share data
DROP PROCEDURE IF EXISTS `sp_get_all_payments`$$
CREATE PROCEDURE `sp_get_all_payments`()
BEGIN
  SELECT
    p.id, p.payment_ref, p.booking_id, p.client_name,
    p.staff_id, p.staff_name, p.total_amount, p.cash_received,
    p.change_amount, p.payment_method, p.status, p.created_at,
    r.gross_amount, r.park_share, r.barangay_share, r.guide_share
  FROM payments p
  LEFT JOIN revenue_shares r ON p.id = r.payment_id
  ORDER BY p.id DESC;
END$$

-- 16. Get single payment by id or payment_ref
DROP PROCEDURE IF EXISTS `sp_get_payment_by_id`$$
CREATE PROCEDURE `sp_get_payment_by_id`(
  IN p_id VARCHAR(50)
)
BEGIN
  SELECT
    p.id, p.payment_ref, p.booking_id, p.client_name,
    p.staff_id, p.staff_name, p.total_amount, p.cash_received,
    p.change_amount, p.payment_method, p.status, p.created_at,
    r.gross_amount, r.park_share, r.barangay_share, r.guide_share
  FROM payments p
  LEFT JOIN revenue_shares r ON p.id = r.payment_id
  WHERE p.id = p_id OR p.payment_ref = p_id
  LIMIT 1;
END$$

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 4: SERVICES OPERATIONS
-- ═══════════════════════════════════════════════════════════════════════════════

-- 17. Get all services
DROP PROCEDURE IF EXISTS `sp_get_all_services`$$
CREATE PROCEDURE `sp_get_all_services`()
BEGIN
  SELECT
    service_id, service_code, service_name, category,
    description, price, unit, total_capacity, available_qty,
    image_url, status, created_at, updated_at
  FROM services
  ORDER BY service_code ASC;
END$$

-- 18. Create service
DROP PROCEDURE IF EXISTS `sp_create_service`$$
CREATE PROCEDURE `sp_create_service`(
  IN p_service_code    VARCHAR(20),
  IN p_service_name    VARCHAR(100),
  IN p_category        VARCHAR(50),
  IN p_description     TEXT,
  IN p_price           DECIMAL(10,2),
  IN p_unit            VARCHAR(30),
  IN p_total_capacity  INT,
  IN p_image_url       VARCHAR(255),
  IN p_status          VARCHAR(20)
)
BEGIN
  INSERT INTO services
    (service_code, service_name, category, description, price,
     unit, total_capacity, available_qty, image_url, status)
  VALUES
    (p_service_code, p_service_name, COALESCE(p_category, 'Rental'),
     COALESCE(p_description, ''), p_price,
     COALESCE(p_unit, 'unit'), COALESCE(p_total_capacity, 10),
     COALESCE(p_total_capacity, 10),
     COALESCE(p_image_url, '/src/assets/images/services/cottage.png'),
     COALESCE(p_status, 'Active'));

  SELECT LAST_INSERT_ID() AS service_id;
END$$

-- 19. Update service
DROP PROCEDURE IF EXISTS `sp_update_service`$$
CREATE PROCEDURE `sp_update_service`(
  IN p_service_id     INT,
  IN p_service_name   VARCHAR(100),
  IN p_category       VARCHAR(50),
  IN p_description    TEXT,
  IN p_price          DECIMAL(10,2),
  IN p_unit           VARCHAR(30),
  IN p_total_capacity INT,
  IN p_available_qty  INT,
  IN p_status         VARCHAR(20)
)
BEGIN
  UPDATE services SET
    service_name   = COALESCE(p_service_name,   service_name),
    category       = COALESCE(p_category,       category),
    description    = COALESCE(p_description,    description),
    price          = COALESCE(p_price,          price),
    unit           = COALESCE(p_unit,           unit),
    total_capacity = COALESCE(p_total_capacity, total_capacity),
    available_qty  = COALESCE(p_available_qty,  available_qty),
    status         = COALESCE(p_status,         status),
    updated_at     = NOW()
  WHERE service_id = p_service_id;

  SELECT ROW_COUNT() AS affected_rows;
END$$

-- 20. Delete service
DROP PROCEDURE IF EXISTS `sp_delete_service`$$
CREATE PROCEDURE `sp_delete_service`(
  IN p_service_id INT
)
BEGIN
  DELETE FROM services WHERE service_id = p_service_id;
  SELECT ROW_COUNT() AS affected_rows;
END$$

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 5: DASHBOARD & REPORTS
-- ═══════════════════════════════════════════════════════════════════════════════

-- 21. Unified dashboard summary (returns 6 result sets)
DROP PROCEDURE IF EXISTS `sp_get_dashboard_summary`$$
CREATE PROCEDURE `sp_get_dashboard_summary`()
BEGIN
  -- Result Set 1: Settings
  SELECT setting_key, setting_value FROM settings;

  -- Result Set 2: Revenue today
  SELECT COALESCE(SUM(total_amount), 0) AS revenue_today
  FROM payments
  WHERE status = 'Paid' AND DATE(created_at) = CURDATE();

  -- Result Set 3: Active bookings count
  SELECT COUNT(*) AS active_bookings
  FROM bookings
  WHERE status IN ('Confirmed', 'Checked In', 'Pending');

  -- Result Set 4: Visitors today
  SELECT COALESCE(SUM(pax), 0) AS total_visitors_today
  FROM bookings
  WHERE DATE(booking_date) = CURDATE()
    AND status IN ('Confirmed', 'Checked In', 'Completed');

  -- Result Set 5: Active services
  SELECT service_code, service_name, category, price, unit,
         total_capacity, available_qty, image_url
  FROM services
  WHERE status = 'Active';

  -- Result Set 6: 5 most recent bookings
  SELECT id, booking_number, client_name, booking_date,
         arrival_time, pax, total_amount, status
  FROM bookings
  ORDER BY created_at DESC
  LIMIT 5;
END$$

-- 22. Daily revenue report (last 30 days)
DROP PROCEDURE IF EXISTS `sp_get_daily_revenue_report`$$
CREATE PROCEDURE `sp_get_daily_revenue_report`()
BEGIN
  SELECT
    DATE(created_at)               AS date,
    COUNT(*)                       AS transaction_count,
    COALESCE(SUM(total_amount), 0) AS total_revenue
  FROM payments
  WHERE status = 'Paid'
  GROUP BY DATE(created_at)
  ORDER BY date DESC
  LIMIT 30;
END$$

-- 23. Monthly revenue report (last 12 months)
DROP PROCEDURE IF EXISTS `sp_get_monthly_revenue_report`$$
CREATE PROCEDURE `sp_get_monthly_revenue_report`()
BEGIN
  SELECT
    DATE_FORMAT(created_at, '%Y-%m') AS month,
    COUNT(*)                         AS transaction_count,
    COALESCE(SUM(total_amount), 0)   AS total_revenue
  FROM payments
  WHERE status = 'Paid'
  GROUP BY DATE_FORMAT(created_at, '%Y-%m')
  ORDER BY month DESC
  LIMIT 12;
END$$

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 6: ANNOUNCEMENTS
-- ═══════════════════════════════════════════════════════════════════════════════

DROP PROCEDURE IF EXISTS `sp_get_announcements`$$
CREATE PROCEDURE `sp_get_announcements`()
BEGIN
  SELECT announcement_id, title, description, created_by, created_at
  FROM announcements
  ORDER BY created_at DESC;
END$$

DROP PROCEDURE IF EXISTS `sp_create_announcement`$$
CREATE PROCEDURE `sp_create_announcement`(
  IN p_title       VARCHAR(150),
  IN p_description TEXT,
  IN p_created_by  INT
)
BEGIN
  INSERT INTO announcements (title, description, created_by)
  VALUES (p_title, p_description, p_created_by);

  SELECT LAST_INSERT_ID() AS announcement_id;
END$$

DROP PROCEDURE IF EXISTS `sp_delete_announcement`$$
CREATE PROCEDURE `sp_delete_announcement`(
  IN p_id INT
)
BEGIN
  DELETE FROM announcements WHERE announcement_id = p_id;
  SELECT ROW_COUNT() AS affected_rows;
END$$

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 7: AUDIT LOGS
-- ═══════════════════════════════════════════════════════════════════════════════

DROP PROCEDURE IF EXISTS `sp_get_audit_logs`$$
CREATE PROCEDURE `sp_get_audit_logs`()
BEGIN
  SELECT
    a.log_id, a.user_id, a.action, a.description, a.created_at,
    u.fname, u.lname, u.role, u.email
  FROM audit_logs a
  LEFT JOIN users u ON a.user_id = u.user_id
  ORDER BY a.created_at DESC
  LIMIT 100;
END$$

DROP PROCEDURE IF EXISTS `sp_create_audit_log`$$
CREATE PROCEDURE `sp_create_audit_log`(
  IN p_user_id     INT,
  IN p_action      VARCHAR(100),
  IN p_description TEXT
)
BEGIN
  INSERT INTO audit_logs (user_id, action, description)
  VALUES (NULLIF(p_user_id, 0), p_action, p_description);

  SELECT LAST_INSERT_ID() AS log_id;
END$$

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 8: WALK-IN TRANSACTIONS (Future-Ready — no backend wiring yet)
-- ═══════════════════════════════════════════════════════════════════════════════

DROP PROCEDURE IF EXISTS `sp_create_walkin_transaction`$$
CREATE PROCEDURE `sp_create_walkin_transaction`(
  IN p_staff_id       INT,
  IN p_customer_name  VARCHAR(100),
  IN p_total_amount   DECIMAL(10,2),
  IN p_payment_method VARCHAR(30),
  IN p_remarks        TEXT
)
BEGIN
  DECLARE v_txn_id INT;

  START TRANSACTION;

  INSERT INTO walkin_transactions
    (staff_id, customer_name, total_amount, payment_method, remarks)
  VALUES
    (p_staff_id, p_customer_name, p_total_amount,
     COALESCE(p_payment_method, 'cash'), p_remarks);

  SET v_txn_id = LAST_INSERT_ID();

  COMMIT;

  SELECT v_txn_id AS transaction_id;
END$$

DROP PROCEDURE IF EXISTS `sp_get_walkin_transactions`$$
CREATE PROCEDURE `sp_get_walkin_transactions`()
BEGIN
  SELECT
    wt.transaction_id, wt.staff_id, wt.customer_name,
    wt.transaction_date, wt.total_amount, wt.payment_method, wt.remarks,
    u.fname, u.lname
  FROM walkin_transactions wt
  LEFT JOIN users u ON wt.staff_id = u.user_id
  ORDER BY wt.transaction_date DESC;
END$$

DELIMITER ;

-- ═══════════════════════════════════════════════════════════════════════════════
-- Quick smoke-test queries (uncomment to verify after import)
-- ═══════════════════════════════════════════════════════════════════════════════
-- CALL sp_get_all_services();
-- CALL sp_get_user_by_email('admin@ecotourvista.com');
-- CALL sp_get_all_bookings();
-- CALL sp_get_dashboard_summary();
-- CALL sp_get_daily_revenue_report();
-- CALL sp_get_monthly_revenue_report();
-- CALL sp_get_announcements();
-- CALL sp_get_audit_logs();
