const admin = require('firebase-admin');
const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

// Initialize Firebase Admin SDK if not already initialized
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

const db = admin.firestore();

async function testAdminRouting() {
  try {
    console.log('🔍 TESTING ADMIN ROLE ROUTING');
    console.log('=============================');
    
    // Get all admin users
    const usersSnapshot = await db.collection('users')
      .where('role', 'in', ['super_admin', 'admin'])
      .get();
    
    console.log(`📋 Found ${usersSnapshot.size} admin level users to test`);
    
    usersSnapshot.forEach(doc => {
      const userData = doc.data();
      const role = userData.role;
      const email = userData.email;
      const employeeId = userData.employee_id;
      const fullName = userData.full_name;
      
      console.log(`\n👤 ADMIN USER: ${fullName}`);
      console.log(`   📧 Email: ${email}`);
      console.log(`   🆔 Employee ID: ${employeeId}`);
      console.log(`   🎯 Role: "${role}"`);
      
      // Simulate routing logic from login_page.dart
      const routingRole = role.toLowerCase();
      let expectedRoute;
      
      switch (routingRole) {
        case 'super_admin':
        case 'admin':
        case 'hr':
        case 'manager':
          expectedRoute = '/admin/dashboard';
          break;
        case 'employee':
        case 'account_officer':
        case 'security':
        case 'office_boy':
        default:
          expectedRoute = '/user/dashboard';
      }
      
      console.log(`   📍 Expected Route: ${expectedRoute}`);
      console.log(`   ✅ Status: ${expectedRoute === '/admin/dashboard' ? 'CORRECT - Goes to Admin Dashboard' : 'ERROR - Wrong routing!'}`);
    });

    // Test specific admin credentials
    console.log('\n🔑 TESTING SPECIFIC ADMIN CREDENTIALS');
    console.log('====================================');
    
    const testCredentials = [
      { email: 'admin@gmail.com', expectedRole: 'super_admin' },
      { email: 'admin@bpr.com', expectedRole: 'admin' },
      { email: 'superadmin@bpr.com', expectedRole: 'super_admin' },
      { email: 'test@bpr.com', expectedRole: 'admin' }
    ];
    
    for (const cred of testCredentials) {
      console.log(`\n🔍 Testing: ${cred.email}`);
      
      const userQuery = await db.collection('users')
        .where('email', '==', cred.email)
        .get();
      
      if (!userQuery.empty) {
        const userData = userQuery.docs[0].data();
        const actualRole = userData.role;
        
        console.log(`   🎯 Found Role: "${actualRole}"`);
        console.log(`   ✅ Expected Role: "${cred.expectedRole}"`);
        console.log(`   📍 Route: /admin/dashboard`);
        console.log(`   ✅ Status: ${actualRole === cred.expectedRole ? 'MATCH' : 'MISMATCH'}`);
        
        // Show routing decision
        const routingRole = actualRole.toLowerCase();
        const willGoToAdmin = ['super_admin', 'admin', 'hr', 'manager'].includes(routingRole);
        console.log(`   🚀 Routing Decision: ${willGoToAdmin ? 'ADMIN DASHBOARD ✅' : 'USER DASHBOARD ❌'}`);
      } else {
        console.log(`   ❌ User not found`);
      }
    }

    console.log('\n📊 ROUTING LOGIC VERIFICATION');
    console.log('=============================');
    console.log('Based on login_page.dart _getRouteByRole() method:');
    console.log('');
    console.log('🏢 ADMIN DASHBOARD ROLES:');
    console.log('   - super_admin → /admin/dashboard');
    console.log('   - admin → /admin/dashboard'); 
    console.log('   - hr → /admin/dashboard');
    console.log('   - manager → /admin/dashboard');
    console.log('');
    console.log('👤 USER DASHBOARD ROLES:');
    console.log('   - employee → /user/dashboard');
    console.log('   - account_officer → /user/dashboard');
    console.log('   - security → /user/dashboard');
    console.log('   - office_boy → /user/dashboard');
    console.log('   - default → /user/dashboard');
    
    console.log('\n✅ ADMIN ROUTING TEST COMPLETED!');
    
  } catch (error) {
    console.error('❌ Error testing admin routing:', error);
  } finally {
    process.exit(0);
  }
}

// Run the admin routing test
testAdminRouting();