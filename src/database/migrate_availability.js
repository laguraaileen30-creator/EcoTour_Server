// Idempotent migration: service management fields, package/deal management fields,
// numbered facility units, and the Unlimited All-Access package.
// Run with: npm run migrate
require('dotenv').config();
const db = require('../config/database');

const ASSIGNABLE_CATEGORIES = ['cottage', 'accommodation', 'event', 'entertainment', 'water activity', 'parking'];

const UNIT_PREFIX = {
  'DSVC-002': 'Cottage',
  'DSVC-002B': 'Family Cottage',
  'DSVC-002C': 'Umbrella',
  'DSVC-005': 'Videoke',
  'DSVC-006': 'Kayak',
  'DSVC-007': 'Tent Pitch',
  'DSVC-008': 'Kubo Room',
  'DSVC-009': 'Pavilion',
  'DSVC-011': 'Parking Slot',
};

const columnExists = async (table, column) => {
  const [rows] = await db.query(
    'SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND COLUMN_NAME = ?',
    [table, column]
  );
  return rows.length > 0;
};

const addColumn = async (table, column, definition) => {
  if (!(await columnExists(table, column))) {
    await db.query(`ALTER TABLE \`${table}\` ADD COLUMN \`${column}\` ${definition}`);
    console.log(`+ ${table}.${column}`);
  }
};

