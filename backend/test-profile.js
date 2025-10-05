const axios = require('axios');

const BASE_URL = 'http://localhost:3000/api';

// Test credentials
const testUser = {
  email: 'user@bpr.com',
  password: 'user123'
};

const testAdmin = {
  email: 'admin@bpr.com',
  password: 'admin123'
};

let userToken = '';
let adminToken = '';
let testUserId = '';

// Test counters
let totalTests = 0;
let passedTests = 0;
let failedTests = 0;

function logTest(testName, passed, error = null) {
  totalTests++;
  if (passed) {
    passedTests++;
    console.log(`✅ ${testName}`);
  } else {
    failedTests++;
    console.log(`❌ ${testName}`);
    if (error) {
      console.log(`   Error: ${error}`);
    }
  }
}

async function setupAuth() {
  try {
    console.log('🔐 Setting up Authentication...\n');

    // Login as user
    try {
      const userLoginResponse = await axios.post(`${BASE_URL}/auth/login`, testUser);
      userToken = userLoginResponse.data.data.token;
      logTest('User Login', !!userToken);
    } catch (error) {
      console.error('User login error:', error.response?.data || error.message);
      logTest('User Login', false, error.response?.data?.message || error.message);
    }

    // Login as admin
    try {
      const adminLoginResponse = await axios.post(`${BASE_URL}/auth/login`, testAdmin);
      adminToken = adminLoginResponse.data.data.token;
      logTest('Admin Login', !!adminToken);
    } catch (error) {
      console.error('Admin login error:', error.response?.data || error.message);
      logTest('Admin Login', false, error.response?.data?.message || error.message);
    }

    if (!userToken || !adminToken) {
      console.log('Authentication failed, cannot continue tests');
      return;
    }

    // Get user profile to get user ID
    try {
      const profileResponse = await axios.get(`${BASE_URL}/profile`, {
        headers: { Authorization: `Bearer ${userToken}` }
      });
      testUserId = profileResponse.data.data.profile.id;
      console.log('User ID obtained:', testUserId);
    } catch (error) {
      console.error('Get profile error:', error.response?.data || error.message);
    }

  } catch (error) {
    console.error('❌ Auth setup failed:', error.response?.data || error.message);
    process.exit(1);
  }
}

async function testProfileEndpoints() {
  console.log('\n👤 Testing Profile Endpoints...\n');

  // Test 1: Get current user profile
  try {
    const response = await axios.get(`${BASE_URL}/profile`, {
      headers: { Authorization: `Bearer ${userToken}` }
    });
    
    const profile = response.data.data.profile;
    logTest('Get Current User Profile', 
      response.status === 200 && 
      profile && 
      profile.id && 
      profile.email === testUser.email &&
      !profile.password // Should not expose password
    );
  } catch (error) {
    logTest('Get Current User Profile', false, error.response?.data?.message || error.message);
  }

  // Test 2: Update user profile
  try {
    const updateData = {
      full_name: 'Updated Test User',
      phone: '081234567890',
      address: 'Jl. Test Update No. 123',
      emergency_contact: 'Emergency Contact',
      emergency_phone: '087654321098'
    };

    const response = await axios.put(`${BASE_URL}/profile`, updateData, {
      headers: { Authorization: `Bearer ${userToken}` }
    });

    const updatedProfile = response.data.data.profile;
    logTest('Update User Profile', 
      response.status === 200 && 
      updatedProfile.full_name === updateData.full_name &&
      updatedProfile.phone === updateData.phone
    );
  } catch (error) {
    logTest('Update User Profile', false, error.response?.data?.message || error.message);
  }

  // Test 3: Change password
  try {
    const passwordData = {
      current_password: testUser.password,
      new_password: 'newpassword123',
      confirm_password: 'newpassword123'
    };

    const response = await axios.put(`${BASE_URL}/profile/password`, passwordData, {
      headers: { Authorization: `Bearer ${userToken}` }
    });

    logTest('Change Password', response.status === 200);

    // Update test user password for next tests
    testUser.password = 'newpassword123';
  } catch (error) {
    logTest('Change Password', false, error.response?.data?.message || error.message);
  }

  // Test 4: Change password with wrong current password
  try {
    const passwordData = {
      current_password: 'wrongpassword',
      new_password: 'newpassword456',
      confirm_password: 'newpassword456'
    };

    const response = await axios.put(`${BASE_URL}/profile/password`, passwordData, {
      headers: { Authorization: `Bearer ${userToken}` }
    });

    logTest('Change Password - Wrong Current Password', false, 'Should have failed');
  } catch (error) {
    logTest('Change Password - Wrong Current Password', error.response?.status === 400);
  }

  // Test 5: Change password with mismatched passwords
  try {
    const passwordData = {
      current_password: testUser.password,
      new_password: 'newpassword456',
      confirm_password: 'differentpassword'
    };

    const response = await axios.put(`${BASE_URL}/profile/password`, passwordData, {
      headers: { Authorization: `Bearer ${userToken}` }
    });

    logTest('Change Password - Mismatched Passwords', false, 'Should have failed');
  } catch (error) {
    logTest('Change Password - Mismatched Passwords', error.response?.status === 400);
  }

  // Test 6: Delete profile picture (even if no picture exists)
  try {
    const response = await axios.delete(`${BASE_URL}/profile/picture`, {
      headers: { Authorization: `Bearer ${userToken}` }
    });

    logTest('Delete Profile Picture', response.status === 200);
  } catch (error) {
    logTest('Delete Profile Picture', false, error.response?.data?.message || error.message);
  }
}

