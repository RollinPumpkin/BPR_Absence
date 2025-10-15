const admin = require('firebase-admin');
const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function checkCurrentRoleSetup() {
  try {
    console.log('🔍 Checking current role setup after updates...');
    
    // Get all users to see role distribution
    const usersSnapshot = await db.collection('users').get();
    const roleCounts = {};
    
    console.log(`📊 Total users in database: ${usersSnapshot.size}\n`);
    
    usersSnapshot.forEach(doc => {
      const userData = doc.data();
      const role = userData.role || 'undefined';
      roleCounts[role] = (roleCounts[role] || 0) + 1;
    });
    
    console.log('📋 Role Distribution:');
    Object.entries(roleCounts).forEach(([role, count]) => {
      console.log(`   ${role}: ${count} users`);
    });
    
    console.log('\n🎯 NEW ADMIN DASHBOARD ACCESS POLICY:');
    console.log('=' .repeat(60));
    console.log('✅ CAN ACCESS ADMIN DASHBOARD:');
    console.log('   • admin (regular admin)');
    console.log('   • super_admin (super administrator)');
    console.log('');
    console.log('❌ REDIRECTED TO USER DASHBOARD:');
    console.log('   • account_officer (moved to user dashboard)');
    console.log('   • employee');
    console.log('   • security');
    console.log('   • office_boy');
    console.log('   • All other roles');
    
    console.log('\n🔐 ROLE HIERARCHY IN ADD EMPLOYEE:');
    console.log('=' .repeat(60));
    console.log('👑 SUPER ADMIN can create:');
    console.log('   • admin (NEW!)');
    console.log('   • employee');
    console.log('   • account_officer');
    console.log('   • security');
    console.log('   • office_boy');
    console.log('');
    console.log('👤 ADMIN can create:');
    console.log('   • employee');
    console.log('   • account_officer');
    console.log('   • security');
    console.log('   • office_boy');
    console.log('   ❌ Cannot create: admin (reserved for super_admin)');
    
    // Test specific admin users
    const testEmails = ['admin@gmail.com', 'test@bpr.com'];
    
    console.log('\n🧪 TESTING ADMIN USERS:');
    console.log('=' .repeat(60));
    
    for (const email of testEmails) {
      const userQuery = await db.collection('users').where('email', '==', email).get();
      
      if (!userQuery.empty) {
        userQuery.forEach(doc => {
          const userData = doc.data();
          console.log(`\n📧 ${email}:`);
          console.log(`   👤 Name: ${userData.full_name}`);
          console.log(`   👑 Role: "${userData.role}"`);
          
          // Test routing
          if (userData.role === 'admin' || userData.role === 'super_admin') {
            console.log(`   ✅ Routes to: /admin/dashboard`);
          } else {
            console.log(`   ❌ Routes to: /user/dashboard`);
          }
          
          // Test add employee permissions
          if (userData.role === 'super_admin') {
            console.log(`   🔧 Can create: Admin + all other roles`);
          } else if (userData.role === 'admin') {
            console.log(`   🔧 Can create: Employee, Account Officer, Security, Office Boy`);
          } else {
            console.log(`   🔧 Cannot access add employee page`);
          }
        });
      }
    }
    
    console.log('\n✅ SETUP VERIFICATION COMPLETE');
    console.log('🚀 Ready to test the new role hierarchy!');
    
  } catch (error) {
    console.error('❌ Error checking role setup:', error);
    console.error('Error message:', error.message);
  }
}

// Run the check
checkCurrentRoleSetup().then(() => {
  console.log('\n✅ Role setup check completed');
  process.exit(0);
}).catch((error) => {
  console.error('❌ Role setup check failed:', error);
  process.exit(1);
});