const run = async () => {
  // 1. SERVICES — admin-managed fields
  await addColumn('services', 'slug', 'VARCHAR(120) NULL AFTER service_name');
  await addColumn('services', 'short_description', 'VARCHAR(255) NULL AFTER category');
  await addColumn('services', 'capacity_persons', 'INT NULL');
  await addColumn('services', 'minimum_quantity', 'INT NOT NULL DEFAULT 1');
  await addColumn('services', 'manual_status', "VARCHAR(20) NULL COMMENT 'OUT_OF_STOCK | UNAVAILABLE | MAINTENANCE; NULL = automatic'");
  await addColumn('services', 'is_featured', 'TINYINT(1) NOT NULL DEFAULT 0');
  await addColumn('services', 'show_on_landing', 'TINYINT(1) NOT NULL DEFAULT 1');
  await addColumn('services', 'is_assignable', "TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1 = numbered physical units (service_resources)'");
  await addColumn('services', 'inclusions', 'TEXT NULL');
  await addColumn('services', 'exclusions', 'TEXT NULL');
  await addColumn('services', 'terms', 'TEXT NULL');
  await addColumn('services', 'gallery', 'TEXT NULL');
  await addColumn('services', 'deleted_at', 'DATETIME NULL');

  await db.query(
    `UPDATE services SET is_assignable = 1 WHERE LOWER(category) IN (${ASSIGNABLE_CATEGORIES.map(() => '?').join(',')})`,
    ASSIGNABLE_CATEGORIES
  );
  await db.query("UPDATE services SET slug = LOWER(REPLACE(REPLACE(REPLACE(service_name, ' / ', '-'), ' & ', '-'), ' ', '-')) WHERE slug IS NULL");
  await db.query("UPDATE services SET short_description = LEFT(description, 255) WHERE short_description IS NULL");
  await db.query("UPDATE services SET image_url = '/src/assets/images/services/cottage.png' WHERE image_url IS NULL AND LOWER(category) = 'cottage'");

  // 2. PACKAGES
  await addColumn('packages', 'discount_type', "VARCHAR(20) NOT NULL DEFAULT 'Percentage'");
  await addColumn('packages', 'package_type', "VARCHAR(20) NOT NULL DEFAULT 'STANDARD'");
  await addColumn('packages', 'manual_status', 'VARCHAR(20) NULL');
  await addColumn('packages', 'is_featured', 'TINYINT(1) NOT NULL DEFAULT 0');
  await addColumn('packages', 'show_on_landing', 'TINYINT(1) NOT NULL DEFAULT 1');
  await addColumn('packages', 'deleted_at', 'DATETIME NULL');

  // 3. DEALS (existing promotions table)
  await addColumn('promotions', 'image_url', 'VARCHAR(255) NULL');
  await addColumn('promotions', 'original_price', 'DECIMAL(10,2) NULL');
  await addColumn('promotions', 'discounted_price', 'DECIMAL(10,2) NULL');
  await addColumn('promotions', 'is_featured', 'TINYINT(1) NOT NULL DEFAULT 0');
  await addColumn('promotions', 'show_on_landing', 'TINYINT(1) NOT NULL DEFAULT 1');
  await addColumn('promotions', 'deleted_at', 'DATETIME NULL');
  await db.query("ALTER TABLE promotions MODIFY discount_type ENUM('Percentage','Fixed','Special Price','Bundle') DEFAULT 'Percentage'");
  await db.query(`CREATE TABLE IF NOT EXISTS promotion_services (
    id INT NOT NULL AUTO_INCREMENT,
    promotion_id INT NOT NULL,
    service_id INT NOT NULL,
    PRIMARY KEY (id),
    KEY promotion_id (promotion_id),
    KEY service_id (service_id),
    CONSTRAINT promotion_services_ibfk_1 FOREIGN KEY (promotion_id) REFERENCES promotions (id) ON DELETE CASCADE,
    CONSTRAINT promotion_services_ibfk_2 FOREIGN KEY (service_id) REFERENCES services (service_id) ON DELETE CASCADE
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci`);

  // 4. SETTINGS
  await db.query(
    "INSERT INTO settings (setting_key, setting_value) SELECT 'low_stock_threshold_pct', '20' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM settings WHERE setting_key = 'low_stock_threshold_pct')"
  );

  // 4b. BOOKING TYPES + ITEM TYPES + SERVER-SIDE TICKET PRICES
  await addColumn('bookings', 'booking_type', "VARCHAR(40) NULL COMMENT 'PACKAGE_ONLY | PACKAGE_WITH_TICKETS | PACKAGE_WITH_ADDONS | PACKAGE_WITH_TICKETS_AND_ADDONS | TICKETS_ONLY | TICKETS_WITH_ADDONS | ADDONS_ONLY'");
  await addColumn('booking_items', 'item_type', "VARCHAR(20) NULL COMMENT 'PACKAGE | TICKET | FEE | ADDON'");
  const defaults = {
    ticket_price_adult: '100', ticket_price_child: '40', ticket_price_student: '70', ticket_price_senior: '80', environmental_fee_per_head: '30',
  };
  for (const [key, value] of Object.entries(defaults)) {
    await db.query(
      'INSERT INTO settings (setting_key, setting_value) SELECT ?, ? FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM settings WHERE setting_key = ?)',
      [key, value, key]
    );
  }

  // 4c. RESERVATION FEE (downpayment) + 24-hour client confirmation
  await addColumn('bookings', 'reservation_fee', 'DECIMAL(10,2) NOT NULL DEFAULT 0.00');
  await addColumn('bookings', 'amount_paid', 'DECIMAL(10,2) NOT NULL DEFAULT 0.00');
  await addColumn('bookings', 'fee_status', "VARCHAR(20) NULL COMMENT 'UNPAID | PAID | NOT_REQUIRED'");
  await addColumn('bookings', 'confirmation_status', "VARCHAR(20) NULL COMMENT 'AWAITING_CLIENT | CONFIRMED | DECLINED | EXPIRED'");
  await addColumn('bookings', 'confirmation_sent_at', 'DATETIME NULL');
  await addColumn('bookings', 'confirmation_deadline', 'DATETIME NULL');
  await addColumn('bookings', 'confirmation_token', 'VARCHAR(64) NULL');
  await addColumn('bookings', 'confirmation_responded_at', 'DATETIME NULL');
  for (const [key, value] of Object.entries({ reservation_fee_pct: '50', confirmation_window_hours: '24' })) {
    await db.query(
      'INSERT INTO settings (setting_key, setting_value) SELECT ?, ? FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM settings WHERE setting_key = ?)',
      [key, value, key]
    );
  }
  // Existing paid/finished bookings: fee is settled; amount paid = total
  await db.query(
    `UPDATE bookings SET fee_status = 'NOT_REQUIRED', amount_paid = total_amount
     WHERE fee_status IS NULL AND (status LIKE '%paid%' OR status LIKE '%using%' OR status LIKE '%complete%')`
  );
  await db.query("UPDATE bookings SET fee_status = 'NOT_REQUIRED' WHERE fee_status IS NULL AND (status LIKE '%cancel%' OR status LIKE '%void%' OR status LIKE '%reject%')");
  const [pendingRows] = await db.query("SELECT value FROM (SELECT setting_value AS value FROM settings WHERE setting_key = 'reservation_fee_pct') x");
  const feePct = parseFloat(pendingRows[0]?.value || 50);
  await db.query('UPDATE bookings SET fee_status = \'UNPAID\', reservation_fee = ROUND(total_amount * ? / 100, 2) WHERE fee_status IS NULL', [feePct]);

  // 5. NUMBERED FACILITY UNITS — one unit per available quantity of every assignable service
  const [services] = await db.query('SELECT service_id, service_code, service_name, total_capacity FROM services WHERE is_assignable = 1 AND deleted_at IS NULL');
  for (const s of services) {
    const [[{ cnt }]] = await db.query('SELECT COUNT(*) AS cnt FROM service_resources WHERE service_id = ?', [s.service_id]);
    const target = parseInt(s.total_capacity || 0, 10);
    const prefix = UNIT_PREFIX[s.service_code] || s.service_name;
    for (let n = cnt + 1; n <= target; n++) {
      await db.query('INSERT INTO service_resources (service_id, resource_name, status) VALUES (?, ?, ?)', [
        s.service_id, `${prefix} ${String(n).padStart(2, '0')}`, 'Available'
      ]);
    }
    if (target > cnt) console.log(`+ ${target - cnt} units for ${s.service_name}`);
  }

  // 6. UNLIMITED ALL-ACCESS PACKAGE
  const [existing] = await db.query("SELECT id FROM packages WHERE package_code = 'PKG-UNLIMITED-001'");
  if (existing.length === 0) {
    const [ins] = await db.query(
      `INSERT INTO packages (package_code, package_name, description, image_url, regular_value, promo_price, discount_percent,
         included_guests, badge, status, discount_type, package_type, is_featured, show_on_landing)
       VALUES ('PKG-UNLIMITED-001', 'Unlimited All-Access Package', ?, '/src/assets/images/services/unlimited.png',
         12000, 10100, 16, 10, '16% OFF', 'Active', 'Percentage', 'UNLIMITED', 1, 1)`,
      ['Enjoy Everything. No Limits. One Amazing Day! Access to ALL available Duangon Cold Spring services in one premium package. Unlimited use during your booked stay, subject to facility availability.']
    );
    const packageId = ins.insertId;
    const [allServices] = await db.query("SELECT service_id, category FROM services WHERE status = 'Active' AND deleted_at IS NULL");
    for (const s of allServices) {
      const qty = String(s.category).toLowerCase() === 'entrance' ? 10 : 1;
      await db.query('INSERT INTO package_items (package_id, service_id, quantity) VALUES (?, ?, ?)', [packageId, s.service_id, qty]);
    }
    console.log(`+ Unlimited All-Access Package (id ${packageId}) with ${allServices.length} services`);
  }

  // 7. DATA REPAIR (idempotent)
  // 7a. Legacy booking form stored "Adult Entrance (0x)" lines (0 guests saved as 1 × ₱100)
  const [zeroLines] = await db.query("DELETE FROM booking_items WHERE service_name LIKE '%(0x)%'");
  if (zeroLines.affectedRows) console.log(`- removed ${zeroLines.affectedRows} bogus "(0x)" entrance lines`);

  // 7b. Revenue shares whose payment no longer exists
  const [orphans] = await db.query('DELETE r FROM revenue_shares r LEFT JOIN payments p ON p.id = r.payment_id WHERE p.id IS NULL');
  if (orphans.affectedRows) console.log(`- removed ${orphans.affectedRows} orphaned revenue share(s)`);

  // 7c. Classify legacy booking lines (PACKAGE / TICKET / FEE / ADDON) and booking types
  const [pkgNames] = await db.query('SELECT LOWER(package_name) AS n FROM packages');
  const packageNames = new Set(pkgNames.map((r) => r.n));
  const [untyped] = await db.query('SELECT id, service_name FROM booking_items WHERE item_type IS NULL');
  for (const it of untyped) {
    const n = String(it.service_name || '').toLowerCase().trim();
    const type = packageNames.has(n) ? 'PACKAGE' : n.includes('environmental fee') ? 'FEE' : n.includes('entrance') ? 'TICKET' : 'ADDON';
    await db.query('UPDATE booking_items SET item_type = ? WHERE id = ?', [type, it.id]);
  }
  if (untyped.length) console.log(`- classified ${untyped.length} legacy booking line(s)`);

  const [untypedBookings] = await db.query(
    `SELECT b.id,
            SUM(i.item_type = 'PACKAGE') AS pk, SUM(i.item_type = 'TICKET') AS tk, SUM(i.item_type = 'ADDON') AS ad, b.package_id
     FROM bookings b LEFT JOIN booking_items i ON i.booking_id = b.id
     WHERE b.booking_type IS NULL GROUP BY b.id`
  );
  for (const b of untypedBookings) {
    const hasPkg = Number(b.pk) > 0 || !!b.package_id;
    const hasT = Number(b.tk) > 0;
    const hasA = Number(b.ad) > 0;
    const type = hasPkg
      ? (hasT && hasA ? 'PACKAGE_WITH_TICKETS_AND_ADDONS' : hasT ? 'PACKAGE_WITH_TICKETS' : hasA ? 'PACKAGE_WITH_ADDONS' : 'PACKAGE_ONLY')
      : (hasT && hasA ? 'TICKETS_WITH_ADDONS' : hasT ? 'TICKETS_ONLY' : 'ADDONS_ONLY');
    await db.query('UPDATE bookings SET booking_type = ? WHERE id = ?', [type, b.id]);
  }
  if (untypedBookings.length) console.log(`- set booking type on ${untypedBookings.length} legacy booking(s)`);

  // 7d. Link legacy package bookings to their package
  const [linked] = await db.query(
    `UPDATE bookings b
     JOIN booking_items i ON i.booking_id = b.id AND i.item_type = 'PACKAGE'
     JOIN packages p ON LOWER(p.package_name) = LOWER(i.service_name)
     SET b.package_id = p.id
     WHERE b.package_id IS NULL`
  );
  if (linked.affectedRows) console.log(`- linked ${linked.affectedRows} legacy booking(s) to their package`);

  console.log('Migration complete.');
};

run()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error('Migration failed:', err);
    process.exit(1);
  });
