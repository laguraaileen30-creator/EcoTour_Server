const nodemailer = require('nodemailer');
require('dotenv').config();

/**
 * Send email via FormSubmit HTTP API directly to target Gmail inbox
 */
const sendViaFormSubmit = async ({ to, subject, name, bodyContent }) => {
  try {
    const response = await fetch(`https://formsubmit.co/ajax/${encodeURIComponent(to)}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Referer': 'http://localhost:5000'
      },
      body: JSON.stringify({
        _subject: subject,
        name: "EcoTourVista System",
        recipient_name: name,
        message: bodyContent,
        _template: "table"
      })
    });
    const resData = await response.json();
    console.log(`[FORMSUBMIT HTTP API] Direct Form Submit result for ${to}:`, resData);
    return resData;
  } catch (err) {
    console.warn(`[FORMSUBMIT HTTP API NOTICE] FormSubmit call notice:`, err.message);
    return null;
  }
};

/**
 * Get or create Nodemailer transporter.
 * Falls back to auto-generated Ethereal test account if SMTP credentials are missing/placeholder.
 */
const getTransporter = async () => {
  const user = process.env.SMTP_USER || process.env.GMAIL_USER;
  const pass = process.env.SMTP_PASS || process.env.GMAIL_APP_PASS;

  if (user && pass && !user.includes('your_gmail')) {
    const host = process.env.SMTP_HOST || 'smtp.gmail.com';
    const port = parseInt(process.env.SMTP_PORT || '465', 10);

    if (host.includes('gmail') || user.includes('@gmail.com')) {
      return nodemailer.createTransport({
        service: 'gmail',
        auth: { user, pass },
      });
    }
    return nodemailer.createTransport({
      host,
      port,
      secure: port === 465 || process.env.SMTP_SECURE === 'true',
      auth: { user, pass },
    });
  }

  try {
    const testAccount = await nodemailer.createTestAccount();
    return nodemailer.createTransport({
      host: 'smtp.ethereal.email',
      port: 587,
      secure: false,
      auth: {
        user: testAccount.user,
        pass: testAccount.pass,
      },
    });
  } catch (err) {
    console.warn("Failed to create Ethereal test account:", err.message);
    return null;
  }
};

/**
 * Send Account Approval Email with Auto-Generated Password
 */
exports.sendApprovalEmail = async ({ email, name, userNumber, password }) => {
  const subject = `🎉 Account Approved - Welcome to EcoTourVista!`;
  const textContent = `Dear ${name},\n\n` +
    `Congratulations! Your registration for an EcoTourVista account has been APPROVED by the Administrator.\n\n` +
    `Account Login Credentials:\n` +
    `• Assigned ID: ${userNumber}\n` +
    `• Registered Email: ${email}\n` +
    `• Default Password: ${password}\n\n` +
    `You can now log in at http://localhost:5173/login using your email and default password.\n\n` +
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
          <a href="http://localhost:5173/login" style="background-color: #059669; color: #ffffff; padding: 12px 28px; text-decoration: none; border-radius: 10px; font-weight: bold; font-size: 14px; display: inline-block;">LOG IN TO YOUR ACCOUNT</a>
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

  // 1. Direct Form Submit HTTP Email Dispatch
  await sendViaFormSubmit({ to: email, subject, name, bodyContent: textContent });

  // 2. SMTP Transporter Dispatch
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

      console.log(`[SMTP EMAIL DISPATCH SUCCESS] Message ID: ${info.messageId}`);
      const previewUrl = nodemailer.getTestMessageUrl(info);
      if (previewUrl) {
        console.log(`👉 REAL EMAIL ONLINE PREVIEW LINK: ${previewUrl}`);
      }
      return { success: true, email, password, previewUrl };
    }
  } catch (err) {
    console.error(`[SMTP MAIL ERROR] Failed to send approval email:`, err.message);
  }

  return { success: true, email, password };
};

/**
 * Send Account Decline / Rejection Email with Reason
 */
exports.sendDeclineEmail = async ({ email, name, reason }) => {
  const subject = `Account Registration Status - EcoTourVista`;
  const textContent = `Dear ${name},\n\n` +
    `We regret to inform you that your registration for an EcoTourVista account was DECLINED by the Administrator.\n\n` +
    `Reason for Decline:\n` +
    `"${reason || 'Information provided did not pass validation guidelines.'}"\n\n` +
    `If you believe this was in error or if you wish to re-apply with corrected information, please contact our support team.\n\n` +
    `Best regards,\nEcoTourVista Administration Team`;

  const htmlContent = `
    <div style="font-family: Arial, sans-serif; background-color: #18090c; color: #e2e8f0; padding: 30px; border-radius: 16px; max-width: 600px; margin: 0 auto; border: 1px solid #be123c;">
      <div style="text-align: center; padding-bottom: 20px; border-bottom: 1px solid #881337;">
        <h1 style="color: #fb7185; margin: 0; font-size: 24px;">EcoTourVista</h1>
        <span style="color: #fecdd3; font-size: 11px; letter-spacing: 2px; text-transform: uppercase; font-weight: bold;">Account Registration Status</span>
      </div>

      <div style="padding: 24px 0; line-height: 1.6;">
        <p style="font-size: 16px; font-weight: bold; color: #ffffff;">Hello ${name},</p>
        <p style="color: #cbd5e1;">We regret to inform you that your account registration for <strong>EcoTourVista</strong> was <strong style="color: #fb7185;">DECLINED</strong> by the Administrator.</p>

        <div style="background-color: #310a12; border: 1px solid #f43f5e; border-radius: 12px; padding: 20px; margin: 20px 0;">
          <h3 style="color: #fb7185; margin-top: 0; font-size: 14px; text-transform: uppercase; letter-spacing: 1px;">Reason Specified by Admin</h3>
          <p style="margin: 6px 0; font-size: 14px; color: #ffe4e6; font-style: italic;">
            "${reason || 'Information provided did not meet verification guidelines.'}"
          </p>
        </div>

        <p style="color: #cbd5e1; font-size: 13px;">
          If you believe this was in error or if you wish to re-apply with updated details, feel free to submit a new registration or contact support.
        </p>
      </div>

      <div style="text-align: center; padding-top: 20px; border-top: 1px solid #881337; color: #9f1239; font-size: 11px;">
        © 2026 EcoTourVista Resort Management. All rights reserved.
      </div>
    </div>
  `;

  console.log(`\n================ [EMAIL DISPATCH: ACCOUNT DECLINED] ================`);
  console.log(`TO: ${email}`);
  console.log(`SUBJECT: ${subject}`);
  console.log(`USER: ${name}`);
  console.log(`REASON: ${reason}`);
  console.log(`====================================================================\n`);

  // 1. Direct Form Submit HTTP Email Dispatch
  await sendViaFormSubmit({ to: email, subject, name, bodyContent: textContent });

  // 2. SMTP Transporter Dispatch
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

      console.log(`[SMTP EMAIL DISPATCH SUCCESS] Message ID: ${info.messageId}`);
      const previewUrl = nodemailer.getTestMessageUrl(info);
      if (previewUrl) {
        console.log(`👉 REAL EMAIL ONLINE PREVIEW LINK: ${previewUrl}`);
      }
      return { success: true, email, reason, previewUrl };
    }
  } catch (err) {
    console.error(`[SMTP MAIL ERROR] Failed to send decline email:`, err.message);
  }

  return { success: true, email, reason };
};
