-- EcoTourVista database — generated 2026-10-05T15:20:04.394Z from the live database
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
(1, 'PKG-001', 'Quick Dip Deal', 'Best for small groups and quick family swimming trips.', '/src/assets/images/services/quick dip.png', '900.00', '810.00', '10.00', 5, 'SAVE ₱90', 'Active', NULL, NULL, '2026-09-16 07:53:29', '2026-09-16 07:53:29', 'Percentage', 'STANDARD', NULL, 0, 1, NULL),
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
(3, 'MIDMONTH', '⚡ Mid-Month Flash Splash', 'Special mid-month flash sale!', 'Percentage', 'FLASH', '25.00', '2026-09-15 16:00:00', '2026-09-17 15:59:59', 'Asia/Manila', 'BOOKING_DATE', 1, 0, NULL, 0, 'Active', '2026-09-16 07:30:39', '2026-09-16 07:30:39', NULL, NULL, NULL, 0, 1, NULL);

-- promotion_packages (0 rows)
DELETE FROM `promotion_packages`;

-- promotion_services (0 rows)
DELETE FROM `promotion_services`;

-- tourist_spots (0 rows)
DELETE FROM `tourist_spots`;

SET FOREIGN_KEY_CHECKS = 1;
