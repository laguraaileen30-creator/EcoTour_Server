// Reservation fee (downpayment) + 24-hour client confirmation lifecycle.
//
// 1. Client books online  -> reservation_fee = total × reservation_fee_pct (default 50%), fee_status UNPAID, status Pending
// 2. Staff emails client  -> confirmation_status AWAITING_CLIENT, 24h deadline, one-time Continue / Cancel links
// 3. Client answers       -> CONFIRMED (keeps booking) or DECLINED (booking voided, units released)
//    No answer by deadline-> EXPIRED (booking auto-voided, units released, client emailed)
// 4. Staff records cash   -> reservation fee first, then the balance; fully paid => status Paid
const crypto = require('crypto');
const db = require('../config/database');
const { sendEmail } = require('../services/emailService');
const { createSystemNotification } = require('./notificationController');
const { syncAssignmentsForBookingStatus } = require('./availabilityController');
const { getScope, ownsBooking } = require('../services/accessScope');

const APP_URL = process.env.APP_URL || 'http://localhost:5173';
const API_URL = process.env.API_URL || `http://localhost:${process.env.PORT || 5000}`;
const FEE_PAID_STATUS = 'Pending - Reservation Fee Paid';

const peso = (n) => `₱${Number(n || 0).toLocaleString('en-PH', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
const phDateTime = (d) => new Date(d).toLocaleString('en-US', { timeZone: 'Asia/Manila', dateStyle: 'medium', timeStyle: 'short' });
const toDate = (d) => (d instanceof Date ? d : new Date(d));

const getSettings = async (conn = db) => {
  const [rows] = await conn.query("SELECT setting_key, setting_value FROM settings WHERE setting_key IN ('reservation_fee_pct','confirmation_window_hours')");
  const s = Object.fromEntries(rows.map((r) => [r.setting_key, r.setting_value]));
  return {
    feePct: Math.min(100, Math.max(0, parseFloat(s.reservation_fee_pct ?? 50))),
    windowHours: Math.max(1, parseFloat(s.confirmation_window_hours ?? 24)),
  };
};
exports.getSettings = getSettings;

const findBooking = async (idOrRef, conn = db, lock = false) => {
  const ref = String(idOrRef || '').trim();
  const numericId = /^\d+$/.test(ref) ? Number(ref) : 0;
  const [rows] = await conn.query(
    `SELECT b.*, u.email AS account_email, u.fname AS account_fname
     FROM bookings b LEFT JOIN users u ON u.user_id = b.user_id
     WHERE b.id = ? OR b.booking_number = ? LIMIT 1 ${lock ? 'FOR UPDATE' : ''}`,
    [numericId, ref]
  );
  return rows[0] || null;
};

// Email goes to the address on the client's account; walk-in / guest bookings fall back to the booking email
const recipientOf = (b) => ({
  email: b.account_email || b.client_email,
  name: b.account_fname || String(b.client_name || 'Guest').split(' ')[0],
});

const isOpen = (status) => !/cancel|void|reject|complete|checked out/i.test(String(status || ''));

const emailFrame = (title, body) => `
  <div style="font-family:Segoe UI,Arial,sans-serif;background:#f0fdf4;padding:24px">
    <div style="max-width:600px;margin:0 auto;background:#ffffff;border-radius:18px;overflow:hidden;border:1px solid #bbf7d0">
      <div style="background:linear-gradient(135deg,#065f46,#0f766e);padding:22px 26px;color:#ecfdf5">
        <div style="font-size:12px;letter-spacing:3px;font-weight:700;color:#a7f3d0">DUANGON COLD SPRING • ECOTOURVISTA</div>
        <div style="font-size:21px;font-weight:800;margin-top:6px">${title}</div>
      </div>
      <div style="padding:24px 26px;color:#1f2937;font-size:14px;line-height:1.6">${body}</div>
      <div style="padding:14px 26px;background:#f8fafc;color:#64748b;font-size:11px;text-align:center">Duangon, Zamora, Bilar, Bohol • (038) 501-8920 • support@ecotourvista.ph</div>
    </div>
  </div>`;

const summaryTable = (b) => {
  const balance = Math.max(0, Number(b.total_amount) - Number(b.amount_paid || 0));
  const row = (k, v, strong = false) => `<tr><td style="padding:7px 0;color:#64748b">${k}</td><td style="padding:7px 0;text-align:right;${strong ? 'font-weight:800;color:#047857' : 'font-weight:600'}">${v}</td></tr>`;
  const visit = b.booking_date ? new Date(b.booking_date).toLocaleDateString('en-US', { timeZone: 'Asia/Manila', dateStyle: 'full' }) : '';
  return `<table style="width:100%;border-collapse:collapse;font-size:13px;margin:14px 0">
    ${row('Booking reference', `<span style="font-family:monospace">${b.booking_number}</span>`)}
    ${row('Visit date', `${visit} • ${b.arrival_time || ''}`)}
    ${row('Guests', `${b.pax} pax`)}
    ${row('Booking total', peso(b.total_amount))}
    ${row('Reservation fee (downpayment)', peso(b.reservation_fee), true)}
    ${row('Paid so far', peso(b.amount_paid))}
    ${row('Balance due', peso(balance))}
  </table>`;
};

const button = (href, label, color) => `<a href="${href}" style="display:inline-block;background:${color};color:#ffffff;text-decoration:none;font-weight:800;padding:12px 22px;border-radius:12px;margin:4px 6px">${label}</a>`;

// ── POST /api/v1/reservations/:id/request-confirmation (staff/admin) ──
exports.requestConfirmation = async (req, res) => {
  try {
    const b = await findBooking(req.params.id);
    if (!b) return res.status(404).json({ success: false, message: 'Reservation not found' });
    if (!isOpen(b.status)) return res.status(400).json({ success: false, message: `This reservation is already ${b.status}.` });
    if (Number(b.amount_paid) >= Number(b.total_amount) && Number(b.total_amount) > 0) {
      return res.status(400).json({ success: false, message: 'This reservation is already fully paid.' });
    }
    if (b.fee_status === 'NOT_REQUIRED') {
      return res.status(400).json({ success: false, message: 'Walk-in bookings do not need a reservation fee or confirmation email.' });
    }
    const to = recipientOf(b);
    if (!to.email) return res.status(400).json({ success: false, message: 'This reservation has no email address to notify.' });

    const { windowHours } = await getSettings();
    const token = crypto.randomBytes(24).toString('hex');
    const deadline = new Date(Date.now() + windowHours * 3600 * 1000);
    await db.query(
      `UPDATE bookings SET confirmation_status = 'AWAITING_CLIENT', confirmation_sent_at = NOW(), confirmation_deadline = ?,
         confirmation_token = ?, confirmation_responded_at = NULL WHERE id = ?`,
      [deadline, token, b.id]
    );

    const link = (action) => `${API_URL}/api/v1/reservations/confirm/${token}?action=${action}`;
    const subject = `⏰ Action needed within ${windowHours} hours: continue or cancel reservation ${b.booking_number}`;
    const html = emailFrame('Please confirm your reservation', `
      <p>Hi <b>${to.name}</b>,</p>
      <p>Thank you for booking with Duangon Cold Spring. Please tell us whether you will <b>continue</b> with this reservation.
      You have until <b>${phDateTime(deadline)} (PHT)</b> — about ${windowHours} hours. If we don't hear from you by then,
      the reservation is <b>automatically voided</b> and the cottages are released to other guests.</p>
      ${summaryTable({ ...b })}
      <p style="background:#fffbeb;border:1px solid #fde68a;border-radius:10px;padding:10px 12px;font-size:13px">
        <b>Reservation fee:</b> pay the ${peso(b.reservation_fee)} downpayment in <b>cash at the resort counter</b> to secure your booking.
        The remaining balance is paid on arrival.</p>
      <div style="text-align:center;margin:22px 0 6px">
        ${button(link('continue'), '✓ Yes, continue my reservation', '#059669')}
        ${button(link('cancel'), '✕ Cancel (void) my reservation', '#e11d48')}
      </div>
      <p style="font-size:12px;color:#64748b;text-align:center">You can also answer from <a href="${APP_URL}/login">My Reservations</a> in your EcoTourVista account.</p>
    `);
    const balance = Math.max(0, Number(b.total_amount) - Number(b.amount_paid || 0));
    const visit = b.booking_date ? new Date(b.booking_date).toLocaleDateString('en-US', { timeZone: 'Asia/Manila', dateStyle: 'full' }) : '';
    const text = `Hi ${to.name},\n\n` +
      `Thank you for booking with Duangon Cold Spring Resort. Please tell us whether you will CONTINUE with reservation ${b.booking_number}.\n\n` +
      `You have until ${phDateTime(deadline)} (PHT) — about ${windowHours} hours. If we don't hear from you by then, the reservation is automatically VOIDED and the cottages are released to other guests.\n\n` +
      `Reservation fee: please pay the ${peso(b.reservation_fee)} downpayment in CASH at the resort counter to secure your booking. The remaining balance is paid on arrival.\n\n` +
      `To CONTINUE, open: ${link('continue')}\n` +
      `To CANCEL (void), open: ${link('cancel')}\n\n` +
      `You can also answer from My Reservations in your EcoTourVista account: ${APP_URL}/login\n\n` +
      `— Duangon Cold Spring Resort, Bilar, Bohol`;
    // FormSubmit email: deadline first, then the booking, the money, and the two answer links
    const intro = `Thank you for booking with Duangon Cold Spring Resort! Please tell us within ${windowHours} hours whether you will continue with your reservation. If we don't hear from you in time, it is voided automatically and the cottages are released to other guests.`;
    const fields = {
      '⏰ Please answer before': `${phDateTime(deadline)} (Philippine time)`,
      '🎫 Booking reference': b.booking_number,
      '📅 Visit date': `${visit} ${b.arrival_time || ''}`.trim(),
      '👥 Guests': `${b.pax} pax`,
      '💰 Booking total': peso(b.total_amount),
      '💵 Reservation fee — pay in cash at the counter': peso(b.reservation_fee),
      '🧾 Balance due on arrival': peso(balance),
      '✅ YES, CONTINUE my reservation — open this link': link('continue'),
      '❌ NO, CANCEL (void) my reservation — open this link': link('cancel'),
      '💻 Or answer online': `${APP_URL}/login  (My Reservations)`,
    };
    const mail = await sendEmail({ to: to.email, name: to.name, subject, text, html, intro, fields });

    await db.query('INSERT INTO audit_logs (action, description) VALUES (?, ?)', [
      'RESERVATION_CONFIRMATION_REQUESTED',
      `${req.user?.role || 'staff'} emailed ${to.email} to confirm ${b.booking_number} (deadline ${deadline.toISOString()})`,
    ]);
    createSystemNotification({
      roleTarget: 'client', userId: b.user_id || null,
      title: `Please confirm reservation ${b.booking_number}`,
      message: `Continue or cancel before ${phDateTime(deadline)} (PHT), or the reservation is voided automatically.`,
      type: 'booking', referenceId: b.booking_number,
    });

    res.json({
      success: true,
      message: `Confirmation email sent to ${to.email}. The client has ${windowHours} hours to answer.`,
      data: { email: to.email, deadline, delivered: mail.delivered, channel: mail.channel, previewUrl: mail.previewUrl, notice: mail.notice || null },
    });
  } catch (error) {
    console.error('Request confirmation error:', error);
    require('fs').writeFileSync('email_err.txt', error.stack);
    res.status(500).json({ success: false, message: 'Could not send the confirmation email', error: error.message });
  }
};

