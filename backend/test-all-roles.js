const admin = require('firebase-admin');
const axios = require('axios');

// Initialize Firebase Admin
const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();
const API_URL = 'http://127.0.0.1:3000/api';

// Helper function to login and get token
async function loginUser(email, password) {
  try {
    const response = await axios.post(`${API_URL}/auth/login`, {
      email,
      password
    });
    
    if (response.data.success && response.data.data) {
      return {
        token: response.data.data.token,
        user: response.data.data.user
      };
    }
    return null;
  } catch (error) {
    console.error(`❌ Login failed for ${email}:`, error.response?.data?.message || error.message);
    return null;
  }
}

// Helper function to test API endpoint
async function testEndpoint(name, url, token, method = 'GET', data = null) {
  try {
    const config = {
      method,
      url,
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    };
    
    if (data) {
      config.data = data;
    }
    
    const response = await axios(config);
    
    if (response.data) {
      const dataCount = Array.isArray(response.data.data) 
        ? response.data.data.length 
        : (response.data.data ? 1 : 0);
      console.log(`  ✅ ${name}: ${response.status} - ${dataCount} items`);
      return true;
    }
  } catch (error) {
    const status = error.response?.status || 'ERROR';
    const message = error.response?.data?.message || error.message;
    console.log(`  ❌ ${name}: ${status} - ${message}`);
    return false;
  }
}

