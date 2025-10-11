const admin = require('firebase-admin');
const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://bpr-absens-default-rtdb.firebaseio.com'
});

const db = admin.firestore();

async function checkDatabase() {
  console.log('🔍 Checking Firebase Database...\n');
  
  try {
    // Check users collection
    console.log('👥 USERS COLLECTION:');
    console.log('='.repeat(50));
    const usersSnapshot = await db.collection('users').get();
    
    if (usersSnapshot.empty) {
      console.log('❌ No users found in Firestore');
    } else {
      console.log(`✅ Found ${usersSnapshot.size} users:\n`);
      
      usersSnapshot.forEach(doc => {
        const userData = doc.data();
        console.log(`📋 User ID: ${doc.id}`);
        console.log(`   Email: ${userData.email}`);
        console.log(`   Name: ${userData.full_name}`);
        console.log(`   Role: ${userData.role}`);
        console.log(`   Employee ID: ${userData.employee_id}`);
        console.log(`   Firebase UID: ${userData.firebase_uid || 'Not set'}`);
        console.log(`   Active: ${userData.is_active}`);
        console.log('');
      });
    }
    
    // Check Firebase Auth users
    console.log('🔐 FIREBASE AUTH USERS:');
    console.log('='.repeat(50));
    
    const authUsers = [];
    let nextPageToken;
    
    do {
      const listUsersResult = await admin.auth().listUsers(1000, nextPageToken);
      authUsers.push(...listUsersResult.users);
      nextPageToken = listUsersResult.pageToken;
    } while (nextPageToken);
    
    if (authUsers.length === 0) {
      console.log('❌ No users found in Firebase Auth');
    } else {
      console.log(`✅ Found ${authUsers.length} Firebase Auth users:\n`);
      
      authUsers.forEach(user => {
        console.log(`🔑 UID: ${user.uid}`);
        console.log(`   Email: ${user.email}`);
        console.log(`   Display Name: ${user.displayName || 'Not set'}`);
        console.log(`   Email Verified: ${user.emailVerified}`);
        console.log(`   Disabled: ${user.disabled}`);
        console.log(`   Creation Time: ${user.metadata.creationTime}`);
        console.log('');
      });
    }
    
    // Check if user@gmail.com exists in both
    console.log('🎯 CHECKING user@gmail.com:');
    console.log('='.repeat(50));
    
    try {
      const firebaseUser = await admin.auth().getUserByEmail('user@gmail.com');
      console.log('✅ user@gmail.com found in Firebase Auth');
      console.log(`   UID: ${firebaseUser.uid}`);
      console.log(`   Email Verified: ${firebaseUser.emailVerified}`);
      
      // Check in Firestore
      const firestoreQuery = await db.collection('users')
        .where('email', '==', 'user@gmail.com')
        .get();
        
      if (!firestoreQuery.empty) {
        console.log('✅ user@gmail.com found in Firestore');
        const userData = firestoreQuery.docs[0].data();
        console.log(`   Firestore ID: ${firestoreQuery.docs[0].id}`);
        console.log(`   Firebase UID in Firestore: ${userData.firebase_uid}`);
        console.log(`   Role: ${userData.role}`);
      } else {
        console.log('❌ user@gmail.com NOT found in Firestore');
      }
      
    } catch (error) {
      console.log('❌ user@gmail.com NOT found in Firebase Auth');
      console.log(`   Error: ${error.message}`);
    }
    
    // Test Firebase ID token verification
    console.log('\n🧪 TESTING TOKEN VERIFICATION:');
    console.log('='.repeat(50));
    
    try {
      // Try to sign in programmatically to test
      const testUser = await admin.auth().getUserByEmail('user@gmail.com');
      const customToken = await admin.auth().createCustomToken(testUser.uid);
      console.log('✅ Custom token created successfully');
      console.log(`   Token preview: ${customToken.substring(0, 50)}...`);
    } catch (error) {
      console.log('❌ Failed to create custom token');
      console.log(`   Error: ${error.message}`);
    }
    
  } catch (error) {
    console.error('❌ Error checking database:', error);
  }
  
  process.exit(0);
}

checkDatabase();