const nodemailer = require('nodemailer');
require('dotenv').config();

console.log('🔧 Alternative Email Test (without App Password)...\n');

// Try using OAuth2 or less secure app access
async function testAlternativeEmail() {
    try {
        console.log('🔄 Testing with less secure app access...');
        
        // This might work if "Less secure app access" is enabled
        const transporter = nodemailer.createTransport({
            service: 'gmail',
            auth: {
                user: process.env.EMAIL_USER,
                pass: 'your_regular_gmail_password' // Just for testing
            }
        });

        console.log('❌ This method is deprecated by Gmail.');
        console.log('');
        console.log('📋 RECOMMENDED SOLUTION:');
        console.log('1. Enable 2-Step Verification on septapuma@gmail.com');
        console.log('2. This will unlock "App passwords" option');
        console.log('3. Generate app password for BPR Absence');
        console.log('');
        console.log('🔗 Quick link: https://myaccount.google.com/security');
        console.log('');
        console.log('⚡ 2-Step Verification is actually MORE secure!');
        console.log('   It protects your Gmail from hackers.');

    } catch (error) {
        console.log('Error:', error.message);
    }
}

testAlternativeEmail();