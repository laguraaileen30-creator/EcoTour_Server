const { createApp } = require('./app');
require('dotenv').config();

const app = createApp();
const initialPort = Number(process.env.PORT) || 5000;

const startServer = (port) => {
  const server = app.listen(port, () => {
    console.log(`EcoTour server running on port ${server.address().port}`);
  });

  server.on('error', (error) => {
    if (error.code === 'EADDRINUSE') {
      const nextPort = port + 1;
      console.warn(`Port ${port} is already in use. Trying ${nextPort}...`);
      server.close(() => startServer(nextPort));
    } else {
      console.error(error);
      process.exit(1);
    }
  });
};

startServer(initialPort);
