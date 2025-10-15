const bcrypt = require('bcryptjs');
const admin = require('firebase-admin');

// Initialize admin if not already done
if (!admin.apps.length) {
  const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

const db = admin.firestore();

async function testPasswordMatch() {
  try {
    console.log('🔍 Testing password match for admin@gmail.com...');
    
    // Get user from database
    const snapshot = await db.collection('users')
      .where('email', '==', 'admin@gmail.com')
      .limit(1)
      .get();
    
    if (snapshot.empty) {
      console.log('❌ User not found!');
      return;
    }
    
    const userData = snapshot.docs[0].data();
    const storedHash = userData.password;
    
    console.log('📧 Email:', userData.email);
    console.log('🔐 Stored hash:', storedHash.substring(0, 20) + '...');
    
    // Test different passwords
    const passwords = ['admin123', '123456', 'admin', 'password'];
    
    for (const password of passwords) {
      const isMatch = await bcrypt.compare(password, storedHash);
      console.log(`🔑 Testing "${password}": ${isMatch ? '✅ MATCH' : '❌ NO MATCH'}`);
    }
    
  } catch (error) {
    console.error('❌ Error:', error);
  }
  
  process.exit(0);
}

testPasswordMatch();