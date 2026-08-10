/*
SQLyog Ultimate v9.62 
MySQL - 8.0.46 : Database - ecotour_db
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/`ecotour_db` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `ecotour_db`;

/*Table structure for table `announcements` */

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

/*Data for the table `announcements` */

/*Table structure for table `audit_logs` */

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

/*Data for the table `audit_logs` */

/*Table structure for table `booking_items` */

DROP TABLE IF EXISTS `booking_items`;

CREATE TABLE `booking_items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `booking_id` int NOT NULL,
  `service_id` int NOT NULL,
  `service_name` varchar(100) NOT NULL,
  `unit_price` decimal(10,2) NOT NULL,
  `quantity` int DEFAULT '1',
  `subtotal` decimal(10,2) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `booking_id` (`booking_id`),
  CONSTRAINT `booking_items_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `booking_items` */

/*Table structure for table `bookings` */

DROP TABLE IF EXISTS `bookings`;

CREATE TABLE `bookings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `booking_number` varchar(30) NOT NULL,
  `user_id` int DEFAULT NULL,
  `client_name` varchar(100) NOT NULL,
  `client_email` varchar(100) DEFAULT NULL,
  `client_phone` varchar(20) DEFAULT NULL,
  `booking_date` date NOT NULL,
  `arrival_time` varchar(20) DEFAULT NULL,
  `pax` int DEFAULT '1',
  `total_amount` decimal(10,2) NOT NULL DEFAULT '0.00',
  `payment_method` varchar(30) DEFAULT 'Cash',
  `status` enum('Pending','Confirmed','Checked In','Completed','Cancelled','Rejected') DEFAULT 'Pending',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `booking_number` (`booking_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `bookings` */

/*Table structure for table `gallery` */

DROP TABLE IF EXISTS `gallery`;