async function testAdminProfileEndpoints() {
  console.log('\n👨‍💼 Testing Admin Profile Endpoints...\n');

  // Test 1: Get user profile by ID (Admin only)
  try {
    const response = await axios.get(`${BASE_URL}/profile/user/${testUserId}`, {
      headers: { Authorization: `Bearer ${adminToken}` }
    });

    const profile = response.data.data.profile;
    logTest('Get User Profile By ID (Admin)', 
      response.status === 200 && 
      profile && 
      profile.id === testUserId &&
      !profile.password
    );
  } catch (error) {
    logTest('Get User Profile By ID (Admin)', false, error.response?.data?.message || error.message);
  }

  // Test 2: Update user profile by ID (Admin only)
  try {
    const updateData = {
      position: 'Senior Test Engineer',
      department: 'IT Testing',
      salary: 8000000
    };

    const response = await axios.put(`${BASE_URL}/profile/user/${testUserId}`, updateData, {
      headers: { Authorization: `Bearer ${adminToken}` }
    });

    const updatedProfile = response.data.data.profile;
    logTest('Update User Profile By ID (Admin)', 
      response.status === 200 && 
      updatedProfile.position === updateData.position &&
      updatedProfile.department === updateData.department
    );
  } catch (error) {
    logTest('Update User Profile By ID (Admin)', false, error.response?.data?.message || error.message);
  }

  // Test 3: Get all users (Admin only)
  try {
    const response = await axios.get(`${BASE_URL}/profile/users`, {
      headers: { Authorization: `Bearer ${adminToken}` }
    });

    const users = response.data.data.users;
    logTest('Get All Users (Admin)', 
      response.status === 200 && 
      Array.isArray(users) &&
      users.length > 0 &&
      users.every(user => !user.password)
    );
  } catch (error) {
    logTest('Get All Users (Admin)', false, error.response?.data?.message || error.message);
  }

  // Test 4: Get users with filtering
  try {
    const response = await axios.get(`${BASE_URL}/profile/users?department=IT Testing&status=active`, {
      headers: { Authorization: `Bearer ${adminToken}` }
    });

    logTest('Get Users with Filtering (Admin)', response.status === 200);
  } catch (error) {
    logTest('Get Users with Filtering (Admin)', false, error.response?.data?.message || error.message);
  }

  // Test 5: Search users
  try {
    const response = await axios.get(`${BASE_URL}/profile/users?search=test`, {
      headers: { Authorization: `Bearer ${adminToken}` }
    });

    logTest('Search Users (Admin)', response.status === 200);
  } catch (error) {
    logTest('Search Users (Admin)', false, error.response?.data?.message || error.message);
  }

  // Test 6: Reset user password (Admin only)
  try {
    const resetData = {
      new_password: 'resetpassword123'
    };

    const response = await axios.put(`${BASE_URL}/profile/user/${testUserId}/reset-password`, resetData, {
      headers: { Authorization: `Bearer ${adminToken}` }
    });

    logTest('Reset User Password (Admin)', response.status === 200);

    // Update test user password
    testUser.password = 'resetpassword123';
  } catch (error) {
    logTest('Reset User Password (Admin)', false, error.response?.data?.message || error.message);
  }
}

