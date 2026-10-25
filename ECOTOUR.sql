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
) ENGINE=InnoDB AUTO_INCREMENT=52 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `audit_logs` */

insert  into `audit_logs`(`log_id`,`user_id`,`action`,`description`,`created_at`) values (1,1,'USER_PASSWORD_CHANGED','User ID 1 changed their password via profile settings.','2026-09-29 20:49:47'),(2,1,'USER_PASSWORD_CHANGED','User ID 1 changed their password via profile settings.','2026-09-29 21:03:46'),(3,NULL,'AUTO_DAILY_CLOSURE','System automatically completed Walk-In #WI-20260902-283 for ness. Reason: END-OF-DAY AUTOMATIC CLOSURE. Services released.','2026-09-29 22:00:45'),(4,NULL,'AUTO_DAILY_CLOSURE','System automatically completed Walk-In #WI-20260924-899 for Aileen. Reason: END-OF-DAY AUTOMATIC CLOSURE. Services released.','2026-09-29 22:00:45'),(5,NULL,'SERVICE_STATUS_CHANGED','Service #5 status updated: {\"manual_status\":\"MAINTENANCE\"}','2026-10-05 20:59:33'),(6,NULL,'SERVICE_STATUS_CHANGED','Service #5 status updated: {\"manual_status\":null}','2026-10-05 20:59:43'),(7,5,'USER_PASSWORD_CHANGED','User ID 5 changed their password via profile settings.','2026-10-05 21:10:10'),(8,1,'USER_APPROVED','Admin approved account for aileenlagura16@gmail.com. Default password generated.','2026-10-05 22:18:33'),(9,1,'USER_APPROVED','Admin approved account for laguraaileen30@gmail.com. Default password generated.','2026-10-05 23:10:41'),(10,NULL,'Daily Reset','Automatic 12:00 AM Midnight Daily Tally Reset. New business day started: 2026-10-06.','2026-10-06 00:00:05'),(11,3,'DAILY_TALLY_SUBMITTED','Staff Cashier (Juan Dela Cruz) submitted Daily Sales Tally for 2026-10-20 - Total Cash: ₱0 (0 visitors)','2026-10-20 03:15:33'),(12,1,'DAILY_TALLY_ACKNOWLEDGED','Admin (Admin) acknowledged & verified Daily Sales Tally for 2026-10-20','2026-10-20 03:16:39'),(13,NULL,'FACILITY_ASSIGNED','Cottage 07 assigned to REF-2026-672611 (AILEEN LAGURA) for 2026-10-05','2026-10-20 03:17:11'),(14,NULL,'RESERVATION_CONFIRMATION_REQUESTED','staff emailed aileenlagura16@gmail.com to confirm REF-2026-672611 (deadline 2026-10-20T19:17:06.225Z)','2026-10-20 03:17:11'),(15,NULL,'FACILITY_ASSIGNED','Videoke 03 assigned to REF-2026-672611 (AILEEN LAGURA) for 2026-10-05','2026-10-20 03:30:54'),(16,NULL,'FACILITY_ASSIGNED','Kayak 03 assigned to REF-2026-672611 (AILEEN LAGURA) for 2026-10-05','2026-10-20 03:30:55'),(17,NULL,'FACILITY_ASSIGNED','Tent Pitch 08 assigned to REF-2026-672611 (AILEEN LAGURA) for 2026-10-05','2026-10-20 03:30:56'),(18,NULL,'FACILITY_ASSIGNED','Kubo Room 03 assigned to REF-2026-672611 (AILEEN LAGURA) for 2026-10-05','2026-10-20 03:30:58'),(19,NULL,'FACILITY_ASSIGNED','Pavilion 02 assigned to REF-2026-672611 (AILEEN LAGURA) for 2026-10-05','2026-10-20 03:30:58'),(20,NULL,'FACILITY_ASSIGNED','Parking Slot 23 assigned to REF-2026-672611 (AILEEN LAGURA) for 2026-10-05','2026-10-20 03:31:00'),(21,1,'USER_APPROVED','Admin approved account for ailleenlagura@gmail.com. Default password generated.','2026-10-20 22:18:00'),(22,NULL,'RESERVATION_CONFIRMATION_REQUESTED','staff emailed ailleenlagura@gmail.com to confirm REF-2026-868517 (deadline 2026-10-21T14:21:39.486Z)','2026-10-20 22:21:43'),(23,NULL,'FACILITY_ASSIGNED','Cottage 03 assigned to REF-2026-868517 (AILEEN LAGURAa) for 2026-10-23','2026-10-20 22:22:44'),(24,NULL,'FACILITY_ASSIGNED','Videoke 02 assigned to REF-2026-868517 (AILEEN LAGURAa) for 2026-10-23','2026-10-20 22:22:46'),(25,NULL,'FACILITY_ASSIGNED','Parking Slot 18 assigned to REF-2026-868517 (AILEEN LAGURAa) for 2026-10-23','2026-10-20 22:22:49'),(28,11,'USER_PASSWORD_CHANGED','User ID 11 changed their password via profile settings.','2026-10-20 22:48:26'),(29,NULL,'RESERVATION_PAYMENT','OR-2026-000001: ₱960.00 50% reservation fee for REF-2026-868517 (AILEEN LAGURAa) by Staff Cashier','2026-10-20 22:50:21'),(30,NULL,'RESERVATION_PAYMENT','OR-2026-000002: ₱960.00 payment for REF-2026-868517 (AILEEN LAGURAa) by Staff Cashier','2026-10-20 22:51:10'),(31,NULL,'RESERVATION_ADDON_PAID','Receipt #OR-2026-000003: Staff Cashier added services to REF-2026-868517 (AILEEN LAGURAa) - Add-on amount: 850 (previous total 1920.00 not re-charged)','2026-10-20 22:51:38'),(32,3,'UPDATE_RESERVATION_STATUS','Reservation 5 status updated to \"Using Services\" at 2026-10-20T14:52:05.550Z','2026-10-20 22:52:05'),(33,3,'UPDATE_RESERVATION_STATUS','Reservation 5 status updated to \"Completed\" at 2026-10-20T14:52:09.384Z','2026-10-20 22:52:09'),(34,NULL,'RESERVATION_PAYMENT','OR-2026-000004: ₱10,200.00 payment for REF-2026-672611 (AILEEN LAGURA) by Staff Cashier','2026-10-20 22:52:22'),(35,NULL,'RESERVATION_PAYMENT','OR-2026-000005: ₱1,920.00 payment for REF-2026-879563 (AILEEN LAGURA) by Staff Cashier','2026-10-20 22:52:29'),(36,NULL,'RESERVATION_PAYMENT','OR-2026-000006: ₱260.00 payment for BK-2026-602584 (Test) by Staff Cashier','2026-10-20 22:52:31'),(37,NULL,'RESERVATION_PAYMENT','OR-2026-000025: ₱960.00 50% reservation fee for REF-2026-868517 (AILEEN LAGURAa) by Cashier Test','2026-10-20 22:55:48'),(38,NULL,'RESERVATION_PAYMENT','OR-2026-000028: ₱1,810.00 payment for REF-2026-868517 (AILEEN LAGURAa) by Cashier Test','2026-10-20 22:55:48'),(39,3,'UPDATE_RESERVATION_STATUS','Reservation 4 status updated to \"Using Services\" at 2026-10-20T15:39:28.914Z','2026-10-20 23:39:28'),(40,3,'UPDATE_RESERVATION_STATUS','Reservation 4 status updated to \"Completed\" at 2026-10-20T15:39:31.256Z','2026-10-20 23:39:31'),(41,3,'UPDATE_RESERVATION_STATUS','Reservation 3 status updated to \"Using Services\" at 2026-10-20T15:39:33.930Z','2026-10-20 23:39:33'),(42,3,'UPDATE_RESERVATION_STATUS','Reservation 3 status updated to \"Completed\" at 2026-10-20T15:39:36.815Z','2026-10-20 23:39:36'),(43,3,'UPDATE_RESERVATION_STATUS','Reservation 5 status updated to \"Cancelled\" at 2026-10-20T15:43:37.577Z','2026-10-20 23:43:37'),(44,NULL,'RESERVATION_PAYMENT','OR-2026-000025: ₱5,050.00 50% reservation fee for REF-2026-625204 (AILEEN LAGURA) by Juan Dela Cruz','2026-10-21 10:02:59'),(45,NULL,'RESERVATION_PAYMENT','OR-2026-000030: ₱5,050.00 payment for REF-2026-625204 (AILEEN LAGURA) by Juan Dela Cruz','2026-10-21 10:03:06'),(46,1,'USER_APPROVED','Admin approved account for melvagumapac48@gmail.com. Default password generated.','2026-10-21 10:05:37'),(47,NULL,'RESERVATION_PAYMENT','OR-2026-000031: ₱405.00 50% reservation fee for REF-2026-761792 (ALEX LAGURA) by Juan Dela Cruz','2026-10-21 10:11:07'),(48,NULL,'RESERVATION_PAYMENT','OR-2026-000032: ₱405.00 payment for REF-2026-761792 (ALEX LAGURA) by Melva Gumapac','2026-10-21 10:11:57'),(49,NULL,'RESERVATION_PAYMENT','OR-2026-000033: ₱1,920.00 payment for REF-2026-849755 (EVELYN LAGURAa) by Melva Gumapac','2026-10-21 10:12:05'),(50,12,'UPDATE_RESERVATION_STATUS','Reservation 9 status updated to \"Using Services\" at 2026-10-21T02:12:22.371Z','2026-10-21 10:12:22'),(51,NULL,'RESERVATION_ADDON_PAID','Receipt #OR-2026-000009: Melva Gumapac added services to REF-2026-849755 (EVELYN LAGURAa) - Add-on amount: 300 (previous total 1920.00 not re-charged)','2026-10-21 10:12:42');

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
  `item_type` varchar(20) DEFAULT NULL COMMENT 'PACKAGE | TICKET | FEE | ADDON | DAMAGE_FEE',
  PRIMARY KEY (`id`),
  KEY `booking_id` (`booking_id`),
  CONSTRAINT `booking_items_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `booking_items` */

insert  into `booking_items`(`id`,`booking_id`,`service_id`,`service_name`,`unit_price`,`quantity`,`subtotal`,`item_type`) values (1,2,0,'Adult Entrance Ticket','100.00',2,'200.00','TICKET'),(2,2,0,'Barangay Environmental Fee','30.00',2,'60.00','FEE'),(3,3,0,'Barkada Fun Deal','1920.00',1,'1920.00','PACKAGE'),(4,4,0,'Unlimited All-Access Package','10100.00',1,'10100.00','PACKAGE'),(5,4,0,'Damage Fee - glass','100.00',1,'100.00','DAMAGE_FEE'),(6,5,0,'Barkada Fun Deal','1920.00',1,'1920.00','PACKAGE'),(7,5,2,'Standard Open Cottage','600.00',1,'600.00','ADDON'),(8,5,3,'Resort Table & Chairs Set','250.00',1,'250.00','ADDON'),(10,7,0,'Unlimited All-Access Package','10100.00',1,'10100.00','PACKAGE'),(11,8,0,'Quick Dip Deal','810.00',1,'810.00','PACKAGE'),(12,9,0,'Barkada Fun Deal','1920.00',1,'1920.00','PACKAGE'),(13,9,6,'Kayak / Floating Pad Rental','300.00',1,'300.00','ADDON');

/*Table structure for table `bookings` */

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
  `payment_status` varchar(50) DEFAULT 'Unpaid',
  `status` varchar(50) DEFAULT 'Pending',
  `catered_by` varchar(100) DEFAULT NULL,
  `catered_at` datetime DEFAULT NULL,
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
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `bookings` */

insert  into `bookings`(`id`,`booking_number`,`user_id`,`package_id`,`client_name`,`client_email`,`client_phone`,`booking_date`,`arrival_time`,`pax`,`total_amount`,`discount_amount`,`promo_code`,`payment_method`,`payment_status`,`status`,`catered_by`,`catered_at`,`notes`,`checked_in_at`,`checked_out_at`,`updated_at`,`created_at`,`promotion_id`,`applied_promo_name`,`original_value`,`base_package_price`,`booking_type`,`reservation_fee`,`fee_status`,`amount_paid`,`confirmation_status`,`confirmation_sent_at`,`confirmation_deadline`,`confirmation_token`,`confirmation_responded_at`) values (2,'BK-2026-602584',NULL,NULL,'Test',NULL,NULL,'2026-10-10','09:00 AM',2,'260.00','0.00',NULL,'Cash','Paid','Paid',NULL,NULL,NULL,NULL,NULL,'2026-10-20 23:41:31','2026-10-05 22:04:27',NULL,NULL,'260.00','0.00','TICKETS_ONLY','130.00','PAID','260.00',NULL,NULL,NULL,NULL,NULL),(3,'REF-2026-879563',8,3,'AILEEN LAGURA','aileenlagura16@gmail.com','0994512277','2026-10-05','09:00 AM',10,'1920.00','480.00',NULL,'Cash on Arrival','Paid','Completed',NULL,NULL,NULL,NULL,NULL,'2026-10-20 23:39:36','2026-10-05 22:34:33',NULL,NULL,'2400.00','1920.00','PACKAGE_ONLY','960.00','PAID','1920.00',NULL,NULL,NULL,NULL,NULL),(4,'REF-2026-672611',8,8,'AILEEN LAGURA','aileenlagura16@gmail.com','0994512277','2026-10-05','09:00 AM',10,'10200.00','1900.00',NULL,'Cash on Arrival','Paid','Completed',NULL,NULL,NULL,NULL,NULL,'2026-10-20 23:39:31','2026-10-05 22:35:17',NULL,NULL,'12000.00','10100.00','PACKAGE_ONLY','5050.00','PAID','10200.00','CONFIRMED','2026-10-20 03:17:06','2026-10-21 03:17:06',NULL,'2026-10-20 23:39:01'),(5,'REF-2026-868517',11,3,'AILEEN LAGURAa','ailleenlagura@gmail.com','2222222222222222','2026-10-23','07:00 AM',10,'2770.00','480.00',NULL,'Cash on Arrival','Unpaid','Cancelled',NULL,NULL,NULL,NULL,NULL,'2026-10-20 23:43:37','2026-10-20 22:20:30',NULL,NULL,'2400.00','1920.00','PACKAGE_ONLY','960.00','UNPAID','0.00','CONFIRMED','2026-10-20 22:21:39','2026-10-21 22:21:39',NULL,'2026-10-20 23:37:55'),(7,'REF-2026-625204',8,8,'AILEEN LAGURA','aileenlagura16@gmail.com','0994512277','2026-10-20','09:00 AM',10,'10100.00','1900.00',NULL,'Cash on Arrival','Paid','Paid',NULL,NULL,NULL,NULL,NULL,'2026-10-21 10:03:06','2026-10-20 23:40:01',NULL,NULL,'12000.00','10100.00','PACKAGE_ONLY','5050.00','PAID','10100.00',NULL,NULL,NULL,NULL,NULL),(8,'REF-2026-761792',10,1,'ALEX LAGURA','laguraaileen30@gmail.com','09945122977','2026-10-21','09:00 AM',5,'810.00','90.00',NULL,'Cash on Arrival','Paid','Paid',NULL,NULL,NULL,NULL,NULL,'2026-10-21 10:11:57','2026-10-21 10:07:54',NULL,NULL,'900.00','810.00','PACKAGE_ONLY','405.00','PAID','810.00',NULL,NULL,NULL,NULL,NULL),(9,'REF-2026-849755',11,3,'EVELYN LAGURAa','ailleenlagura@gmail.com','2222222222222222','2026-10-21','09:00 AM',10,'2220.00','480.00',NULL,'Cash on Arrival','Paid','Using Services',NULL,NULL,NULL,NULL,NULL,'2026-10-21 10:12:42','2026-10-21 10:09:33',NULL,NULL,'2400.00','1920.00','PACKAGE_ONLY','960.00','PAID','1920.00',NULL,NULL,NULL,NULL,NULL);

/*Table structure for table `capacity_limits` */

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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `capacity_limits` */

insert  into `capacity_limits`(`id`,`service_id`,`daily_capacity`,`created_at`,`updated_at`) values (1,1,300,'2026-09-16 15:13:34','2026-09-16 15:13:34');

/*Table structure for table `daily_cash_history` */

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
  `notes` text,
  `cashier_name` varchar(100) DEFAULT NULL,
  `total_transactions` int DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `date` (`date`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `daily_cash_history` */

insert  into `daily_cash_history`(`id`,`date`,`total_visitors`,`entrance_revenue`,`service_revenue`,`total_cash_revenue`,`park_share`,`barangay_share`,`municipal_share`,`saved_by`,`status`,`created_at`,`notes`,`cashier_name`,`total_transactions`) values (1,'2026-08-10',0,'0.00','0.00','0.00','0.00','0.00','0.00','Administrator','Frozen & Saved','2026-08-11 03:09:23',NULL,NULL,0),(4,'2026-08-07',14,'1720.00','3050.00','4770.00','3339.00','954.00','477.00','Administrator','Frozen & Saved','2026-08-11 03:10:00',NULL,NULL,0),(5,'2026-08-06',43,'5230.00','16450.00','21680.00','15176.00','4336.00','2168.00','Administrator','Frozen & Saved','2026-08-11 03:10:07',NULL,NULL,0),(6,'2026-08-05',4,'520.00','800.00','1320.00','924.00','264.00','132.00','Administrator','Frozen & Saved','2026-08-11 03:10:08',NULL,NULL,0),(7,'2026-08-08',0,'0.00','0.00','0.00','0.00','0.00','0.00','Administrator','Frozen & Saved','2026-08-11 03:10:10',NULL,NULL,0),(8,'2026-08-09',0,'0.00','0.00','0.00','0.00','0.00','0.00','Administrator','Frozen & Saved','2026-08-11 03:10:11',NULL,NULL,0),(12,'2026-08-21',1,'0.00','0.00','16130.00','11291.00','3226.00','1613.00','Administrator','Frozen & Saved','2026-08-21 20:37:26',NULL,NULL,0),(13,'2026-10-20',0,'0.00','0.00','0.00','0.00','0.00','0.00','Juan Dela Cruz (Verified by Admin)','Verified & Acknowledged','2026-10-20 03:15:33','[Evening Shift (4PM - 10PM)] Cash drawer count verified and remitted to Admin.','Juan Dela Cruz',0);

/*Table structure for table `damage_reports` */

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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `damage_reports` */

insert  into `damage_reports`(`id`,`booking_id`,`inspection_id`,`item_name`,`damage_type`,`description`,`evidence_url`,`repair_cost`,`labor_cost`,`recommended_fee`,`final_fee`,`status`,`reported_by`,`approved_by`,`created_at`,`updated_at`) values (1,4,2,'glass','Cracked Screen / Glass','glass broken 3 pcs.',NULL,'0.00','0.00','100.00','100.00','Approved',3,1,'2026-10-20 00:46:38','2026-10-20 02:10:18'),(2,4,3,'ngfjhft','Stained / Burned Linen','jhtyriyr6t',NULL,'0.00','0.00','1.00','0.00','Waived',3,1,'2026-10-20 03:32:41','2026-10-20 03:33:10');

/*Table structure for table `facility_inspections` */

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
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `facility_inspections` */

insert  into `facility_inspections`(`id`,`booking_id`,`type`,`status`,`inspected_by`,`created_at`) values (1,4,'Checkout','Damage Found',3,'2026-10-20 00:45:42'),(2,4,'Checkout','Damage Found',3,'2026-10-20 00:46:38'),(3,4,'Checkout','Damage Found',3,'2026-10-20 03:32:41');

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

/*Table structure for table `inspection_items` */

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
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `inspection_items` */

insert  into `inspection_items`(`id`,`inspection_id`,`item_name`,`condition`,`notes`) values (1,1,'General Inspection','Damaged','broken glass'),(2,2,'glass','Damaged','Cracked Screen / Glass: glass broken 3 pcs.'),(3,3,'ngfjhft','Damaged','Stained / Burned Linen: jhtyriyr6t');

/*Table structure for table `notifications` */

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
) ENGINE=InnoDB AUTO_INCREMENT=264 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `notifications` */

insert  into `notifications`(`id`,`user_id`,`role_target`,`title`,`message`,`type`,`reference_id`,`is_read`,`created_at`) values (1,NULL,'all','Reservation #1 Status Updated','Reservation 1 has moved to \"Using Services\".','booking','1',1,'2026-08-21 20:34:03'),(2,NULL,'all','Reservation #1 Status Updated','Reservation 1 has moved to \"Completed\".','booking','1',1,'2026-08-21 20:34:03'),(3,NULL,'all','Reservation #1 Status Updated','Reservation 1 has moved to \"Pending\".','booking','1',1,'2026-08-21 20:34:03'),(4,NULL,'all','Reservation #1 Status Updated','Reservation 1 has moved to \"Paid\".','booking','1',1,'2026-08-21 20:36:06'),(5,NULL,'all','Reservation #1 Status Updated','Reservation 1 has moved to \"Using Services\".','booking','1',1,'2026-08-21 20:36:11'),(6,NULL,'all','Reservation #1 Status Updated','Reservation 1 has moved to \"Completed\".','booking','1',1,'2026-08-21 20:36:21'),(7,NULL,'staff','New Reservation (REF-2026-572046)','AILEEN LAGURA booked Duangon Walk-In Day Pass for 2026-08-21 (3 guests). Total: ₱540','booking','REF-2026-572046',1,'2026-08-21 20:40:07'),(8,NULL,'all','Reservation #2 Status Updated','Reservation 2 has moved to \"Paid\".','booking','2',1,'2026-08-21 20:40:31'),(9,NULL,'all','Reservation #2 Status Updated','Reservation 2 has moved to \"Using Services\".','booking','2',1,'2026-08-21 20:40:58'),(10,NULL,'all','Reservation #2 Status Updated','Reservation 2 has moved to \"Completed\".','booking','2',1,'2026-08-21 20:41:15'),(11,NULL,'staff','New Reservation (BK-2026-981519)','Rica booked Standard Open Cottage + Resort Day Pass for 2026-08-21 (4 guests). Total: ₱3450','booking','BK-2026-981519',1,'2026-08-21 20:44:50'),(12,NULL,'staff','New Reservation (BK-2026-125379)','Rica booked Standard Open Cottage + Resort Day Pass for 2026-08-21 (4 guests). Total: ₱3450','booking','BK-2026-125379',1,'2026-08-21 20:44:50'),(13,NULL,'all','Reservation #3 Status Updated','Reservation 3 has moved to \"Paid\".','booking','3',1,'2026-08-21 20:45:35'),(14,NULL,'all','Reservation #4 Status Updated','Reservation 4 has moved to \"Cancelled\".','booking','4',1,'2026-08-21 20:48:40'),(15,NULL,'all','Reservation #4 Status Updated','Reservation 4 has moved to \"Cancelled\".','booking','4',1,'2026-08-21 20:48:49'),(16,NULL,'all','Reservation #4 Status Updated','Reservation 4 has moved to \"Cancelled\".','booking','4',1,'2026-08-21 20:51:05'),(17,NULL,'all','Reservation #4 Status Updated','Reservation 4 has moved to \"Cancelled\".','booking','4',1,'2026-08-21 20:51:09'),(18,NULL,'all','Reservation #4 Status Updated','Reservation 4 has moved to \"Paid\".','booking','4',1,'2026-08-21 20:51:14'),(19,NULL,'all','Reservation #4 Status Updated','Reservation 4 has moved to \"Using Services\".','booking','4',1,'2026-08-21 20:51:25'),(20,NULL,'all','Reservation #4 Status Updated','Reservation 4 has moved to \"Completed\".','booking','4',1,'2026-08-21 20:57:34'),(21,NULL,'all','Reservation #3 Status Updated','Reservation 3 has moved to \"Using Services\".','booking','3',1,'2026-08-21 20:57:44'),(22,NULL,'all','Reservation #3 Status Updated','Reservation 3 has moved to \"Completed\".','booking','3',1,'2026-08-21 21:56:37'),(23,NULL,'all','Announcement: Summer','Message','announcement','3',1,'2026-08-23 15:32:23'),(24,NULL,'staff','New Reservation (BK-2026-198806)','AIlLEEN LAGURA booked Cold Spring Resort Day Pass for 2026-08-23 (4 guests). Total: ₱410','booking','BK-2026-198806',1,'2026-08-24 06:44:11'),(25,NULL,'staff','New Reservation (BK-2026-184630)','AIlLEEN LAGURA booked Cold Spring Resort Day Pass for 2026-08-23 (4 guests). Total: ₱410','booking','BK-2026-184630',1,'2026-08-24 06:44:11'),(26,NULL,'staff','New Reservation (BK-2026-645686)','AILEEN LAGURA booked Cold Spring Resort Day Pass for 2026-08-23 (1 guests). Total: ₱1130','booking','BK-2026-645686',1,'2026-08-24 06:44:43'),(27,NULL,'staff','New Reservation (BK-2026-964817)','AILEEN LAGURA booked Cold Spring Resort Day Pass for 2026-08-23 (1 guests). Total: ₱1130','booking','BK-2026-964817',1,'2026-08-24 06:44:43'),(28,NULL,'all','Reservation #8 Status Updated','Reservation 8 has moved to \"Cancelled\".','booking','8',1,'2026-08-24 06:45:14'),(29,NULL,'all','Reservation #8 Status Updated','Reservation 8 has moved to \"Cancelled\".','booking','8',1,'2026-08-24 06:45:27'),(30,NULL,'all','Reservation #7 Status Updated','Reservation 7 has moved to \"Cancelled\".','booking','7',1,'2026-08-24 06:45:45'),(31,NULL,'all','Reservation #8 Status Updated','Reservation 8 has moved to \"Paid\".','booking','8',1,'2026-08-24 06:46:01'),(32,NULL,'all','Reservation #8 Status Updated','Reservation 8 has moved to \"Using Services\".','booking','8',1,'2026-08-24 06:48:50'),(33,NULL,'all','Reservation #7 Status Updated','Reservation 7 has moved to \"Cancelled\".','booking','7',1,'2026-08-24 06:49:21'),(34,NULL,'all','Reservation #8 Status Updated','Reservation 8 has moved to \"Cancelled\".','booking','8',1,'2026-08-24 06:49:28'),(35,NULL,'all','Reservation #7 Status Updated','Reservation 7 has moved to \"Paid\".','booking','7',1,'2026-08-24 06:50:09'),(36,NULL,'all','Reservation #7 Status Updated','Reservation 7 has moved to \"Using Services\".','booking','7',1,'2026-08-24 06:50:14'),(37,NULL,'all','Reservation #7 Status Updated','Reservation 7 has moved to \"Completed\".','booking','7',1,'2026-08-24 06:50:20'),(38,NULL,'all','Reservation #7 Status Updated','Reservation 7 has moved to \"Cancelled\".','booking','7',1,'2026-08-24 06:53:00'),(39,NULL,'all','Reservation #6 Status Updated','Reservation 6 has moved to \"Cancelled\".','booking','6',1,'2026-08-24 06:58:43'),(40,NULL,'all','Reservation #5 Status Updated','Reservation 5 has moved to \"Paid\".','booking','5',1,'2026-08-24 06:58:53'),(41,NULL,'all','Reservation #5 Status Updated','Reservation 5 has moved to \"Using Services\".','booking','5',1,'2026-08-24 07:01:29'),(42,NULL,'all','Reservation #7 Status Updated','Reservation 7 has moved to \"Paid (Cash - Gate Verified)\".','booking','7',1,'2026-08-24 07:02:49'),(43,NULL,'all','Reservation #1 Status Updated','Reservation 1 has moved to \"Cancelled\".','booking','1',1,'2026-08-24 07:05:19'),(44,NULL,'all','Reservation #7 Status Updated','Reservation 7 has moved to \"Using Services\".','booking','7',1,'2026-08-24 18:29:01'),(45,NULL,'all','Reservation #7 Status Updated','Reservation 7 has moved to \"Completed\".','booking','7',1,'2026-08-24 18:29:04'),(46,NULL,'all','Reservation #5 Status Updated','Reservation 5 has moved to \"Completed\".','booking','5',1,'2026-08-24 18:29:08'),(47,NULL,'staff','New Reservation (REG-20260824-8583)','ai booked Duangon Resort Day Registration for 2026-08-24 (3 guests). Total: ₱330','booking','REG-20260824-8583',1,'2026-08-24 18:49:19'),(48,NULL,'all','Reservation #9 Status Updated','Reservation 9 has moved to \"Paid\".','booking','9',1,'2026-08-24 18:49:43'),(49,NULL,'all','Reservation #9 Status Updated','Reservation 9 has moved to \"Using Services\".','booking','9',1,'2026-08-24 18:49:54'),(50,NULL,'all','Reservation #9 Status Updated','Reservation 9 has moved to \"Completed\".','booking','9',1,'2026-08-24 18:53:35'),(51,NULL,'staff','New Reservation (REG-20260901-8546)','jhon booked Duangon Resort Day Registration for 2026-09-01 (3 guests). Total: ₱320','booking','REG-20260901-8546',0,'2026-09-01 22:41:28'),(58,NULL,'all','Reservation #12 Status Updated','Reservation 12 has moved to \"Paid\".','booking','12',0,'2026-09-01 23:37:59'),(59,NULL,'all','Reservation #12 Status Updated','Reservation 12 has moved to \"Using Services\".','booking','12',0,'2026-09-01 23:39:39'),(60,NULL,'all','Reservation #12 Status Updated','Reservation 12 has moved to \"Completed\".','booking','12',0,'2026-09-01 23:39:53'),(61,NULL,'staff','New Reservation (BK-20260902-909)','aliii booked Adult Entrance Ticket for 2026-09-02 (2 guests). Total: ₱130','booking','BK-20260902-909',0,'2026-09-02 00:07:43'),(62,NULL,'staff','New Reservation (BK-20260902-544)','aeee booked Adult Entrance Ticket for 2026-09-02 (1 guests). Total: ₱130','booking','BK-20260902-544',0,'2026-09-02 00:08:01'),(63,NULL,'all','Reservation #14 Status Updated','Reservation 14 has moved to \"Paid\".','booking','14',0,'2026-09-02 00:08:14'),(64,NULL,'all','Reservation #14 Status Updated','Reservation 14 has moved to \"Using Services\".','booking','14',0,'2026-09-02 00:22:28'),(65,NULL,'all','Reservation #14 Status Updated','Reservation 14 has moved to \"Completed\".','booking','14',0,'2026-09-02 00:22:55'),(66,NULL,'all','Reservation #13 Status Updated','Reservation 13 has moved to \"Using Services\".','booking','13',1,'2026-09-02 00:40:41'),(67,NULL,'staff','New Reservation (BK-2026-123123)','melva booked Cold Spring Resort Day Pass for 2026-09-02 (3 guests). Total: ₱330','booking','BK-2026-123123',0,'2026-09-02 10:39:34'),(68,NULL,'staff','New Reservation (BK-2026-586808)','melva booked Cold Spring Resort Day Pass for 2026-09-02 (3 guests). Total: ₱330','booking','BK-2026-586808',0,'2026-09-02 10:39:34'),(69,NULL,'all','Reservation #17 Status Updated','Reservation 17 has moved to \"Cancelled\".','booking','17',0,'2026-09-02 10:40:11'),(70,NULL,'staff','New Reservation (BK-20260902-315)','Walk-In Tourist booked Walk-In Day Pass & Cottage for 2026-09-02 (1 guests). Total: ₱330','booking','BK-20260902-315',0,'2026-09-02 10:48:49'),(71,NULL,'all','Reservation #18 Status Updated','Reservation 18 has moved to \"Paid (Cash - Gate Verified)\".','booking','18',0,'2026-09-02 10:48:49'),(72,NULL,'staff','New Reservation (BK-20260902-951)','ness booked Adult Entrance Ticket for 2026-09-02 (1 guests). Total: ₱130','booking','BK-20260902-951',0,'2026-09-02 10:49:30'),(73,NULL,'all','Reservation #20 Status Updated','Reservation 20 has moved to \"Paid\".','booking','20',0,'2026-09-02 10:49:45'),(74,NULL,'staff','New Reservation (BK-2026-671736)','melva booked Cold Spring Resort Day Pass for 2026-09-08 (3 guests). Total: ₱270','booking','BK-2026-671736',0,'2026-09-08 22:10:35'),(75,NULL,'staff','New Reservation (BK-2026-799111)','melva booked Cold Spring Resort Day Pass for 2026-09-08 (3 guests). Total: ₱270','booking','BK-2026-799111',0,'2026-09-08 22:10:35'),(76,NULL,'all','Reservation #22 Status Updated','Reservation 22 has moved to \"Cancelled\".','booking','22',0,'2026-09-08 22:19:59'),(77,NULL,'all','Reservation #23 Status Updated','Reservation 23 has moved to \"Cancelled\".','booking','23',0,'2026-09-15 09:25:00'),(78,NULL,'staff','New Reservation (BK-20260915-839)','melva booked Adult Entrance Ticket for 2026-09-15 (4 guests). Total: ₱450','booking','BK-20260915-839',0,'2026-09-15 09:29:16'),(79,NULL,'all','Reservation #22 Status Updated','Reservation 22 has moved to \"Paid (Cash - Gate Verified)\".','booking','22',0,'2026-09-15 09:29:16'),(80,NULL,'all','Reservation #24 Status Updated','Reservation 24 has moved to \"Using Services\".','booking','24',0,'2026-09-15 09:29:50'),(81,NULL,'staff','New Reservation (BK-20260915-275)','joyce booked Adult Entrance Ticket for 2026-09-15 (1 guests). Total: ₱180','booking','BK-20260915-275',0,'2026-09-15 09:30:35'),(82,NULL,'all','Reservation #25 Status Updated','Reservation 25 has moved to \"Paid\".','booking','25',0,'2026-09-15 09:30:51'),(83,NULL,'all','Reservation #25 Status Updated','Reservation 25 has moved to \"Using Services\".','booking','25',0,'2026-09-15 09:31:11'),(84,NULL,'all','Reservation #25 Status Updated','Reservation 25 has moved to \"Completed\".','booking','25',0,'2026-09-15 09:31:34'),(85,NULL,'all','Reservation #24 Status Updated','Reservation 24 has moved to \"Completed\".','booking','24',0,'2026-09-15 09:33:53'),(86,NULL,'staff','New Reservation (BK-20260915-474)','AILEEN LAGURA booked Adult Entrance Ticket for 2026-09-15 (1 guests). Total: ₱130','booking','BK-20260915-474',0,'2026-09-15 10:22:26'),(87,NULL,'staff','New Reservation (BK-20260915-321)','AILEEN LAGURA booked Adult Entrance Ticket for 2026-09-15 (2 guests). Total: ₱130','booking','BK-20260915-321',0,'2026-09-15 10:24:08'),(88,NULL,'all','Reservation #29 Status Updated','Reservation 29 has moved to \"Paid (Cash - Gate Verified)\".','booking','29',0,'2026-09-15 10:24:08'),(89,NULL,'staff','New Reservation (BK-20260915-637)','AILEEN LAGURA booked Adult Entrance Ticket for 2026-09-15 (1 guests). Total: ₱130','booking','BK-20260915-637',0,'2026-09-15 10:25:02'),(90,NULL,'all','Reservation #30 Status Updated','Reservation 30 has moved to \"Using Services\".','booking','30',0,'2026-09-15 10:26:24'),(91,NULL,'all','Reservation #29 Status Updated','Reservation 29 has moved to \"Using Services\".','booking','29',0,'2026-09-15 10:26:29'),(92,NULL,'all','Reservation #29 Status Updated','Reservation 29 has moved to \"Completed\".','booking','29',0,'2026-09-15 10:28:06'),(93,NULL,'staff','New Reservation (BK-20260915-279)','AILEEN LAGURA booked Adult Entrance Ticket for 2026-09-15 (2 guests). Total: ₱7130','booking','BK-20260915-279',0,'2026-09-15 10:38:57'),(94,NULL,'all','Reservation #31 Status Updated','Reservation 31 has moved to \"Paid (Cash - Gate Verified)\".','booking','31',0,'2026-09-15 10:38:57'),(95,NULL,'all','Reservation #32 Status Updated','Reservation 32 has moved to \"Using Services\".','booking','32',0,'2026-09-15 10:39:11'),(96,NULL,'staff','New Reservation (BK-2026-503443)','AILEEN LAGURA booked Cold Spring Resort Day Pass for 2026-09-15 (1 guests). Total: ₱35130','booking','BK-2026-503443',0,'2026-09-15 10:40:40'),(97,NULL,'staff','New Reservation (BK-2026-564405)','AILEEN LAGURA booked Cold Spring Resort Day Pass for 2026-09-15 (1 guests). Total: ₱35130','booking','BK-2026-564405',0,'2026-09-15 10:40:40'),(98,NULL,'all','Reservation #33 Status Updated','Reservation 33 has moved to \"Cancelled\".','booking','33',0,'2026-09-15 10:44:53'),(99,NULL,'all','Reservation #34 Status Updated','Reservation 34 has moved to \"Cancelled\".','booking','34',0,'2026-09-15 10:44:58'),(100,NULL,'staff','New Reservation (BK-2026-588790)','AILEEN LAGURA booked Celebration Package for 2026-09-16 (1 guests). Total: ₱5750','booking','BK-2026-588790',0,'2026-09-16 16:21:20'),(101,NULL,'staff','New Reservation (BK-2026-165336)','AILEEN LAGURA booked Celebration Package for 2026-09-16 (1 guests). Total: ₱5750','booking','BK-2026-165336',0,'2026-09-16 16:21:20'),(102,NULL,'staff','New Reservation (BK-2026-422745)','Test booked Resort Reservation for 2026-10-10 (1 guests). Total: ₱100','booking','BK-2026-422745',0,'2026-09-16 16:49:59'),(103,NULL,'staff','New Reservation (BK-2026-146457)','aileen lagura booked Family Splash Deal for 2026-09-17 (5 guests). Total: ₱1340','booking','BK-2026-146457',0,'2026-09-17 22:49:19'),(104,NULL,'staff','New Reservation (BK-2026-232639)','aileen lagura booked Family Splash Deal for 2026-09-17 (5 guests). Total: ₱1340','booking','BK-2026-232639',0,'2026-09-17 22:49:19'),(105,NULL,'all','Reservation #37 Status Updated','Reservation 37 has moved to \"Paid\".','booking','37',0,'2026-09-17 23:03:54'),(106,NULL,'staff','New Reservation (BK-20260917-684)','Walk-In Tourist booked Walk-In Day Pass & Cottage for 2026-09-17 (1 guests). Total: ₱1340','booking','BK-20260917-684',0,'2026-09-17 23:12:30'),(107,NULL,'all','Reservation #38 Status Updated','Reservation 38 has moved to \"Paid (Cash - Gate Verified)\".','booking','38',0,'2026-09-17 23:12:30'),(108,NULL,'all','Reservation #41 Status Updated','Reservation 41 has moved to \"Using Services\".','booking','41',0,'2026-09-17 23:12:42'),(109,NULL,'all','Reservation #38 Status Updated','Reservation 38 has moved to \"Paid (Cash - Gate Verified)\".','booking','38',0,'2026-09-17 23:17:55'),(110,NULL,'all','Reservation #38 Status Updated','Reservation 38 has moved to \"Using Services\".','booking','38',0,'2026-09-17 23:18:16'),(111,NULL,'staff','New Reservation (BK-20260917-956)','Walk-In Tourist booked Adult Entrance Ticket for 2026-09-17 (2 guests). Total: ₱180','booking','BK-20260917-956',0,'2026-09-17 23:18:49'),(112,NULL,'all','Reservation #41 Status Updated','Reservation 41 has moved to \"Paid (Cash - Gate Verified)\".','booking','41',0,'2026-09-17 23:18:49'),(113,NULL,'all','Reservation #43 Status Updated','Reservation 43 has moved to \"Using Services\".','booking','43',0,'2026-09-17 23:19:06'),(114,NULL,'staff','New Reservation (BK-2026-630996)','AILEEN LAGURA booked Cold Spring Resort Day Pass for 2026-09-19 (1 guests). Total: ₱900','booking','BK-2026-630996',0,'2026-09-19 21:13:34'),(115,NULL,'staff','New Reservation (BK-2026-384571)','AILEEN LAGURA booked Cold Spring Resort Day Pass for 2026-09-19 (1 guests). Total: ₱900','booking','BK-2026-384571',0,'2026-09-19 21:13:34'),(116,NULL,'all','Reservation #45 Status Updated','Reservation 45 has moved to \"Paid\".','booking','45',0,'2026-09-19 21:14:00'),(117,NULL,'all','Reservation #45 Status Updated','Reservation 45 has moved to \"Using Services\".','booking','45',0,'2026-09-19 21:14:21'),(118,NULL,'all','Reservation #45 Status Updated','Reservation 45 has moved to \"Paid (Cash - Gate Verified)\".','booking','45',0,'2026-09-19 21:15:24'),(119,NULL,'all','Reservation #13 Status Updated','Reservation 13 has moved to \"Completed\".','booking','13',0,'2026-09-19 21:17:56'),(120,NULL,'all','Reservation #30 Status Updated','Reservation 30 has moved to \"Completed\".','booking','30',0,'2026-09-19 21:17:58'),(121,NULL,'all','Reservation #32 Status Updated','Reservation 32 has moved to \"Completed\".','booking','32',0,'2026-09-19 21:18:01'),(122,NULL,'all','Reservation #38 Status Updated','Reservation 38 has moved to \"Completed\".','booking','38',0,'2026-09-19 21:18:03'),(123,NULL,'all','Reservation #43 Status Updated','Reservation 43 has moved to \"Completed\".','booking','43',0,'2026-09-19 21:18:06'),(124,NULL,'staff','New Reservation (BK-20260919-752)','Walk-In Tourist booked Walk-In Day Pass & Cottage for 2026-09-19 (1 guests). Total: ₱900','booking','BK-20260919-752',0,'2026-09-19 21:18:27'),(125,NULL,'all','Reservation #44 Status Updated','Reservation 44 has moved to \"Paid (Cash - Gate Verified)\".','booking','44',0,'2026-09-19 21:18:28'),(126,NULL,'all','Reservation #48 Status Updated','Reservation 48 has moved to \"Using Services\".','booking','48',0,'2026-09-19 21:18:57'),(127,NULL,'all','Reservation #48 Status Updated','Reservation 48 has moved to \"Completed\".','booking','48',0,'2026-09-19 21:18:59'),(128,NULL,'all','Reservation #45 Status Updated','Reservation 45 has moved to \"Using Services\".','booking','45',0,'2026-09-19 21:19:02'),(129,NULL,'all','Reservation #45 Status Updated','Reservation 45 has moved to \"Completed\".','booking','45',0,'2026-09-19 21:19:04'),(130,NULL,'all','Reservation #44 Status Updated','Reservation 44 has moved to \"Using Services\".','booking','44',0,'2026-09-19 21:19:06'),(131,NULL,'all','Reservation #44 Status Updated','Reservation 44 has moved to \"Completed\".','booking','44',0,'2026-09-19 21:19:09'),(132,NULL,'all','Reservation #36 Status Updated','Reservation 36 has moved to \"Cancelled\".','booking','36',0,'2026-09-19 21:20:29'),(133,NULL,'all','Reservation #39 Status Updated','Reservation 39 has moved to \"Paid\".','booking','39',0,'2026-09-19 21:20:31'),(134,NULL,'all','Reservation #35 Status Updated','Reservation 35 has moved to \"Paid\".','booking','35',0,'2026-09-19 21:20:44'),(135,NULL,'staff','New Reservation (REF-2026-345052)','AILEEN LAGURA booked Standard Open Cottage for 2026-09-19 (1 guests). Total: ₱700','booking','REF-2026-345052',0,'2026-09-19 21:22:17'),(136,NULL,'staff','New Reservation (BK-2026-679191)','aileen lagura booked Cold Spring Resort Day Pass for 2026-09-20 (1 guests). Total: ₱3900','booking','BK-2026-679191',0,'2026-09-20 11:27:27'),(137,NULL,'all','Reservation #52 Status Updated','Reservation 52 has moved to \"Paid (Cash - Gate Verified)\".','booking','52',0,'2026-09-20 13:23:13'),(138,NULL,'all','Reservation #51 Status Updated','Reservation 51 has moved to \"Paid\".','booking','51',0,'2026-09-21 17:28:08'),(139,NULL,'all','Reservation #52 Status Updated','Reservation 52 has moved to \"Using Services\".','booking','52',0,'2026-09-21 17:30:17'),(140,NULL,'all','Reservation #52 Status Updated','Reservation 52 has moved to \"Paid (Cash - Gate Verified)\".','booking','52',0,'2026-09-21 17:31:32'),(141,NULL,'all','Reservation #52 Status Updated','Reservation 52 has moved to \"Using Services\".','booking','52',0,'2026-09-21 17:32:40'),(142,NULL,'all','Reservation #52 Status Updated','Reservation 52 has moved to \"Completed\".','booking','52',0,'2026-09-21 17:32:42'),(143,NULL,'all','Reservation #51 Status Updated','Reservation 51 has moved to \"Using Services\".','booking','51',0,'2026-09-21 17:32:45'),(144,NULL,'all','Reservation #51 Status Updated','Reservation 51 has moved to \"Completed\".','booking','51',0,'2026-09-21 17:32:47'),(145,NULL,'all','Reservation #41 Status Updated','Reservation 41 has moved to \"Using Services\".','booking','41',0,'2026-09-21 17:32:52'),(146,NULL,'all','Reservation #41 Status Updated','Reservation 41 has moved to \"Completed\".','booking','41',0,'2026-09-21 17:32:54'),(147,NULL,'all','Reservation #39 Status Updated','Reservation 39 has moved to \"Using Services\".','booking','39',0,'2026-09-21 17:32:59'),(148,NULL,'all','Reservation #39 Status Updated','Reservation 39 has moved to \"Completed\".','booking','39',0,'2026-09-21 17:33:01'),(149,NULL,'all','Reservation #37 Status Updated','Reservation 37 has moved to \"Using Services\".','booking','37',0,'2026-09-21 17:33:08'),(150,NULL,'all','Reservation #37 Status Updated','Reservation 37 has moved to \"Completed\".','booking','37',0,'2026-09-21 17:33:14'),(151,NULL,'all','Reservation #35 Status Updated','Reservation 35 has moved to \"Using Services\".','booking','35',0,'2026-09-21 17:33:18'),(152,NULL,'all','Reservation #35 Status Updated','Reservation 35 has moved to \"Completed\".','booking','35',0,'2026-09-21 17:33:21'),(153,NULL,'all','Reservation #18 Status Updated','Reservation 18 has moved to \"Using Services\".','booking','18',0,'2026-09-21 17:33:30'),(154,NULL,'all','Reservation #18 Status Updated','Reservation 18 has moved to \"Completed\".','booking','18',0,'2026-09-21 17:33:32'),(155,NULL,'all','Reservation #19 Status Updated','Reservation 19 has moved to \"Using Services\".','booking','19',0,'2026-09-21 17:33:36'),(156,NULL,'all','Reservation #19 Status Updated','Reservation 19 has moved to \"Completed\".','booking','19',0,'2026-09-21 17:33:40'),(157,NULL,'all','Reservation #20 Status Updated','Reservation 20 has moved to \"Using Services\".','booking','20',0,'2026-09-21 17:33:46'),(158,NULL,'all','Reservation #20 Status Updated','Reservation 20 has moved to \"Completed\".','booking','20',0,'2026-09-21 17:33:48'),(159,NULL,'all','Reservation #22 Status Updated','Reservation 22 has moved to \"Using Services\".','booking','22',0,'2026-09-21 17:33:54'),(160,NULL,'all','Reservation #22 Status Updated','Reservation 22 has moved to \"Completed\".','booking','22',0,'2026-09-21 17:33:56'),(161,NULL,'staff','New Reservation (REF-2026-680072)','AILEEN LAGURA booked Duangon Walk-In Day Pass for 2026-09-21 (1 guests). Total: ₱7150','booking','REF-2026-680072',0,'2026-09-21 17:52:42'),(162,NULL,'staff','New Reservation (BK-2026-733766)','aileen lagura booked Quick Dip Deal for 2026-09-21 (5 guests). Total: ₱960','booking','BK-2026-733766',0,'2026-09-21 17:55:49'),(163,NULL,'staff','New Reservation (REF-2026-633994)','AILEEN LAGURA booked Duangon Walk-In Day Pass for 2026-09-21 (1 guests). Total: ₱2400','booking','REF-2026-633994',0,'2026-09-21 18:29:32'),(164,NULL,'staff','New Reservation (REF-2026-161030)','AILEEN LAGURA booked Duangon Walk-In Day Pass for 2026-09-22 (1 guests). Total: ₱7150','booking','REF-2026-161030',0,'2026-09-22 10:28:33'),(165,NULL,'staff','New Reservation (REF-2026-614912)','AILEEN LAGURA booked Duangon Walk-In Day Pass for 2026-09-22 (1 guests). Total: ₱900','booking','REF-2026-614912',0,'2026-09-22 10:28:54'),(166,NULL,'all','Reservation #61 Status Updated','Reservation 61 has moved to \"Paid\".','booking','61',0,'2026-09-22 10:29:42'),(167,NULL,'all','Reservation #61 Status Updated','Reservation 61 has moved to \"Using Services\".','booking','61',0,'2026-09-22 10:29:54'),(168,NULL,'all','Reservation #61 Status Updated','Reservation 61 has moved to \"Paid (Cash - Gate Verified)\".','booking','61',0,'2026-09-22 10:31:40'),(169,NULL,'all','Reservation #60 Status Updated','Reservation 60 has moved to \"Cancelled\".','booking','60',0,'2026-09-23 13:45:02'),(170,NULL,'all','Reservation #59 Status Updated','Reservation 59 has moved to \"Cancelled\".','booking','59',0,'2026-09-23 13:45:06'),(171,NULL,'all','Reservation #58 Status Updated','Reservation 58 has moved to \"Cancelled\".','booking','58',0,'2026-09-23 13:45:09'),(172,NULL,'all','Reservation #57 Status Updated','Reservation 57 has moved to \"Cancelled\".','booking','57',0,'2026-09-23 13:45:14'),(173,NULL,'all','Reservation #61 Status Updated','Reservation 61 has moved to \"Using Services\".','booking','61',0,'2026-09-23 13:45:23'),(174,NULL,'all','Reservation #61 Status Updated','Reservation 61 has moved to \"Completed\".','booking','61',0,'2026-09-23 13:45:34'),(175,NULL,'all','Reservation #31 Status Updated','Reservation 31 has moved to \"Using Services\".','booking','31',0,'2026-09-23 13:45:42'),(176,NULL,'all','Reservation #31 Status Updated','Reservation 31 has moved to \"Completed\".','booking','31',0,'2026-09-23 13:45:45'),(180,NULL,'all','Reservation #64 Status Updated','Reservation 64 has moved to \"Cancelled\".','booking','64',0,'2026-09-23 15:16:35'),(181,NULL,'staff','New Reservation (REF-2026-118195)','AILEEN LAGURA booked Quick Dip Deal for 2026-09-23 (1 guests). Total: ₱810','booking','REF-2026-118195',0,'2026-09-23 15:22:37'),(182,NULL,'all','Reservation #67 Status Updated','Reservation 67 has moved to \"Paid\".','booking','67',0,'2026-09-23 15:22:53'),(184,NULL,'staff','New Reservation (REF-2026-686945)','Aileen Lagura booked Unlimited All-Access Package for 2026-09-23 (10 guests). Total: ₱10100','booking','REF-2026-686945',0,'2026-09-23 15:50:54'),(185,NULL,'staff','New Reservation (BK-20260923-334)','Aileen Lagura booked Quick Dip Deal for 2026-09-23 (5 guests). Total: ₱810','booking','BK-20260923-334',0,'2026-09-23 15:59:40'),(186,NULL,'all','Reservation #70 Status Updated','Reservation 70 has moved to \"Paid\".','booking','70',0,'2026-09-23 15:59:52'),(187,NULL,'all','Reservation #70 Status Updated','Reservation 70 has moved to \"Using Services\".','booking','70',0,'2026-09-23 18:57:28'),(188,NULL,'all','Reservation #69 Status Updated','Reservation 69 has moved to \"Cancelled\".','booking','69',0,'2026-09-23 18:58:13'),(193,NULL,'all','Reservation #72 Status Updated','Reservation 72 has moved to \"Using Services\".','booking','72',0,'2026-09-23 19:20:03'),(206,NULL,'staff','New Reservation (REF-2026-327503)','AILEEN LAGURA booked Quick Dip Deal for 2026-09-23 (5 guests). Total: ₱810','booking','REF-2026-327503',0,'2026-09-23 20:03:44'),(207,7,'client','Please confirm reservation REF-2026-327503','Continue or cancel before Sep 24, 2026, 8:04 PM (PHT), or the reservation is voided automatically.','booking','REF-2026-327503',0,'2026-09-23 20:04:23'),(212,7,'client','Please confirm reservation REF-2026-327503','Continue or cancel before Sep 24, 2026, 8:19 PM (PHT), or the reservation is voided automatically.','booking','REF-2026-327503',0,'2026-09-23 20:19:12'),(213,NULL,'staff','New Reservation (BK-20260924-273)','Aileen booked Quick Dip Deal for 2026-09-24 (5 guests). Total: ₱810','booking','BK-20260924-273',0,'2026-09-24 09:46:29'),(214,NULL,'staff','New Reservation (REF-2026-435286)','AILEEN LAGURA booked Barkada Fun Deal for 2026-09-24 (10 guests). Total: ₱1920','booking','REF-2026-435286',0,'2026-09-24 09:49:04'),(215,7,'client','Please confirm reservation REF-2026-435286','Continue or cancel before Sep 25, 2026, 9:49 AM (PHT), or the reservation is voided automatically.','booking','REF-2026-435286',0,'2026-09-24 09:50:25'),(216,NULL,'all','Reservation #83 Status Updated','Reservation 83 has moved to \"Using Services\".','booking','83',0,'2026-09-24 09:50:55'),(217,NULL,'staff','Auto-voided REF-2026-327503','AILEEN LAGURA did not respond within the confirmation window.','booking','REF-2026-327503',0,'2026-09-25 10:19:36'),(218,NULL,'staff','Auto-voided REF-2026-435286','AILEEN LAGURA did not respond within the confirmation window.','booking','REF-2026-435286',0,'2026-09-25 10:19:36'),(219,NULL,'all','Reservation #67 Status Updated','Reservation 67 has moved to \"Using Services\".','booking','67',0,'2026-09-25 10:22:35'),(220,NULL,'all','Reservation #67 Status Updated','Reservation 67 has moved to \"Completed\".','booking','67',0,'2026-09-25 10:22:37'),(221,NULL,'all','Reservation #82 Status Updated','Reservation 82 has moved to \"Using Services\".','booking','82',0,'2026-09-25 10:22:42'),(222,NULL,'all','Reservation #82 Status Updated','Reservation 82 has moved to \"Completed\".','booking','82',0,'2026-09-25 10:22:46'),(228,NULL,'staff','New Reservation (BK-20260925-635)','aileen booked Life Vest / Safety Gear for 2026-09-25 (1 guests). Total: ₱50','booking','BK-20260925-635',0,'2026-09-25 13:16:58'),(229,NULL,'all','Reservation #88 Status Updated','Reservation 88 has moved to \"Cancelled\".','booking','88',0,'2026-09-25 13:17:07'),(239,NULL,'all','Reservation #70 Status Updated','Reservation 70 has moved to \"Completed\".','booking','70',0,'2026-09-25 15:25:25'),(240,NULL,'staff','New Reservation (REF-2026-204345)','AILEEN LAGURA booked Unlimited All-Access Package for 2026-09-29 (10 guests). Total: ₱10100','booking','REF-2026-204345',0,'2026-09-29 10:04:27'),(241,NULL,'staff','New Reservation (REF-2026-796363)','AILEEN LAGURA booked Quick Dip Deal for 2026-09-29 (5 guests). Total: ₱810','booking','REF-2026-796363',0,'2026-09-29 10:04:41'),(242,7,'client','Please confirm reservation REF-2026-796363','Continue or cancel before Sep 30, 2026, 10:05 AM (PHT), or the reservation is voided automatically.','booking','REF-2026-796363',0,'2026-09-29 10:05:18'),(243,7,'client','Please confirm reservation REF-2026-204345','Continue or cancel before Sep 30, 2026, 10:05 AM (PHT), or the reservation is voided automatically.','booking','REF-2026-204345',0,'2026-09-29 10:06:09'),(244,NULL,'staff','New Reservation (BK-2026-602584)','Test booked Resort Reservation for 2026-10-10 (2 guests). Total: ₱260','booking','BK-2026-602584',0,'2026-10-05 22:04:27'),(245,NULL,'staff','New Reservation (REF-2026-879563)','AILEEN LAGURA booked Barkada Fun Deal for 2026-10-05 (10 guests). Total: ₱1920','booking','REF-2026-879563',0,'2026-10-05 22:34:33'),(246,NULL,'staff','New Reservation (REF-2026-672611)','AILEEN LAGURA booked Unlimited All-Access Package for 2026-10-05 (10 guests). Total: ₱10100','booking','REF-2026-672611',0,'2026-10-05 22:35:17'),(247,8,'client','Please confirm reservation REF-2026-672611','Continue or cancel before Oct 21, 2026, 3:17 AM (PHT), or the reservation is voided automatically.','booking','REF-2026-672611',0,'2026-10-20 03:17:11'),(248,NULL,'staff','New Reservation (REF-2026-868517)','AILEEN LAGURAa booked Barkada Fun Deal for 2026-10-23 (10 guests). Total: ₱1920','booking','REF-2026-868517',0,'2026-10-20 22:20:30'),(249,11,'client','Please confirm reservation REF-2026-868517','Continue or cancel before Oct 21, 2026, 10:21 PM (PHT), or the reservation is voided automatically.','booking','REF-2026-868517',0,'2026-10-20 22:21:43'),(250,NULL,'all','Reservation #5 Status Updated','Reservation 5 has moved to \"Using Services\".','booking','5',0,'2026-10-20 22:52:05'),(251,NULL,'all','Reservation #5 Status Updated','Reservation 5 has moved to \"Completed\".','booking','5',0,'2026-10-20 22:52:09'),(252,NULL,'staff','New Reservation (BK-2026-172385)','AILEEN LAGURA booked Quick Dip Deal for 2026-11-15 (2 guests). Total: ₱810','booking','BK-2026-172385',0,'2026-10-20 22:53:21'),(253,NULL,'staff','Client confirmed REF-2026-868517','AILEEN LAGURAa will continue (via client portal). Collect the ₱960.00 reservation fee at the counter.','booking','REF-2026-868517',0,'2026-10-20 23:37:55'),(254,NULL,'staff','Client confirmed REF-2026-672611','AILEEN LAGURA will continue (via client portal). Collect the ₱5,050.00 reservation fee at the counter.','booking','REF-2026-672611',0,'2026-10-20 23:39:01'),(255,NULL,'all','Reservation #4 Status Updated','Reservation 4 has moved to \"Using Services\".','booking','4',0,'2026-10-20 23:39:28'),(256,NULL,'all','Reservation #4 Status Updated','Reservation 4 has moved to \"Completed\".','booking','4',0,'2026-10-20 23:39:31'),(257,NULL,'all','Reservation #3 Status Updated','Reservation 3 has moved to \"Using Services\".','booking','3',0,'2026-10-20 23:39:33'),(258,NULL,'all','Reservation #3 Status Updated','Reservation 3 has moved to \"Completed\".','booking','3',0,'2026-10-20 23:39:36'),(259,NULL,'staff','New Reservation (REF-2026-625204)','AILEEN LAGURA booked Unlimited All-Access Package for 2026-10-20 (10 guests). Total: ₱10100','booking','REF-2026-625204',0,'2026-10-20 23:40:01'),(260,NULL,'all','Reservation #5 Status Updated','Reservation 5 has moved to \"Cancelled\".','booking','5',0,'2026-10-20 23:43:37'),(261,NULL,'staff','New Reservation (REF-2026-761792)','ALEX LAGURA booked Quick Dip Deal for 2026-10-21 (5 guests). Total: ₱810','booking','REF-2026-761792',0,'2026-10-21 10:07:54'),(262,NULL,'staff','New Reservation (REF-2026-849755)','EVELYN LAGURAa booked Barkada Fun Deal for 2026-10-21 (10 guests). Total: ₱1920','booking','REF-2026-849755',0,'2026-10-21 10:09:33'),(263,NULL,'all','Reservation #9 Status Updated','Reservation 9 has moved to \"Using Services\".','booking','9',0,'2026-10-21 10:12:22');

/*Table structure for table `package_items` */

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
) ENGINE=InnoDB AUTO_INCREMENT=49 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `package_items` */

insert  into `package_items`(`id`,`package_id`,`service_id`,`quantity`) values (1,1,1,5),(2,1,3,1),(3,1,12,1),(4,2,1,5),(5,2,2,1),(6,2,4,5),(7,2,11,1),(8,3,1,10),(9,3,2,1),(10,3,5,1),(11,3,3,1),(12,3,11,1),(13,4,1,15),(14,4,13,1),(15,4,4,10),(16,4,3,2),(17,4,6,1),(18,4,11,2),(19,5,1,5),(20,5,7,1),(21,5,12,1),(22,5,4,5),(23,5,6,1),(24,5,11,1),(25,6,1,5),(26,6,8,1),(27,6,2,1),(28,6,4,5),(29,6,6,1),(30,6,11,1),(31,7,1,20),(32,7,9,1),(33,7,5,1),(34,7,3,4),(35,7,11,3),(36,8,1,10),(37,8,2,1),(38,8,3,1),(39,8,4,1),(40,8,5,1),(41,8,6,1),(42,8,7,1),(43,8,8,1),(44,8,9,1),(45,8,10,1),(46,8,11,1),(47,8,12,1),(48,8,13,1);

/*Table structure for table `packages` */

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
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `packages` */

insert  into `packages`(`id`,`package_code`,`package_name`,`description`,`image_url`,`regular_value`,`promo_price`,`discount_percent`,`included_guests`,`badge`,`status`,`valid_from`,`valid_until`,`created_at`,`updated_at`,`discount_type`,`package_type`,`manual_status`,`is_featured`,`show_on_landing`,`deleted_at`) values (1,'PKG-001','Quick Dip Deal','Best for small groups and quick family swimming trips.','/src/assets/images/services/quick dip.png','900.00','810.00','10.00',5,'SAVE ₱90','Active',NULL,NULL,'2026-09-16 15:53:29','2026-09-16 15:53:29','Percentage','STANDARD',NULL,0,1,NULL),(2,'PKG-002','Family Splash Deal','Includes cottage, life vests, and parking.','/src/assets/images/services/flash deal.png','1400.00','1190.00','15.00',5,'BEST SELLER','Active',NULL,NULL,'2026-09-16 15:53:30','2026-09-16 15:53:30','Percentage','STANDARD',NULL,0,1,NULL),(3,'PKG-003','Barkada Fun Deal','Designed for friends who want swimming plus entertainment.','/src/assets/images/services/barkada deal.png','2400.00','1920.00','20.00',10,'BARKADA FAVORITE','Active',NULL,NULL,'2026-09-16 15:53:30','2026-09-16 15:53:30','Percentage','STANDARD',NULL,0,1,NULL),(4,'PKG-004','Family Getaway Deal','For extended families and larger day-trip groups.','/src/assets/images/services/family gateway deal.png','3900.00','3120.00','20.00',15,'BEST VALUE','Active',NULL,NULL,'2026-09-16 15:53:30','2026-09-16 15:53:30','Percentage','STANDARD',NULL,0,1,NULL),(5,'PKG-005','Overnight Escape','Affordable overnight camping package.','/src/assets/images/services/quick escape.png','1950.00','1658.00','15.00',5,'OVERNIGHT DEAL','Active',NULL,NULL,'2026-09-16 15:53:30','2026-09-16 15:53:30','Percentage','STANDARD',NULL,0,1,NULL),(6,'PKG-006','Premium Family Escape','Comfortable overnight option with Aircon Kubo.','/src/assets/images/services/premium family.png','3200.00','2560.00','20.00',5,'PREMIUM','Active',NULL,NULL,'2026-09-16 15:53:30','2026-09-16 15:53:30','Percentage','STANDARD',NULL,0,1,NULL),(7,'PKG-007','Celebration Package','For birthdays, reunions and gatherings.','/src/assets/images/services/celebration.png','7150.00','5720.00','20.00',20,'PARTY DEAL','Active',NULL,NULL,'2026-09-16 15:53:30','2026-09-16 15:53:30','Percentage','STANDARD',NULL,0,1,NULL),(8,'PKG-UNLIMITED-001','Unlimited All-Access Package','Enjoy Everything. No Limits. One Amazing Day! Access to ALL available Duangon Cold Spring services in one premium package. Unlimited use during your booked stay, subject to facility availability.','/src/assets/images/services/unlimited.png','12000.00','10100.00','16.00',10,'16% OFF','Active',NULL,NULL,'2026-09-23 15:09:09','2026-09-23 15:09:09','Percentage','UNLIMITED',NULL,1,1,NULL);

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
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `payments` */

insert  into `payments`(`id`,`payment_ref`,`booking_id`,`client_name`,`staff_id`,`staff_name`,`total_amount`,`cash_received`,`change_amount`,`payment_method`,`status`,`created_at`) values (22,'OR-2026-000004',4,'AILEEN LAGURA',3,'Staff Cashier','10200.00','10200.00','0.00','Cash','Paid','2026-10-20 22:52:22'),(23,'OR-2026-000005',3,'AILEEN LAGURA',3,'Staff Cashier','1920.00','1920.00','0.00','Cash','Paid','2026-10-20 22:52:29'),(24,'OR-2026-000006',2,'Test',3,'Staff Cashier','260.00','260.00','0.00','Cash','Paid','2026-10-20 22:52:31'),(29,'OR-2026-000025',7,'AILEEN LAGURA',3,'Juan Dela Cruz','5050.00','5050.00','0.00','Cash','Paid','2026-10-21 10:02:59'),(30,'OR-2026-000030',7,'AILEEN LAGURA',3,'Juan Dela Cruz','5050.00','5050.00','0.00','Cash','Paid','2026-10-21 10:03:06'),(31,'OR-2026-000031',8,'ALEX LAGURA',3,'Juan Dela Cruz','405.00','405.00','0.00','Cash','Paid','2026-10-21 10:11:07'),(32,'OR-2026-000032',8,'ALEX LAGURA',12,'Melva Gumapac','405.00','405.00','0.00','Cash','Paid','2026-10-21 10:11:57'),(33,'OR-2026-000033',9,'EVELYN LAGURAa',12,'Melva Gumapac','1920.00','1920.00','0.00','Cash','Paid','2026-10-21 10:12:05'),(34,'OR-2026-000009',9,'EVELYN LAGURAa',NULL,'Melva Gumapac','300.00','300.00','0.00','Cash','Paid','2026-10-21 10:12:42');

/*Table structure for table `promotion_packages` */

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

/*Data for the table `promotion_packages` */

/*Table structure for table `promotion_services` */

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

/*Data for the table `promotion_services` */

/*Table structure for table `promotions` */

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
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `promotions` */

insert  into `promotions`(`id`,`promo_code`,`promo_name`,`description`,`discount_type`,`promo_type`,`discount_value`,`start_at`,`end_at`,`timezone`,`eligibility_basis`,`priority`,`stackable`,`usage_limit`,`used_count`,`status`,`created_at`,`updated_at`,`image_url`,`original_price`,`discounted_price`,`is_featured`,`show_on_landing`,`deleted_at`) values (1,'SEP2026','September Monthly Sale','Enjoy our regular September discounts','Percentage','MONTHLY','15.00','2026-09-01 00:00:00','2026-09-30 23:59:59','Asia/Manila','BOOKING_DATE',5,0,NULL,0,'Active','2026-09-16 15:30:39','2026-09-16 15:30:39',NULL,NULL,NULL,0,1,NULL),(2,'99SALE','9.9 EcoTour Getaway Sale','Special Double Date Sale','Percentage','DOUBLE_DATE','20.00','2026-09-09 00:00:00','2026-09-09 23:59:59','Asia/Manila','BOOKING_DATE',2,0,NULL,0,'Active','2026-09-16 15:30:39','2026-09-16 15:30:39',NULL,NULL,NULL,0,1,NULL),(3,'MIDMONTH','⚡ Mid-Month Flash Splash','Special mid-month flash sale!','Percentage','FLASH','25.00','2026-09-16 00:00:00','2026-09-17 23:59:59','Asia/Manila','BOOKING_DATE',1,0,NULL,0,'Active','2026-09-16 15:30:39','2026-09-16 15:30:39',NULL,NULL,NULL,0,1,NULL);

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
  `promotion_id` int DEFAULT NULL,
  PRIMARY KEY (`reservation_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `reservations_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `reservations` */

/*Table structure for table `resource_assignments` */

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
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `resource_assignments` */

insert  into `resource_assignments`(`id`,`booking_id`,`service_resource_id`,`start_time`,`end_time`,`status`,`created_at`,`updated_at`) values (2,70,78,'2026-09-23 00:00:00','2026-09-23 23:59:59','Returned','2026-09-23 18:57:18','2026-09-25 15:25:25'),(3,70,19,'2026-09-23 00:00:00','2026-09-23 23:59:59','Returned','2026-09-23 18:57:21','2026-09-25 15:25:25'),(4,79,83,'2026-09-23 00:00:00','2026-09-23 23:59:59','Released','2026-09-23 20:41:19','2026-09-25 10:19:36'),(5,79,88,'2026-09-23 00:00:00','2026-09-23 23:59:59','Released','2026-09-23 20:42:08','2026-09-25 10:19:36'),(6,83,38,'2026-09-24 00:00:00','2026-09-24 23:59:59','Released','2026-09-24 09:50:18','2026-09-25 10:19:36'),(7,83,19,'2026-09-24 00:00:00','2026-09-24 23:59:59','Released','2026-09-24 09:50:20','2026-09-25 10:19:36'),(8,83,17,'2026-09-24 00:00:00','2026-09-24 23:59:59','Released','2026-09-24 09:50:22','2026-09-25 10:19:36'),(9,82,82,'2026-09-24 00:00:00','2026-09-24 23:59:59','Returned','2026-09-25 10:22:20','2026-09-25 10:22:46'),(10,82,4,'2026-09-24 00:00:00','2026-09-24 23:59:59','Returned','2026-09-25 10:22:21','2026-09-25 10:22:46'),(11,82,19,'2026-09-24 00:00:00','2026-09-24 23:59:59','Returned','2026-09-25 10:22:22','2026-09-25 10:22:46'),(12,67,82,'2026-09-23 00:00:00','2026-09-23 23:59:59','Returned','2026-09-25 10:22:29','2026-09-25 10:22:37'),(13,93,75,'2026-09-29 00:00:00','2026-09-29 23:59:59','Reserved','2026-09-29 10:05:13','2026-09-29 10:05:13'),(14,92,19,'2026-09-29 00:00:00','2026-09-29 23:59:59','Reserved','2026-09-29 10:05:58','2026-09-29 10:05:58'),(15,92,3,'2026-09-29 00:00:00','2026-09-29 23:59:59','Reserved','2026-09-29 10:05:59','2026-09-29 10:05:59'),(16,92,13,'2026-09-29 00:00:00','2026-09-29 23:59:59','Reserved','2026-09-29 10:06:01','2026-09-29 10:06:01'),(17,92,27,'2026-09-29 00:00:00','2026-09-29 23:59:59','Reserved','2026-09-29 10:06:03','2026-09-29 10:06:03'),(18,92,31,'2026-09-29 00:00:00','2026-09-29 23:59:59','Reserved','2026-09-29 10:06:06','2026-09-29 10:06:06'),(19,92,33,'2026-09-29 00:00:00','2026-09-29 23:59:59','Reserved','2026-09-29 10:06:07','2026-09-29 10:06:07'),(20,92,37,'2026-09-29 00:00:00','2026-09-29 23:59:59','Reserved','2026-09-29 10:06:08','2026-09-29 10:06:08'),(21,92,87,'2026-09-29 00:00:00','2026-09-29 23:59:59','Reserved','2026-09-29 10:06:13','2026-09-29 10:06:13'),(22,92,78,'2026-09-29 00:00:00','2026-09-29 23:59:59','Reserved','2026-09-29 10:06:14','2026-09-29 10:06:14'),(23,4,15,'2026-10-05 00:00:00','2026-10-05 23:59:59','Returned','2026-10-20 03:17:11','2026-10-20 23:39:31'),(24,4,8,'2026-10-05 00:00:00','2026-10-05 23:59:59','Returned','2026-10-20 03:30:54','2026-10-20 23:39:31'),(25,4,11,'2026-10-05 00:00:00','2026-10-05 23:59:59','Returned','2026-10-20 03:30:55','2026-10-20 23:39:31'),(26,4,27,'2026-10-05 00:00:00','2026-10-05 23:59:59','Returned','2026-10-20 03:30:56','2026-10-20 23:39:31'),(27,4,30,'2026-10-05 00:00:00','2026-10-05 23:59:59','Returned','2026-10-20 03:30:58','2026-10-20 23:39:31'),(28,4,33,'2026-10-05 00:00:00','2026-10-05 23:59:59','Returned','2026-10-20 03:30:58','2026-10-20 23:39:31'),(29,4,56,'2026-10-05 00:00:00','2026-10-05 23:59:59','Returned','2026-10-20 03:31:00','2026-10-20 23:39:31'),(30,5,3,'2026-10-23 00:00:00','2026-10-23 23:59:59','Returned','2026-10-20 22:22:44','2026-10-20 22:52:09'),(31,5,7,'2026-10-23 00:00:00','2026-10-23 23:59:59','Returned','2026-10-20 22:22:46','2026-10-20 22:52:09'),(32,5,51,'2026-10-23 00:00:00','2026-10-23 23:59:59','Returned','2026-10-20 22:22:49','2026-10-20 22:52:09');

/*Table structure for table `resource_blocks` */

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

/*Data for the table `resource_blocks` */

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
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `revenue_shares` */

insert  into `revenue_shares`(`id`,`payment_id`,`gross_amount`,`park_share`,`barangay_share`,`guide_share`,`created_at`) values (22,22,'10200.00','7140.00','2040.00','1020.00','2026-10-20 22:52:22'),(23,23,'1920.00','1344.00','384.00','192.00','2026-10-20 22:52:29'),(24,24,'260.00','182.00','52.00','26.00','2026-10-20 22:52:31'),(27,29,'5050.00','3535.00','1010.00','505.00','2026-10-21 10:02:59'),(28,30,'5050.00','3535.00','1010.00','505.00','2026-10-21 10:03:06'),(29,31,'405.00','283.50','81.00','40.50','2026-10-21 10:11:07'),(30,32,'405.00','283.50','81.00','40.50','2026-10-21 10:11:57'),(31,33,'1920.00','1344.00','384.00','192.00','2026-10-21 10:12:05'),(32,34,'300.00','210.00','60.00','30.00','2026-10-21 10:12:42');

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

/*Table structure for table `service_inventory` */

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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `service_inventory` */

insert  into `service_inventory`(`id`,`service_id`,`total_quantity`,`created_at`,`updated_at`) values (1,4,50,'2026-09-16 15:13:34','2026-09-16 15:13:34'),(2,11,40,'2026-09-16 15:13:34','2026-09-16 15:13:34');

/*Table structure for table `service_resources` */

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
) ENGINE=InnoDB AUTO_INCREMENT=94 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `service_resources` */

insert  into `service_resources`(`id`,`service_id`,`resource_name`,`status`,`created_at`,`updated_at`) values (1,2,'Cottage 01','Available','2026-09-16 15:13:34','2026-09-16 15:13:34'),(2,2,'Cottage 02','Available','2026-09-16 15:13:34','2026-09-16 15:13:34'),(3,2,'Cottage 03','Available','2026-09-16 15:13:34','2026-09-16 15:13:34'),(4,2,'Cottage 04','Available','2026-09-16 15:13:34','2026-09-16 15:13:34'),(5,2,'Cottage 05','Available','2026-09-16 15:13:34','2026-09-16 15:13:34'),(6,5,'Videoke 01','Available','2026-09-16 15:13:34','2026-09-16 15:13:34'),(7,5,'Videoke 02','Available','2026-09-16 15:13:34','2026-09-16 15:13:34'),(8,5,'Videoke 03','Available','2026-09-16 15:13:34','2026-09-16 15:13:34'),(9,6,'Kayak 01','Available','2026-09-16 15:13:34','2026-09-16 15:13:34'),(10,6,'Kayak 02','Available','2026-09-16 15:13:34','2026-09-16 15:13:34'),(11,6,'Kayak 03','Available','2026-09-16 15:13:34','2026-09-16 15:13:34'),(12,6,'Kayak 04','Available','2026-09-16 15:13:34','2026-09-16 15:13:34'),(13,6,'Kayak 05','Available','2026-09-16 15:13:34','2026-09-16 15:13:34'),(14,2,'Cottage 06','Available','2026-09-23 15:09:08','2026-09-23 15:09:08'),(15,2,'Cottage 07','Available','2026-09-23 15:09:08','2026-09-23 15:09:08'),(16,2,'Cottage 08','Available','2026-09-23 15:09:08','2026-09-23 15:09:08'),(17,2,'Cottage 09','Available','2026-09-23 15:09:08','2026-09-23 15:09:08'),(18,2,'Cottage 10','Available','2026-09-23 15:09:08','2026-09-23 15:09:08'),(19,5,'Videoke 04','Available','2026-09-23 15:09:08','2026-09-23 15:09:08'),(20,7,'Tent Pitch 01','Available','2026-09-23 15:09:08','2026-09-23 15:09:08'),(21,7,'Tent Pitch 02','Available','2026-09-23 15:09:08','2026-09-23 15:09:08'),(22,7,'Tent Pitch 03','Available','2026-09-23 15:09:08','2026-09-23 15:09:08'),(23,7,'Tent Pitch 04','Available','2026-09-23 15:09:08','2026-09-23 15:09:08'),(24,7,'Tent Pitch 05','Available','2026-09-23 15:09:08','2026-09-23 15:09:08'),(25,7,'Tent Pitch 06','Available','2026-09-23 15:09:08','2026-09-23 15:09:08'),(26,7,'Tent Pitch 07','Available','2026-09-23 15:09:08','2026-09-23 15:09:08'),(27,7,'Tent Pitch 08','Available','2026-09-23 15:09:08','2026-09-23 15:09:08'),(28,8,'Kubo Room 01','Available','2026-09-23 15:09:08','2026-09-23 15:09:08'),(29,8,'Kubo Room 02','Available','2026-09-23 15:09:08','2026-09-23 15:09:08'),(30,8,'Kubo Room 03','Available','2026-09-23 15:09:08','2026-09-23 15:09:08'),(31,8,'Kubo Room 04','Available','2026-09-23 15:09:08','2026-09-23 15:09:08'),(32,9,'Pavilion 01','Available','2026-09-23 15:09:08','2026-09-23 15:09:08'),(33,9,'Pavilion 02','Available','2026-09-23 15:09:08','2026-09-23 15:09:08'),(34,11,'Parking Slot 01','Available','2026-09-23 15:09:08','2026-09-23 15:09:08'),(35,11,'Parking Slot 02','Available','2026-09-23 15:09:08','2026-09-23 15:09:08'),(36,11,'Parking Slot 03','Available','2026-09-23 15:09:08','2026-09-23 15:09:08'),(37,11,'Parking Slot 04','Available','2026-09-23 15:09:08','2026-09-23 15:09:08'),(38,11,'Parking Slot 05','Available','2026-09-23 15:09:08','2026-09-23 15:09:08'),(39,11,'Parking Slot 06','Available','2026-09-23 15:09:08','2026-09-23 15:09:08'),(40,11,'Parking Slot 07','Available','2026-09-23 15:09:08','2026-09-23 15:09:08'),(41,11,'Parking Slot 08','Available','2026-09-23 15:09:08','2026-09-23 15:09:08'),(42,11,'Parking Slot 09','Available','2026-09-23 15:09:08','2026-09-23 15:09:08'),(43,11,'Parking Slot 10','Available','2026-09-23 15:09:09','2026-09-23 15:09:09'),(44,11,'Parking Slot 11','Available','2026-09-23 15:09:09','2026-09-23 15:09:09'),(45,11,'Parking Slot 12','Available','2026-09-23 15:09:09','2026-09-23 15:09:09'),(46,11,'Parking Slot 13','Available','2026-09-23 15:09:09','2026-09-23 15:09:09'),(47,11,'Parking Slot 14','Available','2026-09-23 15:09:09','2026-09-23 15:09:09'),(48,11,'Parking Slot 15','Available','2026-09-23 15:09:09','2026-09-23 15:09:09'),(49,11,'Parking Slot 16','Available','2026-09-23 15:09:09','2026-09-23 15:09:09'),(50,11,'Parking Slot 17','Available','2026-09-23 15:09:09','2026-09-23 15:09:09'),(51,11,'Parking Slot 18','Available','2026-09-23 15:09:09','2026-09-23 15:09:09'),(52,11,'Parking Slot 19','Available','2026-09-23 15:09:09','2026-09-23 15:09:09'),(53,11,'Parking Slot 20','Available','2026-09-23 15:09:09','2026-09-23 15:09:09'),(54,11,'Parking Slot 21','Available','2026-09-23 15:09:09','2026-09-23 15:09:09'),(55,11,'Parking Slot 22','Available','2026-09-23 15:09:09','2026-09-23 15:09:09'),(56,11,'Parking Slot 23','Available','2026-09-23 15:09:09','2026-09-23 15:09:09'),(57,11,'Parking Slot 24','Available','2026-09-23 15:09:09','2026-09-23 15:09:09'),(58,11,'Parking Slot 25','Available','2026-09-23 15:09:09','2026-09-23 15:09:09'),(59,11,'Parking Slot 26','Available','2026-09-23 15:09:09','2026-09-23 15:09:09'),(60,11,'Parking Slot 27','Available','2026-09-23 15:09:09','2026-09-23 15:09:09'),(61,11,'Parking Slot 28','Available','2026-09-23 15:09:09','2026-09-23 15:09:09'),(62,11,'Parking Slot 29','Available','2026-09-23 15:09:09','2026-09-23 15:09:09'),(63,11,'Parking Slot 30','Available','2026-09-23 15:09:09','2026-09-23 15:09:09'),(64,11,'Parking Slot 31','Available','2026-09-23 15:09:09','2026-09-23 15:09:09'),(65,11,'Parking Slot 32','Available','2026-09-23 15:09:09','2026-09-23 15:09:09'),(66,11,'Parking Slot 33','Available','2026-09-23 15:09:09','2026-09-23 15:09:09'),(67,11,'Parking Slot 34','Available','2026-09-23 15:09:09','2026-09-23 15:09:09'),(68,11,'Parking Slot 35','Available','2026-09-23 15:09:09','2026-09-23 15:09:09'),(69,11,'Parking Slot 36','Available','2026-09-23 15:09:09','2026-09-23 15:09:09'),(70,11,'Parking Slot 37','Available','2026-09-23 15:09:09','2026-09-23 15:09:09'),(71,11,'Parking Slot 38','Available','2026-09-23 15:09:09','2026-09-23 15:09:09'),(72,11,'Parking Slot 39','Available','2026-09-23 15:09:09','2026-09-23 15:09:09'),(73,11,'Parking Slot 40','Available','2026-09-23 15:09:09','2026-09-23 15:09:09'),(74,12,'Umbrella 01','Available','2026-09-23 15:09:09','2026-09-23 15:09:09'),(75,12,'Umbrella 02','Available','2026-09-23 15:09:09','2026-09-23 15:09:09'),(76,12,'Umbrella 03','Available','2026-09-23 15:09:09','2026-09-23 15:09:09'),(77,12,'Umbrella 04','Available','2026-09-23 15:09:09','2026-09-23 15:09:09'),(78,12,'Umbrella 05','Available','2026-09-23 15:09:09','2026-09-23 15:09:09'),(79,12,'Umbrella 06','Available','2026-09-23 15:09:09','2026-09-23 15:09:09'),(80,12,'Umbrella 07','Available','2026-09-23 15:09:09','2026-09-23 15:09:09'),(81,12,'Umbrella 08','Available','2026-09-23 15:09:09','2026-09-23 15:09:09'),(82,12,'Umbrella 09','Available','2026-09-23 15:09:09','2026-09-23 15:09:09'),(83,12,'Umbrella 10','Available','2026-09-23 15:09:09','2026-09-23 15:09:09'),(84,13,'Family Cottage 01','Available','2026-09-23 15:09:09','2026-09-23 15:09:09'),(85,13,'Family Cottage 02','Available','2026-09-23 15:09:09','2026-09-23 15:09:09'),(86,13,'Family Cottage 03','Available','2026-09-23 15:09:09','2026-09-23 15:09:09'),(87,13,'Family Cottage 04','Available','2026-09-23 15:09:09','2026-09-23 15:09:09'),(88,13,'Family Cottage 05','Available','2026-09-23 15:09:09','2026-09-23 15:09:09'),(89,13,'Family Cottage 06','Available','2026-09-23 15:09:09','2026-09-23 15:09:09'),(90,13,'Family Cottage 07','Available','2026-09-23 15:09:09','2026-09-23 15:09:09'),(91,13,'Family Cottage 08','Available','2026-09-23 15:09:09','2026-09-23 15:09:09'),(92,13,'Family Cottage 09','Available','2026-09-23 15:09:09','2026-09-23 15:09:09'),(93,13,'Family Cottage 10','Available','2026-09-23 15:09:09','2026-09-23 15:09:09');

/*Table structure for table `services` */

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
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `services` */

insert  into `services`(`service_id`,`service_code`,`service_name`,`slug`,`category`,`description`,`short_description`,`price`,`unit`,`total_capacity`,`capacity_persons`,`minimum_quantity`,`available_qty`,`image_url`,`status`,`manual_status`,`is_featured`,`show_on_landing`,`is_assignable`,`inclusions`,`exclusions`,`terms`,`gallery`,`deleted_at`,`created_at`,`updated_at`) values (1,'DSVC-001','Cold Spring Pool Entrance Ticket','cold-spring-pool-entrance-ticket','Entrance','Day pass access to natural cold spring pool',NULL,'100.00','head',300,NULL,1,300,'/src/assets/images/services/swimming.png','Active',NULL,0,1,0,NULL,NULL,NULL,NULL,NULL,'2026-08-05 02:03:40','2026-09-29 22:10:58'),(2,'DSVC-002','Standard Open Cottage','standard-open-cottage','Cottage','Shaded native open cottage near pool',NULL,'600.00','day',10,NULL,1,10,'/src/assets/images/services/cottage.png','Active',NULL,0,1,1,NULL,NULL,NULL,NULL,NULL,'2026-08-05 02:03:40','2026-09-29 22:10:58'),(3,'DSVC-003','Resort Table & Chairs Set','resort-table-chairs-set','Rental','1 Table + 4 monoblock chairs',NULL,'250.00','day',15,NULL,1,15,'/src/assets/images/services/table.png','Active',NULL,0,1,0,NULL,NULL,NULL,NULL,NULL,'2026-08-05 02:03:40','2026-09-29 22:10:58'),(4,'DSVC-004','Life Vest / Safety Gear','life-vest-safety-gear','Safety','Adult & Kid safety flotation vest',NULL,'50.00','head',30,NULL,1,30,'/src/assets/images/services/lifevest.png','Active',NULL,0,1,0,NULL,NULL,NULL,NULL,NULL,'2026-08-05 02:03:40','2026-09-29 22:10:58'),(5,'DSVC-005','Videoke Karaoke System','videoke-karaoke-system','Entertainment','Heavy-duty Videoke sound system',NULL,'500.00','day',4,NULL,1,4,'/src/assets/images/services/videoke.png','Active',NULL,0,1,1,NULL,NULL,NULL,NULL,NULL,'2026-08-05 02:03:40','2026-10-05 20:59:43'),(6,'DSVC-006','Kayak / Floating Pad Rental','kayak-floating-pad-rental','Water Activity','1-hour kayak & water pad rental',NULL,'300.00','hour',5,NULL,1,5,'/src/assets/images/services/floating.png','Active',NULL,0,1,1,NULL,NULL,NULL,NULL,NULL,'2026-08-05 02:03:40','2026-09-29 22:10:58'),(7,'DSVC-007','Camping Pitch & Tent','camping-pitch-tent','Accommodation','Overnight camping slot & tent',NULL,'450.00','night',8,NULL,1,8,'/src/assets/images/services/tent.png','Active',NULL,0,1,1,NULL,NULL,NULL,NULL,NULL,'2026-08-05 02:03:40','2026-09-29 22:10:58'),(8,'DSVC-008','Aircon Kubo Guest Room','aircon-kubo-guest-room','Accommodation','Private aircon room with bed & bath',NULL,'1500.00','night',4,NULL,1,4,'/src/assets/images/services/room.png','Active',NULL,0,1,1,NULL,NULL,NULL,NULL,NULL,'2026-08-05 02:03:40','2026-09-29 22:10:58'),(9,'DSVC-009','Private Event Pavilion','private-event-pavilion','Event','Private pavilion for family gatherings & events',NULL,'3500.00','event',2,NULL,1,2,'/src/assets/images/services/event.png','Active',NULL,0,1,1,NULL,NULL,NULL,NULL,NULL,'2026-08-05 02:03:40','2026-09-29 22:10:58'),(10,'DSVC-010','Buffet & Catering Station','buffet-catering-station','Food','Native buffet catering package',NULL,'450.00','head',50,NULL,1,50,'/src/assets/images/services/buffet.png','Active',NULL,0,1,0,NULL,NULL,NULL,NULL,NULL,'2026-08-05 02:03:40','2026-09-29 22:10:58'),(11,'DSVC-011','Secured Resort Parking Slot','secured-resort-parking-slot','Parking','Safe vehicle parking for cars & vans',NULL,'50.00','vehicle',40,NULL,1,40,'/src/assets/images/services/parking.png','Active',NULL,0,1,1,NULL,NULL,NULL,NULL,NULL,'2026-08-05 02:03:40','2026-09-29 22:10:58');

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
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `users` */

insert  into `users`(`user_id`,`user_number`,`fname`,`mname`,`lname`,`gender`,`birthdate`,`address`,`contact_no`,`email`,`username`,`password`,`hashed_password`,`role`,`status`,`created_at`,`updated_at`,`approved_by`,`approved_at`) values (1,'ADM-2026-000001','System','Administrator','Root','Female','2000-01-01','Bilar, Bohol','09123456789','admin@ecotourvista.com','admin','$2a$10$.K9kYf4Pys9ppQDqJb8mt.Ow6fZVaxhcDElyhM38e1I5IiyyLR9M.',NULL,'admin','Approved','2026-08-03 03:48:22','2026-10-20 02:55:38',NULL,NULL),(3,'STF-2026-000003','Juan','D.','Dela Cruz','Male','1998-05-15','Duangon, Zamora, Bilar, Bohol','09171234567','staff@ecotourvista.com','staff01','$2a$10$/uSKaKsVz6OXi1WbZ0eho.uwPJHg2UbRlpeeXzCNFqexq8kz2wSYe',NULL,'staff','Approved','2026-08-04 07:34:25','2026-09-29 21:52:39',NULL,NULL),(5,'CLT-2026-000005','Maria','S.','Santos','Female','2001-08-20','Bilar, Bohol','09981234567','client@ecotourvista.com','client01','$2a$10$zcN98h2YVTs8PbHOK5lCrefZvmjMEBt41xSNVkSI1tkgfLeMmEMOK',NULL,'client','Approved','2026-08-04 07:34:35','2026-10-05 21:10:10',NULL,NULL),(7,'CLT-2026-123456','Test','','User','Male',NULL,'Test Address','09123456789','test@example.com','test@example.com','$2a$10$NYdSeuCbuiKDQXYrk2KtIuUZSG9Vid.CO7fi5rUx5D8U5ZXtWFOsW',NULL,'client','Pending','2026-10-05 21:45:08','2026-10-05 21:45:08',NULL,NULL),(8,'CLT-2026-000003','AILEEN','Tapao','LAGURA','Female',NULL,'Dagohoy, Bilar, Bohol','0994512277','aileenlagura16@gmail.com','aileenlagura16@gmail.com','$2a$10$fpwxxEOM08FPsNhp0Soocuho1hZYqJcDwQiXE/VXbin5L474tSS76',NULL,'client','Approved','2026-10-05 22:18:21','2026-10-05 22:18:33','Admin','2026-10-05 22:18:33'),(9,'CLT-2026-824176','AIRAH','TAPAO','LAGURA','Male',NULL,'Dagohoy, Bilar, Bohol','09945122977','aileen.lagura@bisu.edu.ph','aileen.lagura@bisu.edu.ph','$2a$10$UVNkphRTRie5iZZBPDHCJOOUyQ6tFL.FJ1EnqofvieW65CG8EUcSa',NULL,'client','Approved','2026-10-05 22:28:10','2026-10-05 22:28:10',NULL,NULL),(10,'CLT-2026-586966','ALEX','TAPAO','LAGURA','Male',NULL,'Dagohoy, Bilar, Bohol','09945122977','laguraaileen30@gmail.com','laguraaileen30@gmail.com','$2a$10$OFWxgycK9YSbxmRLYs9Av.nWvE0meL6H7vAdt3OgZmAu2vJQLR2eK',NULL,'client','Approved','2026-10-05 23:10:03','2026-10-05 23:10:41','Admin','2026-10-05 23:10:41'),(11,'CLT-2026-692745','EVELYN','T','LAGURAa','Male',NULL,'Dagohoy, Bilar, Bohol','2222222222222222','ailleenlagura@gmail.com','ailleenlagura@gmail.com','$2a$10$9283UWLqVTLTBANP.i64OeDGvGbEXHY8hs5FE0CUhZyBpEBfec18a',NULL,'client','Approved','2026-10-20 22:16:56','2026-10-20 22:48:26','Admin','2026-10-20 22:18:00'),(12,'STF-2026-000002','Melva','','Gumapac','Female',NULL,'bohol','08908790798','melvagumapac48@gmail.com','melvagumapac48@gmail.com','$2a$10$ZlhWXvXVpAO/8Zb5B8XgIuKtVhFzVIKE.CSGCs6RK7yXxHc6r6mGG',NULL,'staff','Approved','2026-10-21 10:04:41','2026-10-21 10:05:37','System Root','2026-10-21 10:05:37');

/*Table structure for table `vouchers` */

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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `vouchers` */

insert  into `vouchers`(`id`,`code`,`discount_type`,`discount_value`,`min_spend`,`max_discount`,`start_date`,`end_date`,`usage_limit`,`used_count`,`per_user_limit`,`status`,`created_at`,`updated_at`) values (1,'WELCOME100','Fixed','100.00','500.00',NULL,'2026-09-15 15:05:19','2026-10-16 15:05:19',100,0,1,'Active','2026-09-16 15:05:19','2026-09-16 15:05:19');

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

/* Procedure structure for procedure `sp_create_announcement` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_create_announcement` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_create_announcement`(
  IN p_title       VARCHAR(150),
  IN p_description TEXT,
  IN p_created_by  INT
)
BEGIN
  INSERT INTO announcements (title, description, created_by)
  VALUES (p_title, p_description, p_created_by);

  SELECT LAST_INSERT_ID() AS announcement_id;
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_create_audit_log` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_create_audit_log` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_create_audit_log`(
  IN p_user_id     INT,
  IN p_action      VARCHAR(100),
  IN p_description TEXT
)
BEGIN
  INSERT INTO audit_logs (user_id, action, description)
  VALUES (NULLIF(p_user_id, 0), p_action, p_description);

  SELECT LAST_INSERT_ID() AS log_id;
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_create_booking` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_create_booking` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_create_booking`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_create_notification` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_create_notification` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_create_notification`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_create_payment` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_create_payment` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_create_payment`(
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
      END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_create_service` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_create_service` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_create_service`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_create_walkin_transaction` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_create_walkin_transaction` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_create_walkin_transaction`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_delete_announcement` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_delete_announcement` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_announcement`(
  IN p_id INT
)
BEGIN
  DELETE FROM announcements WHERE announcement_id = p_id;
  SELECT ROW_COUNT() AS affected_rows;
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_delete_service` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_delete_service` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_service`(
  IN p_service_id INT
)
BEGIN
  DELETE FROM services WHERE service_id = p_service_id;
  SELECT ROW_COUNT() AS affected_rows;
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_get_all_bookings` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_get_all_bookings` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_all_bookings`()
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_get_all_payments` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_get_all_payments` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_all_payments`()
BEGIN
  SELECT
    p.id, p.payment_ref, p.booking_id, p.client_name,
    p.staff_id, p.staff_name, p.total_amount, p.cash_received,
    p.change_amount, p.payment_method, p.status, p.created_at,
    r.gross_amount, r.park_share, r.barangay_share, r.guide_share
  FROM payments p
  LEFT JOIN revenue_shares r ON p.id = r.payment_id
  ORDER BY p.id DESC;
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_get_all_services` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_get_all_services` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_all_services`()
BEGIN
  SELECT
    service_id, service_code, service_name, category,
    description, price, unit, total_capacity, available_qty,
    image_url, status, created_at, updated_at
  FROM services
  ORDER BY service_code ASC;
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_get_all_users` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_get_all_users` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_all_users`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_get_announcements` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_get_announcements` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_announcements`()
BEGIN
  SELECT announcement_id, title, description, created_by, created_at
  FROM announcements
  ORDER BY created_at DESC;
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_get_audit_logs` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_get_audit_logs` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_audit_logs`()
BEGIN
  SELECT
    a.log_id, a.user_id, a.action, a.description, a.created_at,
    u.fname, u.lname, u.role, u.email
  FROM audit_logs a
  LEFT JOIN users u ON a.user_id = u.user_id
  ORDER BY a.created_at DESC
  LIMIT 100;
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_get_booking_by_id` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_get_booking_by_id` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_booking_by_id`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_get_booking_items` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_get_booking_items` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_booking_items`(
  IN p_booking_id INT
)
BEGIN
  SELECT id, booking_id, service_id, service_name,
         unit_price, quantity, subtotal
  FROM booking_items
  WHERE booking_id = p_booking_id;
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_get_booking_items_bulk` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_get_booking_items_bulk` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_booking_items_bulk`(IN p_booking_ids TEXT)
BEGIN SET @sql = CONCAT('SELECT id, booking_id, service_id, service_name, unit_price, quantity, subtotal, item_type FROM booking_items WHERE booking_id IN (', p_booking_ids, ')'); PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt; END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_get_daily_revenue_report` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_get_daily_revenue_report` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_daily_revenue_report`()
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_get_dashboard_summary` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_get_dashboard_summary` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_dashboard_summary`()
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_get_monthly_revenue_report` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_get_monthly_revenue_report` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_monthly_revenue_report`()
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_get_payment_by_id` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_get_payment_by_id` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_payment_by_id`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_get_user_by_email` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_get_user_by_email` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_user_by_email`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_get_user_by_id` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_get_user_by_id` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_user_by_id`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_get_user_notifications` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_get_user_notifications` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_user_notifications`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_get_walkin_transactions` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_get_walkin_transactions` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_walkin_transactions`()
BEGIN
  SELECT
    wt.transaction_id, wt.staff_id, wt.customer_name,
    wt.transaction_date, wt.total_amount, wt.payment_method, wt.remarks,
    u.fname, u.lname
  FROM walkin_transactions wt
  LEFT JOIN users u ON wt.staff_id = u.user_id
  ORDER BY wt.transaction_date DESC;
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_mark_notification_as_read` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_mark_notification_as_read` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_mark_notification_as_read`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_register_user` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_register_user` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_register_user`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_search_users` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_search_users` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_search_users`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_update_booking_status` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_update_booking_status` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_booking_status`(
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
      END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_update_service` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_update_service` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_service`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_update_user_password` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_update_user_password` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_user_password`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_update_user_profile` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_update_user_profile` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_user_profile`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_update_user_status` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_update_user_status` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_user_status`(
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
END */$$
DELIMITER ;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
