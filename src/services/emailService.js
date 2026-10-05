const nodemailer = require('nodemailer');
require('dotenv').config();

const APP_URL = process.env.APP_URL || 'http://localhost:5173';
const RESORT = {
  name: 'Duangon Cold Spring Resort',
  address: 'Duangon, Zamora, Bilar, Bohol, Philippines 6317',
  contact: '+63 912 345 6789  •  info@coldspringresort.com',
};

/**
 * Send an email through the FormSubmit HTTP API.
 * FormSubmit only renders plain-text rows (no custom HTML), so the design comes from its "box" template:
 * every row is its own card, in this order —
 *   brand header → greeting → message → the caller's rows (details, links) → resort address & help line.
 * Labels carry an icon so the important rows (deadline, buttons, password) stand out in the inbox.
 */
const sendViaFormSubmit = async ({ to, subject, name, intro, fields = {} }) => {
  try {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 5000);

    const response = await fetch(`https://formsubmit.co/ajax/${encodeURIComponent(to)}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        // FormSubmit rejects submissions that don't come from a website ("open this page through a web server")
        'Origin': APP_URL,
        'Referer': `${APP_URL}/`,
      },
      signal: controller.signal,
      body: JSON.stringify({
        _subject: subject,
        _template: 'box',
        _captcha: 'false',
        '🌿 EcoTourVista': `${RESORT.name} • Bilar, Bohol`,
        '👋 Hello': name || 'Guest',
        '📝 Message': intro,
        ...fields,
        '📍 Resort address': RESORT.address,
        '📞 Need help?': RESORT.contact,
      })
    });
    clearTimeout(timeoutId);
    const resData = await response.json();
    console.log(`[FORMSUBMIT HTTP API] Direct Form Submit result for ${to}:`, resData);
    return resData;
  } catch (err) {
    console.warn(`[FORMSUBMIT HTTP API NOTICE] FormSubmit call notice:`, err.message);
    return null;
  }
};

/**
 * Cached Nodemailer transporter
 */
let cachedTransporter = null;

const getTransporter = async () => {
  if (cachedTransporter) return cachedTransporter;

  const user = process.env.SMTP_USER || process.env.GMAIL_USER;
  const pass = process.env.SMTP_PASS || process.env.GMAIL_APP_PASS;

  if (user && pass && !user.includes('your_gmail')) {
    const host = process.env.SMTP_HOST || 'smtp.gmail.com';
    const port = parseInt(process.env.SMTP_PORT || '465', 10);

    if (host.includes('gmail') || user.includes('@gmail.com')) {
      cachedTransporter = nodemailer.createTransport({
        service: 'gmail',
        auth: { user, pass },
      });
      return cachedTransporter;
    }
    cachedTransporter = nodemailer.createTransport({
      host,
      port,
      secure: port === 465 || process.env.SMTP_SECURE === 'true',
      auth: { user, pass },
    });
    return cachedTransporter;
  }

  try {
    const testAccount = await nodemailer.createTestAccount();
    cachedTransporter = nodemailer.createTransport({
      host: 'smtp.ethereal.email',
      port: 587,
      secure: false,
      auth: {
        user: testAccount.user,
        pass: testAccount.pass,
      },
    });
    return cachedTransporter;
  } catch (err) {
    console.warn("Failed to create Ethereal test account:", err.message);
    return null;
  }
};

/**
 * Send Account Approval Email with Auto-Generated Password (High-speed dispatch)
 */
exports.sendApprovalEmail = async ({ email, name, userNumber, password }) => {
  const subject = `🎉 Account Approved - Welcome to EcoTourVista!`;
  const textContent = `Dear ${name},\n\n` +
    `Congratulations! Your registration for an EcoTourVista account has been APPROVED by the Administrator.\n\n` +
    `Account Login Credentials:\n` +
    `• Assigned ID: ${userNumber}\n` +
    `• Registered Email: ${email}\n` +
    `• Default Password: ${password}\n\n` +
    `You can now log in at ${APP_URL}/login using your email and default password.\n\n` +
    `Best regards,\nEcoTourVista Administration Team`;

  const htmlContent = `
    <div style="font-family: Arial, sans-serif; background-color: #04150e; color: #e2e8f0; padding: 30px; border-radius: 16px; max-width: 600px; margin: 0 auto; border: 1px solid #059669;">
      <div style="text-align: center; padding-bottom: 20px; border-bottom: 1px solid #064e3b;">
        <h1 style="color: #34d399; margin: 0; font-size: 24px;">EcoTourVista</h1>
        <span style="color: #a7f3d0; font-size: 11px; letter-spacing: 2px; text-transform: uppercase; font-weight: bold;">Account Approval Notice</span>
      </div>

      <div style="padding: 24px 0; line-height: 1.6;">
        <p style="font-size: 16px; font-weight: bold; color: #ffffff;">Hello ${name},</p>
        <p style="color: #cbd5e1;">Great news! Your account registration for <strong>EcoTourVista</strong> has been <strong style="color: #34d399;">APPROVED</strong> by our Administrator.</p>

        <div style="background-color: #062317; border: 1px solid #10b981; border-radius: 12px; padding: 20px; margin: 20px 0;">
          <h3 style="color: #34d399; margin-top: 0; font-size: 14px; text-transform: uppercase; letter-spacing: 1px;">Your Login Credentials</h3>
          <p style="margin: 6px 0; font-size: 13px;"><strong>Assigned ID:</strong> <span style="font-family: monospace; color: #a7f3d0; font-weight: bold;">${userNumber}</span></p>
          <p style="margin: 6px 0; font-size: 13px;"><strong>Login Email:</strong> <span style="color: #ffffff;">${email}</span></p>
          <p style="margin: 6px 0; font-size: 13px;"><strong>Auto-Generated Password:</strong> <code style="background-color: #022c22; color: #6ee7b7; padding: 4px 8px; border-radius: 6px; font-size: 14px; font-weight: bold;">${password}</code></p>
        </div>

        <div style="text-align: center; margin-top: 30px;">
          <a href="${APP_URL}/login" style="background-color: #059669; color: #ffffff; padding: 12px 28px; text-decoration: none; border-radius: 10px; font-weight: bold; font-size: 14px; display: inline-block;">LOG IN TO YOUR ACCOUNT</a>
        </div>
      </div>

      <div style="text-align: center; padding-top: 20px; border-top: 1px solid #064e3b; color: #64748b; font-size: 11px;">
        © 2026 EcoTourVista Resort Management. All rights reserved.
      </div>
    </div>
  `;

  console.log(`\n================ [EMAIL DISPATCH: ACCOUNT APPROVED] ================`);
  console.log(`TO: ${email}`);
  console.log(`SUBJECT: ${subject}`);
  console.log(`USER: ${name} (${userNumber})`);
  console.log(`GENERATED PASSWORD: ${password}`);
  console.log(`====================================================================\n`);

  // 1. Direct Form Submit HTTP Email Dispatch (Non-blocking async)
  const formSubmitPromise = sendViaFormSubmit({
    to: email,
    subject,
    name,
    intro: 'Great news! Your EcoTourVista account has been APPROVED by the resort administrator. Use the login details below to sign in and start booking.',
    fields: {
      '✅ Account status': 'APPROVED — ready to use',
      '🆔 Assigned client ID': userNumber,
      '📧 Login email': email,
      '🔑 Temporary password': password,
      '🔗 Log in here': `${APP_URL}/login`,
      '🛡️ Security tip': 'Change this temporary password after your first login, and never share it with anyone.',
    },
  });

  // 2. SMTP Transporter Dispatch (Non-blocking async)
  const smtpPromise = (async () => {
    try {
      const transporter = await getTransporter();
      if (transporter) {
        const fromAddress = process.env.SMTP_FROM || `"EcoTourVista Admin" <${process.env.SMTP_USER || 'no-reply@ecotourvista.ph'}>`;
        const info = await transporter.sendMail({
          from: fromAddress,
          to: email,
          subject,
          text: textContent,
          html: htmlContent,
        });
        console.log(`[SMTP EMAIL DISPATCH] Sent to ${email} (MessageID: ${info?.messageId || 'OK'})`);
      }
    } catch (err) {
      console.warn("[SMTP EMAIL NOTICE]", err.message);
    }
  })();

  // Fire in background so API responds in milliseconds
  Promise.allSettled([formSubmitPromise, smtpPromise]).catch(() => {});
};

/**
 * Send Account Decline / Rejection Email (High-speed dispatch)
 */
exports.sendDeclineEmail = async ({ email, name, reason }) => {
  const subject = `⚠️ Account Registration Update - EcoTourVista`;
  const textContent = `Dear ${name},\n\n` +
    `Thank you for your interest in registering with EcoTourVista.\n\n` +
    `We regret to inform you that your registration could not be approved at this time.\n\n` +
    `Reason for Decision:\n` +
    `"${reason || 'The submitted registration details did not pass our initial verification.'}"\n\n` +
    `If you believe this is an error or if you have corrected information, please register again or contact resort support.\n\n` +
    `Best regards,\nEcoTourVista Administration Team`;

  const htmlContent = `
    <div style="font-family: Arial, sans-serif; background-color: #04150e; color: #e2e8f0; padding: 30px; border-radius: 16px; max-width: 600px; margin: 0 auto; border: 1px solid #dc2626;">
      <div style="text-align: center; padding-bottom: 20px; border-bottom: 1px solid #7f1d1d;">
        <h1 style="color: #f87171; margin: 0; font-size: 24px;">EcoTourVista</h1>
        <span style="color: #fca5a5; font-size: 11px; letter-spacing: 2px; text-transform: uppercase; font-weight: bold;">Registration Update</span>
      </div>

      <div style="padding: 24px 0; line-height: 1.6;">
        <p style="font-size: 16px; font-weight: bold; color: #ffffff;">Hello ${name},</p>
        <p style="color: #cbd5e1;">Thank you for your interest in registering an account with <strong>EcoTourVista</strong>.</p>
        <p style="color: #cbd5e1;">We regret to inform you that your application could not be approved at this time.</p>

        <div style="background-color: #1a0808; border: 1px solid #ef4444; border-radius: 12px; padding: 20px; margin: 20px 0;">
          <h3 style="color: #f87171; margin-top: 0; font-size: 14px; text-transform: uppercase; letter-spacing: 1px;">Reason for Non-Approval</h3>
          <p style="margin: 6px 0; font-size: 13px; color: #fecaca; font-style: italic;">
            "${reason || 'The submitted registration details did not pass our initial verification.'}"
          </p>
        </div>

        <p style="color: #94a3b8; font-size: 12px;">If you have updated details or wish to re-apply, you may submit a new registration at any time.</p>

        <div style="text-align: center; margin-top: 30px;">
          <a href="${APP_URL}/signup" style="background-color: #dc2626; color: #ffffff; padding: 12px 28px; text-decoration: none; border-radius: 10px; font-weight: bold; font-size: 14px; display: inline-block;">RE-SUBMIT REGISTRATION</a>
        </div>
      </div>

      <div style="text-align: center; padding-top: 20px; border-top: 1px solid #7f1d1d; color: #64748b; font-size: 11px;">
        © 2026 EcoTourVista Resort Management. All rights reserved.
      </div>
    </div>
  `;

  console.log(`\n================ [EMAIL DISPATCH: ACCOUNT REJECTED] ================`);
  console.log(`TO: ${email}`);
  console.log(`SUBJECT: ${subject}`);
  console.log(`REASON: ${reason}`);
  console.log(`====================================================================\n`);

  // Direct Form Submit HTTP Email Dispatch (Non-blocking async)
  const formSubmitPromise = sendViaFormSubmit({
    to: email,
    subject,
    name,
    intro: 'Thank you for your interest in EcoTourVista. After review, your account registration could not be approved at this time.',
    fields: {
      '⚠️ Registration status': 'NOT APPROVED',
      '📋 Reason': reason || 'The submitted registration details did not pass our initial verification.',
      '🔁 What you can do': 'Correct the details and register again, or contact the resort if you think this is a mistake.',
      '🔗 Register again': `${APP_URL}/signup`,
    },
  });

  // SMTP Transporter Dispatch (Non-blocking async)
  const smtpPromise = (async () => {
    try {
      const transporter = await getTransporter();
      if (transporter) {
        const fromAddress = process.env.SMTP_FROM || `"EcoTourVista Admin" <${process.env.SMTP_USER || 'no-reply@ecotourvista.ph'}>`;
        const info = await transporter.sendMail({
          from: fromAddress,
          to: email,
          subject,
          text: textContent,
          html: htmlContent,
        });
        console.log(`[SMTP EMAIL DISPATCH] Sent to ${email} (MessageID: ${info?.messageId || 'OK'})`);
      }
    } catch (err) {
      console.warn("[SMTP EMAIL NOTICE]", err.message);
    }
  })();

  Promise.allSettled([formSubmitPromise, smtpPromise]).catch(() => {});
};

/**
 * General email sender used by reservation notices (e.g. the staff's 24-hour confirmation email).
 * - Gmail SMTP configured in .env  -> sent through SMTP only (real HTML email).
 * - Otherwise                      -> sent through FormSubmit (same relay as the account emails), plus an
 *                                     Ethereal test copy so staff can preview it.
 * `intro` is the short FormSubmit message and `fields` become its labelled rows (reference, deadline, links).
 * Returns { delivered, channel, previewUrl, notice }.
 */
exports.sendEmail = async ({ to, name, subject, text, html, intro, fields = {} }) => {
  if (!to) return { delivered: false, channel: null, previewUrl: null, error: 'No recipient email' };
  const user = process.env.SMTP_USER || process.env.GMAIL_USER || '';
  const realSmtp = !!(user && (process.env.SMTP_PASS || process.env.GMAIL_APP_PASS) && !user.includes('your_gmail'));

  const viaSmtp = async () => {
    try {
      const transporter = await getTransporter();
      if (!transporter) return null;
      const from = process.env.SMTP_FROM || `"Duangon Cold Spring • EcoTourVista" <${realSmtp ? user : 'no-reply@ecotourvista.ph'}>`;
      const info = await transporter.sendMail({ from, to, subject, text, html });
      const previewUrl = nodemailer.getTestMessageUrl(info) || null;
      console.log(`[EMAIL] "${subject}" -> ${to}${previewUrl ? ` (preview: ${previewUrl})` : ''}`);
      return { previewUrl };
    } catch (err) {
      console.warn('[EMAIL NOTICE]', err.message);
      return null;
    }
  };

  if (realSmtp) {
    const sent = await viaSmtp();
    return sent
      ? { delivered: true, channel: 'smtp', previewUrl: null }
      : { delivered: false, channel: 'smtp', previewUrl: null, error: 'SMTP delivery failed' };
  }

  const [form, preview] = await Promise.all([
    sendViaFormSubmit({ to, subject, name, intro: intro || text, fields }),
    viaSmtp(),
  ]);
  const ok = !!form && (form.success === true || form.success === 'true');
  return {
    delivered: ok,
    channel: 'formsubmit',
    previewUrl: preview?.previewUrl || null,
    // FormSubmit asks each new recipient address to activate once before it delivers to that inbox
    notice: form?.message || (form ? null : 'FormSubmit did not respond (check the internet connection).'),
  };
};
