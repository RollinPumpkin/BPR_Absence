const axios = require('axios');
const colors = require('colors');

// Test configuration
const BASE_URL = 'http://localhost:3000/api';
let authToken = '';
let testUserId = '';
let adminToken = '';

// Test results storage
const testResults = {
  passed: 0,
  failed: 0,
  total: 0,
  details: []
};

// Helper function to log test results
const logTest = (testName, passed, details = '') => {
  testResults.total++;
  if (passed) {
    testResults.passed++;
    console.log(`✅ ${testName}`.green);
  } else {
    testResults.failed++;
    console.log(`❌ ${testName}`.red);
    if (details) console.log(`   ${details}`.yellow);
  }
  testResults.details.push({
    name: testName,
    passed,
    details
  });
};

// Helper function to make authenticated requests
const makeRequest = async (method, url, data = null, token = null) => {
  try {
    const config = {
      method,
      url: `${BASE_URL}${url}`,
      headers: {}
    };

    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }

    if (data) {
      config.data = data;
      config.headers['Content-Type'] = 'application/json';
    }

    const response = await axios(config);
    return { success: true, data: response.data, status: response.status };
  } catch (error) {
    return {
      success: false,
      error: error.response?.data || error.message,
      status: error.response?.status
    };
  }
};

// Test Authentication Endpoints
const testAuthEndpoints = async () => {
  console.log('\n🔐 Testing Authentication Endpoints'.cyan.bold);
  console.log('='.repeat(50).cyan);

  // Test Health Check
  try {
    const healthResponse = await axios.get('http://localhost:3000/health');
    logTest('Health Check', healthResponse.status === 200);
  } catch (error) {
    logTest('Health Check', false, 'Server not responding');
    return false;
  }

  // Test Register (if endpoint exists)
  const registerData = {
    full_name: 'Test User',
    email: 'testuser@example.com',
    password: 'password123',
    employee_id: 'TEST001',
    department: 'IT',
    position: 'Developer',
    phone: '081234567890'
  };

  const registerResult = await makeRequest('POST', '/auth/register', registerData);
  logTest('User Registration', registerResult.success, registerResult.error?.message);

  // Test Login
  const loginData = {
    email: 'testuser@example.com',
    password: 'password123'
  };

  const loginResult = await makeRequest('POST', '/auth/login', loginData);
  logTest('User Login', loginResult.success, loginResult.error?.message);

  if (loginResult.success && loginResult.data?.data?.token) {
    authToken = loginResult.data.data.token;
    testUserId = loginResult.data.data.user.id;
    console.log(`   Token received: ${authToken.substring(0, 20)}...`.gray);
  }

  // Test Reset Password Request
  const resetPasswordData = {
    email: 'testuser@example.com'
  };

  const resetResult = await makeRequest('POST', '/auth/forgot-password', resetPasswordData);
  logTest('Forgot Password Request', resetResult.success || resetResult.status === 404, resetResult.error?.message);

  return loginResult.success;
};

// Test Attendance Endpoints
const testAttendanceEndpoints = async () => {
  console.log('\n📅 Testing Attendance Endpoints'.cyan.bold);
  console.log('='.repeat(50).cyan);

  if (!authToken) {
    console.log('❌ Skipping attendance tests - no auth token'.red);
    return;
  }

  // Test Get Today's Attendance
  const todayResult = await makeRequest('GET', '/attendance/today', null, authToken);
  logTest('Get Today Attendance', todayResult.success, todayResult.error?.message);

  // Test Check-in (requires QR code - will fail but should return proper error)
  const checkinData = {
    qr_code: 'TEST_QR_CODE',
    location: 'Office Main Building',
    notes: 'Test check-in',
    latitude: -6.200000,
    longitude: 106.816666
  };

  const checkinResult = await makeRequest('POST', '/attendance/checkin', checkinData, authToken);
  logTest('Check-in Attempt', checkinResult.status === 400, 'Expected QR code validation error');

  // Test Get Attendance History
  const historyResult = await makeRequest('GET', '/attendance/history?limit=5', null, authToken);
  logTest('Get Attendance History', historyResult.success, historyResult.error?.message);

  // Test Get Attendance Summary
  const summaryResult = await makeRequest('GET', '/attendance/summary', null, authToken);
  logTest('Get Attendance Summary', summaryResult.success, summaryResult.error?.message);

  // Test Get Attendance Statistics
  const statsResult = await makeRequest('GET', '/attendance/statistics?period=week', null, authToken);
  logTest('Get Attendance Statistics', statsResult.success, statsResult.error?.message);

  // Test Get Attendance Insights
  const insightsResult = await makeRequest('GET', '/attendance/insights?days=30', null, authToken);
  logTest('Get Attendance Insights', insightsResult.success, insightsResult.error?.message);

  // Test Leave Request
  const leaveData = {
    leave_type: 'annual',
    start_date: '2025-10-10',
    end_date: '2025-10-11',
    reason: 'Test leave request'
  };

  const leaveResult = await makeRequest('POST', '/attendance/leave-request', leaveData, authToken);
  logTest('Submit Leave Request', leaveResult.success, leaveResult.error?.message);

  // Test Get Leave Requests
  const getLeaveResult = await makeRequest('GET', '/attendance/leave-requests', null, authToken);
  logTest('Get Leave Requests', getLeaveResult.success, getLeaveResult.error?.message);
};