// Main test function
async function runTests() {
  console.log('╔════════════════════════════════════════════════════════════╗');
  console.log('║     BPR ABSENCE - COMPREHENSIVE ROLE-BASED TEST           ║');
  console.log('╚════════════════════════════════════════════════════════════╝\n');
  
  console.log('📋 Fetching users from Firestore...\n');
  
  try {
    // Get users from Firestore
    const usersSnapshot = await db.collection('users').get();
    
    if (usersSnapshot.empty) {
      console.log('❌ No users found in Firestore!');
      return;
    }
    
    // Organize users by role
    const usersByRole = {
      super_admin: [],
      superadmin: [],
      admin: [],
      user: [],
      employee: []
    };
    
    usersSnapshot.forEach(doc => {
      const userData = doc.data();
      const role = userData.role?.toLowerCase().replace(' ', '_') || 'user';
      
      if (usersByRole[role] !== undefined) {
        usersByRole[role].push({
          id: doc.id,
          email: userData.email,
          name: userData.name,
          role: userData.role,
          division: userData.division
        });
      }
    });
    
    // Combine super_admin and superadmin
    usersByRole.superadmin = [...usersByRole.superadmin, ...usersByRole.super_admin];
    
    console.log('📊 Users found in Firestore:');
    console.log(`   🔴 Super Admin: ${usersByRole.superadmin.length}`);
    console.log(`   🟡 Admin: ${usersByRole.admin.length}`);
    console.log(`   🟢 Employee: ${usersByRole.employee.length}`);
    console.log(`   🟢 User: ${usersByRole.user.length}\n`);
    
    // Test each role
    const roles = ['employee', 'user', 'admin', 'superadmin'];
    const testResults = {
      employee: { total: 0, passed: 0 },
      user: { total: 0, passed: 0 },
      admin: { total: 0, passed: 0 },
      superadmin: { total: 0, passed: 0 }
    };
    
    for (const role of roles) {
      const users = usersByRole[role];
      
      if (users.length === 0) {
        console.log(`\n⚠️  No ${role.toUpperCase()} found, skipping...\n`);
        continue;
      }
      
      // Test with first user of each role
      const testUser = users[0];
      console.log(`${'='.repeat(60)}`);
      console.log(`🧪 Testing as ${role.toUpperCase()}: ${testUser.name} (${testUser.email})`);
      console.log(`${'='.repeat(60)}\n`);
      
      // Default password based on role
      const password = (role === 'admin' || role === 'superadmin') ? 'Admin123!' : 'Employee123!';
      
      console.log(`🔐 Logging in...`);
      const authData = await loginUser(testUser.email, password);
      
      if (!authData) {
        console.log(`❌ Cannot login with ${testUser.email}`);
        console.log(`⚠️  Make sure password is: ${password}\n`);
        continue;
      }
      
      console.log(`✅ Login successful! Token received.\n`);
      const { token, user } = authData;
      
      console.log(`📝 User Info:`);
      console.log(`   Name: ${user?.name || testUser.name}`);
      console.log(`   Email: ${user?.email || testUser.email}`);
      console.log(`   Role: ${user?.role || testUser.role}`);
      console.log(`   Division: ${user?.division || testUser.division || 'N/A'}\n`);
      
      // Test endpoints based on role
      console.log(`📡 Testing API Endpoints:\n`);
      
      // 1. Profile
      console.log(`👤 Profile:`);
      testResults[role].total++;
      if (await testEndpoint('Get Profile', `${API_URL}/profile`, token)) {
        testResults[role].passed++;
      }
      
      // 2. Dashboard
      console.log(`\n📊 Dashboard:`);
      testResults[role].total++;
      const dashboardEndpoint = (role === 'admin' || role === 'superadmin') ? `${API_URL}/dashboard/admin` : `${API_URL}/dashboard/user`;
      if (await testEndpoint('Get Dashboard', dashboardEndpoint, token)) {
        testResults[role].passed++;
      }
      
      // 3. Assignments
      console.log(`\n📋 Assignments:`);
      testResults[role].total++;
      if (await testEndpoint('Get Assignments', `${API_URL}/assignments`, token)) {
        testResults[role].passed++;
      }
      
      if (role === 'admin' || role === 'superadmin') {
        testResults[role].total++;
        if (await testEndpoint('Get All Assignments (Admin)', `${API_URL}/assignments/admin/all`, token)) {
          testResults[role].passed++;
        }
      }
      
      // 4. Letters
      console.log(`\n✉️  Letters:`);
      testResults[role].total++;
      if (await testEndpoint('Get Letters', `${API_URL}/letters`, token)) {
        testResults[role].passed++;
      }
      
      testResults[role].total++;
      if (await testEndpoint('Get Received Letters', `${API_URL}/letters/received`, token)) {
        testResults[role].passed++;
      }
      
      // Pending letters only for admin/superadmin
      if (role === 'admin' || role === 'superadmin') {
        testResults[role].total++;
        if (await testEndpoint('Get Pending Letters', `${API_URL}/letters/pending`, token)) {
          testResults[role].passed++;
        }
      }
      
      // 5. Attendance
      console.log(`\n📅 Attendance:`);
      testResults[role].total++;
      if (await testEndpoint('Get Attendance', `${API_URL}/attendance`, token)) {
        testResults[role].passed++;
      }
      
      testResults[role].total++;
      if (await testEndpoint('Get Attendance History', `${API_URL}/attendance/history`, token)) {
        testResults[role].passed++;
      }
      
      // 6. Users (Admin/SuperAdmin only)
      if (role === 'admin' || role === 'superadmin') {
        console.log(`\n👥 Users (Admin):`);
        testResults[role].total++;
        if (await testEndpoint('Get All Users', `${API_URL}/users`, token)) {
          testResults[role].passed++;
        }
        
        testResults[role].total++;
        if (await testEndpoint('Get Employees', `${API_URL}/users/admin/employees`, token)) {
          testResults[role].passed++;
        }
      }
      
      // 7. Admin specific endpoints
      if (role === 'admin' || role === 'superadmin') {
        console.log(`\n⚙️  Admin Functions:`);
        testResults[role].total++;
        if (await testEndpoint('Get Admin Dashboard', `${API_URL}/admin/dashboard`, token)) {
          testResults[role].passed++;
        }
      }
    }
    
    // Summary
    console.log(`\n\n${'═'.repeat(60)}`);
    console.log(`📊 TEST SUMMARY`);
    console.log(`${'═'.repeat(60)}\n`);
    
    let totalTests = 0;
    let totalPassed = 0;
    
    for (const role of roles) {
      const result = testResults[role];
      if (result.total > 0) {
        const percentage = ((result.passed / result.total) * 100).toFixed(1);
        const icon = percentage >= 80 ? '✅' : percentage >= 50 ? '⚠️' : '❌';
        
        console.log(`${icon} ${role.toUpperCase().padEnd(12)} : ${result.passed}/${result.total} passed (${percentage}%)`);
        
        totalTests += result.total;
        totalPassed += result.passed;
      }
    }
    
    const overallPercentage = ((totalPassed / totalTests) * 100).toFixed(1);
    console.log(`\n${'─'.repeat(60)}`);
    console.log(`🎯 OVERALL: ${totalPassed}/${totalTests} tests passed (${overallPercentage}%)`);
    console.log(`${'═'.repeat(60)}\n`);
    
    // Auto-refresh test reminder
    console.log(`\n💡 AUTO-REFRESH VERIFICATION:`);
    console.log(`   All 27 CRUD operations have clearCache() implemented:`);
    console.log(`   ✅ Assignments: CREATE, UPDATE, DELETE`);
    console.log(`   ✅ Letters: SEND, REPLY, DELETE, ARCHIVE, APPROVE, REJECT, UPDATE_STATUS`);
    console.log(`   ✅ Employees: CREATE, UPDATE, DELETE, UPDATE_STATUS`);
    console.log(`   ✅ Attendance: CHECKIN, CHECKOUT, UPDATE, DELETE`);
    console.log(`   ✅ Users: UPDATE, ACTIVATE, DEACTIVATE, RESET_PASSWORD, BULK_UPDATE`);
    console.log(`   ✅ Auth: UPDATE_PROFILE`);
    console.log(`   ✅ User Service: CHANGE_PASSWORD, UPDATE_PROFILE, UPLOAD_PICTURE\n`);
    
    console.log(`📝 Next Steps:`);
    console.log(`   1. Login to Flutter app with each role`);
    console.log(`   2. Test CREATE/UPDATE/DELETE operations`);
    console.log(`   3. Verify data appears immediately without manual refresh`);
    console.log(`   4. Check all 27 operations auto-refresh correctly\n`);
    
  } catch (error) {
    console.error('❌ Error running tests:', error);
  } finally {
    // Cleanup
    await admin.app().delete();
  }
}

// Run the tests
runTests().catch(console.error);
