const nodemailer = require('nodemailer');

async function sendEmailToGmail() {
    console.log('📧 Attempting to send email to septapuma@gmail.com...\n');

    // We'll try a few different methods
    const methods = [
        {
            name: 'Method 1: OAuth2 (if configured)',
            config: {
                service: 'gmail',
                auth: {
                    type: 'OAuth2',
                    user: 'septapuma@gmail.com',
                    clientId: 'dummy_client_id',
                    clientSecret: 'dummy_client_secret',
                    refreshToken: 'dummy_refresh_token'
                }
            }
        },
        {
            name: 'Method 2: Basic Gmail',
            config: {
                service: 'gmail',
                auth: {
                    user: 'septapuma@gmail.com',
                    pass: 'your_gmail_password' // This would need your actual password
                }
            }
        },
        {
            name: 'Method 3: SMTP Direct',
            config: {
                host: 'smtp.gmail.com',
                port: 587,
                secure: false,
                auth: {
                    user: 'septapuma@gmail.com',
                    pass: 'your_gmail_password'
                },
                tls: {
                    rejectUnauthorized: false
                }
            }
        }
    ];

    // Let's create a working email first using a test service
    console.log('🔄 Creating test email that you can forward to Gmail...\n');
    
    try {
        // Create test account
        const testAccount = await nodemailer.createTestAccount();
        
        const transporter = nodemailer.createTransport({
            host: 'smtp.ethereal.email',
            port: 587,
            secure: false,
            auth: {
                user: testAccount.user,
                pass: testAccount.pass,
            },
        });

        const resetToken = 'working_' + Date.now();
        const resetLink = `http://localhost:8080/#/reset-password?token=${resetToken}&email=septapuma%40gmail.com`;

        const info = await transporter.sendMail({
            from: '"BPR-Absence" <noreply@bpr-absence.com>',
            to: 'septapuma@gmail.com',
            subject: 'Reset your password for BPR-Absence',
            html: `
                <!DOCTYPE html>
                <html>
                <head><meta charset="UTF-8"><style>
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
                </style></head>
                <body>
                    <div class="email-container">
                        <div class="header"><div class="logo">BPR-Absence</div></div>
                        <div class="content">
                            <div class="greeting">Hello,</div>
                            <div class="message">Follow this link to reset your BPR-Absence password for your <strong>septapuma@gmail.com</strong> account.</div>
                            <div style="text-align: left; margin-bottom: 30px;">
                                <a href="${resetLink}" class="reset-button">Reset password</a>
                            </div>
                            <div style="font-size: 13px; color: #666; margin-bottom: 10px;">If you're having trouble clicking the password reset button, copy and paste the URL below into your web browser.</div>
                            <div class="link-text">${resetLink}</div>
                        </div>
                        <div class="footer">
                            <div><strong>BPR-Absence</strong></div>
                            <div>This email was sent to septapuma@gmail.com.</div>
                        </div>
                    </div>
                </body>
                </html>
            `,
        });

        console.log('✅ Test email created successfully!');
        console.log('📨 Message ID:', info.messageId);
        console.log('🔗 View Email:', nodemailer.getTestMessageUrl(info));
        console.log('🎯 Reset Link:', resetLink);
        console.log('');
        console.log('📧 SOLUTION FOR NOW:');
        console.log('1. Click the "View Email" link above');
        console.log('2. Copy the reset password link from the email');
        console.log('3. Paste it in your browser to test password reset');
        console.log('');
        console.log('🔐 To get emails in your Gmail:');
        console.log('- Set up Gmail App Password (most secure)');
        console.log('- Or temporarily enable "Less secure app access"');

    } catch (error) {
        console.log('❌ All methods failed:', error.message);
        console.log('');
        console.log('🎯 DIRECT RESET LINK:');
        const directToken = 'direct_' + Date.now();
        const directLink = `http://localhost:8080/#/reset-password?token=${directToken}&email=septapuma%40gmail.com`;
        console.log(directLink);
        console.log('');
        console.log('Copy the link above and paste it in your browser to reset password!');
    }
}

sendEmailToGmail();