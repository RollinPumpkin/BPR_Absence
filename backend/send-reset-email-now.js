const nodemailer = require('nodemailer');
require('dotenv').config();

async function sendTestPasswordResetEmail() {
    console.log('📧 Sending Password Reset Email Test...\n');

    if (!process.env.EMAIL_USER || !process.env.EMAIL_PASS || process.env.EMAIL_PASS === 'your_gmail_app_password_here') {
        console.log('❌ Gmail App Password not configured yet!');
        console.log('Please set up Gmail App Password first:');
        console.log('1. Go to: https://myaccount.google.com/security');
        console.log('2. Find "App passwords" (2-Step Verification must be ON)');
        console.log('3. Generate password for "BPR Absence"');
        console.log('4. Update .env file: EMAIL_PASS=your16charpassword');
        return;
    }

    try {
        const transporter = nodemailer.createTransport({
            service: 'gmail',
            auth: {
                user: process.env.EMAIL_USER,
                pass: process.env.EMAIL_PASS
            }
        });

        const resetToken = 'test_token_' + Date.now();
        const userEmail = 'septapuma@gmail.com';
        const resetLink = `http://localhost:8080/#/reset-password?token=${resetToken}&email=${encodeURIComponent(userEmail)}`;

        const emailData = {
            from: `"BPR-Absence" <${process.env.EMAIL_USER}>`,
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
        };

        console.log('🔄 Sending password reset email...');
        const result = await transporter.sendMail(emailData);
        
        console.log('✅ Password reset email sent successfully!');
        console.log('📨 Message ID:', result.messageId);
        console.log('📧 Check septapuma@gmail.com inbox');
        console.log('🔗 Reset link:', resetLink);
        console.log('');
        console.log('🎯 What to do next:');
        console.log('1. Check your Gmail inbox for the reset email');
        console.log('2. Click the "Reset password" button in the email');
        console.log('3. It will open your browser to the password reset page');

    } catch (error) {
        console.log('❌ Failed to send email:', error.message);
        console.log('');
        console.log('🔧 Setup Gmail App Password:');
        console.log('1. https://myaccount.google.com/security');
        console.log('2. App passwords → Generate for BPR Absence');
        console.log('3. Update .env with the 16-character password');
    }
}

sendTestPasswordResetEmail();