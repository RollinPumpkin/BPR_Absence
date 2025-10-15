const admin = require('firebase-admin');
const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function checkAdminUserRoles() {
  try {
    console.log('🔍 Checking admin user roles...');
    
    const targetEmails = ['admin@gmail.com', 'test@bpr.com'];
    
    for (const email of targetEmails) {
      console.log(`\n${'='.repeat(50)}`);
      console.log(`🔍 Checking: ${email}`);
      console.log(`${'='.repeat(50)}`);
      
      const userQuery = await db.collection('users').where('email', '==', email).get();
      
      if (userQuery.empty) {
        console.log('❌ User not found in Firestore');
        continue;
      }
      
      userQuery.forEach(doc => {
        const userData = doc.data();
        console.log(`📄 Document ID: ${doc.id}`);
        console.log(`👤 Full Name: ${userData.full_name}`);
        console.log(`📧 Email: ${userData.email}`);
        console.log(`🆔 Employee ID: ${userData.employee_id}`);
        console.log(`👑 Role: "${userData.role}"`);
        console.log(`👑 Role Type: ${typeof userData.role}`);
        console.log(`✅ Active: ${userData.is_active}`);
        
        // Check what the Flutter app expects
        console.log(`\n🎯 Flutter Routing Analysis:`);
        if (userData.role === 'admin' || userData.role === 'account_officer') {
          console.log(`   ✅ Should route to: /admin/dashboard`);
          console.log(`   ✅ Reason: Role "${userData.role}" matches admin condition`);
        } else if (userData.role === 'super_admin') {
          console.log(`   ❌ Will route to: /user/dashboard`);
          console.log(`   ❌ Problem: Role "super_admin" NOT in admin condition`);
          console.log(`   🔧 Fix needed: Add "super_admin" to admin routing condition`);
        } else {
          console.log(`   ❌ Will route to: /user/dashboard`);
          console.log(`   ❌ Reason: Role "${userData.role}" not recognized as admin`);
        }
      });
    }
    
    console.log(`\n${'='.repeat(60)}`);
    console.log('🎯 ROUTING ISSUE ANALYSIS');
    console.log(`${'='.repeat(60)}`);
    console.log('');
    console.log('📋 Current Flutter routing logic:');
    console.log('   if (userRole == \'admin\' || userRole == \'account_officer\') {');
    console.log('     → /admin/dashboard');
    console.log('   } else {');
    console.log('     → /user/dashboard');
    console.log('   }');
    console.log('');
    console.log('🔧 Problem identified:');
    console.log('   • admin@gmail.com has role "super_admin"');
    console.log('   • "super_admin" is NOT included in admin routing condition');
    console.log('   • This causes super_admin to be routed to user dashboard');
    console.log('');
    console.log('✅ Solution:');
    console.log('   Add "super_admin" to the admin routing condition in login_page.dart');
    
  } catch (error) {
    console.error('❌ Error checking user roles:', error);
    console.error('Error message:', error.message);
  }
}

// Run the check
checkAdminUserRoles().then(() => {
  console.log('\n✅ Role check completed');
  process.exit(0);
}).catch((error) => {
  console.error('❌ Role check failed:', error);
  process.exit(1);
});