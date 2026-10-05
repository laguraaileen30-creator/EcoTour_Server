require('dotenv').config();
const db = require('./src/config/database');

const sp = `
CREATE PROCEDURE sp_register_user(
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
END`;

async function run() {
  try {
    await db.query('DROP PROCEDURE IF EXISTS sp_register_user');
    await db.query(sp);
    console.log('SP updated');
  } catch (e) {
    console.error(e);
  } finally {
    process.exit(0);
  }
}
run();