// Test Admin Endpoints (requires admin token)
const testAdminEndpoints = async () => {
  console.log('\n👨‍💼 Testing Admin Endpoints'.cyan.bold);
  console.log('='.repeat(50).cyan);

  // Try to login as admin (this might fail if no admin user exists)
  const adminLoginData = {
    email: 'admin@bpr.com',
    password: 'admin123'
  };

  const adminLoginResult = await makeRequest('POST', '/auth/login', adminLoginData);
  
  if (adminLoginResult.success && adminLoginResult.data?.data?.token) {
    adminToken = adminLoginResult.data.data.token;
    console.log(`   Admin token received: ${adminToken.substring(0, 20)}...`.gray);
  }

  if (!adminToken) {
    console.log('❌ Skipping admin tests - no admin token (try creating admin user first)'.yellow);
    return;
  }

  // Test Get Users
  const usersResult = await makeRequest('GET', '/admin/users?page=1&limit=10', null, adminToken);
  logTest('Get Users List', usersResult.success, usersResult.error?.message);

  // Test Get Dashboard Stats
  const dashStatsResult = await makeRequest('GET', '/admin/dashboard-stats', null, adminToken);
  logTest('Get Dashboard Statistics', dashStatsResult.success, dashStatsResult.error?.message);

  // Test Get Attendance Reports
  const reportsResult = await makeRequest('GET', '/admin/attendance-reports', null, adminToken);
  logTest('Get Attendance Reports', reportsResult.success, reportsResult.error?.message);

  // Test Get Leave Requests (Admin)
  const adminLeaveResult = await makeRequest('GET', '/admin/leave-requests', null, adminToken);
  logTest('Get Leave Requests (Admin)', adminLeaveResult.success, adminLeaveResult.error?.message);

  // Test Generate QR Code
  const qrData = {
    location: 'Test Office Location'
  };

  const qrResult = await makeRequest('POST', '/admin/generate-qr', qrData, adminToken);
  logTest('Generate QR Code', qrResult.success, qrResult.error?.message);

  // Test Get QR Codes
  const getQrResult = await makeRequest('GET', '/admin/qr-codes', null, adminToken);
  logTest('Get QR Codes List', getQrResult.success, getQrResult.error?.message);
};

