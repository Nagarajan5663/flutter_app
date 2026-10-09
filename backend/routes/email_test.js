const express = require('express');
const router = express.Router();

const {
  verifyEmailConnection,
  sendEmail,
} = require('../utils/email');

// Test SMTP connection
router.get('/verify', async (req, res) => {
  const success = await verifyEmailConnection();

  if (success) {
    return res.json({
      success: true,
      message: 'SMTP connection successful',
    });
  }

  return res.status(500).json({
    success: false,
    message: 'SMTP connection failed',
  });
});

// Send a test email
router.post('/send', async (req, res) => {
  try {
    const { to } = req.body;

    if (!to) {
      return res.status(400).json({
        success: false,
        message: 'Recipient email is required',
      });
    }

    const html = `
      <!DOCTYPE html>
      <html>
        <body style="font-family: Arial, sans-serif;">
          <h2>CODExIA Email Test</h2>

          <p>Hello,</p>

          <p>
            This is a test email from the CODExIA backend.
          </p>

          <p>
            Your Hostinger SMTP configuration is working correctly.
          </p>

          <p>
            Regards,<br>
            CODExIA
          </p>
        </body>
      </html>
    `;

    const result = await sendEmail(
      to,
      'CODExIA SMTP Test',
      html
    );

    return res.json({
      success: true,
      message: 'Test email sent successfully',
      messageId: result.messageId,
    });
  } catch (error) {
    console.error('Test email error:', error);

    return res.status(500).json({
      success: false,
      message: 'Failed to send test email',
      error: error.message,
    });
  }
});

module.exports = router;