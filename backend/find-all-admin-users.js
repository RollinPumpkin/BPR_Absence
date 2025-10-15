const admin = require('firebase-admin');

// Initialize admin if not already done
if (!admin.apps.length) {
  const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

const db = admin.firestore();

async function findAllAdminUsers() {
  try {
    console.log('🔍 Finding all admin/super admin users...');
    
    // Query for super_admin role
    const superAdminQuery = await db.collection('users')
      .where('role', '==', 'super_admin')
      .get();
    
    // Query for admin role  
    const adminQuery = await db.collection('users')
      .where('role', '==', 'admin')
      .get();
    
    // Query for SUP employee IDs
    const supQuery = await db.collection('users')
      .where('employee_id', '>=', 'SUP')
      .where('employee_id', '<', 'SUQ')
      .get();
    
    // Query for ADM employee IDs
    const admQuery = await db.collection('users')
      .where('employee_id', '>=', 'ADM')
      .where('employee_id', '<', 'ADN')
      .get();
    
    const allAdmins = new Map();
    
    // Collect all unique admin users
    [superAdminQuery, adminQuery, supQuery, admQuery].forEach(querySnapshot => {
      querySnapshot.forEach(doc => {
        const data = doc.data();
        allAdmins.set(data.email, {
          id: doc.id,
          email: data.email,
          employee_id: data.employee_id,
          role: data.role,
          full_name: data.full_name,
          status: data.status,
          is_active: data.is_active,
          firebase_uid: data.firebase_uid
        });
      });
    });
    
    console.log(`\n✅ Found ${allAdmins.size} admin users:\n`);
    
    const sortedAdmins = Array.from(allAdmins.values()).sort((a, b) => a.employee_id.localeCompare(b.employee_id));
    
    sortedAdmins.forEach((user, index) => {
      console.log(`${index + 1}. ${user.full_name}`);
      console.log(`   📧 Email: ${user.email}`);
      console.log(`   🆔 Employee ID: ${user.employee_id}`);
      console.log(`   👤 Role: ${user.role}`);
      console.log(`   📱 Status: ${user.status} | Active: ${user.is_active}`);
      console.log(`   🔗 Firebase UID: ${user.firebase_uid || 'Not set'}`);
      console.log('');
    });
    
    console.log('📋 Test these credentials:');
    console.log('Password for all users: 123456');
    console.log('\n🎯 Recommended test accounts:');
    
    const testAccounts = sortedAdmins.filter(user => 
      user.is_active && 
      user.status === 'active' && 
      user.firebase_uid &&
      (user.role === 'super_admin' || user.role === 'admin' || user.employee_id.startsWith('SUP') || user.employee_id.startsWith('ADM'))
    );
    
    testAccounts.forEach((user, index) => {
      console.log(`${index + 1}. Email: ${user.email} | ID: ${user.employee_id} | Role: ${user.role}`);
    });
    
  } catch (error) {
    console.error('❌ Error:', error);
  }
  
  process.exit(0);
}

findAllAdminUsers();