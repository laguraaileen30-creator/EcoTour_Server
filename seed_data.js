require('dotenv').config();
const db = require('./src/config/database');

async function seedDatabase() {
  try {
    const [spots] = await db.query('SELECT COUNT(*) as cnt FROM tourist_spots');
    if (spots[0].cnt === 0) {
      await db.query(`
        INSERT INTO tourist_spots (spot_name, description, location, entrance_local, entrance_foreign, image, status) VALUES 
        ('Rajah Sikatuna Protected Landscape', 'Bohols largest protected forest sanctuary, home to rare birds, lush trails, and natural springs.', 'Riverside, Bilar', 100.00, 150.00, '/src/assets/images/services/Rajah.png', 'active'),
        ('Kinaiyahan Forest Park', 'A peaceful forest park featuring camping grounds, scenic walking paths, and mountain air.', 'Zamora, Bilar', 50.00, 100.00, '/src/assets/images/services/Kinaiyahan.jpg', 'active'),
        ('Tinugdan Spring', 'A serene natural spring with cool, flowing mountain water surrounded by lush foliage.', 'Campagao, Bilar', 30.00, 50.00, '/src/assets/images/services/Tinugdan.png', 'active'),
        ('Pangas Falls', 'A cascading waterfall with a wide natural pool, ideal for swimming and picnics.', 'Dagohoy, Bilar', 40.00, 80.00, '/src/assets/images/services/Pangas.png', 'active'),
        ('Camelo View Deck', 'A viewpoint offering panoramic views of Bilars lush valleys.', 'Zamora, Bilar', 20.00, 50.00, '/src/assets/images/services/Camelo.png', 'active')
      `);
      console.log('✅ Seeded tourist_spots in MySQL!');
    }

    const [gal] = await db.query('SELECT COUNT(*) as cnt FROM gallery');
    if (gal[0].cnt === 0) {
      await db.query(`
        INSERT INTO gallery (title, image, category) VALUES 
        ('Crystal Cold Spring Pool', '/src/assets/images/services/swimming.png', 'Pool Area'),
        ('Native Shaded Open Cottage', '/src/assets/images/services/cottage.png', 'Cottages'),
        ('Aircon Kubo Guest Room', '/src/assets/images/services/room.png', 'Accommodation'),
        ('River Kayak Stream Experience', '/src/assets/images/services/floating.png', 'Activities'),
        ('Private Event Pavilion', '/src/assets/images/services/event.png', 'Events')
      `);
      console.log('✅ Seeded gallery in MySQL!');
    }

    const [ann] = await db.query('SELECT COUNT(*) as cnt FROM announcements');
    if (ann[0].cnt === 0) {
      await db.query(`
        INSERT INTO announcements (title, description, created_by) VALUES 
        ('Welcome to Duangon Cold Spring Resort', 'We are open daily from 07:00 AM to 06:00 PM. Enjoy our fresh natural spring pools, cottages, and amenities!', 1),
        ('Environmental Care Reminder', 'Please keep our resort grounds clean and green. Proper waste disposal bins are located near all cottages.', 1)
      `);
      console.log('✅ Seeded announcements in MySQL!');
    }

    console.log('🚀 MySQL Database fully populated with real data!');
    process.exit(0);
  } catch (err) {
    console.error('❌ Seed error:', err);
    process.exit(1);
  }
}

seedDatabase();
