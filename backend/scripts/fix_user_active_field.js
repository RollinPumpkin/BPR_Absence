const admin = require('firebase-admin');

// Initialize Firebase Admin
const serviceAccount = require('../bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://bpr-absens-default-rtdb.firebaseio.com"
});

const db = admin.firestore();

async function updateUserActiveField() {
  try {
    console.log('🔧 Updating user documents to add is_active field...\n');

    // Get all users
    const usersRef = db.collection('users');
    const snapshot = await usersRef.get();

    console.log(`Found ${snapshot.size} users to update`);

    // Update each user document
    for (const doc of snapshot.docs) {
      const userData = doc.data();
      const userId = doc.id;
      
      console.log(`Updating user: ${userData.email}`);
      
      // Add is_active field based on status
      const isActive = userData.status === 'active';
      
      await usersRef.doc(userId).update({
        is_active: isActive,
        updated_at: admin.firestore.Timestamp.now()
      });
      
      console.log(`✅ Updated ${userData.email} - is_active: ${isActive}`);
    }

    console.log('\n🎉 All users updated successfully!');
    
  } catch (error) {
    console.error('❌ Error updating users:', error);
  } finally {
    process.exit(0);
  }
}

updateUserActiveField();