// Apply a client's decision (shared by the email link and the client portal)
const applyDecision = async (b, action, via) => {
  if (b.confirmation_status !== 'AWAITING_CLIENT') {
    return { ok: false, code: 'NOT_AWAITING', message: b.confirmation_status ? `This reservation was already ${b.confirmation_status.toLowerCase()}.` : 'No confirmation is pending for this reservation.' };
  }
  if (b.confirmation_deadline && toDate(b.confirmation_deadline) < new Date()) {
    await expireBooking(b);
    return { ok: false, code: 'EXPIRED', message: 'The 24-hour confirmation window has passed, so this reservation was voided.' };
  }
  if (action === 'continue') {
    await db.query("UPDATE bookings SET confirmation_status = 'CONFIRMED', confirmation_responded_at = NOW(), confirmation_token = NULL WHERE id = ?", [b.id]);
    createSystemNotification({ roleTarget: 'staff', title: `Client confirmed ${b.booking_number}`, message: `${b.client_name} will continue (via ${via}). Collect the ${peso(b.reservation_fee)} reservation fee at the counter.`, type: 'booking', referenceId: b.booking_number });
    return { ok: true, status: 'CONFIRMED', message: 'Thank you! Your reservation is confirmed. Please pay the reservation fee in cash at the resort counter.' };
  }
  await db.query("UPDATE bookings SET status = 'Cancelled', confirmation_status = 'DECLINED', confirmation_responded_at = NOW(), confirmation_token = NULL WHERE id = ?", [b.id]);
  await syncAssignmentsForBookingStatus(b.id, 'Cancelled');
  createSystemNotification({ roleTarget: 'staff', title: `Client cancelled ${b.booking_number}`, message: `${b.client_name} chose to void the reservation (via ${via}). Units were released.`, type: 'booking', referenceId: b.booking_number });
  return { ok: true, status: 'DECLINED', message: 'Your reservation has been cancelled (voided). We hope to see you another time!' };
};

