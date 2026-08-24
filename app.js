const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const helmet = require('helmet');
const compression = require('compression');
const cookieParser = require('cookie-parser');
const xss = require('xss-clean');
const hpp = require('hpp');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

const authRoutes = require('./src/routes/authRoutes');
const userRoutes = require('./src/routes/userRoutes');
const serviceRoutes = require('./src/routes/serviceRoutes');
const reservationRoutes = require('./src/routes/reservationRoutes');
const paymentRoutes = require('./src/routes/paymentRoutes');
const galleryRoutes = require('./src/routes/galleryRoutes');
const reportRoutes = require('./src/routes/reportRoutes');
const dashboardRoutes = require('./src/routes/dashboardRoutes');
const announcementRoutes = require('./src/routes/announcementRoutes');
const settingRoutes = require('./src/routes/settingRoutes');
const auditLogRoutes = require('./src/routes/auditLogRoutes');
const notificationRoutes = require('./src/routes/notificationRoutes');
const notFoundMiddleware = require('./src/middleware/notFoundMiddleware');
const errorMiddleware = require('./src/middleware/errorMiddleware');

const createApp = () => {
  const app = express();

  app.use(helmet());
  app.use(compression());
  app.use(morgan('dev'));
  app.use(cors({ origin: true, credentials: true }));
  app.use(express.json({ limit: '10mb' }));
  app.use(express.urlencoded({ extended: true }));
  app.use(cookieParser(process.env.COOKIE_SECRET || 'secret'));
  app.use(xss());
  app.use(hpp());

  const limiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 50000,
    standardHeaders: true,
    legacyHeaders: false,
    message: { success: false, message: 'Too many requests from this IP, please try again later.' },
    skip: (req) => req.ip === '127.0.0.1' || req.ip === '::1' || req.ip === '::ffff:127.0.0.1' || req.path === '/health' || req.path.startsWith('/api/v1/auth'),
  });
  app.use(limiter);

  app.get('/health', (req, res) => {
    res.status(200).json({ status: 'ok', service: 'ecotour-server' });
  });

  app.use('/api/v1/auth', authRoutes);
  app.use('/api/v1/users', userRoutes);
  app.use('/api/v1/services', serviceRoutes);
  app.use('/api/v1/reservations', reservationRoutes);
  app.use('/api/v1/payments', paymentRoutes);
  app.use('/api/v1/gallery', galleryRoutes);
  app.use('/api/v1/reports', reportRoutes);
  app.use('/api/v1/dashboard', dashboardRoutes);
  app.use('/api/v1/announcements', announcementRoutes);
  app.use('/api/v1/settings', settingRoutes);
  app.use('/api/v1/audit_logs', auditLogRoutes);
  app.use('/api/v1/tourist_spots', require('./src/routes/touristSpotRoutes'));
  app.use('/api/v1/notifications', notificationRoutes);

  app.use(notFoundMiddleware);
  app.use(errorMiddleware);

  return app;
};

module.exports = { createApp };
