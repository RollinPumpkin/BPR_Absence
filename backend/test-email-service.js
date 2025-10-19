const nodemailer = require('nodemailer');
require('dotenv').config();

console.log('🧪 Testing Email Configuration for BPR Absence System...\n');

// Check environment variables
console.log('📋 Environment Check:');
console.log('EMAIL_USER:', process.env.EMAIL_USER || '❌ Not set');
console.log('EMAIL_PASS:', process.env.EMAIL_PASS ? '✅ Set (hidden for security)' : '❌ Not set');
console.log('');

if (!process.env.EMAIL_USER || !process.env.EMAIL_PASS) {
    console.log('❌ Email credentials not configured!');
    console.log('📖 Please follow the Gmail App Password setup guide:');
    console.log('   Open: gmail-setup-guide.html in your browser\n');
    process.exit(1);
}

async function testEmailService() {
  // Test email configuration
  const transporter = nodemailer.createTransporter({
    service: 'gmail',
    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASS
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