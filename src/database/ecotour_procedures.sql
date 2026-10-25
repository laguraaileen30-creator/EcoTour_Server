-- EcoTourVista database — generated 2026-10-05T15:20:04.394Z from the live database
-- Do not edit by hand; run `npm run db:export` to regenerate.

SET NAMES utf8mb4;

DELIMITER $$

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

DROP PROCEDURE IF EXISTS `sp_create_notification`$$
CREATE PROCEDURE `sp_create_notification`(
  IN p_user_id      INT,
  IN p_role_target  VARCHAR(20),
  IN p_title        VARCHAR(150),
  IN p_message      TEXT,
  IN p_type         VARCHAR(50),
  IN p_reference_id VARCHAR(50)
)
BEGIN
  INSERT INTO `notifications` (
    `user_id`, `role_target`, `title`, `message`, `type`, `reference_id`, `is_read`, `created_at`
  ) VALUES (
    NULLIF(p_user_id, 0),
    COALESCE(p_role_target, 'all'),
    p_title,
    p_message,
    COALESCE(p_type, 'general'),
    p_reference_id,
    0,
    NOW()
  );

  SELECT LAST_INSERT_ID() AS notification_id;
END$$

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

        INSERT INTO revenue_shares
          (payment_id, gross_amount, park_share, barangay_share, guide_share)
        VALUES
          (v_payment_id, p_total_amount, v_park_share, v_barangay, v_guide);

        IF p_booking_id IS NOT NULL AND p_booking_id > 0 THEN
          UPDATE bookings SET status = 'Paid' WHERE id = p_booking_id;
        END IF;

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

DROP PROCEDURE IF EXISTS `sp_delete_announcement`$$
CREATE PROCEDURE `sp_delete_announcement`(
  IN p_id INT
)
BEGIN
  DELETE FROM announcements WHERE announcement_id = p_id;
  SELECT ROW_COUNT() AS affected_rows;
END$$

DROP PROCEDURE IF EXISTS `sp_delete_service`$$
CREATE PROCEDURE `sp_delete_service`(
  IN p_service_id INT
)
BEGIN
  DELETE FROM services WHERE service_id = p_service_id;
  SELECT ROW_COUNT() AS affected_rows;
END$$

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

DROP PROCEDURE IF EXISTS `sp_get_all_users`$$
CREATE PROCEDURE `sp_get_all_users`(
  IN p_status   VARCHAR(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
  IN p_role     VARCHAR(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci
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

DROP PROCEDURE IF EXISTS `sp_get_announcements`$$
CREATE PROCEDURE `sp_get_announcements`()
BEGIN
  SELECT announcement_id, title, description, created_by, created_at
  FROM announcements
  ORDER BY created_at DESC;
END$$

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

DROP PROCEDURE IF EXISTS `sp_get_booking_items_bulk`$$
CREATE PROCEDURE `sp_get_booking_items_bulk`(IN p_booking_ids TEXT)
BEGIN SET @sql = CONCAT('SELECT id, booking_id, service_id, service_name, unit_price, quantity, subtotal, item_type FROM booking_items WHERE booking_id IN (', p_booking_ids, ')'); PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt; END$$

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

DROP PROCEDURE IF EXISTS `sp_get_dashboard_summary`$$
CREATE PROCEDURE `sp_get_dashboard_summary`()
BEGIN
  
  SELECT setting_key, setting_value FROM settings;

  
  SELECT COALESCE(SUM(total_amount), 0) AS revenue_today
  FROM payments
  WHERE status = 'Paid' AND DATE(created_at) = CURDATE();

  
  SELECT COUNT(*) AS active_bookings
  FROM bookings
  WHERE status IN ('Confirmed', 'Checked In', 'Pending');

  
  SELECT COALESCE(SUM(pax), 0) AS total_visitors_today
  FROM bookings
  WHERE DATE(booking_date) = CURDATE()
    AND status IN ('Confirmed', 'Checked In', 'Completed');

  
  SELECT service_code, service_name, category, price, unit,
         total_capacity, available_qty, image_url
  FROM services
  WHERE status = 'Active';

  
  SELECT id, booking_number, client_name, booking_date,
         arrival_time, pax, total_amount, status
  FROM bookings
  ORDER BY created_at DESC
  LIMIT 5;
END$$

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

DROP PROCEDURE IF EXISTS `sp_get_user_by_id`$$
CREATE PROCEDURE `sp_get_user_by_id`(
  IN p_id VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci
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

DROP PROCEDURE IF EXISTS `sp_get_user_notifications`$$
CREATE PROCEDURE `sp_get_user_notifications`(
  IN p_user_id INT,
  IN p_role    VARCHAR(20)
)
BEGIN
  SELECT 
    `id`, `user_id`, `role_target`, `title`, `message`, `type`,
    `reference_id`, `is_read`, `created_at`
  FROM `notifications`
  WHERE 
    (`user_id` = p_user_id) 
    OR (`user_id` IS NULL AND (`role_target` = 'all' OR LOWER(`role_target`) = LOWER(p_role)))
  ORDER BY `is_read` ASC, `created_at` DESC
  LIMIT 50;

  SELECT COUNT(*) AS unread_count
  FROM `notifications`
  WHERE 
    `is_read` = 0
    AND (
      (`user_id` = p_user_id) 
      OR (`user_id` IS NULL AND (`role_target` = 'all' OR LOWER(`role_target`) = LOWER(p_role)))
    );
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

DROP PROCEDURE IF EXISTS `sp_mark_notification_as_read`$$
CREATE PROCEDURE `sp_mark_notification_as_read`(
  IN p_notification_id INT,
  IN p_user_id         INT,
  IN p_role            VARCHAR(20),
  IN p_mark_all        TINYINT(1)
)
BEGIN
  IF p_mark_all = 1 THEN
    UPDATE `notifications`
    SET `is_read` = 1
    WHERE 
      `is_read` = 0
      AND (
        (`user_id` = p_user_id) 
        OR (`user_id` IS NULL AND (`role_target` = 'all' OR LOWER(`role_target`) = LOWER(p_role)))
      );
  ELSE
    UPDATE `notifications`
    SET `is_read` = 1
    WHERE `id` = p_notification_id;
  END IF;

  SELECT ROW_COUNT() AS affected_rows;
END$$

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
     role, email, password, status, username)
  VALUES
    (p_user_number, p_fname, p_mname, p_lname, p_contact_no, p_address,
     p_gender, p_role, p_email, p_password_hash, p_status, p_email);

  SELECT LAST_INSERT_ID() AS new_user_id;
END$$

DROP PROCEDURE IF EXISTS `sp_search_users`$$
CREATE PROCEDURE `sp_search_users`(
  IN p_term VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci
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

DROP PROCEDURE IF EXISTS `sp_update_booking_status`$$
CREATE PROCEDURE `sp_update_booking_status`(
        IN p_id VARCHAR(50),
        IN p_status VARCHAR(50)
      )
BEGIN
        UPDATE bookings
        SET status = p_status
        WHERE id = p_id
           OR booking_number = p_id
           OR booking_number = REPLACE(p_id, 'REF-', 'BK-')
           OR booking_number = REPLACE(p_id, 'BK-', 'REF-');

        SELECT ROW_COUNT() AS affected_rows;
      END$$

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

DELIMITER ;
