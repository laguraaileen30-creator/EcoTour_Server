require('dotenv').config();
const db = require('./src/config/database');
async function run() {
  try {
    await db.query("ALTER TABLE booking_items ADD COLUMN item_type varchar(20) DEFAULT NULL COMMENT 'PACKAGE | TICKET | FEE | ADDON | DAMAGE_FEE'");
    console.log('Column added');
  } catch (e) {
    console.error(e);
  } finally {
    process.exit(0);
  }
}
run();
