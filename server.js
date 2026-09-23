const { createApp } = require('./app');
require('dotenv').config();

const app = createApp();
const port = Number(process.env.PORT) || 5000;

const server = app.listen(port, () => {
  console.log(`EcoTour server running on port ${port}`);
  // Auto-void reservations whose 24-hour confirmation window passed (checked every minute)
  const { expireOverdueConfirmations } = require('./src/controllers/reservationLifecycleController');
  expireOverdueConfirmations();
  setInterval(expireOverdueConfirmations, 60 * 1000);
});

server.on('error', (error) => {
  if (error.code === 'EADDRINUSE') {
    // The frontend always calls http://localhost:5000 — silently moving to another port would break it.
    console.error(`Port ${port} is already in use. Stop the other process (it may be an older EcoTour server) and start again.`);
  } else {
    console.error(error);
  }
  process.exit(1);
});
