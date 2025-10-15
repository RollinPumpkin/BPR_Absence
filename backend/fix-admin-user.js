const { getFirestore, initializeFirebase } = require('./config/database');

async function fixAdminUser() {
  try {
    // Initialize Firebase first
    await initializeFirebase();
    
    const db = getFirestore();
    
    console.log('🔧 Fixing admin@gmail.com user data...');
    
    // Get user document for admin@gmail.com
    const usersSnapshot = await db.collection('users')
      .where('email', '==', 'admin@gmail.com')
      .get();
    
    if (usersSnapshot.empty) {
      console.log('❌ admin@gmail.com not found');
      return;
    }
    
    const userDoc = usersSnapshot.docs[0];
    const userData = userDoc.data();
    
    console.log(`👤 Current user data:`);
    console.log(`   Email: ${userData.email}`);
    console.log(`   Firebase UID: ${userData.firebase_uid || 'undefined'}`);
    console.log(`   Status: ${userData.status || 'undefined'}`);
    console.log(`   Disabled: ${userData.disabled || 'undefined'}`);
    
    // Update user with proper fields
    await db.collection('users').doc(userDoc.id).update({
      firebase_uid: userDoc.id, // Use Firestore ID as Firebase UID for now
      status: 'active',
      is_active: true,
      disabled: false,
      updated_at: new Date()
    });
    
    console.log('✅ User data updated successfully');
    
    // Verify the update
    const updatedDoc = await db.collection('users').doc(userDoc.id).get();
    const updatedData = updatedDoc.data();
    
    console.log(`✅ Updated user data:`);
    console.log(`   Firebase UID: ${updatedData.firebase_uid}`);
    console.log(`   Status: ${updatedData.status}`);
    console.log(`   Is Active: ${updatedData.is_active}`);
    console.log(`   Disabled: ${updatedData.disabled}`);
    
    console.log(`\n🔑 LOGIN CREDENTIALS:`);
    console.log(`   Email: admin@gmail.com`);
    console.log(`   Password: admin123`);
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  }
}

fixAdminUser();