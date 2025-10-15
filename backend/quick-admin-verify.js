// Quick admin verification script
const admin = require('firebase-admin');

// Initialize Firebase Admin
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json')
  });
}

const db = admin.firestore();

async function verifyAdminUser() {
  try {
    console.log('\n🔍 QUICK ADMIN VERIFICATION');
    console.log('============================');
    
    // Check admin@gmail.com specifically
    const usersRef = db.collection('users');
    const snapshot = await usersRef.where('email', '==', 'admin@gmail.com').get();
    
    if (snapshot.empty) {
      console.log('❌ No user found with email: admin@gmail.com');
      return;
    }
    
    snapshot.forEach(doc => {
      const userData = doc.data();
      console.log('\n📋 ADMIN USER DATA:');
      console.log('Document ID:', doc.id);
      console.log('Email:', userData.email);
      console.log('Role:', userData.role);
      console.log('Employee ID:', userData.employee_id);
      console.log('Full Name:', userData.full_name);
      console.log('Is Active:', userData.is_active);
      
      // Analyze routing decision
      const hasAdminEmployeeId = userData.employee_id?.startsWith('SUP') || userData.employee_id?.startsWith('ADM');
      const hasAdminRole = userData.role === 'admin' || userData.role === 'super_admin';
      const shouldAccessAdmin = hasAdminEmployeeId || hasAdminRole;
      
      console.log('\n🎯 ROUTING ANALYSIS:');
      console.log('Has Admin Employee ID (SUP/ADM):', hasAdminEmployeeId);
      console.log('Has Admin Role:', hasAdminRole);
      console.log('Should Access Admin:', shouldAccessAdmin);
      console.log('Expected Route:', shouldAccessAdmin ? '/admin/dashboard' : '/user/dashboard');
    });
    
  } catch (error) {
    console.error('Error verifying admin user:', error);
  }
}

verifyAdminUser();