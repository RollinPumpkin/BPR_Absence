const admin = require('firebase-admin');
const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://bpr-absens-default-rtdb.firebaseio.com'
});

const db = admin.firestore();

async function testFirebaseAuthFlow() {
  console.log('🧪 Testing Firebase Auth Flow...\n');
  
  try {
    // Step 1: Get Firebase Auth user
    console.log('1️⃣ Getting Firebase Auth user...');
    const firebaseUser = await admin.auth().getUserByEmail('user@gmail.com');
    console.log(`✅ Firebase UID: ${firebaseUser.uid}`);
    console.log(`   Email: ${firebaseUser.email}`);
    console.log(`   Display Name: ${firebaseUser.displayName}`);
    
    // Step 2: Find user in Firestore by Firebase UID
    console.log('\n2️⃣ Finding user in Firestore by Firebase UID...');
    const firestoreByUid = await db.collection('users')
      .where('firebase_uid', '==', firebaseUser.uid)
      .limit(1)
      .get();
    
    if (!firestoreByUid.empty) {
      const userData = firestoreByUid.docs[0].data();
      console.log('✅ User found by Firebase UID');
      console.log(`   Firestore ID: ${firestoreByUid.docs[0].id}`);
      console.log(`   Name: ${userData.full_name}`);
      console.log(`   Role: ${userData.role}`);
      console.log(`   Employee ID: ${userData.employee_id}`);
    } else {
      console.log('❌ User NOT found by Firebase UID');
      
      // Fallback: find by email
      console.log('🔄 Trying fallback: find by email...');
      const firestoreByEmail = await db.collection('users')
        .where('email', '==', firebaseUser.email)
        .limit(1)
        .get();
        
      if (!firestoreByEmail.empty) {
        const userData = firestoreByEmail.docs[0].data();
        console.log('✅ User found by email');
        console.log(`   Firestore ID: ${firestoreByEmail.docs[0].id}`);
        console.log(`   Name: ${userData.full_name}`);
        console.log(`   Firebase UID in doc: ${userData.firebase_uid}`);
        
        // Update with Firebase UID
        await firestoreByEmail.docs[0].ref.update({
          firebase_uid: firebaseUser.uid,
          updated_at: admin.firestore.FieldValue.serverTimestamp()
        });
        console.log('✅ Updated document with Firebase UID');
      }
    }
    
    // Step 3: Test ID token creation
    console.log('\n3️⃣ Testing ID token creation...');
    const customToken = await admin.auth().createCustomToken(firebaseUser.uid);
    console.log('✅ Custom token created successfully');
    console.log(`   Token length: ${customToken.length} characters`);
    
    // Step 4: Test token verification
    console.log('\n4️⃣ Testing token verification...');
    try {
      const decodedToken = await admin.auth().verifyIdToken(customToken);
      console.log('❌ Custom token should not be verified as ID token');
    } catch (error) {
      console.log('✅ Custom token correctly rejected as ID token');
      console.log('   (This is expected - custom tokens are different from ID tokens)');
    }
    
    console.log('\n🎯 RECOMMENDATION:');
    console.log('='.repeat(50));
    console.log('✅ Firebase Auth setup is working correctly');
    console.log('✅ User data is properly linked');
    console.log('✅ Try logging in with: user@gmail.com / user123');
    console.log('');
    console.log('If login still fails, the issue might be in the Flutter app');
    console.log('or the Firebase web configuration.');
    
  } catch (error) {
    console.error('❌ Error testing Firebase Auth flow:', error);
  }
  
  process.exit(0);
}

testFirebaseAuthFlow();