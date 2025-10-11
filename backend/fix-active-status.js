const { getFirestore, initializeFirebase } = require('./config/database');

async function updateUserActiveStatus() {
  try {
    // Initialize Firebase first
    await initializeFirebase();
    
    const db = getFirestore();
    
    console.log('🔍 Checking is_active field for test@bpr.com...');
    
    // Get user document for test@bpr.com
    const usersSnapshot = await db.collection('users')
      .where('email', '==', 'test@bpr.com')
      .get();
    
    if (usersSnapshot.empty) {
      console.log('❌ User test@bpr.com not found');
      return;
    }
    
    const userDoc = usersSnapshot.docs[0];
    const userData = userDoc.data();
    
    console.log(`👤 User: ${userData.email}`);
    console.log(`   UID: ${userDoc.id}`);
    console.log(`   is_active: ${userData.is_active}`);
    console.log(`   status: ${userData.status}`);
    console.log(`   disabled: ${userData.disabled}`);
    
    // Update is_active to true if it's false or undefined
    if (!userData.is_active) {
      console.log('🔄 Setting is_active to true...');
      await db.collection('users').doc(userDoc.id).update({
        is_active: true,
        status: 'active',
        disabled: false,
        updated_at: new Date()
      });
      console.log('✅ User activated successfully');
    } else {
      console.log('✅ User already active');
    }
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  }
}

updateUserActiveStatus();