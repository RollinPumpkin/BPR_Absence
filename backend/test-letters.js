const axios = require('axios');
const colors = require('colors');

// Base URL for API
const BASE_URL = 'http://localhost:3000/api';

// Test configuration
let authToken = '';
let adminToken = '';
let testUserId = '';
let letterId = '';

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
    return { success: true, data: response.data };
  } catch (error) {
    return { 
      success: false, 
      error: error.response?.data?.message || error.message,
      status: error.response?.status 
    };
  }
}

// Test Authentication Setup
async function setupAuthentication() {
  console.log('\n🔐 Setting up Authentication...\n'.blue.bold);

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
    return false;
  }

  // Test admin login
  const adminLoginResult = await apiRequest('POST', '/auth/login', {
    email: 'admin@bpr.com',
    password: 'admin123'
  });

  if (adminLoginResult.success) {
    adminToken = adminLoginResult.data.data.token;
    logTest('Admin Login', true);
  } else {
    logTest('Admin Login', false, adminLoginResult.error);
    return false;
  }

  return true;
}

// Test Letters Endpoints
async function testLettersEndpoints() {
  console.log('\n📝 Testing Letters Endpoints...\n'.blue.bold);

  // Test create letter (Admin only)
  const createLetterResult = await apiRequest('POST', '/letters', {
    recipient_id: testUserId,
    subject: 'Employee Performance Review',
    content: 'This is to notify you about your upcoming performance review scheduled for next week. Please prepare all necessary documents and reports.',
    letter_type: 'memo',
    priority: 'normal',
    requires_response: true,
    response_deadline: '2025-10-20'
  }, adminToken);

  if (createLetterResult.success) {
    letterId = createLetterResult.data.data.letter.id;
    logTest('Create Letter', true);
  } else {
    logTest('Create Letter', false, createLetterResult.error);
  }

  // Test get letters list (User view)
  const getLettersResult = await apiRequest('GET', '/letters?page=1&limit=10', null, authToken);
  logTest('Get Letters List (User)', getLettersResult.success, 
    getLettersResult.success ? '' : getLettersResult.error);

  // Test get letters list (Admin view)
  const getLettersAdminResult = await apiRequest('GET', '/letters?page=1&limit=10', null, adminToken);
  logTest('Get Letters List (Admin)', getLettersAdminResult.success, 
    getLettersAdminResult.success ? '' : getLettersAdminResult.error);

  // Test get single letter
  if (letterId) {
    const getLetterResult = await apiRequest('GET', `/letters/${letterId}`, null, authToken);
    logTest('Get Single Letter', getLetterResult.success, 
      getLetterResult.success ? '' : getLetterResult.error);

    // Test submit response
    const responseResult = await apiRequest('POST', `/letters/${letterId}/response`, {
      response_content: 'Thank you for the notification. I will prepare all the necessary documents for the performance review. I look forward to discussing my progress and areas for improvement.'
    }, authToken);
    logTest('Submit Letter Response', responseResult.success, 
      responseResult.success ? '' : responseResult.error);

    // Create another letter for update test (since the first one is now read)
    const createLetterForUpdateResult = await apiRequest('POST', '/letters', {
      recipient_id: testUserId,
      subject: 'Meeting Reminder',
      content: 'This is a reminder about the upcoming team meeting.',
      letter_type: 'memo',
      priority: 'low'
    }, adminToken);

    let updateLetterId = '';
    if (createLetterForUpdateResult.success) {
      updateLetterId = createLetterForUpdateResult.data.data.letter.id;
    }

    // Test update letter (Admin only) - using the new unread letter
    const updateLetterResult = await apiRequest('PUT', `/letters/${updateLetterId}`, {
      priority: 'high',
      content: 'This is a reminder about the upcoming team meeting. Updated: This is now marked as high priority.'
    }, adminToken);
    logTest('Update Letter', updateLetterResult.success, 
      updateLetterResult.success ? '' : updateLetterResult.error);
  }

  // Test get letter templates
  const getTemplatesResult = await apiRequest('GET', '/letters/templates/list', null, adminToken);
  logTest('Get Letter Templates', getTemplatesResult.success, 
    getTemplatesResult.success ? '' : getTemplatesResult.error);

  // Test get letter statistics
  const getStatsResult = await apiRequest('GET', '/letters/stats/overview?period=month', null, authToken);
  logTest('Get Letter Statistics', getStatsResult.success, 
    getStatsResult.success ? '' : getStatsResult.error);

  // Test get letter statistics (Admin)
  const getStatsAdminResult = await apiRequest('GET', '/letters/stats/overview?period=month', null, adminToken);
  logTest('Get Letter Statistics (Admin)', getStatsAdminResult.success, 
    getStatsAdminResult.success ? '' : getStatsAdminResult.error);

  // Test filtering letters
  const filterLettersResult = await apiRequest('GET', '/letters?type=memo&status=read&priority=high', null, adminToken);
  logTest('Filter Letters', filterLettersResult.success, 
    filterLettersResult.success ? '' : filterLettersResult.error);

  // Test search letters
  const searchLettersResult = await apiRequest('GET', '/letters?search=performance', null, authToken);
  logTest('Search Letters', searchLettersResult.success, 
    searchLettersResult.success ? '' : searchLettersResult.error);

  // Test access control (User trying to access admin endpoint)
  const unauthorizedResult = await apiRequest('POST', '/letters', {
    recipient_id: testUserId,
    subject: 'Test',
    content: 'Test content',
    letter_type: 'memo'
  }, authToken);
  logTest('Access Control Test', !unauthorizedResult.success && unauthorizedResult.status === 403, 
    unauthorizedResult.success ? 'Should have been forbidden' : 'Correctly denied access');
}

// Main test runner
async function runTests() {
  console.log('🚀 Starting Letters Management API Tests...\n'.cyan.bold);
  
  const authSuccess = await setupAuthentication();
  if (!authSuccess) {
    console.log('❌ Authentication setup failed. Aborting tests.'.red);
    return;
  }

  await testLettersEndpoints();

  // Print summary
  console.log('\n============================================================'.yellow);
  console.log('📊 Test Results Summary'.cyan.bold);
  console.log('============================================================'.yellow);
  console.log(`Total Tests: ${testResults.total}`);
  console.log(`Passed: ${testResults.passed}`.green);
  console.log(`Failed: ${testResults.failed}`.red);
  console.log(`Success Rate: ${((testResults.passed / testResults.total) * 100).toFixed(1)}%`);

  if (testResults.failed > 0) {
    console.log('\n❌ Failed Tests:'.red.bold);
    testResults.errors.forEach((error, index) => {
      console.log(`${index + 1}. ${error.test}: ${error.error}`.red);
    });
  }

  console.log('\n🎉 Letters Testing Complete!\n'.cyan.bold);
}

// Run the tests
runTests().catch(error => {
  console.error('Test runner error:', error);
});