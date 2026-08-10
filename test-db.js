require("dotenv").config();
const mysql = require("mysql2/promise");

(async () => {
  try {
    const connection = await mysql.createConnection({
      host: process.env.DB_HOST,
      port: process.env.DB_PORT,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME,
    });

    console.log("✅ Connected to MySQL successfully!");

    const [rows] = await connection.query("SELECT NOW() AS currentDateTime");

    console.log(rows);

    await connection.end();

    console.log("✅ Connection closed.");
  } catch (err) {
    console.error("❌ Connection Error:");
    console.error(err.message);
  }
})();