const resultPage = (ok, title, message) => `<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>${title}</title></head>
<body style="margin:0;font-family:Segoe UI,Arial,sans-serif;background:linear-gradient(135deg,#ecfdf5,#ccfbf1);min-height:100vh;display:flex;align-items:center;justify-content:center;padding:20px">
  <div style="max-width:460px;background:#fff;border-radius:22px;padding:32px;text-align:center;box-shadow:0 20px 50px rgba(6,78,59,.15);border:1px solid #bbf7d0">
    <div style="font-size:46px">${ok ? '✅' : '⚠️'}</div>
    <h1 style="font-size:22px;color:#064e3b;margin:10px 0">${title}</h1>
    <p style="color:#475569;line-height:1.6">${message}</p>
    <a href="${APP_URL}/login" style="display:inline-block;margin-top:14px;background:#059669;color:#fff;text-decoration:none;font-weight:800;padding:11px 20px;border-radius:12px">Open My Reservations</a>
  </div></body></html>`;

// ── GET /api/v1/reservations/confirm/:token?action=continue|cancel (public, from the email) ──
exports.respondByToken = async (req, res) => {
  try {
    const action = req.query.action === 'cancel' ? 'cancel' : req.query.action === 'continue' ? 'continue' : null;
    if (!action || !/^[a-f0-9]{48}$/.test(req.params.token || '')) {
      return res.status(400).send(resultPage(false, 'Invalid link', 'This confirmation link is not valid.'));
    }
    const [rows] = await db.query('SELECT * FROM bookings WHERE confirmation_token = ? LIMIT 1', [req.params.token]);
    const b = rows[0];
    if (!b) return res.status(404).send(resultPage(false, 'Link already used', 'This link has already been used or has expired. Please check My Reservations for the latest status.'));
    const result = await applyDecision(b, action, 'email');
    res.status(result.ok ? 200 : 409).send(resultPage(result.ok, result.ok ? (action === 'continue' ? 'Reservation confirmed' : 'Reservation cancelled') : 'Could not update reservation', `${result.message}<br><br><b>Reference:</b> ${b.booking_number}`));
  } catch (error) {
    console.error('Confirm by token error:', error);
    res.status(500).send(resultPage(false, 'Something went wrong', 'Please try again or contact the resort.'));
  }
};

