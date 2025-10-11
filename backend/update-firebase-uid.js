const { getFirestore, initializeFirebase } = require('./config/database');

async function updateFirebaseUID() {
  try {
    // Initialize Firebase first
    await initializeFirebase();
    
    const db = getFirestore();
    
    console.log('🔧 Updating Firebase UID for user@gmail.com...');
    
    // Get Firestore user document
    const usersSnapshot = await db.collection('users')
      .where('email', '==', 'user@gmail.com')
      .get();
    
    if (usersSnapshot.empty) {
      console.log('❌ User not found in Firestore');
      return;
    }
    
    const userDoc = usersSnapshot.docs[0];
    const userData = userDoc.data();
    
    console.log(`👤 Current User Data:`);
    console.log(`   Email: ${userData.email}`);
    console.log(`   Name: ${userData.full_name}`);
    console.log(`   Current firebase_uid: ${userData.firebase_uid || 'null'}`);
    console.log(`   Firestore ID: ${userDoc.id}`);
    
    // From previous testing, we know the Firebase Auth UID should be w64DcvH6PQM1aOR0VYoARqStjCW2
    // But let's use the existing one if it exists, or set a new one based on the Firestore ID
    const newFirebaseUID = userData.firebase_uid || userDoc.id;
    
    // Update Firestore document
    await db.collection('users').doc(userDoc.id).update({
      firebase_uid: newFirebaseUID,
      updated_at: new Date()
    });
    
    console.log('✅ Firebase UID updated successfully');
    console.log(`   New firebase_uid: ${newFirebaseUID}`);
    
    // Verify the update
    const updatedDoc = await db.collection('users').doc(userDoc.id).get();
    const updatedData = updatedDoc.data();
    console.log(`✅ Verification - firebase_uid: ${updatedData.firebase_uid}`);
    
  } catch (error) {
    console.error('❌ Error updating Firebase UID:', error.message);
  }
}

updateFirebaseUID();