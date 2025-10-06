const axios = require('axios');

const BASE_URL = 'http://localhost:3000/api';

// Test credentials
const testAdmin = {
  email: 'admin@bpr.com',
  password: 'admin123'
};

const testUser = {
  email: 'user@bpr.com',
  password: 'user123'
};

let adminToken = '';
let userToken = '';
let testUserId = '';

// Test counters
let totalTests = 0;
let passedTests = 0;
let failedTests = 0;

function logTest(testName, passed, details = '') {
  totalTests++;
  if (passed) {
    passedTests++;
    console.log(`✅ ${testName}`);
  } else {
    failedTests++;
    console.log(`❌ ${testName}`);
    if (details) {
      console.log(`   ${details}`);
    }
  }
}

function logSection(sectionName) {
  console.log(`\n🔸 ${sectionName}`);
  console.log(''.padEnd(60, '-'));
}

async function setupAuthentication() {
  try {
    logSection('AUTHENTICATION SETUP');

    // Admin login
    const adminResponse = await axios.post(`${BASE_URL}/auth/login`, testAdmin);
    adminToken = adminResponse.data.data.token;
    logTest('Admin Login', !!adminToken);

    // User login
    const userResponse = await axios.post(`${BASE_URL}/auth/login`, testUser);
    userToken = userResponse.data.data.token;
    testUserId = userResponse.data.data.user.id;
    logTest('User Login', !!userToken);

    return adminToken && userToken;
  } catch (error) {
    console.error('Authentication setup failed:', error.response?.data || error.message);
    return false;
  }
}

async function testHealthCheck() {
  try {
    logSection('SYSTEM HEALTH CHECK');
    
    const response = await axios.get('http://localhost:3000/health');
    logTest('Server Health Check', response.status === 200 && response.data.status === 'OK');
    
    if (response.data.database) {
      logTest('Database Connection', response.data.database === 'Firebase Firestore');
    }
  } catch (error) {
    logTest('Server Health Check', false, error.message);
  }
}

async function testAuthModule() {
  try {
    logSection('AUTHENTICATION MODULE');

    // Test register new user
    const newUser = {
      employee_id: 'TEST002',
      full_name: 'Test User 2',
      email: 'test2@bpr.com',
      password: 'test123',
      department: 'Testing',
      position: 'Test Engineer',
      role: 'employee'
    };

    try {
      const registerResponse = await axios.post(`${BASE_URL}/auth/register`, newUser, {
        headers: { Authorization: `Bearer ${adminToken}` }
      });
      logTest('User Registration', registerResponse.status === 201);
    } catch (error) {
      logTest('User Registration', false, 'May already exist');
    }

    // Test login validation
    try {
      await axios.post(`${BASE_URL}/auth/login`, {
        email: 'invalid@email.com',
        password: 'wrongpassword'
      });
      logTest('Invalid Login Rejection', false, 'Should have failed');
    } catch (error) {
      logTest('Invalid Login Rejection', error.response?.status === 401);
    }

    // Test token validation
    try {
      const profileResponse = await axios.get(`${BASE_URL}/profile`, {
        headers: { Authorization: `Bearer ${userToken}` }
      });
      logTest('Token Validation', profileResponse.status === 200);
    } catch (error) {
      logTest('Token Validation', false, error.response?.data?.message);
    }

  } catch (error) {
    console.error('Auth module test failed:', error.message);
  }
}

