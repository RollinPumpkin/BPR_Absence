const nodemailer = require('nodemailer');
require('dotenv').config();

console.log('🧪 Testing BPR Absence Email Service...\n');

// Check environment variables
console.log('📋 Configuration Check:');
console.log('EMAIL_USER:', process.env.EMAIL_USER || '❌ Not configured');
console.log('EMAIL_PASS:', process.env.EMAIL_PASS ? '✅ Set' : '❌ Not configured');
console.log('');

if (!process.env.EMAIL_USER || !process.env.EMAIL_PASS || process.env.EMAIL_PASS === 'your_gmail_app_password_here') {
    console.log('❌ Gmail App Password not configured!');
    console.log('');
    console.log('🔧 Setup Steps:');
    console.log('1. Go to: https://myaccount.google.com/security');
    console.log('2. Enable 2-Factor Authentication if not enabled');
    console.log('3. Go to App Passwords');
    console.log('4. Create new app password for "Mail"');
    console.log('5. Copy the 16-character password');
    console.log('6. Replace "your_gmail_app_password_here" in .env file');
    console.log('7. Restart this test');
    console.log('');
    console.log('📱 Current .env file location: backend/.env');
    process.exit(1);
}

async function testEmail() {
    try {
        console.log('🔄 Creating Gmail connection...');
        
        const transporter = nodemailer.createTransport({
            service: 'gmail',
            auth: {
                user: process.env.EMAIL_USER,
                pass: process.env.EMAIL_PASS
            }
        });

        console.log('🔍 Verifying connection...');
        await transporter.verify();
        console.log('✅ Gmail connection successful!');

        console.log('📧 Sending professional password reset email...');
        const testResult = await transporter.sendMail({
            from: `"BPR-Absence" <${process.env.EMAIL_USER}>`,
            to: process.env.EMAIL_USER, // Send to self for testing
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
                        Follow this link to reset your BPR-Absence password for your <strong>${process.env.EMAIL_USER}</strong> account.
                      </div>
                      
                      <div style="text-align: left; margin-bottom: 30px;">
                        <a href="bpr-absence://reset-password?token=test123&email=${encodeURIComponent(process.env.EMAIL_USER)}" class="reset-button">Reset password</a>
                      </div>
                      
                      <div class="alternative-text">
                        If you're having trouble clicking the password reset button, copy and paste the URL below into your web browser.
                      </div>
                      
                      <div class="link-text">bpr-absence://reset-password?token=test123&email=${encodeURIComponent(process.env.EMAIL_USER)}</div>
                      
                      <div class="security-note">
                        <strong>Security tip:</strong> This password reset link will expire in 1 hour for your security. If you didn't request this password reset, you can safely ignore this email.
                      </div>
                    </div>
                    
                    <div class="footer">
                      <div style="margin-bottom: 10px;">
                        <strong>BPR-Absence</strong>
                      </div>
                      <div>
                        This email was sent to ${process.env.EMAIL_USER}. If you have any questions, please contact our support team.
                      </div>
                    </div>
                  </div>
                </body>
                </html>
            `
        });

        console.log('✅ Test email sent successfully!');
        console.log('📨 Message ID:', testResult.messageId);
        console.log('');
        console.log('🎉 EMAIL SERVICE READY FOR PRODUCTION!');
        console.log('📧 Check septapuma@gmail.com inbox for test email');
        console.log('🚀 You can now test forgot password in Flutter app');

    } catch (error) {
        console.log('❌ Email test failed:');
        console.log('Error:', error.message);
        console.log('');
        console.log('🔧 Common Solutions:');
        console.log('1. Check Gmail App Password is correct (16 characters, no spaces)');
        console.log('2. Make sure 2-Factor Authentication is enabled');
        console.log('3. Generate new App Password if needed');
        console.log('4. Restart backend server after .env changes');
    }
}

testEmail();