const nodemailer = require('nodemailer');

// Email configuration - try multiple methods
const emailConfig = {
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER || 'septapuma@gmail.com',
    pass: process.env.EMAIL_PASS || 'defaultpass'
  }
};

// Create transporter with fallback
let transporter;
try {
  transporter = nodemailer.createTransport(emailConfig);
} catch (error) {
  console.log('Primary transporter failed, using alternative...');
  // Fallback transporter for testing
  transporter = nodemailer.createTransport({
    host: 'smtp.gmail.com',
    port: 587,
    secure: false,
    auth: {
      user: emailConfig.auth.user,
      pass: emailConfig.auth.pass
    },
    tls: {
      rejectUnauthorized: false
    }
  });
}

// Email templates
const emailTemplates = {
  forgotPassword: (resetLink, userEmail) => ({
    from: `"BPR Absence" <${emailConfig.auth.user}>`,
    to: userEmail,
    subject: 'Reset your password for BPR-Absence',
    html: `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          body { 
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Arial, sans-serif; 
            line-height: 1.6; 
            color: #333; 
            margin: 0; 
            padding: 20px; 
            background-color: #f5f5f5; 
          }
          .email-container { 
            max-width: 600px; 
            margin: 0 auto; 
            background-color: #ffffff; 
            border-radius: 8px; 
            overflow: hidden; 
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1); 
          }
          .header { 
            background-color: #fff; 
            padding: 40px 30px 20px; 
            text-align: left; 
            border-bottom: 1px solid #e5e5e5;
          }
          .logo { 
            font-size: 20px; 
            font-weight: 600; 
            color: #333; 
            margin: 0;
          }
          .content { 
            padding: 30px; 
          }
          .greeting {
            font-size: 16px;
            color: #333;
            margin-bottom: 20px;
          }
          .message {
            font-size: 14px;
            color: #666;
            margin-bottom: 30px;
            line-height: 1.5;
          }
          .reset-button { 
            display: inline-block; 
            background-color: #007bff;
            color: white !important; 
            padding: 12px 30px; 
            text-decoration: none; 
            border-radius: 5px; 
            font-weight: 500;
            font-size: 14px;
            margin-bottom: 30px;
          }
          .reset-button:hover { 
            background-color: #0056b3; 
          }
          .alternative-text {
            font-size: 13px;
            color: #666;
            margin-bottom: 10px;
          }
          .link-text { 
            word-break: break-all; 
            background-color: #f8f9fa; 
            padding: 10px; 
            border-radius: 4px; 
            font-family: monospace; 
            font-size: 12px;
            color: #007bff;
            border: 1px solid #e5e5e5;
          }
          .footer { 
            font-size: 12px; 
            color: #999; 
            border-top: 1px solid #e5e5e5; 
            padding: 20px 30px; 
            background-color: #f8f9fa; 
          }
          .security-note {
            font-size: 12px;
            color: #666;
            margin-top: 20px;
            padding: 15px;
            background-color: #f8f9fa;
            border-radius: 4px;
            border-left: 3px solid #ffc107;
          }
        </style>
      </head>
      <body>
        <div class="email-container">
          <div class="header">
            <div class="logo">BPR-Absence</div>
          </div>
          
          <div class="content">
            <div class="greeting">Hello,</div>
            
            <div class="message">
              Follow this link to reset your BPR-Absence password for your <strong>${userEmail}</strong> account.
            </div>
            
            <div style="text-align: left; margin-bottom: 30px;">
              <a href="${resetLink}" class="reset-button">Reset password</a>
            </div>
            
            <div class="alternative-text">
              If you're having trouble clicking the password reset button, copy and paste the URL below into your web browser.
            </div>
            
            <div class="link-text">${resetLink}</div>
            
            <div class="security-note">
              <strong>Security tip:</strong> This password reset link will expire in 1 hour for your security. If you didn't request this password reset, you can safely ignore this email.
            </div>
          </div>
          
          <div class="footer">
            <div style="margin-bottom: 10px;">
              <strong>BPR-Absence</strong>
            </div>
            <div>
              This email was sent to ${userEmail}. If you have any questions, please contact our support team.
            </div>
          </div>
        </div>
      </body>
      </html>
    `
  })
};

// Send forgot password email
async function sendForgotPasswordEmail(userEmail, resetToken) {
  try {
    // Create reset link that opens web page for password reset
    const resetLink = `http://localhost:8080/#/reset-password?token=${resetToken}&email=${encodeURIComponent(userEmail)}`;
    
    // Try to send email using nodemailer with basic auth
    const transporter = nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user: 'septapuma@gmail.com',
        pass: process.env.EMAIL_PASS || 'your_gmail_password_here'
      },
      tls: {
        rejectUnauthorized: false
      }
    });

    // Get email template
    const emailData = emailTemplates.forgotPassword(resetLink, userEmail);
    
    // Try to send email
    const result = await transporter.sendMail(emailData);
    
    console.log('✅ Email sent successfully to Gmail:', result.messageId);
    return {
      success: true,
      messageId: result.messageId
    };
    
  } catch (error) {
    console.error('❌ Error sending email:', error.message);
    
    // If email fails, at least log the reset link
    const resetLink = `http://localhost:8080/#/reset-password?token=${resetToken}&email=${encodeURIComponent(userEmail)}`;
    console.log('🔗 Password Reset Link (since email failed):');
    console.log(resetLink);
    
    return {
      success: false,
      error: error.message,
      resetLink: resetLink
    };
  }
}

// Test email configuration
async function testEmailConfig() {
  try {
    await transporter.verify();
    console.log('✅ Email configuration is valid');
    return true;
  } catch (error) {
    console.error('❌ Email configuration error:', error);
    return false;
  }
}

module.exports = {
  sendForgotPasswordEmail,
  testEmailConfig
};