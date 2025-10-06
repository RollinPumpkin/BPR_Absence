const axios = require('axios');
const colors = require('colors');

// Base URL for API
const BASE_URL = 'http://localhost:3000/api';

// Test configuration
let authToken = '';
let testUserId = '';
let adminToken = '';

// Test results tracking
const testResults = {
  total: 0,
  passed: 0,
  failed: 0,
  errors: []
};

// Helper function to log test results
function logTest(testName, success, message = '') {
  testResults.total++;
  if (success) {
    testResults.passed++;
    console.log(`✅ ${testName}`.green);
  } else {
    testResults.failed++;
    testResults.errors.push({ test: testName, error: message });
    console.log(`❌ ${testName}: ${message}`.red);
  }
}

// Helper function to make API requests
async function apiRequest(method, endpoint, data = null, token = null) {
  try {
    const config = {
      method,
      url: `${BASE_URL}${endpoint}`,
      headers: {
        'Content-Type': 'application/json'
      }
    };

    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }

    if (data) {
      config.data = data;
    }

    const response = await axios(config);
    return { success: true, data: response.data, status: response.status };
  } catch (error) {
    return { 
      success: false, 
      error: error.response?.data?.message || error.message,
      status: error.response?.status || 500
    };
  }
}

// Test Authentication Endpoints
async function testAuthEndpoints() {
  console.log('\n🔐 Testing Authentication Endpoints...'.blue.bold);

  // Test user registration (if needed)
  const registerResult = await apiRequest('POST', '/auth/register', {
    full_name: 'Test User',
    email: 'test@example.com',
    phone: '081234567890',
    employee_id: 'EMP001',
    password: 'password123',
    department: 'IT',
    position: 'Developer',
    role: 'employee'
  });

  if (registerResult.success || registerResult.status === 400) {
    logTest('User Registration', true, 'User exists or created successfully');
  } else {
    logTest('User Registration', false, registerResult.error);
  }

  // Test user login
  const loginResult = await apiRequest('POST', '/auth/login', {
    email: 'test@example.com',
    password: 'password123'
  });

  if (loginResult.success) {
    authToken = loginResult.data.data.token;
    testUserId = loginResult.data.data.user.id;
    logTest('User Login', true);
  } else {
    logTest('User Login', false, loginResult.error);
  }

  // Test admin login (try default admin)
  const adminLoginResult = await apiRequest('POST', '/auth/login', {
    email: 'admin@bpr.com',
    password: 'admin123'
  });

  if (adminLoginResult.success) {
    adminToken = adminLoginResult.data.data.token;
    logTest('Admin Login', true);
  } else {
    logTest('Admin Login', false, adminLoginResult.error);
  }

  // Test password reset request
  const resetRequestResult = await apiRequest('POST', '/auth/forgot-password', {
    email: 'test@example.com'
  });

  logTest('Password Reset Request', resetRequestResult.success, 
    resetRequestResult.success ? '' : resetRequestResult.error);
}

// Test Attendance Endpoints
async function testAttendanceEndpoints() {
  console.log('\n📊 Testing Attendance Endpoints...'.blue.bold);

  if (!authToken) {
    console.log('⚠️  Skipping attendance tests - no auth token'.yellow);
    return;
  }

  // Test get today's attendance
  const todayResult = await apiRequest('GET', '/attendance/today', null, authToken);
  logTest('Get Today Attendance', todayResult.success, 
    todayResult.success ? '' : todayResult.error);

  // Test attendance history
  const historyResult = await apiRequest('GET', '/attendance/history?page=1&limit=10', null, authToken);
  logTest('Get Attendance History', historyResult.success, 
    historyResult.success ? '' : historyResult.error);

  // Test attendance summary
  const summaryResult = await apiRequest('GET', '/attendance/summary', null, authToken);
  logTest('Get Attendance Summary', summaryResult.success, 
    summaryResult.success ? '' : summaryResult.error);

  // Test attendance statistics
  const statsResult = await apiRequest('GET', '/attendance/statistics?period=week', null, authToken);
  logTest('Get Attendance Statistics', statsResult.success, 
    statsResult.success ? '' : statsResult.error);

  // Test attendance insights
  const insightsResult = await apiRequest('GET', '/attendance/insights', null, authToken);
  logTest('Get Attendance Insights', insightsResult.success, 
    insightsResult.success ? '' : insightsResult.error);

  // Test leave requests
  const leaveRequestsResult = await apiRequest('GET', '/attendance/leave-requests', null, authToken);
  logTest('Get Leave Requests', leaveRequestsResult.success, 
    leaveRequestsResult.success ? '' : leaveRequestsResult.error);

  // Test submit leave request
  const submitLeaveResult = await apiRequest('POST', '/attendance/leave-request', {
    leave_type: 'annual',
    start_date: '2025-10-15',
    end_date: '2025-10-16',
    reason: 'Test leave request'
  }, authToken);
  logTest('Submit Leave Request', submitLeaveResult.success, 
    submitLeaveResult.success ? '' : submitLeaveResult.error);
}

