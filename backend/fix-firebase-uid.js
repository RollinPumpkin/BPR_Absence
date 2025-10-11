const { getFirestore, getAuth, initializeFirebase } = require('./config/database');

async function fixFirebaseUID() {
  try {
    // Initialize Firebase first
    await initializeFirebase();
    
    const db = getFirestore();
    const auth = getAuth();
    
    console.log('🔧 Fixing Firebase UID mapping...');
    
    // Get Firebase Auth user for user@gmail.com
    const firebaseUser = await auth.getUserByEmail('user@gmail.com');
    console.log(`🔍 Firebase Auth UID: ${firebaseUser.uid}`);
    
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
    
    console.log(`👤 Firestore User: ${userData.email}`);
    console.log(`   Current firebase_uid: ${userData.firebase_uid || 'null'}`);
    console.log(`   Firestore ID: ${userDoc.id}`);
    
    // Update Firestore document with correct Firebase UID
    await db.collection('users').doc(userDoc.id).update({
      firebase_uid: firebaseUser.uid,
      updated_at: new Date()
    });
    
    console.log('✅ Firebase UID mapping updated successfully');
    console.log(`   Firebase UID: ${firebaseUser.uid}`);
    console.log(`   Firestore ID: ${userDoc.id}`);
    
    // Verify the update
    const updatedDoc = await db.collection('users').doc(userDoc.id).get();
    const updatedData = updatedDoc.data();
    console.log(`✅ Verification - firebase_uid: ${updatedData.firebase_uid}`);
    
  } catch (error) {
    console.error('❌ Error fixing Firebase UID:', error.message);
  }
}

fixFirebaseUID();