// ── POST /api/v1/reservations/:id/decision { action } (client portal, own booking) ──
exports.clientDecision = async (req, res) => {
  try {
    const action = req.body?.action === 'cancel' ? 'cancel' : req.body?.action === 'continue' ? 'continue' : null;
    if (!action) return res.status(400).json({ success: false, message: 'Choose continue or cancel.' });
    const b = await findBooking(req.params.id);
    if (!b || !ownsBooking(await getScope(req), b)) return res.status(404).json({ success: false, message: 'Reservation not found' });
    const result = await applyDecision(b, action, 'client portal');
    res.status(result.ok ? 200 : 409).json({ success: result.ok, code: result.code, status: result.status, message: result.message });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Could not save your decision', error: error.message });
  }
};

// ── POST /api/v1/reservations/:id/payments { kind: 'FEE'|'BALANCE'|'FULL', cash_received } (staff/admin) ──
// Cash collected at the counter is saved to payments (+ revenue shares). Amounts are computed on the server.
exports.recordPayment = async (req, res) => {
  const conn = await db.getConnection();
  try {
    await conn.beginTransaction();
    const b = await findBooking(req.params.id, conn, true);
    if (!b) { await conn.rollback(); return res.status(404).json({ success: false, message: 'Reservation not found' }); }
    if (!isOpen(b.status)) { await conn.rollback(); return res.status(400).json({ success: false, message: `This reservation is ${b.status}.` }); }

    const total = Number(b.total_amount);
    const paid = Number(b.amount_paid || 0);
    const balance = Math.max(0, Math.round((total - paid) * 100) / 100);
    if (balance <= 0) { await conn.rollback(); return res.status(400).json({ success: false, message: 'This reservation is already fully paid.' }); }

    const kind = ['FEE', 'BALANCE', 'FULL'].includes(req.body?.kind) ? req.body.kind : 'FULL';
    const feeOutstanding = b.fee_status === 'UNPAID' ? Math.min(balance, Number(b.reservation_fee || 0)) : 0;
    const amount = kind === 'FEE' ? feeOutstanding : balance;
    if (!(amount > 0)) { await conn.rollback(); return res.status(400).json({ success: false, message: 'The reservation fee is already paid.' }); }

    const cash = parseFloat(req.body?.cash_received ?? amount);
    if (!(cash >= amount)) { await conn.rollback(); return res.status(400).json({ success: false, code: 'INSUFFICIENT_CASH', message: `Cash received must be at least ${peso(amount)}.` }); }

    const [countResult] = await conn.query('SELECT COUNT(*) AS cnt FROM payments');
    const paymentRef = `OR-${new Date().getFullYear()}-${String((countResult[0]?.cnt || 0) + 1).padStart(6, '0')}`;
    const staffName = req.body?.staff_name || 'Duty Cashier';
    const [pay] = await conn.query(
      `INSERT INTO payments (payment_ref, booking_id, client_name, staff_id, staff_name, total_amount, cash_received, change_amount, payment_method, status)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'Cash', 'Paid')`,
      [paymentRef, b.id, b.client_name, req.user?.user_id || null, staffName, amount, cash, Math.max(0, cash - amount)]
    );
    const [settings] = await conn.query("SELECT setting_key, setting_value FROM settings WHERE setting_key IN ('park_share_pct','barangay_share_pct','guide_share_pct')");
    const pct = { park_share_pct: 70, barangay_share_pct: 20, guide_share_pct: 10 };
    settings.forEach((r) => { pct[r.setting_key] = parseFloat(r.setting_value) || pct[r.setting_key]; });
    const r2 = (n) => Math.round(n * 100) / 100;
    await conn.query('INSERT INTO revenue_shares (payment_id, gross_amount, park_share, barangay_share, guide_share) VALUES (?, ?, ?, ?, ?)', [
      pay.insertId, amount, r2(amount * pct.park_share_pct / 100), r2(amount * pct.barangay_share_pct / 100), r2(amount * pct.guide_share_pct / 100),
    ]);

    const newPaid = r2(paid + amount);
    const fullyPaid = newPaid >= total - 0.009;
    const feePaid = b.fee_status === 'UNPAID' ? (newPaid >= Number(b.reservation_fee) - 0.009 ? 'PAID' : 'UNPAID') : b.fee_status;
    const newStatus = fullyPaid ? 'Paid' : (feePaid === 'PAID' ? FEE_PAID_STATUS : b.status);
    await conn.query('UPDATE bookings SET amount_paid = ?, fee_status = ?, status = ? WHERE id = ?', [newPaid, feePaid, newStatus, b.id]);
    await conn.query('INSERT INTO audit_logs (action, description) VALUES (?, ?)', [
      'RESERVATION_PAYMENT', `${paymentRef}: ${peso(amount)} ${kind === 'FEE' ? 'reservation fee' : 'payment'} for ${b.booking_number} (${b.client_name}) by ${staffName}`,
    ]);
    await conn.commit();

    res.status(201).json({
      success: true,
      message: fullyPaid ? 'Fully paid.' : kind === 'FEE' ? 'Reservation fee recorded.' : 'Payment recorded.',
      data: {
        receiptNo: paymentRef, amount, cashReceived: cash, change: Math.max(0, cash - amount),
        amountPaid: newPaid, balanceDue: r2(Math.max(0, total - newPaid)), feeStatus: feePaid, status: newStatus, kind,
      },
    });
  } catch (error) {
    await conn.rollback().catch(() => {});
    console.error('Record payment error:', error);
    res.status(500).json({ success: false, message: 'Could not record the payment', error: error.message });
  } finally {
    conn.release();
  }
};

