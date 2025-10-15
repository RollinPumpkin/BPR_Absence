const admin = require('firebase-admin');

// Initialize admin if not already done
if (!admin.apps.length) {
  const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

const auth = admin.auth();
const db = admin.firestore();

async function checkFirebaseAuthUser() {
  try {
    console.log('🔍 Checking Firebase Auth user admin@gmail.com...');
    
    // Check Firebase Auth user
    try {
      const userRecord = await auth.getUserByEmail('admin@gmail.com');
      console.log('✅ Firebase Auth user found:');
      console.log('🆔 UID:', userRecord.uid);
      console.log('📧 Email:', userRecord.email);
      console.log('📅 Created:', userRecord.metadata.creationTime);
      console.log('🔐 Email verified:', userRecord.emailVerified);
      
      // Check Firestore user with this UID
      console.log('\n🔍 Checking Firestore user with this UID...');
      const firestoreQuery = await db.collection('users')
        .where('firebase_uid', '==', userRecord.uid)
        .limit(1)
        .get();
      
      if (firestoreQuery.empty) {
        console.log('❌ No Firestore user found with this Firebase UID');
        
        // Check if there's a user with this email
        const emailQuery = await db.collection('users')
          .where('email', '==', 'admin@gmail.com')
          .limit(1)
          .get();
        
        if (!emailQuery.empty) {
          const userData = emailQuery.docs[0].data();
          console.log('✅ Found Firestore user by email:');
          console.log('🆔 Employee ID:', userData.employee_id);
          console.log('👤 Role:', userData.role);
          console.log('🔗 Firebase UID in Firestore:', userData.firebase_uid);
          console.log('❗ UID MISMATCH! Firebase Auth UID:', userRecord.uid);
          console.log('❗ Expected UID in Firestore:', userData.firebase_uid);
        }
      } else {
        const userData = firestoreQuery.docs[0].data();
        console.log('✅ Found matching Firestore user:');
        console.log('🆔 Employee ID:', userData.employee_id);
        console.log('👤 Role:', userData.role);
        console.log('✅ UIDs match perfectly!');
      }
      
    } catch (authError) {
      if (authError.code === 'auth/user-not-found') {
        console.log('❌ No Firebase Auth user found for admin@gmail.com');
        console.log('🔍 This means user needs to be created in Firebase Auth');
      } else {
        console.log('❌ Firebase Auth error:', authError.message);
      }
    }
    
  } catch (error) {
    console.error('❌ Error:', error);
  }
  
  process.exit(0);
}

checkFirebaseAuthUser();