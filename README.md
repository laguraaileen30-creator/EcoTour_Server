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
3. Create the database. New install — run these in order against an empty MySQL database:
   ```
   src/database/ecotour_schema.sql      # tables
   src/database/ecotour_procedures.sql  # stored procedures
   src/database/ecotour_seed.sql        # services, packages, deals, facility units, settings
   ```
   Existing database — apply the latest structure and data fixes (safe to run repeatedly):
   ```bash
   npm run migrate
   ```
4. Start the server:
   ```bash
   npm run dev
   ```
   The server listens on port 5000, which the frontend expects. If 5000 is busy it stops with an error instead of moving to another port.
5. Check health: http://localhost:5000/health

## Database scripts
- `npm run migrate` — idempotent upgrade and data repair of an existing database
- `npm run db:export` — regenerate the three SQL files above from the live database (catalog data only, no customer data)

## Access rules
- Public: browsing services / packages / deals, availability, quotes, new reservations, register, login
- Logged-in users: their own reservations, payments, notifications and profile
- Staff / Admin: all reservations, payments, reports, dashboard, facility assignment, add-on charges
- Admin only: user management, services / packages / deals, settings, tourist spots

## Verification
The application module currently loads successfully with:
```bash
node -e "require('./app'); console.log('app loaded successfully')"
```
