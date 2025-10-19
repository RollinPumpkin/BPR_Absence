const nodemailer = require('nodemailer');

// Simple email test without Gmail App Password
async function sendSimpleEmail() {
    console.log('🧪 Trying to send email without Gmail App Password...\n');

    // Method 1: Try with a test email service (Ethereal)
    try {
        console.log('🔄 Creating test email account...');
        
        // Create a test account with Ethereal Email
        const testAccount = await nodemailer.createTestAccount();
        
        console.log('✅ Test account created!');
        console.log('📧 User:', testAccount.user);
        console.log('🔑 Pass:', testAccount.pass);
        
        // Create transporter using test account
        const transporter = nodemailer.createTransport({
            host: 'smtp.ethereal.email',
            port: 587,
            secure: false, // true for 465, false for other ports
            auth: {
                user: testAccount.user,
                pass: testAccount.pass,
            },
        });

        // Send email
        const resetToken = 'test_' + Date.now();
        const userEmail = 'septapuma@gmail.com';
        const resetLink = `http://localhost:8080/#/reset-password?token=${resetToken}&email=${encodeURIComponent(userEmail)}`;

        const info = await transporter.sendMail({
            from: '"BPR-Absence" <noreply@bpr-absence.com>',
            to: 'septapuma@gmail.com',
            subject: 'Reset your password for BPR-Absence',
            html: `
                <!DOCTYPE html>
                <html>
                <head>
                  <meta charset="UTF-8">
                  <style>
                    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 20px; background-color: #f5f5f5; }
                    .email-container { max-width: 600px; margin: 0 auto; background-color: #ffffff; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1); }
                    .header { background-color: #fff; padding: 40px 30px 20px; text-align: left; border-bottom: 1px solid #e5e5e5; }
                    .logo { font-size: 20px; font-weight: 600; color: #333; margin: 0; }
                    .content { padding: 30px; }
                    .greeting { font-size: 16px; color: #333; margin-bottom: 20px; }
                    .message { font-size: 14px; color: #666; margin-bottom: 30px; line-height: 1.5; }
                    .reset-button { display: inline-block; background-color: #007bff; color: white !important; padding: 12px 30px; text-decoration: none; border-radius: 5px; font-weight: 500; font-size: 14px; margin-bottom: 30px; }
                    .link-text { word-break: break-all; background-color: #f8f9fa; padding: 10px; border-radius: 4px; font-family: monospace; font-size: 12px; color: #007bff; border: 1px solid #e5e5e5; }
                    .footer { font-size: 12px; color: #999; border-top: 1px solid #e5e5e5; padding: 20px 30px; background-color: #f8f9fa; }
                  </style>
                </head>
                <body>
                  <div class="email-container">
                    <div class="header">
                      <div class="logo">BPR-Absence</div>
                    </div>
                    <div class="content">
                      <div class="greeting">Hello,</div>
                      <div class="message">Follow this link to reset your BPR-Absence password for your <strong>${userEmail}</strong> account.</div>
                      <div style="text-align: left; margin-bottom: 30px;">
                        <a href="${resetLink}" class="reset-button">Reset password</a>
                      </div>
                      <div style="font-size: 13px; color: #666; margin-bottom: 10px;">If you're having trouble clicking the password reset button, copy and paste the URL below into your web browser.</div>
                      <div class="link-text">${resetLink}</div>
                    </div>
                    <div class="footer">
                      <div><strong>BPR-Absence</strong></div>
                      <div>This email was sent to ${userEmail}.</div>
                    </div>
                  </div>
                </body>
                </html>
            `,
        });

        console.log('✅ Email sent successfully!');
        console.log('📨 Message ID:', info.messageId);
        console.log('🔗 Preview URL:', nodemailer.getTestMessageUrl(info));
        console.log('');
        console.log('🎯 Since this is a test email service:');
        console.log('1. Click the Preview URL above to see the email');
        console.log('2. The email looks exactly like it would in Gmail');
        console.log('3. You can test the reset link from the preview');
        console.log('');
        console.log('📧 To send to your real Gmail, we need Gmail App Password');

    } catch (error) {
        console.log('❌ Test email failed:', error.message);
        
        // Method 2: Direct console output method
        console.log('\n🔄 Using direct method instead...');
        console.log('🎯 Password Reset Email for septapuma@gmail.com');
        console.log('═══════════════════════════════════════════════');
        
        const resetToken = 'manual_' + Date.now();
        const resetLink = `http://localhost:8080/#/reset-password?token=${resetToken}&email=septapuma%40gmail.com`;
        
        console.log('📧 Subject: Reset your password for BPR-Absence');
        console.log('📝 Message: Follow this link to reset your password');
        console.log('🔗 Reset Link:', resetLink);
        console.log('');
        console.log('🎯 Copy the reset link above and paste it in your browser');
        console.log('   This will take you directly to the password reset page!');
    }
}

sendSimpleEmail();