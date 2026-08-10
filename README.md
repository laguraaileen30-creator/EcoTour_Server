# EcoTour Server

A scalable Node.js + Express.js + MySQL backend skeleton for a resort management and reservation system with three roles: Admin-Owner, Staff, and Client.

## Features scaffolded
- Authentication routes and middleware
- User profile endpoints
- Reservation, payment, and gallery endpoints
- Report and dashboard endpoints
- Clean modular folder structure for future expansion

## Getting started
1. Copy .env.example to .env and update database and JWT settings.
2. Install dependencies:
   ```bash
   npm install
   ```
3. Start the server:
   ```bash
   npm run dev
   ```
4. Check health:
   ```bash
   http://localhost:5000/health
   ```
   If port 5000 is busy, the server will automatically try the next available port and report it in the console.

## Verification
The application module currently loads successfully with:
```bash
node -e "require('./app'); console.log('app loaded successfully')"
```
