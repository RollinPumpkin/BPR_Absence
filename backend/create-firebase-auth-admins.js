const admin = require('firebase-admin');
const bcrypt = require('bcryptjs');

// Initialize admin if not already done
if (!admin.apps.length) {
  const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

const auth = admin.auth();
const db = admin.firestore();

async function createFirebaseAuthForAdmins() {
  try {
    console.log('🔧 Creating Firebase Auth users for admin accounts...\n');
    
    // Get all admin users without Firebase UID
    const adminUsers = [
      { email: 'test@bpr.com', employee_id: 'ADM003' },
      { email: 'superadmin@bpr.com', employee_id: 'SUP002' },
      { email: 'superadmin@gmail.com', employee_id: 'SUP003' }
    ];
    
    for (const adminUser of adminUsers) {
      console.log(`🔧 Processing: ${adminUser.email}`);
      
      // Get user from Firestore
      const userQuery = await db.collection('users')
        .where('email', '==', adminUser.email)
        .limit(1)
        .get();
      
      if (userQuery.empty) {
        console.log(`❌ User not found in Firestore: ${adminUser.email}`);
        continue;
      }
      
      const userDoc = userQuery.docs[0];
      const userData = userDoc.data();
      
      console.log(`   📧 Email: ${userData.email}`);
      console.log(`   🆔 Employee ID: ${userData.employee_id}`);
      console.log(`   👤 Role: ${userData.role}`);
      
      // Check if Firebase Auth user already exists
      let firebaseUser;
      try {
        firebaseUser = await auth.getUserByEmail(adminUser.email);
        console.log(`   ✅ Firebase Auth user exists: ${firebaseUser.uid}`);
      } catch (error) {
        if (error.code === 'auth/user-not-found') {
          console.log(`   🔧 Creating Firebase Auth user...`);
          
          // Create Firebase Auth user
          firebaseUser = await auth.createUser({
            email: adminUser.email,
            password: '123456', // Standard password
            emailVerified: true,
            displayName: userData.full_name
          });
          
          console.log(`   ✅ Created Firebase Auth user: ${firebaseUser.uid}`);
        } else {
          console.log(`   ❌ Error checking Firebase user: ${error.message}`);
          continue;
        }
      }
      
      // Update Firestore with Firebase UID
      if (firebaseUser && (!userData.firebase_uid || userData.firebase_uid !== firebaseUser.uid)) {
        await userDoc.ref.update({
          firebase_uid: firebaseUser.uid,
          updated_at: admin.firestore.FieldValue.serverTimestamp()
        });
        console.log(`   ✅ Updated Firestore with Firebase UID`);
      }
      
      console.log(`   🎯 Test credentials: ${adminUser.email} + 123456`);
      console.log('');
    }
    
    console.log('🎉 Firebase Auth setup complete!');
    console.log('\n📋 Available admin test accounts:');
    console.log('1. admin@gmail.com + 123456 (SUP001, super_admin)');
    console.log('2. test@bpr.com + 123456 (ADM003, admin)');
    console.log('3. superadmin@bpr.com + 123456 (SUP002, super_admin)');
    console.log('4. superadmin@gmail.com + 123456 (SUP003, super_admin)');
    
  } catch (error) {
    console.error('❌ Error:', error);
  }
  
  process.exit(0);
}

createFirebaseAuthForAdmins();