const admin = require('firebase-admin');
const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

// Initialize Firebase Admin SDK if not already initialized
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

const db = admin.firestore();
const auth = admin.auth();

async function debugRoutingIssues() {
  try {
    console.log('🔍 DEBUGGING ROUTING ISSUES');
    console.log('===========================');
    
    // Check specific admin users that might have routing issues
    const testUsers = [
      'admin@gmail.com',
      'admin@bpr.com',
      'test@bpr.com',
      'superadmin@bpr.com',
      'user@gmail.com'
    ];

    console.log('📋 CHECKING USER DATA AND EXPECTED ROUTING:');
    console.log('===========================================');

    for (const email of testUsers) {
      console.log(`\n👤 USER: ${email}`);
      console.log('─'.repeat(40));
      
      try {
        const userQuery = await db.collection('users')
          .where('email', '==', email)
          .get();
        
        if (userQuery.empty) {
          console.log('❌ User not found in database');
          continue;
        }

        const userData = userQuery.docs[0].data();
        const role = userData.role;
        const employeeId = userData.employee_id;
        const fullName = userData.full_name;
        
        console.log(`📧 Email: ${email}`);
        console.log(`👨‍💼 Name: ${fullName}`);
        console.log(`🆔 Employee ID: ${employeeId}`);
        console.log(`🎯 Role: "${role}"`);
        console.log(`📏 Role Length: ${role.length}`);
        console.log(`🔤 Role Type: ${typeof role}`);
        
        // Check for hidden characters
        const roleBytes = Buffer.from(role);
        console.log(`🔢 Role Bytes: [${roleBytes.join(', ')}]`);
        console.log(`🧹 Role Trimmed: "${role.trim()}"`);
        console.log(`🔄 Role toLowerCase(): "${role.toLowerCase()}"`);
        
        // Simulate exact Flutter routing logic
        console.log('\n🔍 SIMULATING FLUTTER ROUTING:');
        
        // Test the exact switch case logic from login_page.dart
        const normalizedRole = role.toLowerCase().trim();
        let expectedRoute;
        let routingCase;
        
        switch (normalizedRole) {
          case 'super_admin':
            expectedRoute = '/admin/dashboard';
            routingCase = 'super_admin case';
            break;
          case 'admin':
            expectedRoute = '/admin/dashboard';
            routingCase = 'admin case';
            break;
          case 'hr':
            expectedRoute = '/admin/dashboard';
            routingCase = 'hr case';
            break;
          case 'manager':
            expectedRoute = '/admin/dashboard';
            routingCase = 'manager case';
            break;
          case 'employee':
            expectedRoute = '/user/dashboard';
            routingCase = 'employee case';
            break;
          case 'account_officer':
            expectedRoute = '/user/dashboard';
            routingCase = 'account_officer case';
            break;
          case 'security':
            expectedRoute = '/user/dashboard';
            routingCase = 'security case';
            break;
          case 'office_boy':
            expectedRoute = '/user/dashboard';
            routingCase = 'office_boy case';
            break;
          default:
            expectedRoute = '/user/dashboard';
            routingCase = 'default case';
        }
        
        console.log(`🎯 Normalized Role: "${normalizedRole}"`);
        console.log(`📍 Routing Case: ${routingCase}`);
        console.log(`🚀 Expected Route: ${expectedRoute}`);
        
        // Check if this matches admin expectation
        const shouldBeAdmin = ['super_admin', 'admin', 'hr', 'manager'].includes(normalizedRole);
        const actuallyAdmin = expectedRoute === '/admin/dashboard';
        
        if (email.includes('admin') || email.includes('superadmin')) {
          console.log(`🔍 This is an admin email: ${shouldBeAdmin ? '✅ Should go to admin' : '❌ Will go to user dashboard!'}`);
          console.log(`📊 Routing Result: ${actuallyAdmin ? '✅ Goes to admin dashboard' : '❌ PROBLEM: Goes to user dashboard!'}`);
          
          if (!actuallyAdmin && email.includes('admin')) {
            console.log('🚨 ROUTING ISSUE DETECTED! Admin user going to user dashboard!');
            console.log(`🔧 Issue: Role "${role}" → normalized to "${normalizedRole}" → ${routingCase} → ${expectedRoute}`);
          }
        } else {
          console.log(`📊 Employee Route: ${actuallyAdmin ? '❌ PROBLEM: Employee going to admin!' : '✅ Correctly goes to user dashboard'}`);
        }
        
        // Additional checks
        console.log('\n🔬 ADDITIONAL CHECKS:');
        
        // Check for whitespace issues
        if (role !== role.trim()) {
          console.log('⚠️ Role has whitespace padding!');
        }
        
        // Check for case issues
        if (role !== role.toLowerCase()) {
          console.log('⚠️ Role is not lowercase - this could cause issues!');
        }
        
        // Check Firebase Auth status
        try {
          const firebaseUser = await auth.getUserByEmail(email);
          console.log(`🔐 Firebase Auth: ✅ User exists (${firebaseUser.uid})`);
          console.log(`📧 Email Verified: ${firebaseUser.emailVerified}`);
          console.log(`🚫 Disabled: ${firebaseUser.disabled}`);
        } catch (authError) {
          console.log(`🔐 Firebase Auth: ❌ ${authError.message}`);
        }

      } catch (error) {
        console.log(`❌ Error checking ${email}: ${error.message}`);
      }
    }
    
    // Check for potential issues in the database
    console.log('\n🔍 POTENTIAL DATABASE ISSUES:');
    console.log('=============================');
    
    const allUsersSnapshot = await db.collection('users').get();
    const rolesFound = new Set();
    let issueCount = 0;
    
    allUsersSnapshot.forEach(doc => {
      const userData = doc.data();
      const role = userData.role;
      rolesFound.add(role);
      
      // Check for problematic roles
      if (role !== role.trim()) {
        console.log(`⚠️ User ${userData.email} has role with whitespace: "${role}"`);
        issueCount++;
      }
      
      if (role !== role.toLowerCase()) {
        console.log(`⚠️ User ${userData.email} has uppercase role: "${role}"`);
        issueCount++;
      }
      
      // Check admin emails with wrong roles
      const email = userData.email;
      if ((email.includes('admin') || email.includes('superadmin')) && 
          !['admin', 'super_admin'].includes(role)) {
        console.log(`🚨 Admin email ${email} has wrong role: "${role}"`);
        issueCount++;
      }
    });
    
    console.log(`\n📊 SUMMARY:`);
    console.log(`Total users: ${allUsersSnapshot.size}`);
    console.log(`Roles found: [${Array.from(rolesFound).join(', ')}]`);
    console.log(`Issues detected: ${issueCount}`);
    
    if (issueCount === 0) {
      console.log('✅ No obvious database issues found');
    } else {
      console.log(`❌ ${issueCount} potential issues found that could cause routing problems`);
    }
    
    console.log('\n🎯 ROUTING LOGIC VERIFICATION:');
    console.log('==============================');
    
    console.log('From login_page.dart _getRouteByRole method:');
    console.log('Admin Dashboard roles: super_admin, admin, hr, manager');
    console.log('User Dashboard roles: employee, account_officer, security, office_boy, default');
    console.log('');
    console.log('🔍 If admin users are going to user dashboard, check:');
    console.log('1. Role data in database (whitespace, case)');
    console.log('2. AuthProvider user data loading');
    console.log('3. Route registration in main.dart');
    console.log('4. Navigation context issues');
    
  } catch (error) {
    console.error('❌ Error in routing debug:', error);
  } finally {
    process.exit(0);
  }
}

// Run the routing debug
debugRoutingIssues();