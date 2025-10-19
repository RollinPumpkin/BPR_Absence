const { initializeFirebase, getFirestore } = require('./backend/config/database');

async function getResetToken() {
  try {
    // Initialize Firebase
    initializeFirebase();
    const db = getFirestore();
    
    console.log('🔍 Looking for reset tokens...');
    
    // Get all password reset tokens
    const resetTokensSnapshot = await db.collection('password_resets')
      .orderBy('created_at', 'desc')
      .limit(5)
      .get();
    
    if (resetTokensSnapshot.empty) {
      console.log('❌ No reset tokens found');
      console.log('\n💡 To generate a reset token:');
      console.log('curl -X POST "http://localhost:3000/api/auth/forgot-password" -H "Content-Type: application/json" -d "{\\"email\\":\\"septapuma@gmail.com\\"}"');
      return;
    }
    
    console.log(`✅ Found ${resetTokensSnapshot.size} reset token(s):\n`);
    
    resetTokensSnapshot.forEach((doc) => {
      const data = doc.data();
      const createdAt = data.created_at?.toDate();
      const expiresAt = data.expires_at?.toDate();
      const isExpired = expiresAt && new Date() > expiresAt;
      const isUsed = data.used;
      
      console.log(`📧 Email: ${data.email}`);
      console.log(`🔑 Token: ${data.token}`);
      console.log(`📅 Created: ${createdAt?.toLocaleString()}`);
      console.log(`⏰ Expires: ${expiresAt?.toLocaleString()}`);
      console.log(`🚫 Used: ${isUsed ? 'YES' : 'NO'}`);
      console.log(`⚠️  Status: ${isExpired ? 'EXPIRED' : isUsed ? 'USED' : 'VALID'}`);
      
      if (!isExpired && !isUsed) {
        const resetLink = `http://localhost:8080/#/reset-password?token=${encodeURIComponent(data.token)}&email=${encodeURIComponent(data.email)}`;
        console.log(`🔗 Reset Link: ${resetLink}`);
      }
      
      console.log('─'.repeat(50));
    });
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  }
}

// Run the function
getResetToken();