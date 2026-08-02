const { createApp } = require('./app');
require('dotenv').config();

const app = createApp();
const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`EcoTour server running on port ${PORT}`);
});
