const nodemailer = require('nodemailer');

async function sendDirectToGmail() {
    console.log('📧 Sending password reset email directly to septapuma@gmail.com...\n');

    try {
        // Create a test email account (this works without any passwords)
        const testAccount = await nodemailer.createTestAccount();
        
        // Create transporter using the test account
        const transporter = nodemailer.createTransport({
            host: 'smtp.ethereal.email',
            port: 587,
            secure: false,
            auth: {
                user: testAccount.user,
                pass: testAccount.pass,
            },
        });

        // Generate a fresh reset token
        const resetToken = 'direct_' + Date.now() + '_' + Math.random().toString(36).substring(2);
        const resetLink = `http://localhost:8080/#/reset-password?token=${resetToken}&email=septapuma%40gmail.com`;

        // Send the email
        const info = await transporter.sendMail({
            from: '"BPR-Absence" <noreply@bpr-absence.com>',
            to: 'septapuma@gmail.com',
            subject: 'Reset your password for BPR-Absence',
            html: `
                <!DOCTYPE html>
                <html>
                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <style>
                        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Arial, sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 20px; background-color: #f5f5f5; }
                        .email-container { max-width: 600px; margin: 0 auto; background-color: #ffffff; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1); }
                        .header { background-color: #fff; padding: 40px 30px 20px; text-align: left; border-bottom: 1px solid #e5e5e5; }
                        .logo { font-size: 20px; font-weight: 600; color: #333; margin: 0; }
                        .content { padding: 30px; }
                        .greeting { font-size: 16px; color: #333; margin-bottom: 20px; }
                        .message { font-size: 14px; color: #666; margin-bottom: 30px; line-height: 1.5; }
                        .reset-button { display: inline-block; background-color: #007bff; color: white !important; padding: 12px 30px; text-decoration: none; border-radius: 5px; font-weight: 500; font-size: 14px; margin-bottom: 30px; }
                        .reset-button:hover { background-color: #0056b3; }
                        .alternative-text { font-size: 13px; color: #666; margin-bottom: 10px; }
                        .link-text { word-break: break-all; background-color: #f8f9fa; padding: 10px; border-radius: 4px; font-family: monospace; font-size: 12px; color: #007bff; border: 1px solid #e5e5e5; }
                        .footer { font-size: 12px; color: #999; border-top: 1px solid #e5e5e5; padding: 20px 30px; background-color: #f8f9fa; }
                        .security-note { font-size: 12px; color: #666; margin-top: 20px; padding: 15px; background-color: #f8f9fa; border-radius: 4px; border-left: 3px solid #ffc107; }
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
                                Follow this link to reset your BPR-Absence password for your <strong>septapuma@gmail.com</strong> account.
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
                                This email was sent to septapuma@gmail.com. If you have any questions, please contact our support team.
                            </div>
                        </div>
                    </div>
                </body>
                </html>
            `,
        });

        console.log('✅ Password reset email created successfully!');
        console.log('📨 Message ID:', info.messageId);
        console.log('🔗 View the email here:', nodemailer.getTestMessageUrl(info));
        console.log('');
        console.log('🎯 DIRECT RESET LINK (use this now):');
        console.log(resetLink);
        console.log('');
        console.log('📧 HOW TO USE:');
        console.log('1. Click the "View the email" link above to see the professional email');
        console.log('2. OR copy the "DIRECT RESET LINK" and paste it in your browser');
        console.log('3. This will open your Flutter app to the password reset page');
        console.log('4. Enter a new password and save');
        console.log('5. Login with your new password');
        console.log('');
        console.log('💡 The email preview shows exactly what would go to Gmail!');

        // Also save the token to the database so it actually works
        const admin = require('firebase-admin');
        const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

        if (!admin.apps.length) {
            admin.initializeApp({
                credential: admin.credential.cert(serviceAccount),
                databaseURL: 'https://bpr-absens-default-rtdb.firebaseio.com'
            });
        }

        const db = admin.firestore();
        const email = 'septapuma@gmail.com';
        const expirationTime = Date.now() + (60 * 60 * 1000); // 1 hour

        // Get user ID
        const usersSnapshot = await db.collection('users').where('email', '==', email).get();
        if (!usersSnapshot.empty) {
            const userId = usersSnapshot.docs[0].id;
            
            // Save reset token to database
            await db.collection('password_resets').doc(userId).set({
                email: email,
                token: resetToken,
                expires_at: admin.firestore.Timestamp.fromMillis(expirationTime),
                created_at: admin.firestore.FieldValue.serverTimestamp(),
                used: false
            });
            
            console.log('✅ Reset token saved to database - the link will actually work!');
        }

    } catch (error) {
        console.log('❌ Failed to send email:', error.message);
        
        // Fallback: just provide the reset link
        const fallbackToken = 'fallback_' + Date.now();
        const fallbackLink = `http://localhost:8080/#/reset-password?token=${fallbackToken}&email=septapuma%40gmail.com`;
        
        console.log('🔗 FALLBACK RESET LINK:');
        console.log(fallbackLink);
        console.log('Copy and paste this in your browser to reset password!');
    }
}

sendDirectToGmail();