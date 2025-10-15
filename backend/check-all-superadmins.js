// Check all super admin accounts
const admin = require('firebase-admin');

// Initialize Firebase Admin
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json')
  });
}

const db = admin.firestore();

async function checkAllSuperAdmins() {
  try {
    console.log('\n🔍 ALL SUPER ADMIN ACCOUNTS');
    console.log('============================');
    
    // Check all super admin users
    const usersRef = db.collection('users');
    const snapshot = await usersRef.where('role', '==', 'super_admin').get();
    
    if (snapshot.empty) {
      console.log('❌ No super admin users found');
      return;
    }
    
    let count = 1;
    snapshot.forEach(doc => {
      const userData = doc.data();
      console.log(`\n${count}. 📋 SUPER ADMIN ${count}:`);
      console.log('   Document ID:', doc.id);
      console.log('   Email:', userData.email);
      console.log('   Employee ID:', userData.employee_id);
      console.log('   Full Name:', userData.full_name);
      console.log('   Firebase UID:', userData.firebase_uid);
      console.log('   Is Active:', userData.is_active);
      count++;
    });
    
    // Now check Firebase Auth to see if there are password issues
    console.log('\n🔍 CHECKING FIREBASE AUTH ACCOUNTS');
    console.log('===================================');
    
    const auth = admin.auth();
    const listUsersResult = await auth.listUsers();
    
    listUsersResult.users.forEach(userRecord => {
      if (userRecord.email && userRecord.email.includes('superadmin')) {
        console.log('\n📧 Firebase Auth Account:');
        console.log('   Email:', userRecord.email);
        console.log('   UID:', userRecord.uid);
        console.log('   Email Verified:', userRecord.emailVerified);
        console.log('   Disabled:', userRecord.disabled);
        console.log('   Created:', new Date(userRecord.metadata.creationTime));
      }
    });
    
  } catch (error) {
    console.error('Error checking super admins:', error);
  }
}

checkAllSuperAdmins();