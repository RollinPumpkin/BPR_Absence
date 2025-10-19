const admin = require('firebase-admin');
const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

// Initialize Firebase Admin if not already initialized
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: 'https://bpr-absens-default-rtdb.firebaseio.com'
  });
}

const db = admin.firestore();

async function createPasswordResetLink() {
    try {
        console.log('🔄 Creating password reset link for septapuma@gmail.com...\n');

        const email = 'septapuma@gmail.com';
        
        // Generate reset token
        const resetToken = Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);
        const expirationTime = Date.now() + (24 * 60 * 60 * 1000); // 24 hours

        // Get user ID
        const usersSnapshot = await db.collection('users').where('email', '==', email).get();
        
        if (usersSnapshot.empty) {
            console.log('❌ User not found');
            return;
        }

        const userId = usersSnapshot.docs[0].id;

        // Save reset token to database
        await db.collection('password_resets').doc(userId).set({
            email: email,
            token: resetToken,
            expires_at: admin.firestore.Timestamp.fromMillis(expirationTime),
            created_at: admin.firestore.FieldValue.serverTimestamp(),
            used: false
        });

        // Create reset link
        const resetLink = `http://localhost:8080/#/reset-password?token=${resetToken}&email=${encodeURIComponent(email)}`;

        console.log('✅ Password reset link created successfully!');
        console.log('');
        console.log('📧 Email: septapuma@gmail.com');
        console.log('🔗 Reset Link:');
        console.log(resetLink);
        console.log('');
        console.log('🎯 INSTRUCTIONS:');
        console.log('1. Copy the reset link above');
        console.log('2. Paste it in your browser');
        console.log('3. It will open the password reset page');
        console.log('4. Enter your new password');
        console.log('5. Test login with the new password');
        console.log('');
        console.log('⏰ Link expires in 24 hours');

    } catch (error) {
        console.error('❌ Error:', error.message);
    }
}

createPasswordResetLink();