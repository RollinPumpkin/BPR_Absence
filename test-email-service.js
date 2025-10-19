const nodemailer = require('nodemailer');

async function testEmailService() {
  console.log('🧪 Testing Email Service Configuration...');
  
  // Get email credentials from environment
  const emailUser = process.env.EMAIL_USER || 'septapuma@gmail.com';
  const emailPass = process.env.EMAIL_PASS || 'your_gmail_app_password_here';
  
  console.log(`📧 Email User: ${emailUser}`);
  console.log(`🔑 Email Pass: ${emailPass.substring(0, 4)}${'*'.repeat(emailPass.length - 4)}`);
  
  if (emailPass === 'your_gmail_app_password_here') {
    console.log('');
    console.log('❌ EMAIL_PASS NOT CONFIGURED!');
    console.log('');
    console.log('🔧 To fix this:');
    console.log('1. Go to myaccount.google.com');
    console.log('2. Security → 2-Step Verification → App Passwords');
    console.log('3. Generate app password for "Mail"');
    console.log('4. Copy the 16-character password');
    console.log('5. Update .env file: EMAIL_PASS=your_16_char_password');
    console.log('6. Restart the backend server');
    console.log('');
    return;
  }
  
  // Test email configuration
  const transporter = nodemailer.createTransporter({
    service: 'gmail',
    auth: {
      user: emailUser,
      pass: emailPass
    }
  });
  
  try {
    console.log('🔍 Verifying email connection...');
    await transporter.verify();
    console.log('✅ Email service connection successful!');
    
    // Try to send a test email
    console.log('📤 Sending test email...');
    const testResult = await transporter.sendMail({
      from: emailUser,
      to: emailUser, // Send to self for testing
      subject: 'BPR Absence - Email Service Test',
      html: `
        <h2>✅ Email Service Working!</h2>
        <p>This is a test email from BPR Absence system.</p>
        <p>Time: ${new Date().toLocaleString()}</p>
        <p>If you receive this, the email service is configured correctly.</p>
      `
    });
    
    console.log('✅ Test email sent successfully!');
    console.log(`📧 Message ID: ${testResult.messageId}`);
    console.log('📬 Check your inbox for the test email');
    
  } catch (error) {
    console.log('❌ Email service error:');
    console.log(`   Error: ${error.message}`);
    
    if (error.code === 'EAUTH') {
      console.log('');
      console.log('🔧 Authentication failed. Common solutions:');
      console.log('1. Make sure EMAIL_PASS is a Gmail App Password (not regular password)');
      console.log('2. Enable 2-Factor Authentication on your Gmail account');
      console.log('3. Generate a new App Password from Google Account settings');
    }
  }
}

// Load environment variables
require('dotenv').config();
testEmailService();