CREATE TABLE `gallery` (
  `image_id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(100) DEFAULT NULL,
  `image` varchar(255) NOT NULL,
  `category` varchar(50) DEFAULT NULL,
  `uploaded_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`image_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `gallery` */

/*Table structure for table `payments` */

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

/*Data for the table `payments` */

/*Table structure for table `reservation_details` */

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

/*Data for the table `reservation_details` */

/*Table structure for table `reservations` */

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
  PRIMARY KEY (`reservation_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `reservations_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `reservations` */

/*Table structure for table `revenue_shares` */

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

/*Data for the table `revenue_shares` */

/*Table structure for table `reviews` */

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

/*Data for the table `reviews` */

/*Table structure for table `services` */

DROP TABLE IF EXISTS `services`;

CREATE TABLE `services` (
  `service_id` int NOT NULL AUTO_INCREMENT,
  `service_code` varchar(20) NOT NULL,
  `service_name` varchar(100) NOT NULL,
  `category` varchar(50) NOT NULL,
  `description` text,
  `price` decimal(10,2) NOT NULL DEFAULT '0.00',
  `unit` varchar(30) DEFAULT 'unit',
  `total_capacity` int DEFAULT '10',
  `available_qty` int DEFAULT '10',
  `image_url` varchar(255) DEFAULT NULL,
  `status` enum('Active','Inactive') DEFAULT 'Active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`service_id`),
  UNIQUE KEY `service_code` (`service_code`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `services` */

insert  into `services`(`service_id`,`service_code`,`service_name`,`category`,`description`,`price`,`unit`,`total_capacity`,`available_qty`,`image_url`,`status`,`created_at`,`updated_at`) values (1,'DSVC-001','Cold Spring Pool Entrance Ticket','Entrance','Day pass access to natural cold spring pool','100.00','head',300,300,'/src/assets/images/services/swimming.png','Active','2026-08-05 02:03:40','2026-08-05 02:03:40'),(2,'DSVC-002','Standard Open Cottage','Cottage','Shaded native open cottage near pool','600.00','day',10,10,'/src/assets/images/services/cottage.png','Active','2026-08-05 02:03:40','2026-08-05 02:03:40'),(3,'DSVC-003','Resort Table & Chairs Set','Rental','1 Table + 4 monoblock chairs','250.00','day',15,15,'/src/assets/images/services/table.png','Active','2026-08-05 02:03:40','2026-08-05 02:03:40'),(4,'DSVC-004','Life Vest / Safety Gear','Safety','Adult & Kid safety flotation vest','50.00','head',30,30,'/src/assets/images/services/lifevest.png','Active','2026-08-05 02:03:40','2026-08-05 02:03:40'),(5,'DSVC-005','Videoke Karaoke System','Entertainment','Heavy-duty Videoke sound system','500.00','day',4,4,'/src/assets/images/services/videoke.png','Active','2026-08-05 02:03:40','2026-08-05 02:03:40'),(6,'DSVC-006','Kayak / Floating Pad Rental','Water Activity','1-hour kayak & water pad rental','300.00','hour',5,5,'/src/assets/images/services/floating.png','Active','2026-08-05 02:03:40','2026-08-05 02:03:40'),(7,'DSVC-007','Camping Pitch & Tent','Accommodation','Overnight camping slot & tent','450.00','night',8,8,'/src/assets/images/services/tent.png','Active','2026-08-05 02:03:40','2026-08-05 02:03:40'),(8,'DSVC-008','Aircon Kubo Guest Room','Accommodation','Private aircon room with bed & bath','1500.00','night',4,4,'/src/assets/images/services/room.png','Active','2026-08-05 02:03:40','2026-08-05 02:03:40'),(9,'DSVC-009','Private Event Pavilion','Event','Private pavilion for family gatherings & events','3500.00','event',2,2,'/src/assets/images/services/event.png','Active','2026-08-05 02:03:40','2026-08-05 02:03:40'),(10,'DSVC-010','Buffet & Catering Station','Food','Native buffet catering package','450.00','head',50,50,'/src/assets/images/services/buffet.png','Active','2026-08-05 02:03:40','2026-08-05 02:03:40'),(11,'DSVC-011','Secured Resort Parking Slot','Parking','Safe vehicle parking for cars & vans','50.00','vehicle',40,40,'/src/assets/images/services/parking.png','Active','2026-08-05 02:03:40','2026-08-05 02:03:40');

/*Table structure for table `settings` */

DROP TABLE IF EXISTS `settings`;

CREATE TABLE `settings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `setting_key` varchar(50) NOT NULL,
  `setting_value` text NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `setting_key` (`setting_key`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `settings` */

insert  into `settings`(`id`,`setting_key`,`setting_value`,`description`,`updated_at`) values (1,'resort_name','Duangon Cold Spring','Official Resort Name','2026-08-05 00:46:03'),(2,'location','Bilar, Bohol, Philippines','Resort Address','2026-08-05 00:46:03'),(3,'max_daily_capacity','300','Maximum daily visitor capacity','2026-08-05 00:46:03'),(4,'park_share_pct','70','Resort/Park Revenue Share Percentage','2026-08-05 00:46:03'),(5,'barangay_share_pct','20','Barangay Revenue Share Percentage','2026-08-05 00:46:03'),(6,'guide_share_pct','10','Guide Association Share Percentage','2026-08-05 00:46:03');

/*Table structure for table `tourist_spots` */

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

/*Data for the table `tourist_spots` */

/*Table structure for table `users` */

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
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `users` */

insert  into `users`(`user_id`,`user_number`,`fname`,`mname`,`lname`,`gender`,`birthdate`,`address`,`contact_no`,`email`,`username`,`password`,`hashed_password`,`role`,`status`,`created_at`,`updated_at`,`approved_by`,`approved_at`) values (1,NULL,'System','Administrator','Root','Male','2000-01-01','Bilar, Bohol','09123456789','admin@ecotourvista.com','admin','admin123',NULL,'admin','Approved','2026-08-03 03:48:22','2026-08-03 03:48:22',NULL,NULL),(3,NULL,'Juan','D.','Dela Cruz','Male','1998-05-15','Duangon, Zamora, Bilar, Bohol','09171234567','staff@ecotourvista.com','staff01','staff123',NULL,'staff','Approved','2026-08-04 07:34:25','2026-08-04 07:34:25',NULL,NULL),(5,NULL,'Maria','S.','Santos','Female','2001-08-20','Bilar, Bohol','09981234567','client@ecotourvista.com','client01','client123',NULL,'client','Approved','2026-08-04 07:34:35','2026-08-04 07:34:35',NULL,NULL);

/*Table structure for table `walkin_details` */

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

/*Data for the table `walkin_details` */

/*Table structure for table `walkin_transactions` */

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

/*Data for the table `walkin_transactions` */

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