async function testAttendanceModule() {
  try {
    logSection('ATTENDANCE MODULE');

    // Test get attendance records
    const attendanceResponse = await axios.get(`${BASE_URL}/attendance`, {
      headers: { Authorization: `Bearer ${userToken}` }
    });
    logTest('Get Attendance Records', attendanceResponse.status === 200);

    // Test attendance statistics
    const statsResponse = await axios.get(`${BASE_URL}/attendance/statistics`, {
      headers: { Authorization: `Bearer ${userToken}` }
    });
    logTest('Get Attendance Statistics', statsResponse.status === 200);

    // Test admin attendance overview
    const adminStatsResponse = await axios.get(`${BASE_URL}/attendance/admin/statistics`, {
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    logTest('Admin Attendance Statistics', adminStatsResponse.status === 200);

    // Test get all attendance (admin)
    const allAttendanceResponse = await axios.get(`${BASE_URL}/attendance/admin/all`, {
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    logTest('Admin Get All Attendance', allAttendanceResponse.status === 200);

  } catch (error) {
    logTest('Attendance Module Error', false, error.response?.data?.message || error.message);
  }
}

async function testUserManagement() {
  try {
    logSection('USER MANAGEMENT MODULE');

    // Test get all users (admin)
    const usersResponse = await axios.get(`${BASE_URL}/users`, {
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    logTest('Get All Users (Admin)', usersResponse.status === 200);

    // Test get user by ID (admin)
    const userByIdResponse = await axios.get(`${BASE_URL}/users/${testUserId}`, {
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    logTest('Get User By ID (Admin)', userByIdResponse.status === 200);

    // Test user access control
    try {
      await axios.get(`${BASE_URL}/users`, {
        headers: { Authorization: `Bearer ${userToken}` }
      });
      logTest('User Access Control', false, 'Should be blocked');
    } catch (error) {
      logTest('User Access Control', error.response?.status === 403);
    }

  } catch (error) {
    logTest('User Management Error', false, error.response?.data?.message || error.message);
  }
}

async function testProfileModule() {
  try {
    logSection('PROFILE MODULE');

    // Test get current profile
    const profileResponse = await axios.get(`${BASE_URL}/profile`, {
      headers: { Authorization: `Bearer ${userToken}` }
    });
    logTest('Get Current Profile', profileResponse.status === 200);

    // Test update profile
    const updateData = {
      full_name: 'Updated Test User',
      phone: '081234567890'
    };
    
    const updateResponse = await axios.put(`${BASE_URL}/profile`, updateData, {
      headers: { Authorization: `Bearer ${userToken}` }
    });
    logTest('Update Profile', updateResponse.status === 200);

    // Test admin get all users
    const adminUsersResponse = await axios.get(`${BASE_URL}/profile/users`, {
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    logTest('Admin Get Users', adminUsersResponse.status === 200);

    // Test search users
    const searchResponse = await axios.get(`${BASE_URL}/profile/users?search=test`, {
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    logTest('Search Users', searchResponse.status === 200);

  } catch (error) {
    logTest('Profile Module Error', false, error.response?.data?.message || error.message);
  }
}

async function testLettersModule() {
  try {
    logSection('LETTERS MODULE');

    // Test get letters
    const lettersResponse = await axios.get(`${BASE_URL}/letters`, {
      headers: { Authorization: `Bearer ${userToken}` }
    });
    logTest('Get Letters', lettersResponse.status === 200);

    // Test get letter templates (admin)
    const templatesResponse = await axios.get(`${BASE_URL}/letters/templates/list`, {
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    logTest('Get Letter Templates', templatesResponse.status === 200);

    // Test create letter (admin)
    const letterData = {
      recipient_id: testUserId,
      subject: 'Test Letter',
      content: 'This is a test letter content for comprehensive testing.',
      letter_type: 'memo',
      priority: 'normal'
    };

    const createResponse = await axios.post(`${BASE_URL}/letters`, letterData, {
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    logTest('Create Letter (Admin)', createResponse.status === 201);

    // Test letter statistics
    const letterStatsResponse = await axios.get(`${BASE_URL}/letters/statistics`, {
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    logTest('Letter Statistics', letterStatsResponse.status === 200);

  } catch (error) {
    logTest('Letters Module Error', false, error.response?.data?.message || error.message);
  }
}

async function testAdminModule() {
  try {
    logSection('ADMIN MODULE');

    // Test admin dashboard
    const dashboardResponse = await axios.get(`${BASE_URL}/admin/dashboard`, {
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    logTest('Admin Dashboard', dashboardResponse.status === 200);

    // Test admin users overview
    const adminUsersResponse = await axios.get(`${BASE_URL}/admin/users`, {
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    logTest('Admin Users Overview', adminUsersResponse.status === 200);

  } catch (error) {
    logTest('Admin Module Error', false, error.response?.data?.message || error.message);
  }
}

async function testSystemSecurity() {
  try {
    logSection('SECURITY & VALIDATION');

    // Test unauthorized access
    try {
      await axios.get(`${BASE_URL}/admin/dashboard`);
      logTest('Unauthorized Access Prevention', false, 'Should require token');
    } catch (error) {
      logTest('Unauthorized Access Prevention', error.response?.status === 401);
    }

    // Test invalid token
    try {
      await axios.get(`${BASE_URL}/profile`, {
        headers: { Authorization: 'Bearer invalid_token' }
      });
      logTest('Invalid Token Rejection', false, 'Should be rejected');
    } catch (error) {
      logTest('Invalid Token Rejection', error.response?.status === 401);
    }

    // Test role-based access control
    try {
      await axios.get(`${BASE_URL}/admin/users`, {
        headers: { Authorization: `Bearer ${userToken}` }
      });
      logTest('Role-based Access Control', false, 'User should not access admin endpoints');
    } catch (error) {
      logTest('Role-based Access Control', error.response?.status === 403);
    }

  } catch (error) {
    logTest('Security Test Error', false, error.message);
  }
}

async function testDataIntegrity() {
  try {
    logSection('DATA INTEGRITY & VALIDATION');

    // Test invalid data validation
    try {
      await axios.post(`${BASE_URL}/auth/register`, {
        employee_id: 'X', // Too short
        full_name: '',    // Required field
        email: 'invalid', // Invalid email
        password: '123'   // Too short
      }, {
        headers: { Authorization: `Bearer ${adminToken}` }
      });
      logTest('Data Validation', false, 'Should reject invalid data');
    } catch (error) {
      logTest('Data Validation', error.response?.status === 400);
    }

    // Test duplicate email prevention
    try {
      await axios.post(`${BASE_URL}/auth/register`, {
        employee_id: 'DUPLICATE001',
        full_name: 'Duplicate User',
        email: testUser.email, // Existing email
        password: 'password123'
      }, {
        headers: { Authorization: `Bearer ${adminToken}` }
      });
      logTest('Duplicate Email Prevention', false, 'Should prevent duplicate email');
    } catch (error) {
      logTest('Duplicate Email Prevention', error.response?.status === 400);
    }

  } catch (error) {
    logTest('Data Integrity Error', false, error.message);
  }
}

async function runComprehensiveTests() {
  console.log('🚀 STARTING COMPREHENSIVE BPR ABSENCE SYSTEM TESTS');
  console.log(''.padEnd(80, '='));
  console.log(`📅 Test Date: ${new Date().toLocaleString()}`);
  console.log(`🌐 Server URL: ${BASE_URL}`);
  console.log(''.padEnd(80, '='));

  // Setup authentication first
  const authSuccess = await setupAuthentication();
  if (!authSuccess) {
    console.log('\n❌ Authentication setup failed. Cannot continue tests.');
    return;
  }

  // Run all test modules
  await testHealthCheck();
  await testAuthModule();
  await testAttendanceModule();
  await testUserManagement();
  await testProfileModule();
  await testLettersModule();
  await testAdminModule();
  await testSystemSecurity();
  await testDataIntegrity();

  // Print comprehensive summary
  console.log('\n'.padEnd(81, '='));
  console.log('📊 COMPREHENSIVE TEST RESULTS SUMMARY');
  console.log(''.padEnd(80, '='));
  console.log(`Total Tests Executed: ${totalTests}`);
  console.log(`✅ Passed: ${passedTests}`);
  console.log(`❌ Failed: ${failedTests}`);
  console.log(`📈 Success Rate: ${((passedTests / totalTests) * 100).toFixed(1)}%`);
  
  if (passedTests === totalTests) {
    console.log('\n🎉 ALL TESTS PASSED! SYSTEM IS FULLY OPERATIONAL! 🎉');
  } else if ((passedTests / totalTests) >= 0.9) {
    console.log('\n✅ EXCELLENT! System is highly stable with minor issues.');
  } else if ((passedTests / totalTests) >= 0.8) {
    console.log('\n👍 GOOD! System is mostly functional with some areas needing attention.');
  } else {
    console.log('\n⚠️  ATTENTION NEEDED! System has significant issues requiring fixes.');
  }

  console.log('\n📋 Module Status Summary:');
  console.log('- Authentication & Authorization: Core system security');
  console.log('- Attendance Management: Employee time tracking');
  console.log('- User Management: User accounts and roles');
  console.log('- Profile Management: User profile and settings');
  console.log('- Letters Management: Document and correspondence');
  console.log('- Admin Dashboard: Administrative overview');
  console.log('- Security & Validation: Data protection and integrity');
  
  console.log('\n'.padEnd(81, '='));
  console.log('🏁 COMPREHENSIVE TESTING COMPLETED');
  console.log(''.padEnd(80, '='));
}

// Run the comprehensive tests
runComprehensiveTests().catch(console.error);