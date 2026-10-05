-- EcoTourVista database â€” generated 2026-10-05T15:20:04.394Z from the live database
-- Do not edit by hand; run `npm run db:export` to regenerate.

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `announcements`;
CREATE TABLE `announcements` (
  `announcement_id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(150) NOT NULL,
  `description` text NOT NULL,
  `created_by` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`announcement_id`),
  KEY `created_by` (`created_by`),
  CONSTRAINT `announcements_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS `audit_logs`;
CREATE TABLE `audit_logs` (
  `log_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `action` varchar(100) NOT NULL,
  `description` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`log_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `audit_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS `booking_items`;
CREATE TABLE `booking_items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `booking_id` int NOT NULL,
  `service_id` int NOT NULL,
  `service_name` varchar(100) NOT NULL,
  `unit_price` decimal(10,2) NOT NULL,
  `quantity` int DEFAULT '1',
  `subtotal` decimal(10,2) NOT NULL,
  `item_type` varchar(20) DEFAULT NULL COMMENT 'PACKAGE | TICKET | FEE | ADDON | DAMAGE_FEE',
  PRIMARY KEY (`id`),
  KEY `booking_id` (`booking_id`),
  CONSTRAINT `booking_items_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS `bookings`;
CREATE TABLE `bookings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `booking_number` varchar(30) NOT NULL,
  `user_id` int DEFAULT NULL,
  `package_id` int DEFAULT NULL,
  `client_name` varchar(100) NOT NULL,
  `client_email` varchar(100) DEFAULT NULL,
  `client_phone` varchar(20) DEFAULT NULL,
  `booking_date` date NOT NULL,
  `arrival_time` varchar(20) DEFAULT NULL,
  `pax` int DEFAULT '1',
  `total_amount` decimal(10,2) NOT NULL DEFAULT '0.00',
  `discount_amount` decimal(10,2) NOT NULL DEFAULT '0.00',
  `promo_code` varchar(30) DEFAULT NULL,
  `payment_method` varchar(30) DEFAULT 'Cash',
  `payment_status` varchar(30) NOT NULL DEFAULT 'Unpaid',
  `status` enum('Pending','Confirmed','Checked In','Completed','Cancelled','Rejected') DEFAULT 'Pending',
  `notes` text,
  `checked_in_at` datetime DEFAULT NULL,
  `checked_out_at` datetime DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `promotion_id` int DEFAULT NULL,
  `applied_promo_name` varchar(255) DEFAULT NULL,
  `original_value` decimal(10,2) DEFAULT NULL,
  `base_package_price` decimal(10,2) DEFAULT NULL,
  `booking_type` varchar(50) DEFAULT NULL,
  `reservation_fee` decimal(10,2) DEFAULT NULL,
  `fee_status` varchar(50) DEFAULT NULL,
  `amount_paid` decimal(10,2) DEFAULT NULL,
  `confirmation_status` varchar(50) DEFAULT NULL,
  `confirmation_sent_at` datetime DEFAULT NULL,
  `confirmation_deadline` datetime DEFAULT NULL,
  `confirmation_token` varchar(255) DEFAULT NULL,
  `confirmation_responded_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `booking_number` (`booking_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS `capacity_limits`;
CREATE TABLE `capacity_limits` (
  `id` int NOT NULL AUTO_INCREMENT,
  `service_id` int NOT NULL,
  `daily_capacity` int NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `service_id` (`service_id`),
  CONSTRAINT `capacity_limits_ibfk_1` FOREIGN KEY (`service_id`) REFERENCES `services` (`service_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS `daily_cash_history`;
CREATE TABLE `daily_cash_history` (
  `id` int NOT NULL AUTO_INCREMENT,
  `date` varchar(20) NOT NULL,
  `total_visitors` int DEFAULT '0',
  `entrance_revenue` decimal(10,2) DEFAULT '0.00',
  `service_revenue` decimal(10,2) DEFAULT '0.00',
  `total_cash_revenue` decimal(10,2) DEFAULT '0.00',
  `park_share` decimal(10,2) DEFAULT '0.00',
  `barangay_share` decimal(10,2) DEFAULT '0.00',
  `municipal_share` decimal(10,2) DEFAULT '0.00',
  `saved_by` varchar(100) DEFAULT 'Admin',
  `status` varchar(30) DEFAULT 'Frozen & Saved',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `date` (`date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS `damage_reports`;
CREATE TABLE `damage_reports` (
  `id` int NOT NULL AUTO_INCREMENT,
  `booking_id` int NOT NULL,
  `inspection_id` int NOT NULL,
  `item_name` varchar(100) NOT NULL,
  `damage_type` varchar(100) NOT NULL,
  `description` text NOT NULL,
  `evidence_url` varchar(255) DEFAULT NULL,
  `repair_cost` decimal(10,2) DEFAULT '0.00',
  `labor_cost` decimal(10,2) DEFAULT '0.00',
  `recommended_fee` decimal(10,2) DEFAULT '0.00',
  `final_fee` decimal(10,2) DEFAULT '0.00',
  `status` enum('Pending','Approved','Rejected','Waived') DEFAULT 'Pending',
  `reported_by` int NOT NULL,
  `approved_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `booking_id` (`booking_id`),
  KEY `inspection_id` (`inspection_id`),
  KEY `reported_by` (`reported_by`),
  KEY `approved_by` (`approved_by`),
  CONSTRAINT `damage_reports_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE CASCADE,
  CONSTRAINT `damage_reports_ibfk_2` FOREIGN KEY (`inspection_id`) REFERENCES `facility_inspections` (`id`) ON DELETE CASCADE,
  CONSTRAINT `damage_reports_ibfk_3` FOREIGN KEY (`reported_by`) REFERENCES `users` (`user_id`) ON DELETE RESTRICT,
  CONSTRAINT `damage_reports_ibfk_4` FOREIGN KEY (`approved_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS `facility_inspections`;
CREATE TABLE `facility_inspections` (
  `id` int NOT NULL AUTO_INCREMENT,
  `booking_id` int NOT NULL,
  `type` enum('Pre-Checkin','Checkout') NOT NULL,
  `status` enum('Clear','Damage Found') DEFAULT 'Clear',
  `inspected_by` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `booking_id` (`booking_id`),
  KEY `inspected_by` (`inspected_by`),
  CONSTRAINT `facility_inspections_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE CASCADE,
  CONSTRAINT `facility_inspections_ibfk_2` FOREIGN KEY (`inspected_by`) REFERENCES `users` (`user_id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS `gallery`;
CREATE TABLE `gallery` (
  `image_id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(100) DEFAULT NULL,
  `image` varchar(255) NOT NULL,
  `category` varchar(50) DEFAULT NULL,
  `uploaded_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`image_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS `inspection_items`;
CREATE TABLE `inspection_items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `inspection_id` int NOT NULL,
  `item_name` varchar(100) NOT NULL,
  `condition` varchar(100) NOT NULL,
  `notes` text,
  PRIMARY KEY (`id`),
  KEY `inspection_id` (`inspection_id`),
  CONSTRAINT `inspection_items_ibfk_1` FOREIGN KEY (`inspection_id`) REFERENCES `facility_inspections` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS `notifications`;
CREATE TABLE `notifications` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `role_target` enum('all','admin','staff','client') DEFAULT 'all',
  `title` varchar(150) NOT NULL,
  `message` text NOT NULL,
  `type` varchar(50) DEFAULT 'general',
  `reference_id` varchar(50) DEFAULT NULL,
  `is_read` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_read` (`user_id`,`is_read`),
  KEY `idx_role_target` (`role_target`,`is_read`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS `package_items`;
CREATE TABLE `package_items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `package_id` int NOT NULL,
  `service_id` int NOT NULL,
  `quantity` int DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `package_id` (`package_id`),
  KEY `service_id` (`service_id`),
  CONSTRAINT `package_items_ibfk_1` FOREIGN KEY (`package_id`) REFERENCES `packages` (`id`) ON DELETE CASCADE,
  CONSTRAINT `package_items_ibfk_2` FOREIGN KEY (`service_id`) REFERENCES `services` (`service_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS `packages`;
CREATE TABLE `packages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `package_code` varchar(30) NOT NULL,
  `package_name` varchar(100) NOT NULL,
  `description` text,
  `image_url` varchar(255) DEFAULT NULL,
  `regular_value` decimal(10,2) NOT NULL DEFAULT '0.00',
  `promo_price` decimal(10,2) NOT NULL DEFAULT '0.00',
  `discount_percent` decimal(5,2) DEFAULT '0.00',
  `included_guests` int DEFAULT '1',
  `badge` varchar(50) DEFAULT NULL,
  `status` enum('Active','Inactive') DEFAULT 'Active',
  `valid_from` datetime DEFAULT NULL,
  `valid_until` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `discount_type` varchar(20) NOT NULL DEFAULT 'Percentage',
  `package_type` varchar(20) NOT NULL DEFAULT 'STANDARD',
  `manual_status` varchar(20) DEFAULT NULL,
  `is_featured` tinyint(1) NOT NULL DEFAULT '0',
  `show_on_landing` tinyint(1) NOT NULL DEFAULT '1',
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `package_code` (`package_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS `payments`;
CREATE TABLE `payments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `payment_ref` varchar(30) NOT NULL,
  `booking_id` int DEFAULT NULL,
  `client_name` varchar(100) NOT NULL,
  `staff_id` int DEFAULT NULL,
  `staff_name` varchar(100) DEFAULT NULL,
  `total_amount` decimal(10,2) NOT NULL,
  `cash_received` decimal(10,2) NOT NULL,
  `change_amount` decimal(10,2) NOT NULL DEFAULT '0.00',
  `payment_method` varchar(30) DEFAULT 'Cash',
  `status` enum('Paid','Refunded','Cancelled') DEFAULT 'Paid',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `payment_ref` (`payment_ref`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS `promotion_packages`;
CREATE TABLE `promotion_packages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `promotion_id` int NOT NULL,
  `package_id` int NOT NULL,
  `discount_type` enum('Percentage','Fixed') DEFAULT NULL,
  `discount_value` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `promotion_id` (`promotion_id`),
  KEY `package_id` (`package_id`),
  CONSTRAINT `promotion_packages_ibfk_1` FOREIGN KEY (`promotion_id`) REFERENCES `promotions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `promotion_packages_ibfk_2` FOREIGN KEY (`package_id`) REFERENCES `packages` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS `promotion_services`;
CREATE TABLE `promotion_services` (
  `id` int NOT NULL AUTO_INCREMENT,
  `promotion_id` int NOT NULL,
  `service_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `promotion_id` (`promotion_id`),
  KEY `service_id` (`service_id`),
  CONSTRAINT `promotion_services_ibfk_1` FOREIGN KEY (`promotion_id`) REFERENCES `promotions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `promotion_services_ibfk_2` FOREIGN KEY (`service_id`) REFERENCES `services` (`service_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS `promotions`;
CREATE TABLE `promotions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `promo_code` varchar(30) NOT NULL,
  `promo_name` varchar(100) NOT NULL,
  `description` text,
  `discount_type` enum('Percentage','Fixed','Special Price','Bundle') DEFAULT 'Percentage',
  `promo_type` enum('MONTHLY','DOUBLE_DATE','WEEKEND','FLASH','HOLIDAY','RECURRING','CUSTOM') DEFAULT 'CUSTOM',
  `discount_value` decimal(10,2) NOT NULL DEFAULT '0.00',
  `start_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `end_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `timezone` varchar(50) DEFAULT 'Asia/Manila',
  `eligibility_basis` enum('BOOKING_DATE','VISIT_DATE') DEFAULT 'BOOKING_DATE',
  `priority` int DEFAULT '5',
  `stackable` tinyint(1) DEFAULT '0',
  `usage_limit` int DEFAULT NULL,
  `used_count` int DEFAULT '0',
  `status` enum('Active','Inactive') DEFAULT 'Active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `image_url` varchar(255) DEFAULT NULL,
  `original_price` decimal(10,2) DEFAULT NULL,
  `discounted_price` decimal(10,2) DEFAULT NULL,
  `is_featured` tinyint(1) NOT NULL DEFAULT '0',
  `show_on_landing` tinyint(1) NOT NULL DEFAULT '1',
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `promo_code` (`promo_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS `reservation_details`;
CREATE TABLE `reservation_details` (
  `detail_id` int NOT NULL AUTO_INCREMENT,
  `reservation_id` int NOT NULL,
  `service_id` int NOT NULL,
  `quantity` int NOT NULL DEFAULT '1',
  `price` decimal(10,2) NOT NULL,
  `subtotal` decimal(10,2) NOT NULL,
  PRIMARY KEY (`detail_id`),
  KEY `reservation_id` (`reservation_id`),
  KEY `service_id` (`service_id`),
  CONSTRAINT `reservation_details_ibfk_1` FOREIGN KEY (`reservation_id`) REFERENCES `reservations` (`reservation_id`) ON DELETE CASCADE,
  CONSTRAINT `reservation_details_ibfk_2` FOREIGN KEY (`service_id`) REFERENCES `services` (`service_id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS `reservations`;
CREATE TABLE `reservations` (
  `reservation_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `reservation_date` date NOT NULL,
  `visit_date` date NOT NULL,
  `total_amount` decimal(10,2) DEFAULT '0.00',
  `payment_status` enum('pending','paid','cancelled') DEFAULT 'pending',
  `reservation_status` enum('pending','approved','completed','cancelled') DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `promotion_id` int DEFAULT NULL,
  PRIMARY KEY (`reservation_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `reservations_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS `resource_assignments`;
CREATE TABLE `resource_assignments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `booking_id` int NOT NULL,
  `service_resource_id` int NOT NULL,
  `start_time` datetime NOT NULL,
  `end_time` datetime NOT NULL,
  `status` enum('Held','Reserved','In Use','Returned','Released') DEFAULT 'Held',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `booking_id` (`booking_id`),
  KEY `service_resource_id` (`service_resource_id`),
  CONSTRAINT `resource_assignments_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE CASCADE,
  CONSTRAINT `resource_assignments_ibfk_2` FOREIGN KEY (`service_resource_id`) REFERENCES `service_resources` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS `resource_blocks`;
CREATE TABLE `resource_blocks` (
  `id` int NOT NULL AUTO_INCREMENT,
  `service_resource_id` int NOT NULL,
  `start_time` datetime NOT NULL,
  `end_time` datetime NOT NULL,
  `reason` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `service_resource_id` (`service_resource_id`),
  CONSTRAINT `resource_blocks_ibfk_1` FOREIGN KEY (`service_resource_id`) REFERENCES `service_resources` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS `revenue_shares`;
CREATE TABLE `revenue_shares` (
  `id` int NOT NULL AUTO_INCREMENT,
  `payment_id` int NOT NULL,
  `gross_amount` decimal(10,2) NOT NULL,
  `park_share` decimal(10,2) NOT NULL,
  `barangay_share` decimal(10,2) NOT NULL,
  `guide_share` decimal(10,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS `reviews`;
CREATE TABLE `reviews` (
  `review_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `spot_id` int NOT NULL,
  `rating` int DEFAULT NULL,
  `comment` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`review_id`),
  KEY `user_id` (`user_id`),
  KEY `spot_id` (`spot_id`),
  CONSTRAINT `reviews_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `reviews_ibfk_2` FOREIGN KEY (`spot_id`) REFERENCES `tourist_spots` (`spot_id`) ON DELETE CASCADE,
  CONSTRAINT `reviews_chk_1` CHECK (((`rating` >= 1) and (`rating` <= 5)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS `service_inventory`;
CREATE TABLE `service_inventory` (
  `id` int NOT NULL AUTO_INCREMENT,
  `service_id` int NOT NULL,
  `total_quantity` int NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `service_id` (`service_id`),
  CONSTRAINT `service_inventory_ibfk_1` FOREIGN KEY (`service_id`) REFERENCES `services` (`service_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS `service_resources`;
CREATE TABLE `service_resources` (
  `id` int NOT NULL AUTO_INCREMENT,
  `service_id` int NOT NULL,
  `resource_name` varchar(100) NOT NULL,
  `status` enum('Available','Maintenance','Out of Order') DEFAULT 'Available',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `service_id` (`service_id`),
  CONSTRAINT `service_resources_ibfk_1` FOREIGN KEY (`service_id`) REFERENCES `services` (`service_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS `services`;
CREATE TABLE `services` (
  `service_id` int NOT NULL AUTO_INCREMENT,
  `service_code` varchar(20) NOT NULL,
  `service_name` varchar(100) NOT NULL,
  `slug` varchar(150) DEFAULT NULL,
  `category` varchar(50) NOT NULL,
  `description` text,
  `short_description` varchar(255) DEFAULT NULL,
  `price` decimal(10,2) NOT NULL DEFAULT '0.00',
  `unit` varchar(30) DEFAULT 'unit',
  `total_capacity` int DEFAULT '10',
  `capacity_persons` int DEFAULT NULL,
  `minimum_quantity` int NOT NULL DEFAULT '1',
  `available_qty` int DEFAULT '10',
  `image_url` varchar(255) DEFAULT NULL,
  `status` enum('Active','Inactive') DEFAULT 'Active',
  `manual_status` varchar(20) DEFAULT NULL,
  `is_featured` tinyint(1) NOT NULL DEFAULT '0',
  `show_on_landing` tinyint(1) NOT NULL DEFAULT '1',
  `is_assignable` tinyint(1) NOT NULL DEFAULT '0',
  `inclusions` text,
  `exclusions` text,
  `terms` text,
  `gallery` text,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`service_id`),
  UNIQUE KEY `service_code` (`service_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS `settings`;
CREATE TABLE `settings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `setting_key` varchar(50) NOT NULL,
  `setting_value` text NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `setting_key` (`setting_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS `tourist_spots`;
CREATE TABLE `tourist_spots` (
  `spot_id` int NOT NULL AUTO_INCREMENT,
  `spot_name` varchar(100) NOT NULL,
  `description` text,
  `location` varchar(255) DEFAULT NULL,
  `entrance_local` decimal(10,2) DEFAULT '0.00',
  `entrance_foreign` decimal(10,2) DEFAULT '0.00',
  `image` varchar(255) DEFAULT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  PRIMARY KEY (`spot_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `user_number` varchar(30) DEFAULT NULL,
  `fname` varchar(50) NOT NULL,
  `mname` varchar(50) DEFAULT NULL,
  `lname` varchar(50) NOT NULL,
  `gender` enum('Male','Female') NOT NULL,
  `birthdate` date DEFAULT NULL,
  `address` varchar(255) NOT NULL,
  `contact_no` varchar(20) NOT NULL,
  `email` varchar(100) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `hashed_password` varchar(255) DEFAULT NULL,
  `role` enum('admin','staff','client') DEFAULT 'client',
  `status` enum('Pending','Approved','Rejected','Suspended') NOT NULL DEFAULT 'Pending',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `approved_by` varchar(100) DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `user_number` (`user_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS `vouchers`;
CREATE TABLE `vouchers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `code` varchar(50) NOT NULL,
  `discount_type` enum('Percent','Fixed') DEFAULT 'Fixed',
  `discount_value` decimal(10,2) NOT NULL,
  `min_spend` decimal(10,2) DEFAULT '0.00',
  `max_discount` decimal(10,2) DEFAULT NULL,
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `usage_limit` int DEFAULT '100',
  `used_count` int DEFAULT '0',
  `per_user_limit` int DEFAULT '1',
  `status` enum('Active','Inactive') DEFAULT 'Active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS `walkin_details`;
CREATE TABLE `walkin_details` (
  `detail_id` int NOT NULL AUTO_INCREMENT,
  `transaction_id` int NOT NULL,
  `service_id` int NOT NULL,
  `quantity` int NOT NULL DEFAULT '1',
  `subtotal` decimal(10,2) NOT NULL,
  PRIMARY KEY (`detail_id`),
  KEY `transaction_id` (`transaction_id`),
  KEY `service_id` (`service_id`),
  CONSTRAINT `walkin_details_ibfk_1` FOREIGN KEY (`transaction_id`) REFERENCES `walkin_transactions` (`transaction_id`) ON DELETE CASCADE,
  CONSTRAINT `walkin_details_ibfk_2` FOREIGN KEY (`service_id`) REFERENCES `services` (`service_id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS `walkin_transactions`;
CREATE TABLE `walkin_transactions` (
  `transaction_id` int NOT NULL AUTO_INCREMENT,
  `staff_id` int NOT NULL,
  `customer_name` varchar(100) NOT NULL,
  `transaction_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `total_amount` decimal(10,2) DEFAULT '0.00',
  `payment_method` enum('cash','gcash','bank_transfer') DEFAULT 'cash',
  `remarks` text,
  PRIMARY KEY (`transaction_id`),
  KEY `staff_id` (`staff_id`),
  CONSTRAINT `walkin_transactions_ibfk_1` FOREIGN KEY (`staff_id`) REFERENCES `users` (`user_id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SET FOREIGN_KEY_CHECKS = 1;
-- EcoTourVista database â€” generated 2026-10-05T15:20:04.394Z from the live database
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
  IN p_email VARCHAR(100)
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
-- EcoTourVista database â€” generated 2026-10-05T15:20:04.394Z from the live database
-- Do not edit by hand; run `npm run db:export` to regenerate.

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- settings (6 rows)
DELETE FROM `settings`;
INSERT INTO `settings` (`id`, `setting_key`, `setting_value`, `description`, `updated_at`) VALUES
(1, 'resort_name', 'Duangon Cold Spring', 'Official Resort Name', '2026-08-04 16:46:03'),
(2, 'location', 'Bilar, Bohol, Philippines', 'Resort Address', '2026-08-04 16:46:03'),
(3, 'max_daily_capacity', '300', 'Maximum daily visitor capacity', '2026-08-04 16:46:03'),
(4, 'park_share_pct', '70', 'Resort/Park Revenue Share Percentage', '2026-08-04 16:46:03'),
(5, 'barangay_share_pct', '20', 'Barangay Revenue Share Percentage', '2026-08-04 16:46:03'),
(6, 'guide_share_pct', '10', 'Guide Association Share Percentage', '2026-08-04 16:46:03');

-- services (11 rows)
DELETE FROM `services`;
INSERT INTO `services` (`service_id`, `service_code`, `service_name`, `slug`, `category`, `description`, `short_description`, `price`, `unit`, `total_capacity`, `capacity_persons`, `minimum_quantity`, `available_qty`, `image_url`, `status`, `manual_status`, `is_featured`, `show_on_landing`, `is_assignable`, `inclusions`, `exclusions`, `terms`, `gallery`, `deleted_at`, `created_at`, `updated_at`) VALUES
(1, 'DSVC-001', 'Cold Spring Pool Entrance Ticket', 'cold-spring-pool-entrance-ticket', 'Entrance', 'Day pass access to natural cold spring pool', NULL, '100.00', 'head', 300, NULL, 1, 300, '/src/assets/images/services/swimming.png', 'Active', NULL, 0, 1, 0, NULL, NULL, NULL, NULL, NULL, '2026-08-04 18:03:40', '2026-09-29 14:10:58'),
(2, 'DSVC-002', 'Standard Open Cottage', 'standard-open-cottage', 'Cottage', 'Shaded native open cottage near pool', NULL, '600.00', 'day', 10, NULL, 1, 10, '/src/assets/images/services/cottage.png', 'Active', NULL, 0, 1, 1, NULL, NULL, NULL, NULL, NULL, '2026-08-04 18:03:40', '2026-09-29 14:10:58'),
(3, 'DSVC-003', 'Resort Table & Chairs Set', 'resort-table-chairs-set', 'Rental', '1 Table + 4 monoblock chairs', NULL, '250.00', 'day', 15, NULL, 1, 15, '/src/assets/images/services/table.png', 'Active', NULL, 0, 1, 0, NULL, NULL, NULL, NULL, NULL, '2026-08-04 18:03:40', '2026-09-29 14:10:58'),
(4, 'DSVC-004', 'Life Vest / Safety Gear', 'life-vest-safety-gear', 'Safety', 'Adult & Kid safety flotation vest', NULL, '50.00', 'head', 30, NULL, 1, 30, '/src/assets/images/services/lifevest.png', 'Active', NULL, 0, 1, 0, NULL, NULL, NULL, NULL, NULL, '2026-08-04 18:03:40', '2026-09-29 14:10:58'),
(5, 'DSVC-005', 'Videoke Karaoke System', 'videoke-karaoke-system', 'Entertainment', 'Heavy-duty Videoke sound system', NULL, '500.00', 'day', 4, NULL, 1, 4, '/src/assets/images/services/videoke.png', 'Active', NULL, 0, 1, 1, NULL, NULL, NULL, NULL, NULL, '2026-08-04 18:03:40', '2026-10-05 12:59:43'),
(6, 'DSVC-006', 'Kayak / Floating Pad Rental', 'kayak-floating-pad-rental', 'Water Activity', '1-hour kayak & water pad rental', NULL, '300.00', 'hour', 5, NULL, 1, 5, '/src/assets/images/services/floating.png', 'Active', NULL, 0, 1, 1, NULL, NULL, NULL, NULL, NULL, '2026-08-04 18:03:40', '2026-09-29 14:10:58'),
(7, 'DSVC-007', 'Camping Pitch & Tent', 'camping-pitch-tent', 'Accommodation', 'Overnight camping slot & tent', NULL, '450.00', 'night', 8, NULL, 1, 8, '/src/assets/images/services/tent.png', 'Active', NULL, 0, 1, 1, NULL, NULL, NULL, NULL, NULL, '2026-08-04 18:03:40', '2026-09-29 14:10:58'),
(8, 'DSVC-008', 'Aircon Kubo Guest Room', 'aircon-kubo-guest-room', 'Accommodation', 'Private aircon room with bed & bath', NULL, '1500.00', 'night', 4, NULL, 1, 4, '/src/assets/images/services/room.png', 'Active', NULL, 0, 1, 1, NULL, NULL, NULL, NULL, NULL, '2026-08-04 18:03:40', '2026-09-29 14:10:58'),
(9, 'DSVC-009', 'Private Event Pavilion', 'private-event-pavilion', 'Event', 'Private pavilion for family gatherings & events', NULL, '3500.00', 'event', 2, NULL, 1, 2, '/src/assets/images/services/event.png', 'Active', NULL, 0, 1, 1, NULL, NULL, NULL, NULL, NULL, '2026-08-04 18:03:40', '2026-09-29 14:10:58'),
(10, 'DSVC-010', 'Buffet & Catering Station', 'buffet-catering-station', 'Food', 'Native buffet catering package', NULL, '450.00', 'head', 50, NULL, 1, 50, '/src/assets/images/services/buffet.png', 'Active', NULL, 0, 1, 0, NULL, NULL, NULL, NULL, NULL, '2026-08-04 18:03:40', '2026-09-29 14:10:58'),
(11, 'DSVC-011', 'Secured Resort Parking Slot', 'secured-resort-parking-slot', 'Parking', 'Safe vehicle parking for cars & vans', NULL, '50.00', 'vehicle', 40, NULL, 1, 40, '/src/assets/images/services/parking.png', 'Active', NULL, 0, 1, 1, NULL, NULL, NULL, NULL, NULL, '2026-08-04 18:03:40', '2026-09-29 14:10:58');

-- service_resources (93 rows)
DELETE FROM `service_resources`;
INSERT INTO `service_resources` (`id`, `service_id`, `resource_name`, `status`, `created_at`, `updated_at`) VALUES
(1, 2, 'Cottage 01', 'Available', '2026-09-16 07:13:34', '2026-09-16 07:13:34'),
(2, 2, 'Cottage 02', 'Available', '2026-09-16 07:13:34', '2026-09-16 07:13:34'),
(3, 2, 'Cottage 03', 'Available', '2026-09-16 07:13:34', '2026-09-16 07:13:34'),
(4, 2, 'Cottage 04', 'Available', '2026-09-16 07:13:34', '2026-09-16 07:13:34'),
(5, 2, 'Cottage 05', 'Available', '2026-09-16 07:13:34', '2026-09-16 07:13:34'),
(6, 5, 'Videoke 01', 'Available', '2026-09-16 07:13:34', '2026-09-16 07:13:34'),
(7, 5, 'Videoke 02', 'Available', '2026-09-16 07:13:34', '2026-09-16 07:13:34'),
(8, 5, 'Videoke 03', 'Available', '2026-09-16 07:13:34', '2026-09-16 07:13:34'),
(9, 6, 'Kayak 01', 'Available', '2026-09-16 07:13:34', '2026-09-16 07:13:34'),
(10, 6, 'Kayak 02', 'Available', '2026-09-16 07:13:34', '2026-09-16 07:13:34'),
(11, 6, 'Kayak 03', 'Available', '2026-09-16 07:13:34', '2026-09-16 07:13:34'),
(12, 6, 'Kayak 04', 'Available', '2026-09-16 07:13:34', '2026-09-16 07:13:34'),
(13, 6, 'Kayak 05', 'Available', '2026-09-16 07:13:34', '2026-09-16 07:13:34'),
(14, 2, 'Cottage 06', 'Available', '2026-09-23 07:09:08', '2026-09-23 07:09:08'),
(15, 2, 'Cottage 07', 'Available', '2026-09-23 07:09:08', '2026-09-23 07:09:08'),
(16, 2, 'Cottage 08', 'Available', '2026-09-23 07:09:08', '2026-09-23 07:09:08'),
(17, 2, 'Cottage 09', 'Available', '2026-09-23 07:09:08', '2026-09-23 07:09:08'),
(18, 2, 'Cottage 10', 'Available', '2026-09-23 07:09:08', '2026-09-23 07:09:08'),
(19, 5, 'Videoke 04', 'Available', '2026-09-23 07:09:08', '2026-09-23 07:09:08'),
(20, 7, 'Tent Pitch 01', 'Available', '2026-09-23 07:09:08', '2026-09-23 07:09:08'),
(21, 7, 'Tent Pitch 02', 'Available', '2026-09-23 07:09:08', '2026-09-23 07:09:08'),
(22, 7, 'Tent Pitch 03', 'Available', '2026-09-23 07:09:08', '2026-09-23 07:09:08'),
(23, 7, 'Tent Pitch 04', 'Available', '2026-09-23 07:09:08', '2026-09-23 07:09:08'),
(24, 7, 'Tent Pitch 05', 'Available', '2026-09-23 07:09:08', '2026-09-23 07:09:08'),
(25, 7, 'Tent Pitch 06', 'Available', '2026-09-23 07:09:08', '2026-09-23 07:09:08'),
(26, 7, 'Tent Pitch 07', 'Available', '2026-09-23 07:09:08', '2026-09-23 07:09:08'),
(27, 7, 'Tent Pitch 08', 'Available', '2026-09-23 07:09:08', '2026-09-23 07:09:08'),
(28, 8, 'Kubo Room 01', 'Available', '2026-09-23 07:09:08', '2026-09-23 07:09:08'),
(29, 8, 'Kubo Room 02', 'Available', '2026-09-23 07:09:08', '2026-09-23 07:09:08'),
(30, 8, 'Kubo Room 03', 'Available', '2026-09-23 07:09:08', '2026-09-23 07:09:08'),
(31, 8, 'Kubo Room 04', 'Available', '2026-09-23 07:09:08', '2026-09-23 07:09:08'),
(32, 9, 'Pavilion 01', 'Available', '2026-09-23 07:09:08', '2026-09-23 07:09:08'),
(33, 9, 'Pavilion 02', 'Available', '2026-09-23 07:09:08', '2026-09-23 07:09:08'),
(34, 11, 'Parking Slot 01', 'Available', '2026-09-23 07:09:08', '2026-09-23 07:09:08'),
(35, 11, 'Parking Slot 02', 'Available', '2026-09-23 07:09:08', '2026-09-23 07:09:08'),
(36, 11, 'Parking Slot 03', 'Available', '2026-09-23 07:09:08', '2026-09-23 07:09:08'),
(37, 11, 'Parking Slot 04', 'Available', '2026-09-23 07:09:08', '2026-09-23 07:09:08'),
(38, 11, 'Parking Slot 05', 'Available', '2026-09-23 07:09:08', '2026-09-23 07:09:08'),
(39, 11, 'Parking Slot 06', 'Available', '2026-09-23 07:09:08', '2026-09-23 07:09:08'),
(40, 11, 'Parking Slot 07', 'Available', '2026-09-23 07:09:08', '2026-09-23 07:09:08'),
(41, 11, 'Parking Slot 08', 'Available', '2026-09-23 07:09:08', '2026-09-23 07:09:08'),
(42, 11, 'Parking Slot 09', 'Available', '2026-09-23 07:09:08', '2026-09-23 07:09:08'),
(43, 11, 'Parking Slot 10', 'Available', '2026-09-23 07:09:09', '2026-09-23 07:09:09'),
(44, 11, 'Parking Slot 11', 'Available', '2026-09-23 07:09:09', '2026-09-23 07:09:09'),
(45, 11, 'Parking Slot 12', 'Available', '2026-09-23 07:09:09', '2026-09-23 07:09:09'),
(46, 11, 'Parking Slot 13', 'Available', '2026-09-23 07:09:09', '2026-09-23 07:09:09'),
(47, 11, 'Parking Slot 14', 'Available', '2026-09-23 07:09:09', '2026-09-23 07:09:09'),
(48, 11, 'Parking Slot 15', 'Available', '2026-09-23 07:09:09', '2026-09-23 07:09:09'),
(49, 11, 'Parking Slot 16', 'Available', '2026-09-23 07:09:09', '2026-09-23 07:09:09'),
(50, 11, 'Parking Slot 17', 'Available', '2026-09-23 07:09:09', '2026-09-23 07:09:09'),
(51, 11, 'Parking Slot 18', 'Available', '2026-09-23 07:09:09', '2026-09-23 07:09:09'),
(52, 11, 'Parking Slot 19', 'Available', '2026-09-23 07:09:09', '2026-09-23 07:09:09'),
(53, 11, 'Parking Slot 20', 'Available', '2026-09-23 07:09:09', '2026-09-23 07:09:09'),
(54, 11, 'Parking Slot 21', 'Available', '2026-09-23 07:09:09', '2026-09-23 07:09:09'),
(55, 11, 'Parking Slot 22', 'Available', '2026-09-23 07:09:09', '2026-09-23 07:09:09'),
(56, 11, 'Parking Slot 23', 'Available', '2026-09-23 07:09:09', '2026-09-23 07:09:09'),
(57, 11, 'Parking Slot 24', 'Available', '2026-09-23 07:09:09', '2026-09-23 07:09:09'),
(58, 11, 'Parking Slot 25', 'Available', '2026-09-23 07:09:09', '2026-09-23 07:09:09'),
(59, 11, 'Parking Slot 26', 'Available', '2026-09-23 07:09:09', '2026-09-23 07:09:09'),
(60, 11, 'Parking Slot 27', 'Available', '2026-09-23 07:09:09', '2026-09-23 07:09:09'),
(61, 11, 'Parking Slot 28', 'Available', '2026-09-23 07:09:09', '2026-09-23 07:09:09'),
(62, 11, 'Parking Slot 29', 'Available', '2026-09-23 07:09:09', '2026-09-23 07:09:09'),
(63, 11, 'Parking Slot 30', 'Available', '2026-09-23 07:09:09', '2026-09-23 07:09:09'),
(64, 11, 'Parking Slot 31', 'Available', '2026-09-23 07:09:09', '2026-09-23 07:09:09'),
(65, 11, 'Parking Slot 32', 'Available', '2026-09-23 07:09:09', '2026-09-23 07:09:09'),
(66, 11, 'Parking Slot 33', 'Available', '2026-09-23 07:09:09', '2026-09-23 07:09:09'),
(67, 11, 'Parking Slot 34', 'Available', '2026-09-23 07:09:09', '2026-09-23 07:09:09'),
(68, 11, 'Parking Slot 35', 'Available', '2026-09-23 07:09:09', '2026-09-23 07:09:09'),
(69, 11, 'Parking Slot 36', 'Available', '2026-09-23 07:09:09', '2026-09-23 07:09:09'),
(70, 11, 'Parking Slot 37', 'Available', '2026-09-23 07:09:09', '2026-09-23 07:09:09'),
(71, 11, 'Parking Slot 38', 'Available', '2026-09-23 07:09:09', '2026-09-23 07:09:09'),
(72, 11, 'Parking Slot 39', 'Available', '2026-09-23 07:09:09', '2026-09-23 07:09:09'),
(73, 11, 'Parking Slot 40', 'Available', '2026-09-23 07:09:09', '2026-09-23 07:09:09'),
(74, 12, 'Umbrella 01', 'Available', '2026-09-23 07:09:09', '2026-09-23 07:09:09'),
(75, 12, 'Umbrella 02', 'Available', '2026-09-23 07:09:09', '2026-09-23 07:09:09'),
(76, 12, 'Umbrella 03', 'Available', '2026-09-23 07:09:09', '2026-09-23 07:09:09'),
(77, 12, 'Umbrella 04', 'Available', '2026-09-23 07:09:09', '2026-09-23 07:09:09'),
(78, 12, 'Umbrella 05', 'Available', '2026-09-23 07:09:09', '2026-09-23 07:09:09'),
(79, 12, 'Umbrella 06', 'Available', '2026-09-23 07:09:09', '2026-09-23 07:09:09'),
(80, 12, 'Umbrella 07', 'Available', '2026-09-23 07:09:09', '2026-09-23 07:09:09'),
(81, 12, 'Umbrella 08', 'Available', '2026-09-23 07:09:09', '2026-09-23 07:09:09'),
(82, 12, 'Umbrella 09', 'Available', '2026-09-23 07:09:09', '2026-09-23 07:09:09'),
(83, 12, 'Umbrella 10', 'Available', '2026-09-23 07:09:09', '2026-09-23 07:09:09'),
(84, 13, 'Family Cottage 01', 'Available', '2026-09-23 07:09:09', '2026-09-23 07:09:09'),
(85, 13, 'Family Cottage 02', 'Available', '2026-09-23 07:09:09', '2026-09-23 07:09:09'),
(86, 13, 'Family Cottage 03', 'Available', '2026-09-23 07:09:09', '2026-09-23 07:09:09'),
(87, 13, 'Family Cottage 04', 'Available', '2026-09-23 07:09:09', '2026-09-23 07:09:09'),
(88, 13, 'Family Cottage 05', 'Available', '2026-09-23 07:09:09', '2026-09-23 07:09:09'),
(89, 13, 'Family Cottage 06', 'Available', '2026-09-23 07:09:09', '2026-09-23 07:09:09'),
(90, 13, 'Family Cottage 07', 'Available', '2026-09-23 07:09:09', '2026-09-23 07:09:09'),
(91, 13, 'Family Cottage 08', 'Available', '2026-09-23 07:09:09', '2026-09-23 07:09:09'),
(92, 13, 'Family Cottage 09', 'Available', '2026-09-23 07:09:09', '2026-09-23 07:09:09'),
(93, 13, 'Family Cottage 10', 'Available', '2026-09-23 07:09:09', '2026-09-23 07:09:09');

-- service_inventory (2 rows)
DELETE FROM `service_inventory`;
INSERT INTO `service_inventory` (`id`, `service_id`, `total_quantity`, `created_at`, `updated_at`) VALUES
(1, 4, 50, '2026-09-16 07:13:34', '2026-09-16 07:13:34'),
(2, 11, 40, '2026-09-16 07:13:34', '2026-09-16 07:13:34');

-- capacity_limits (1 rows)
DELETE FROM `capacity_limits`;
INSERT INTO `capacity_limits` (`id`, `service_id`, `daily_capacity`, `created_at`, `updated_at`) VALUES
(1, 1, 300, '2026-09-16 07:13:34', '2026-09-16 07:13:34');

-- packages (8 rows)
DELETE FROM `packages`;
INSERT INTO `packages` (`id`, `package_code`, `package_name`, `description`, `image_url`, `regular_value`, `promo_price`, `discount_percent`, `included_guests`, `badge`, `status`, `valid_from`, `valid_until`, `created_at`, `updated_at`, `discount_type`, `package_type`, `manual_status`, `is_featured`, `show_on_landing`, `deleted_at`) VALUES
(1, 'PKG-001', 'Quick Dip Deal', 'Best for small groups and quick family swimming trips.', '/src/assets/images/services/quick dip.png', '900.00', '810.00', '10.00', 5, 'SAVE â‚±90', 'Active', NULL, NULL, '2026-09-16 07:53:29', '2026-09-16 07:53:29', 'Percentage', 'STANDARD', NULL, 0, 1, NULL),
(2, 'PKG-002', 'Family Splash Deal', 'Includes cottage, life vests, and parking.', '/src/assets/images/services/flash deal.png', '1400.00', '1190.00', '15.00', 5, 'BEST SELLER', 'Active', NULL, NULL, '2026-09-16 07:53:30', '2026-09-16 07:53:30', 'Percentage', 'STANDARD', NULL, 0, 1, NULL),
(3, 'PKG-003', 'Barkada Fun Deal', 'Designed for friends who want swimming plus entertainment.', '/src/assets/images/services/barkada deal.png', '2400.00', '1920.00', '20.00', 10, 'BARKADA FAVORITE', 'Active', NULL, NULL, '2026-09-16 07:53:30', '2026-09-16 07:53:30', 'Percentage', 'STANDARD', NULL, 0, 1, NULL),
(4, 'PKG-004', 'Family Getaway Deal', 'For extended families and larger day-trip groups.', '/src/assets/images/services/family gateway deal.png', '3900.00', '3120.00', '20.00', 15, 'BEST VALUE', 'Active', NULL, NULL, '2026-09-16 07:53:30', '2026-09-16 07:53:30', 'Percentage', 'STANDARD', NULL, 0, 1, NULL),
(5, 'PKG-005', 'Overnight Escape', 'Affordable overnight camping package.', '/src/assets/images/services/quick escape.png', '1950.00', '1658.00', '15.00', 5, 'OVERNIGHT DEAL', 'Active', NULL, NULL, '2026-09-16 07:53:30', '2026-09-16 07:53:30', 'Percentage', 'STANDARD', NULL, 0, 1, NULL),
(6, 'PKG-006', 'Premium Family Escape', 'Comfortable overnight option with Aircon Kubo.', '/src/assets/images/services/premium family.png', '3200.00', '2560.00', '20.00', 5, 'PREMIUM', 'Active', NULL, NULL, '2026-09-16 07:53:30', '2026-09-16 07:53:30', 'Percentage', 'STANDARD', NULL, 0, 1, NULL),
(7, 'PKG-007', 'Celebration Package', 'For birthdays, reunions and gatherings.', '/src/assets/images/services/celebration.png', '7150.00', '5720.00', '20.00', 20, 'PARTY DEAL', 'Active', NULL, NULL, '2026-09-16 07:53:30', '2026-09-16 07:53:30', 'Percentage', 'STANDARD', NULL, 0, 1, NULL),
(8, 'PKG-UNLIMITED-001', 'Unlimited All-Access Package', 'Enjoy Everything. No Limits. One Amazing Day! Access to ALL available Duangon Cold Spring services in one premium package. Unlimited use during your booked stay, subject to facility availability.', '/src/assets/images/services/unlimited.png', '12000.00', '10100.00', '16.00', 10, '16% OFF', 'Active', NULL, NULL, '2026-09-23 07:09:09', '2026-09-23 07:09:09', 'Percentage', 'UNLIMITED', NULL, 1, 1, NULL);

-- package_items (48 rows)
DELETE FROM `package_items`;
INSERT INTO `package_items` (`id`, `package_id`, `service_id`, `quantity`) VALUES
(1, 1, 1, 5),
(2, 1, 3, 1),
(3, 1, 12, 1),
(4, 2, 1, 5),
(5, 2, 2, 1),
(6, 2, 4, 5),
(7, 2, 11, 1),
(8, 3, 1, 10),
(9, 3, 2, 1),
(10, 3, 5, 1),
(11, 3, 3, 1),
(12, 3, 11, 1),
(13, 4, 1, 15),
(14, 4, 13, 1),
(15, 4, 4, 10),
(16, 4, 3, 2),
(17, 4, 6, 1),
(18, 4, 11, 2),
(19, 5, 1, 5),
(20, 5, 7, 1),
(21, 5, 12, 1),
(22, 5, 4, 5),
(23, 5, 6, 1),
(24, 5, 11, 1),
(25, 6, 1, 5),
(26, 6, 8, 1),
(27, 6, 2, 1),
(28, 6, 4, 5),
(29, 6, 6, 1),
(30, 6, 11, 1),
(31, 7, 1, 20),
(32, 7, 9, 1),
(33, 7, 5, 1),
(34, 7, 3, 4),
(35, 7, 11, 3),
(36, 8, 1, 10),
(37, 8, 2, 1),
(38, 8, 3, 1),
(39, 8, 4, 1),
(40, 8, 5, 1),
(41, 8, 6, 1),
(42, 8, 7, 1),
(43, 8, 8, 1),
(44, 8, 9, 1),
(45, 8, 10, 1),
(46, 8, 11, 1),
(47, 8, 12, 1),
(48, 8, 13, 1);

-- promotions (3 rows)
DELETE FROM `promotions`;
INSERT INTO `promotions` (`id`, `promo_code`, `promo_name`, `description`, `discount_type`, `promo_type`, `discount_value`, `start_at`, `end_at`, `timezone`, `eligibility_basis`, `priority`, `stackable`, `usage_limit`, `used_count`, `status`, `created_at`, `updated_at`, `image_url`, `original_price`, `discounted_price`, `is_featured`, `show_on_landing`, `deleted_at`) VALUES
(1, 'SEP2026', 'September Monthly Sale', 'Enjoy our regular September discounts', 'Percentage', 'MONTHLY', '15.00', '2026-08-31 16:00:00', '2026-09-30 15:59:59', 'Asia/Manila', 'BOOKING_DATE', 5, 0, NULL, 0, 'Active', '2026-09-16 07:30:39', '2026-09-16 07:30:39', NULL, NULL, NULL, 0, 1, NULL),
(2, '99SALE', '9.9 EcoTour Getaway Sale', 'Special Double Date Sale', 'Percentage', 'DOUBLE_DATE', '20.00', '2026-09-08 16:00:00', '2026-09-09 15:59:59', 'Asia/Manila', 'BOOKING_DATE', 2, 0, NULL, 0, 'Active', '2026-09-16 07:30:39', '2026-09-16 07:30:39', NULL, NULL, NULL, 0, 1, NULL),
(3, 'MIDMONTH', 'âš¡ Mid-Month Flash Splash', 'Special mid-month flash sale!', 'Percentage', 'FLASH', '25.00', '2026-09-15 16:00:00', '2026-09-17 15:59:59', 'Asia/Manila', 'BOOKING_DATE', 1, 0, NULL, 0, 'Active', '2026-09-16 07:30:39', '2026-09-16 07:30:39', NULL, NULL, NULL, 0, 1, NULL);

-- promotion_packages (0 rows)
DELETE FROM `promotion_packages`;

-- promotion_services (0 rows)
DELETE FROM `promotion_services`;

-- tourist_spots (0 rows)
DELETE FROM `tourist_spots`;

SET FOREIGN_KEY_CHECKS = 1;
