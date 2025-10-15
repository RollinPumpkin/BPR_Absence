const admin = require('firebase-admin');
const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();
const auth = admin.auth();

async function checkFirebaseStatus() {
  try {
    console.log('🔍 FIREBASE AUTHENTICATION & FIRESTORE DIAGNOSTIC');
    console.log('=' .repeat(60));
    
    // 1. Check Firebase project connection
    console.log('\n1️⃣ Testing Firebase Connection...');
    const projectId = serviceAccount.project_id;
    console.log(`📋 Project ID: ${projectId}`);
    
    // Test Firestore connection
    try {
      await db.collection('test').doc('connection-test').set({
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        test: true
      });
      await db.collection('test').doc('connection-test').delete();
      console.log('✅ Firestore connection: WORKING');
    } catch (firestoreError) {
      console.log('❌ Firestore connection: FAILED');
      console.log(`   Error: ${firestoreError.message}`);
    }
    
    // 2. Check Firebase Auth users
    console.log('\n2️⃣ Checking Firebase Authentication Users...');
    try {
      const listUsersResult = await auth.listUsers(50); // Get first 50 users
      console.log(`👥 Total Auth users found: ${listUsersResult.users.length}`);
      
      const targetEmails = ['admin@gmail.com', 'test@bpr.com'];
      
      for (const email of targetEmails) {
        console.log(`\n🔍 Checking ${email}:`);
        try {
          const userRecord = await auth.getUserByEmail(email);
          console.log(`   ✅ Firebase Auth: FOUND`);
          console.log(`   🆔 UID: ${userRecord.uid}`);
          console.log(`   📧 Email: ${userRecord.email}`);
          console.log(`   ✅ Email Verified: ${userRecord.emailVerified}`);
          console.log(`   🚫 Disabled: ${userRecord.disabled}`);
          console.log(`   📅 Created: ${userRecord.metadata.creationTime}`);
          console.log(`   🔄 Last Sign In: ${userRecord.metadata.lastSignInTime || 'Never'}`);
          
          // Check custom claims
          if (userRecord.customClaims) {
            console.log(`   🏷️ Custom Claims: ${JSON.stringify(userRecord.customClaims)}`);
          }
          
        } catch (authError) {
          console.log(`   ❌ Firebase Auth: NOT FOUND`);
          console.log(`   Error: ${authError.message}`);
        }
      }
      
    } catch (listError) {
      console.log('❌ Cannot list Firebase Auth users');
      console.log(`   Error: ${listError.message}`);
    }
    
    // 3. Check Firestore users collection
    console.log('\n3️⃣ Checking Firestore Users Collection...');
    try {
      const usersSnapshot = await db.collection('users').get();
      console.log(`👥 Total Firestore users: ${usersSnapshot.size}`);
      
      const targetEmails = ['admin@gmail.com', 'test@bpr.com'];
      
      for (const email of targetEmails) {
        console.log(`\n🔍 Firestore user: ${email}`);
        const userQuery = await db.collection('users').where('email', '==', email).get();
        
        if (userQuery.empty) {
          console.log(`   ❌ Firestore: NOT FOUND`);
        } else {
          userQuery.forEach(doc => {
            const userData = doc.data();
            console.log(`   ✅ Firestore: FOUND`);
            console.log(`   📄 Document ID: ${doc.id}`);
            console.log(`   👤 Name: ${userData.full_name || 'N/A'}`);
            console.log(`   🆔 Employee ID: ${userData.employee_id || 'N/A'}`);
            console.log(`   👑 Role: ${userData.role || 'N/A'}`);
            console.log(`   🔥 Firebase UID: ${userData.firebase_uid || 'N/A'}`);
            console.log(`   🔑 Has Password: ${userData.password ? 'YES' : 'NO'}`);
            console.log(`   ✅ Active: ${userData.is_active}`);
            console.log(`   📅 Created: ${userData.created_at ? userData.created_at.toDate() : 'N/A'}`);
          });
        }
      }
      
    } catch (firestoreUsersError) {
      console.log('❌ Cannot access Firestore users collection');
      console.log(`   Error: ${firestoreUsersError.message}`);
    }
    
    // 4. Check for inconsistencies
    console.log('\n4️⃣ Checking for Auth/Firestore Inconsistencies...');
    
    const targetEmails = ['admin@gmail.com', 'test@bpr.com'];
    
    for (const email of targetEmails) {
      console.log(`\n🔍 Consistency check for ${email}:`);
      
      let firebaseUser = null;
      let firestoreUsers = [];
      
      // Get Firebase Auth user
      try {
        firebaseUser = await auth.getUserByEmail(email);
      } catch (e) {
        console.log(`   📭 Firebase Auth: Missing`);
      }
      
      // Get Firestore users
      try {
        const userQuery = await db.collection('users').where('email', '==', email).get();
        userQuery.forEach(doc => {
          firestoreUsers.push({ id: doc.id, ...doc.data() });
        });
      } catch (e) {
        console.log(`   📭 Firestore query failed`);
      }
      
      // Analysis
      if (firebaseUser && firestoreUsers.length > 0) {
        console.log(`   ✅ Both systems have user`);
        
        // Check if Firestore document ID matches Firebase UID
        const matchingDoc = firestoreUsers.find(u => u.id === firebaseUser.uid);
        if (matchingDoc) {
          console.log(`   ✅ Document ID matches Firebase UID`);
        } else {
          console.log(`   ⚠️ Document ID mismatch:`);
          console.log(`      Firebase UID: ${firebaseUser.uid}`);
          console.log(`      Firestore IDs: ${firestoreUsers.map(u => u.id).join(', ')}`);
        }
        
      } else if (firebaseUser && firestoreUsers.length === 0) {
        console.log(`   ⚠️ User exists in Firebase Auth but missing in Firestore`);
      } else if (!firebaseUser && firestoreUsers.length > 0) {
        console.log(`   ⚠️ User exists in Firestore but missing in Firebase Auth`);
      } else {
        console.log(`   ❌ User missing in both systems`);
      }
    }
    
    // 5. Check Firebase project settings
    console.log('\n5️⃣ Firebase Project Configuration...');
    console.log(`📋 Project ID: ${serviceAccount.project_id}`);
    console.log(`🔑 Service Account Email: ${serviceAccount.client_email}`);
    console.log(`📅 Service Account Key ID: ${serviceAccount.private_key_id}`);
    
    console.log('\n✅ DIAGNOSTIC COMPLETE');
    
  } catch (error) {
    console.error('❌ DIAGNOSTIC FAILED:', error);
    console.error('Error message:', error.message);
    console.error('Error code:', error.code);
  }
}

// Run diagnostic
checkFirebaseStatus().then(() => {
  console.log('\n🏁 Diagnostic completed');
  process.exit(0);
}).catch((error) => {
  console.error('❌ Diagnostic script failed:', error);
  process.exit(1);
});