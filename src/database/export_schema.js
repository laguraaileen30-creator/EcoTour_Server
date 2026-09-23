// Regenerates the database scripts from the live database:
//   ecotour_schema.sql      — every table (structure only)
//   ecotour_procedures.sql  — every stored procedure
//   ecotour_seed.sql        — catalog data only (services, packages, deals, facility units, settings); no customer data
// Run with: npm run db:export
require('dotenv').config();
const fs = require('fs');
const path = require('path');
const db = require('../config/database');

const SEED_TABLES = ['settings', 'services', 'service_resources', 'service_inventory', 'capacity_limits', 'packages', 'package_items', 'promotions', 'promotion_packages', 'promotion_services', 'tourist_spots'];
const OUT = __dirname;

const sqlValue = (v) => {
  if (v === null || v === undefined) return 'NULL';
  if (v instanceof Date) return `'${v.toISOString().slice(0, 19).replace('T', ' ')}'`;
  if (typeof v === 'number') return String(v);
  if (Buffer.isBuffer(v)) return `0x${v.toString('hex')}`;
  return `'${String(v).replace(/\\/g, '\\\\').replace(/'/g, "\\'").replace(/\n/g, '\\n').replace(/\r/g, '\\r')}'`;
};

const run = async () => {
  const [tables] = await db.query("SELECT TABLE_NAME AS t FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_TYPE = 'BASE TABLE' ORDER BY TABLE_NAME");
  const header = `-- EcoTourVista database — generated ${new Date().toISOString()} from the live database\n-- Do not edit by hand; run \`npm run db:export\` to regenerate.\n\nSET NAMES utf8mb4;\nSET FOREIGN_KEY_CHECKS = 0;\n\n`;

  let schema = header;
  for (const { t } of tables) {
    const [[row]] = await db.query(`SHOW CREATE TABLE \`${t}\``);
    schema += `DROP TABLE IF EXISTS \`${t}\`;\n${row['Create Table'].replace(/ AUTO_INCREMENT=\d+/, '')};\n\n`;
  }
  schema += 'SET FOREIGN_KEY_CHECKS = 1;\n';
  fs.writeFileSync(path.join(OUT, 'ecotour_schema.sql'), schema);

  const [procs] = await db.query("SELECT ROUTINE_NAME AS n FROM information_schema.ROUTINES WHERE ROUTINE_SCHEMA = DATABASE() AND ROUTINE_TYPE = 'PROCEDURE' ORDER BY ROUTINE_NAME");
  let procSql = header.replace('SET FOREIGN_KEY_CHECKS = 0;\n', '') + 'DELIMITER $$\n\n';
  for (const { n } of procs) {
    const [[row]] = await db.query(`SHOW CREATE PROCEDURE \`${n}\``);
    const body = row['Create Procedure'].replace(/CREATE DEFINER=`[^`]+`@`[^`]+` PROCEDURE/, 'CREATE PROCEDURE');
    procSql += `DROP PROCEDURE IF EXISTS \`${n}\`$$\n${body}$$\n\n`;
  }
  procSql += 'DELIMITER ;\n';
  fs.writeFileSync(path.join(OUT, 'ecotour_procedures.sql'), procSql);

  let seed = header;
  for (const t of SEED_TABLES) {
    const exists = tables.some((x) => x.t === t);
    if (!exists) continue;
    const [rows] = await db.query(`SELECT * FROM \`${t}\``);
    seed += `-- ${t} (${rows.length} rows)\nDELETE FROM \`${t}\`;\n`;
    if (rows.length) {
      const cols = Object.keys(rows[0]);
      seed += `INSERT INTO \`${t}\` (${cols.map((c) => `\`${c}\``).join(', ')}) VALUES\n${rows.map((r) => `(${cols.map((c) => sqlValue(r[c])).join(', ')})`).join(',\n')};\n`;
    }
    seed += '\n';
  }
  seed += 'SET FOREIGN_KEY_CHECKS = 1;\n';
  fs.writeFileSync(path.join(OUT, 'ecotour_seed.sql'), seed);

  console.log(`Exported ${tables.length} tables, ${procs.length} procedures, seed for ${SEED_TABLES.length} catalog tables -> ${OUT}`);
};

run().then(() => process.exit(0)).catch((e) => { console.error(e); process.exit(1); });