// Test Admin Endpoints
async function testAdminEndpoints() {
  console.log('\n👨‍💼 Testing Admin Endpoints...'.blue.bold);

  if (!adminToken) {
    console.log('⚠️  Skipping admin tests - no admin token'.yellow);
    return;
  }

  // Test get dashboard stats
  const dashboardStatsResult = await apiRequest('GET', '/admin/dashboard-stats', null, adminToken);
  logTest('Get Dashboard Stats', dashboardStatsResult.success, 
    dashboardStatsResult.success ? '' : dashboardStatsResult.error);

  // Test get users
  const usersResult = await apiRequest('GET', '/admin/users?page=1&limit=10', null, adminToken);
  logTest('Get Users List', usersResult.success, 
    usersResult.success ? '' : usersResult.error);

  // Test get attendance reports
  const reportsResult = await apiRequest('GET', '/admin/attendance-reports', null, adminToken);
  logTest('Get Attendance Reports', reportsResult.success, 
    reportsResult.success ? '' : reportsResult.error);

  // Test get leave requests
  const adminLeaveResult = await apiRequest('GET', '/admin/leave-requests', null, adminToken);
  logTest('Get Admin Leave Requests', adminLeaveResult.success, 
    adminLeaveResult.success ? '' : adminLeaveResult.error);

  // Test get QR codes
  const qrCodesResult = await apiRequest('GET', '/admin/qr-codes', null, adminToken);
  logTest('Get QR Codes', qrCodesResult.success, 
    qrCodesResult.success ? '' : qrCodesResult.error);

  // Test generate QR code
  const generateQRResult = await apiRequest('POST', '/admin/generate-qr', {
    location: 'Test Office'
  }, adminToken);
  logTest('Generate QR Code', generateQRResult.success, 
    generateQRResult.success ? '' : generateQRResult.error);
}

// Test Dashboard Endpoints
async function testDashboardEndpoints() {
  console.log('\n📈 Testing Dashboard Endpoints...'.blue.bold);

  if (!authToken) {
    console.log('⚠️  Skipping dashboard tests - no auth token'.yellow);
    return;
  }

  // Test user dashboard
  const userDashboardResult = await apiRequest('GET', '/dashboard/user', null, authToken);
  logTest('Get User Dashboard', userDashboardResult.success, 
    userDashboardResult.success ? '' : userDashboardResult.error);

  // Test user activity
  const userActivityResult = await apiRequest('GET', '/dashboard/user/activity?period=week', null, authToken);
  logTest('Get User Activity', userActivityResult.success, 
    userActivityResult.success ? '' : userActivityResult.error);

  // Test quick stats widget
  const quickStatsResult = await apiRequest('GET', '/dashboard/widgets/quick-stats', null, authToken);
  logTest('Get Quick Stats Widget', quickStatsResult.success, 
    quickStatsResult.success ? '' : quickStatsResult.error);

  // Test attendance chart widget
  const attendanceChartResult = await apiRequest('GET', '/dashboard/widgets/attendance-chart?period=week', null, authToken);
  logTest('Get Attendance Chart Widget', attendanceChartResult.success, 
    attendanceChartResult.success ? '' : attendanceChartResult.error);

  // Test recent activities widget
  const recentActivitiesResult = await apiRequest('GET', '/dashboard/widgets/recent-activities', null, authToken);
  logTest('Get Recent Activities Widget', recentActivitiesResult.success, 
    recentActivitiesResult.success ? '' : recentActivitiesResult.error);

  // Test admin dashboard (if admin token available)
  if (adminToken) {
    const adminDashboardResult = await apiRequest('GET', '/dashboard/admin', null, adminToken);
    logTest('Get Admin Dashboard', adminDashboardResult.success, 
      adminDashboardResult.success ? '' : adminDashboardResult.error);

    const departmentStatsResult = await apiRequest('GET', '/dashboard/admin/departments', null, adminToken);
    logTest('Get Department Statistics', departmentStatsResult.success, 
      departmentStatsResult.success ? '' : departmentStatsResult.error);

    const realtimeAttendanceResult = await apiRequest('GET', '/dashboard/realtime/attendance', null, adminToken);
    logTest('Get Realtime Attendance', realtimeAttendanceResult.success, 
      realtimeAttendanceResult.success ? '' : realtimeAttendanceResult.error);
  }
}

