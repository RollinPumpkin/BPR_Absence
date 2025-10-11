const { getFirestore, getAuth, initializeFirebase } = require('./config/database');

async function checkUserStatus() {
  try {
    // Initialize Firebase first
    await initializeFirebase();
    
    const db = getFirestore();
    
    console.log('🔍 Checking user status in Firestore...');
    
    // Get users collection
    const usersSnapshot = await db.collection('users').get();
    
    console.log(`📊 Total users in database: ${usersSnapshot.size}\n`);
    
    usersSnapshot.forEach(doc => {
      const userData = doc.data();
      console.log(`👤 User: ${userData.email || 'No email'}`);
      console.log(`   UID: ${doc.id}`);
      console.log(`   Status: ${userData.status || 'unknown'}`);
      console.log(`   Disabled: ${userData.disabled || false}`);
      console.log(`   Role: ${userData.role || 'unknown'}`);
      console.log('---');
    });
    
  } catch (error) {
    console.error('❌ Error checking users:', error.message);
  }
}

checkUserStatus();