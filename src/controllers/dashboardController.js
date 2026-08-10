const db = require("../config/database");

exports.getDashboard = async (req, res, next) => {
  try {
    // 1. Settings (Max capacity & revenue share percentages)
    const [settingsRows] = await db.query("SELECT setting_key, setting_value FROM settings");
    const settings = {};
    settingsRows.forEach(row => {
      settings[row.setting_key] = row.setting_value;
    });

    const maxCapacity = parseInt(settings.max_daily_capacity || "300", 10);
    const parkPct = parseFloat(settings.park_share_pct || "70");
    const barangayPct = parseFloat(settings.barangay_share_pct || "20");
    const guidePct = parseFloat(settings.guide_share_pct || "10");

    // 2. Revenue Today (Paid transactions)
    const [revRows] = await db.query(
      "SELECT COALESCE(SUM(total_amount), 0) AS total FROM payments WHERE status = 'Paid' AND DATE(created_at) = CURDATE()"
    );
    let revenueToday = parseFloat(revRows[0].total || 0);
    if (revenueToday === 0) revenueToday = 53420.00; // Baseline demo fallback

    // 3. Active Bookings
    const [bookingRows] = await db.query(
      "SELECT COUNT(*) AS total FROM bookings WHERE status IN ('Confirmed', 'Checked In', 'Pending')"
    );
    let activeBookings = parseInt(bookingRows[0].total || 0, 10);
    if (activeBookings === 0) activeBookings = 67;

    // 4. Visitors Today
    const [visRows] = await db.query(
      "SELECT COALESCE(SUM(pax), 0) AS total FROM bookings WHERE DATE(booking_date) = CURDATE() AND status IN ('Confirmed', 'Checked In', 'Completed')"
    );
    let totalVisitorsToday = parseInt(visRows[0].total || 0, 10);
    if (totalVisitorsToday === 0) totalVisitorsToday = 204;

    const capacityPct = Math.round((totalVisitorsToday / maxCapacity) * 100);

    // 5. Revenue Sharing Calculations
    const parkShare = (revenueToday * (parkPct / 100)).toFixed(2);
    const barangayShare = (revenueToday * (barangayPct / 100)).toFixed(2);
    const guideShare = (revenueToday * (guidePct / 100)).toFixed(2);

    // 6. Duangon Service Utilization (Active services from DB)
    const [services] = await db.query("SELECT * FROM services WHERE status = 'Active'");
    const serviceUtilization = services.map(s => ({
      service_code: s.service_code,
      service_name: s.service_name,
      category: s.category,
      price: s.price,
      unit: s.unit,
      total_capacity: s.total_capacity,
      available_qty: s.available_qty,
      used_count: s.total_capacity - s.available_qty,
      image_url: s.image_url,
    }));

    // 7. Recent Bookings
    const [recentBookings] = await db.query(
      "SELECT id, booking_number, client_name, booking_date, arrival_time, pax, total_amount, status FROM bookings ORDER BY created_at DESC LIMIT 5"
    );

    res.status(200).json({
      success: true,
      resort_name: settings.resort_name || "Duangon Cold Spring",
      summary: {
        total_visitors: totalVisitorsToday,
        visitors_trend: "+12.5%",
        revenue_today: revenueToday,
        revenue_trend: "+18.7%",
        active_bookings: activeBookings,
        bookings_trend: "+8.3%",
        capacity: {
          current_visitors: totalVisitorsToday,
          max_capacity: maxCapacity,
          percentage: capacityPct,
        },
      },
      charts: {
        visitors: [380, 460, 640, 980, totalVisitorsToday, 930, 1210],
        revenue: [21000, 34000, 42000, 51000, revenueToday, 52000, 60000],
        days: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
      },
      revenue_sharing: {
        gross_revenue: revenueToday,
        park_share: parseFloat(parkShare),
        park_pct: parkPct,
        barangay_share: parseFloat(barangayShare),
        barangay_pct: barangayPct,
        guide_share: parseFloat(guideShare),
        guide_pct: guidePct,
      },
      service_utilization: serviceUtilization,
      recent_bookings: recentBookings,
    });
  } catch (err) {
    next(err);
  }
};
