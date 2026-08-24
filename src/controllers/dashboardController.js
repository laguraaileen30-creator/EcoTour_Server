const db = require("../config/database");

exports.getDashboard = async (req, res, next) => {
  try {
    // Call unified dashboard SP — returns 6 result sets
    const [allResults] = await db.query("CALL sp_get_dashboard_summary()");

    // Result sets from CALL:
    //   allResults[0] = settings rows
    //   allResults[1] = [{ revenue_today }]
    //   allResults[2] = [{ active_bookings }]
    //   allResults[3] = [{ total_visitors_today }]
    //   allResults[4] = active services rows
    //   allResults[5] = recent 5 bookings
    //   allResults[6] = OK packet (mysql2 includes it)

    const settingsRows    = allResults[0] || [];
    const revenueRow      = (allResults[1] || [])[0] || {};
    const bookingsRow     = (allResults[2] || [])[0] || {};
    const visitorsRow     = (allResults[3] || [])[0] || {};
    const services        = allResults[4] || [];
    const recentBookings  = allResults[5] || [];

    // Parse settings
    const settings = {};
    settingsRows.forEach(row => {
      settings[row.setting_key] = row.setting_value;
    });

    const maxCapacity      = parseInt(settings.max_daily_capacity || "300", 10);
    const parkPct          = parseFloat(settings.park_share_pct    || "70");
    const barangayPct      = parseFloat(settings.barangay_share_pct || "20");
    const guidePct         = parseFloat(settings.guide_share_pct   || "10");
    const revenueToday     = parseFloat(revenueRow.revenue_today    || 0);
    const activeBookings   = parseInt(bookingsRow.active_bookings   || 0, 10);
    const totalVisitors    = parseInt(visitorsRow.total_visitors_today || 0, 10);
    const capacityPct      = maxCapacity > 0 ? Math.round((totalVisitors / maxCapacity) * 100) : 0;

    const parkShare    = (revenueToday * (parkPct    / 100)).toFixed(2);
    const barangayShare = (revenueToday * (barangayPct / 100)).toFixed(2);
    const guideShare   = (revenueToday * (guidePct   / 100)).toFixed(2);

    const serviceUtilization = services.map(s => ({
      service_code:   s.service_code,
      service_name:   s.service_name,
      category:       s.category,
      price:          parseFloat(s.price || 0),
      unit:           s.unit,
      total_capacity: s.total_capacity || 10,
      available_qty:  s.available_qty  || 10,
      used_count:     (s.total_capacity || 10) - (s.available_qty || 10),
      image_url:      s.image_url,
    }));

    const daysList   = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const revenueArr = [0, 0, 0, 0, 0, 0, revenueToday];
    const visitorsArr = [0, 0, 0, 0, 0, 0, totalVisitors];

    res.status(200).json({
      success: true,
      resort_name: settings.resort_name || "Duangon Cold Spring",
      summary: {
        total_visitors:  totalVisitors,
        visitors_trend:  "+0%",
        revenue_today:   revenueToday,
        revenue_trend:   "+0%",
        active_bookings: activeBookings,
        bookings_trend:  "+0%",
        capacity: {
          current_visitors: totalVisitors,
          max_capacity:     maxCapacity,
          percentage:       capacityPct,
        },
      },
      charts: {
        visitors: visitorsArr,
        revenue:  revenueArr,
        days:     daysList,
      },
      revenue_sharing: {
        gross_revenue:   revenueToday,
        park_share:      parseFloat(parkShare),
        park_pct:        parkPct,
        barangay_share:  parseFloat(barangayShare),
        barangay_pct:    barangayPct,
        guide_share:     parseFloat(guideShare),
        guide_pct:       guidePct,
      },
      service_utilization: serviceUtilization,
      recent_bookings:     recentBookings,
    });
  } catch (err) {
    next(err);
  }
};