async function testAccessControl() {
  console.log('\n🔒 Testing Access Control...\n');

  // Test 1: Regular user trying to access admin endpoints
  try {
    const response = await axios.get(`${BASE_URL}/profile/users`, {
      headers: { Authorization: `Bearer ${userToken}` }
    });

    logTest('User Access to Admin Endpoint', false, 'Should have been denied');
  } catch (error) {
    logTest('User Access to Admin Endpoint', error.response?.status === 403);
  }

  // Test 2: User trying to get another user's profile
  try {
    // Create a dummy user ID
    const dummyUserId = 'dummy123';
    const response = await axios.get(`${BASE_URL}/profile/user/${dummyUserId}`, {
      headers: { Authorization: `Bearer ${userToken}` }
    });

    logTest('User Access to Other User Profile', false, 'Should have been denied');
  } catch (error) {
    logTest('User Access to Other User Profile', error.response?.status === 403);
  }

  // Test 3: Invalid token
  try {
    const response = await axios.get(`${BASE_URL}/profile`, {
      headers: { Authorization: 'Bearer invalid_token' }
    });

    logTest('Invalid Token Access', false, 'Should have been denied');
  } catch (error) {
    logTest('Invalid Token Access', error.response?.status === 401);
  }

  // Test 4: No token
  try {
    const response = await axios.get(`${BASE_URL}/profile`);

    logTest('No Token Access', false, 'Should have been denied');
  } catch (error) {
    logTest('No Token Access', error.response?.status === 401);
  }
}

async function testValidation() {
  console.log('\n✅ Testing Validation...\n');

  // Test 1: Invalid profile update data
  try {
    const invalidData = {
      full_name: 'A', // Too short
      email: 'invalid-email', // Invalid email format
      phone: '12345678901234567890123456789' // Too long
    };

    const response = await axios.put(`${BASE_URL}/profile`, invalidData, {
      headers: { Authorization: `Bearer ${userToken}` }
    });

    logTest('Invalid Profile Data Validation', false, 'Should have been rejected');
  } catch (error) {
    logTest('Invalid Profile Data Validation', error.response?.status === 400);
  }

  // Test 2: Short password validation
  try {
    const shortPasswordData = {
      current_password: testUser.password,
      new_password: '123',
      confirm_password: '123'
    };

    const response = await axios.put(`${BASE_URL}/profile/password`, shortPasswordData, {
      headers: { Authorization: `Bearer ${userToken}` }
    });

    logTest('Short Password Validation', false, 'Should have been rejected');
  } catch (error) {
    logTest('Short Password Validation', error.response?.status === 400);
  }

  // Test 3: Admin reset password validation
  try {
    const shortPasswordData = {
      new_password: '123' // Too short
    };

    const response = await axios.put(`${BASE_URL}/profile/user/${testUserId}/reset-password`, shortPasswordData, {
      headers: { Authorization: `Bearer ${adminToken}` }
    });

    logTest('Admin Reset Short Password Validation', false, 'Should have been rejected');
  } catch (error) {
    logTest('Admin Reset Short Password Validation', error.response?.status === 400);
  }
}

async function testErrorHandling() {
  console.log('\n🚨 Testing Error Handling...\n');

  // Test 1: Get non-existent user profile
  try {
    const fakeUserId = 'nonexistent123';
    const response = await axios.get(`${BASE_URL}/profile/user/${fakeUserId}`, {
      headers: { Authorization: `Bearer ${adminToken}` }
    });

    logTest('Get Non-existent User Profile', false, 'Should return 404');
  } catch (error) {
    logTest('Get Non-existent User Profile', error.response?.status === 404);
  }

  // Test 2: Update non-existent user profile
  try {
    const fakeUserId = 'nonexistent123';
    const updateData = { full_name: 'Test Update' };
    
    const response = await axios.put(`${BASE_URL}/profile/user/${fakeUserId}`, updateData, {
      headers: { Authorization: `Bearer ${adminToken}` }
    });

    logTest('Update Non-existent User Profile', false, 'Should return 404');
  } catch (error) {
    logTest('Update Non-existent User Profile', error.response?.status === 404);
  }

  // Test 3: Reset password for non-existent user
  try {
    const fakeUserId = 'nonexistent123';
    const resetData = { new_password: 'newpassword123' };
    
    const response = await axios.put(`${BASE_URL}/profile/user/${fakeUserId}/reset-password`, resetData, {
      headers: { Authorization: `Bearer ${adminToken}` }
    });

    logTest('Reset Password Non-existent User', false, 'Should return 404');
  } catch (error) {
    logTest('Reset Password Non-existent User', error.response?.status === 404);
  }
}

async function runAllTests() {
  console.log('🚀 Starting Profile Management API Tests...\n');

  try {
    await setupAuth();
    await testProfileEndpoints();
    await testAdminProfileEndpoints();
    await testAccessControl();
    await testValidation();
    await testErrorHandling();

  } catch (error) {
    console.error('Test execution failed:', error);
  }

  // Print summary
  console.log('\n============================================================');
  console.log('📊 Test Results Summary');
  console.log('============================================================');
  console.log(`Total Tests: ${totalTests}`);
  console.log(`Passed: ${passedTests}`);
  console.log(`Failed: ${failedTests}`);
  console.log(`Success Rate: ${((passedTests / totalTests) * 100).toFixed(1)}%`);
  console.log('\n🎉 Profile Testing Complete!');
}

// Run tests
runAllTests();