// Test Dashboard Endpoints
const testDashboardEndpoints = async () => {
  console.log('\n📊 Testing Dashboard Endpoints'.cyan.bold);
  console.log('='.repeat(50).cyan);

  if (!authToken) {
    console.log('❌ Skipping dashboard tests - no auth token'.red);
    return;
  }

  // Test User Dashboard
  const userDashResult = await makeRequest('GET', '/dashboard/user', null, authToken);
  logTest('Get User Dashboard', userDashResult.success, userDashResult.error?.message);

  // Test User Activity
  const userActivityResult = await makeRequest('GET', '/dashboard/user/activity?period=week', null, authToken);
  logTest('Get User Activity', userActivityResult.success, userActivityResult.error?.message);

  // Test Attendance Chart Widget
  const chartResult = await makeRequest('GET', '/dashboard/widgets/attendance-chart?period=week', null, authToken);
  logTest('Get Attendance Chart Widget', chartResult.success, chartResult.error?.message);

  // Test Quick Stats Widget
  const quickStatsResult = await makeRequest('GET', '/dashboard/widgets/quick-stats', null, authToken);
  logTest('Get Quick Stats Widget', quickStatsResult.success, quickStatsResult.error?.message);

  // Test Recent Activities Widget
  const activitiesResult = await makeRequest('GET', '/dashboard/widgets/recent-activities?limit=10', null, authToken);
  logTest('Get Recent Activities Widget', activitiesResult.success, activitiesResult.error?.message);

  // Test Admin Dashboard (if admin token available)
  if (adminToken) {
    const adminDashResult = await makeRequest('GET', '/dashboard/admin', null, adminToken);
    logTest('Get Admin Dashboard', adminDashResult.success, adminDashResult.error?.message);

    const deptStatsResult = await makeRequest('GET', '/dashboard/admin/departments', null, adminToken);
    logTest('Get Department Statistics', deptStatsResult.success, deptStatsResult.error?.message);

    const realtimeResult = await makeRequest('GET', '/dashboard/realtime/attendance', null, adminToken);
    logTest('Get Real-time Attendance', realtimeResult.success, realtimeResult.error?.message);
  }
};

// Test Error Handling
const testErrorHandling = async () => {
  console.log('\n🛡️ Testing Error Handling'.cyan.bold);
  console.log('='.repeat(50).cyan);

  // Test unauthorized access
  const unauthorizedResult = await makeRequest('GET', '/admin/users');
  logTest('Unauthorized Access Protection', unauthorizedResult.status === 401, 'Should return 401');

  // Test invalid token
  const invalidTokenResult = await makeRequest('GET', '/attendance/today', null, 'invalid_token');
  logTest('Invalid Token Protection', invalidTokenResult.status === 401, 'Should return 401');

  // Test invalid endpoints
  const invalidEndpointResult = await makeRequest('GET', '/nonexistent-endpoint');
  logTest('Invalid Endpoint Handling', invalidEndpointResult.status === 404, 'Should return 404');

  // Test malformed data
  const malformedResult = await makeRequest('POST', '/auth/login', { invalid: 'data' });
  logTest('Malformed Data Handling', !malformedResult.success, 'Should reject invalid data');
};

// Main test runner
const runAllTests = async () => {
  console.log('🧪 BPR Absence Backend API Test Suite'.rainbow.bold);
  console.log('='.repeat(60).rainbow);
  console.log(`📅 Test Date: ${new Date().toISOString()}`.gray);
  console.log(`🌐 Base URL: ${BASE_URL}`.gray);
  console.log('\n🚀 Starting comprehensive API tests...'.green.bold);

  try {
    // Run all test suites
    const authSuccess = await testAuthEndpoints();
    await testAttendanceEndpoints();
    await testAdminEndpoints();
    await testDashboardEndpoints();
    await testErrorHandling();

    // Print final results
    console.log('\n📋 Test Results Summary'.rainbow.bold);
    console.log('='.repeat(60).rainbow);
    console.log(`✅ Passed: ${testResults.passed}`.green.bold);
    console.log(`❌ Failed: ${testResults.failed}`.red.bold);
    console.log(`📊 Total:  ${testResults.total}`.blue.bold);
    
    const successRate = ((testResults.passed / testResults.total) * 100).toFixed(1);
    console.log(`🎯 Success Rate: ${successRate}%`.yellow.bold);

    if (testResults.failed > 0) {
      console.log('\n⚠️ Failed Tests:'.red.bold);
      testResults.details
        .filter(test => !test.passed)
        .forEach(test => {
          console.log(`   • ${test.name}`.red);
          if (test.details) console.log(`     ${test.details}`.gray);
        });
    }

    console.log('\n🏁 Test Suite Complete!'.green.bold);
    
    if (successRate >= 80) {
      console.log('🎉 Backend API is functioning well!'.green);
    } else if (successRate >= 60) {
      console.log('⚠️ Backend API has some issues that need attention.'.yellow);
    } else {
      console.log('🚨 Backend API requires immediate attention.'.red);
    }

  } catch (error) {
    console.error('💥 Test suite crashed:'.red.bold, error.message);
  }
};

// Export for use as module or run directly
if (require.main === module) {
  runAllTests();
}

module.exports = { runAllTests, testResults };