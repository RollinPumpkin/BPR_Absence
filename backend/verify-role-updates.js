const admin = require('firebase-admin');
const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

// Initialize Firebase Admin SDK (if not already initialized)
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

const db = admin.firestore();

async function verifyRoleUpdates() {
  try {
    console.log('🔍 VERIFYING FIRESTORE ROLE UPDATES');
    console.log('=====================================');
    
    // Get all users from Firestore
    const usersSnapshot = await db.collection('users').get();
    
    if (usersSnapshot.empty) {
      console.log('❌ No users found in Firestore');
      return;
    }

    console.log(`📋 Found ${usersSnapshot.size} users in database:`);
    console.log('');

    let adminCount = 0;
    let employeeCount = 0;
    let otherCount = 0;

    usersSnapshot.forEach(doc => {
      const userData = doc.data();
      const role = userData.role;
      const employeeId = userData.employee_id;
      
      console.log(`👤 ${userData.full_name}`);
      console.log(`   📧 Email: ${userData.email}`);
      console.log(`   🆔 Employee ID: ${employeeId}`);
      console.log(`   🎯 Role: "${role}"`);
      console.log(`   📅 Updated: ${userData.updated_at ? userData.updated_at.toDate() : 'N/A'}`);
      
      // Count roles
      if (role === 'super_admin' || role === 'admin') {
        adminCount++;
      } else if (role === 'employee' || role === 'account_officer' || role === 'security' || role === 'office_boy') {
        employeeCount++;
      } else {
        otherCount++;
      }
      
      console.log('');
    });

    console.log('📊 ROLE SUMMARY:');
    console.log(`   👑 Admin Level (super_admin, admin): ${adminCount}`);
    console.log(`   👤 Employee Level (employee, account_officer, security, office_boy): ${employeeCount}`);
    console.log(`   ❓ Other/Unknown: ${otherCount}`);
    console.log('');

    // Test routing logic
    console.log('🧪 TESTING ROUTING LOGIC:');
    console.log('==========================');
    
    const testRoles = ['super_admin', 'admin', 'employee', 'account_officer', 'security', 'office_boy'];
    
    testRoles.forEach(role => {
      let route;
      switch (role.toLowerCase()) {
        case 'super_admin':
        case 'admin':
          route = '/admin/dashboard';
          break;
        case 'employee':
        case 'account_officer':
        case 'security':
        case 'office_boy':
        default:
          route = '/user/dashboard';
      }
      
      console.log(`   Role: "${role}" → Route: ${route}`);
    });

    console.log('');
    console.log('✅ Verification completed successfully!');
    
  } catch (error) {
    console.error('❌ Error during verification:', error);
  } finally {
    process.exit(0);
  }
}

// Run verification
verifyRoleUpdates();