// Void a booking whose confirmation window passed and tell the client
const expireBooking = async (b) => {
  const [r] = await db.query(
    "UPDATE bookings SET status = 'Cancelled', confirmation_status = 'EXPIRED', confirmation_token = NULL WHERE id = ? AND confirmation_status = 'AWAITING_CLIENT'",
    [b.id]
  );
  if (!r.affectedRows) return false;
  await syncAssignmentsForBookingStatus(b.id, 'Cancelled');
  const full = await findBooking(b.id);
  const to = recipientOf(full || b);
  if (to.email) {
    sendEmail({
      to: to.email,
      name: to.name,
      subject: `⛔ Reservation ${b.booking_number} was voided (no response within the confirmation window)`,
      intro: 'We did not receive your answer within the confirmation window, so your reservation was automatically voided and the cottages were released to other guests. You are welcome to book again anytime.',
      fields: {
        '🎫 Booking reference': b.booking_number,
        '⛔ Status': 'VOIDED — no reply before the deadline',
        '🔗 Book again': `${APP_URL}/login`,
      },
      text: `Hi ${to.name},\n\nWe did not receive your answer in time, so reservation ${b.booking_number} was automatically voided and the facilities were released. You are welcome to book again anytime.\n`,
      html: emailFrame('Your reservation was voided', `<p>Hi <b>${to.name}</b>,</p><p>We did not receive your answer within the confirmation window, so reservation <b style="font-family:monospace">${b.booking_number}</b> was <b>automatically voided</b> and the cottages were released to other guests.</p><p>You are welcome to <a href="${APP_URL}/login">book again</a> anytime.</p>`),
    }).catch(() => {});
  }
  createSystemNotification({ roleTarget: 'staff', title: `Auto-voided ${b.booking_number}`, message: `${b.client_name} did not respond within the confirmation window.`, type: 'booking', referenceId: b.booking_number });
  await db.query('INSERT INTO audit_logs (action, description) VALUES (?, ?)', ['RESERVATION_AUTO_VOIDED', `${b.booking_number} voided: no client response before ${new Date(b.confirmation_deadline).toISOString()}`]);
  return true;
};

// Background job: void every booking whose 24-hour window has passed
exports.expireOverdueConfirmations = async () => {
  try {
    const [rows] = await db.query("SELECT * FROM bookings WHERE confirmation_status = 'AWAITING_CLIENT' AND confirmation_deadline IS NOT NULL AND confirmation_deadline < NOW()");
    let count = 0;
    for (const b of rows) { if (await expireBooking(b)) count += 1; }
    if (count) console.log(`[CONFIRMATION JOB] Auto-voided ${count} reservation(s) with no client response`);
    return count;
  } catch (error) {
    console.warn('[CONFIRMATION JOB]', error.message);
    return 0;
  }
};
