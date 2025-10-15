const admin = require('firebase-admin');
const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function fixAdminRole() {
  try {
    console.log('🔧 Fixing admin@gmail.com role...');
    
    // Find the user with valid Firebase UID (the one that's currently working)
    const userDoc = await db.collection('users').doc('yhmBo28DqzXPLpx7XPxI').get();
    
    if (userDoc.exists) {
      const userData = userDoc.data();
      console.log(`👤 Current user: ${userData.full_name}`);
      console.log(`   Email: ${userData.email}`);
      console.log(`   Current role: ${userData.role}`);
      console.log(`   Firebase UID: ${userData.firebase_uid}`);
      
      // Update role to super_admin
      await userDoc.ref.update({
        role: 'super_admin',
        updated_at: admin.firestore.Timestamp.now()
      });
      
      console.log('✅ Role updated to super_admin');
      
      // Verify the update
      const updatedDoc = await userDoc.ref.get();
      const updatedData = updatedDoc.data();
      console.log(`✅ Verified - New role: ${updatedData.role}`);
      
    } else {
      console.log('❌ User document not found');
    }
  } catch (e) {
    console.error('❌ Error:', e.message);
  }
}

fixAdminRole();