// Test User Profile Endpoints
async function testUserEndpoints() {
  console.log('\n👤 Testing User Profile Endpoints...'.blue.bold);

  if (!authToken) {
    console.log('⚠️  Skipping user tests - no auth token'.yellow);
    return;
  }

  // Test get user profile
  const profileResult = await apiRequest('GET', '/users/profile', null, authToken);
  logTest('Get User Profile', profileResult.success, 
    profileResult.success ? '' : profileResult.error);

  // Test update user profile
  const updateProfileResult = await apiRequest('PUT', '/users/profile', {
    full_name: 'Test User Updated',
    phone: '081234567891'
  }, authToken);
  logTest('Update User Profile', updateProfileResult.success, 
    updateProfileResult.success ? '' : updateProfileResult.error);
}

// Test Server Health
async function testServerHealth() {
  console.log('\n🏥 Testing Server Health...'.blue.bold);

  // Test health endpoint
  try {
    const response = await axios.get('http://localhost:3000/health');
    logTest('Server Health Check', response.status === 200);
  } catch (error) {
    logTest('Server Health Check', false, error.message);
  }

  // Test API root
  try {
    const response = await axios.get('http://localhost:3000/api');
    logTest('API Root Endpoint', response.status === 200);
  } catch (error) {
    logTest('API Root Endpoint', false, error.message);
  }
}

// Main test function
async function runAllTests() {
  console.log('🚀 Starting Comprehensive Backend API Tests...'.cyan.bold);
  console.log('=' * 60);

  await testServerHealth();
  await testAuthEndpoints();
  await testUserEndpoints();
  await testAttendanceEndpoints();
  await testAdminEndpoints();
  await testDashboardEndpoints();

  // Print final results
  console.log('\n' + '='.repeat(60));
  console.log('📊 Test Results Summary'.cyan.bold);
  console.log('=' * 60);
  console.log(`Total Tests: ${testResults.total}`.white);
  console.log(`Passed: ${testResults.passed}`.green);
  console.log(`Failed: ${testResults.failed}`.red);
  console.log(`Success Rate: ${((testResults.passed / testResults.total) * 100).toFixed(1)}%`.yellow);

  if (testResults.failed > 0) {
    console.log('\n❌ Failed Tests:'.red.bold);
    testResults.errors.forEach((error, index) => {
      console.log(`${index + 1}. ${error.test}: ${error.error}`.red);
    });
  }

  console.log('\n🎉 Testing Complete!'.cyan.bold);
  
  // Return exit code based on results
  process.exit(testResults.failed > 0 ? 1 : 0);
}

// Handle uncaught errors
process.on('uncaughtException', (error) => {
  console.error('💥 Uncaught Exception:', error.message.red);
  process.exit(1);
});

process.on('unhandledRejection', (error) => {
  console.error('💥 Unhandled Rejection:', error.message.red);
  process.exit(1);
});

// Run tests
runAllTests().catch((error) => {
  console.error('💥 Test Runner Error:', error.message.red);
  process.exit(1);
});