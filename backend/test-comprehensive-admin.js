const axios = require('axios');

const API_BASE = 'http://localhost:3000/api';
const ADMIN_CREDENTIALS = {
  email: 'admin@gmail.com',
  password: '123456'
};

let authToken = null;

async function login() {
  try {
    console.log('🔐 Logging in as admin...');
    const response = await axios.post(`${API_BASE}/auth/login`, ADMIN_CREDENTIALS);
    
    if (response.data.success && response.data.data.token) {
      authToken = response.data.data.token;
      console.log('✅ Login successful!');
      console.log('👤 User:', response.data.data.user.full_name);
      console.log('🎯 Role:', response.data.data.user.role);
      return true;
    }
    
    console.log('❌ Login failed:', response.data.message);
    return false;
  } catch (error) {
    console.log('❌ Login error:', error.response?.data || error.message);
    return false;
  }
}

async function testEndpoint(method, endpoint, description) {
  try {
    console.log(`\n📡 Testing ${method.toUpperCase()} ${endpoint} - ${description}`);
    
    const config = {
      method: method,
      url: `${API_BASE}${endpoint}`,
      headers: {
        'Authorization': `Bearer ${authToken}`,
        'Content-Type': 'application/json'
      }
    };

    const response = await axios(config);
    
    if (response.data) {
      if (Array.isArray(response.data)) {
        console.log(`✅ SUCCESS - ${response.data.length} items returned`);
        if (response.data.length > 0) {
          console.log(`   📋 Sample: ${JSON.stringify(response.data[0], null, 2).substring(0, 200)}...`);
        }
      } else if (response.data.success !== false) {
        console.log('✅ SUCCESS - Response received');
        console.log(`   📋 Data: ${JSON.stringify(response.data, null, 2).substring(0, 200)}...`);
      } else {
        console.log(`⚠️  API returned error: ${response.data.message}`);
      }
    }
    
    return true;
  } catch (error) {
    console.log(`❌ FAILED - ${error.response?.status} ${error.response?.data?.message || error.message}`);
    return false;
  }
}

async function runAllTests() {
  console.log('🚀 Starting comprehensive admin API access test...\n');
  
  // Login first
  const loginSuccess = await login();
  if (!loginSuccess) {
    console.log('💥 Cannot proceed without valid token');
    return;
  }

  const tests = [
    // Letters endpoints
    ['GET', '/letters', 'Get all letters (admin access)'],
    ['GET', '/letters?status=waiting_approval', 'Get pending letters'],
    
    // Assignment endpoints  
    ['GET', '/assignments', 'Get all assignments (admin access)'],
    ['GET', '/assignments/upcoming', 'Get upcoming assignments'],
    
    // Attendance endpoints
    ['GET', '/attendance', 'Get all attendance records (admin access)'],
    ['GET', '/attendance/today', 'Get today\'s attendance'],
    ['GET', '/attendance/leave-requests', 'Get leave requests'],
    
    // Users endpoints
    ['GET', '/users', 'Get all users (admin only)'],
    
    // Dashboard endpoints (if available)
    ['GET', '/dashboard/stats', 'Get dashboard statistics']
  ];

  let successCount = 0;
  let totalTests = tests.length;

  for (const [method, endpoint, description] of tests) {
    const success = await testEndpoint(method, endpoint, description);
    if (success) successCount++;
    
    // Add small delay between requests
    await new Promise(resolve => setTimeout(resolve, 100));
  }

  console.log(`\n📊 Test Results:`);
  console.log(`✅ Successful: ${successCount}/${totalTests}`);
  console.log(`❌ Failed: ${totalTests - successCount}/${totalTests}`);
  
  if (successCount === totalTests) {
    console.log('🎉 All admin endpoints are accessible!');
  } else {
    console.log('⚠️  Some endpoints may need attention');
  }
}

// Run tests
runAllTests().catch(console.error);