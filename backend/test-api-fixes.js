const axios = require('axios');
const FormData = require('form-data');

// API Configuration
const BASE_URL = 'http://localhost:3000/api';
const TEST_USER = {
  email: 'user@gmail.com',
  password: '123456'
};

async function testAPIs() {
  console.log('🧪 Testing API fixes...\n');
  
  try {
    // Step 1: Login
    console.log('1. 🔐 Testing login...');
    const loginResponse = await axios.post(`${BASE_URL}/auth/login`, TEST_USER);
    
    console.log('Login response:', JSON.stringify(loginResponse.data, null, 2));
    
    if (!loginResponse.data.success) {
      throw new Error('Login failed');
    }
    
    const token = loginResponse.data.data.token;
    const user = loginResponse.data.data.user;
    console.log('✅ Login successful');
    console.log(`   User: ${user?.email || 'Unknown'}`);
    if (token) {
      console.log(`   Token received: ${token.substring(0, 20)}...`);
    } else {
      console.log('   No token received');
    }
    
    // Headers for authenticated requests
    const headers = {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    };
    
    // Step 2: Test dashboard user endpoint
    console.log('\n2. 📊 Testing dashboard user endpoint...');
    try {
      const dashboardResponse = await axios.get(`${BASE_URL}/dashboard/user`, { headers });
      console.log('✅ Dashboard user: SUCCESS');
      console.log(`   Today's attendance: ${dashboardResponse.data.data.today_attendance ? 'Found' : 'Not found'}`);
    } catch (error) {
      console.log('❌ Dashboard user: FAILED');
      console.log(`   Error: ${error.response?.data?.message || error.message}`);
      if (error.response?.data?.error) {
        console.log(`   Details: ${error.response.data.error}`);
      }
    }
    
    // Step 3: Test user activity endpoint
    console.log('\n3. 📈 Testing user activity endpoint...');
    try {
      const activityResponse = await axios.get(`${BASE_URL}/dashboard/user/activity`, { headers });
      console.log('✅ User activity: SUCCESS');
      console.log(`   Period: ${activityResponse.data.data.period}`);
      console.log(`   Total days worked: ${activityResponse.data.data.attendance_summary.total_days_worked}`);
    } catch (error) {
      console.log('❌ User activity: FAILED');
      console.log(`   Error: ${error.response?.data?.message || error.message}`);
      if (error.response?.data?.error) {
        console.log(`   Details: ${error.response.data.error}`);
      }
    }
    
    // Step 4: Test recent activities
    console.log('\n4. 📋 Testing recent activities endpoint...');
    try {
      const recentResponse = await axios.get(`${BASE_URL}/dashboard/widgets/recent-activities`, { headers });
      console.log('✅ Recent activities: SUCCESS');
      console.log(`   Activities found: ${recentResponse.data.data.length}`);
    } catch (error) {
      console.log('❌ Recent activities: FAILED');
      console.log(`   Error: ${error.response?.data?.message || error.message}`);
      if (error.response?.data?.error) {
        console.log(`   Details: ${error.response.data.error}`);
      }
    }
    
    // Step 5: Test attendance endpoints
    console.log('\n5. ⏰ Testing attendance endpoints...');
    try {
      const attendanceResponse = await axios.get(`${BASE_URL}/attendance/`, { headers });
      console.log('✅ User attendance: SUCCESS');
      console.log(`   Records found: ${attendanceResponse.data.data.length}`);
    } catch (error) {
      console.log('❌ User attendance: FAILED');
      console.log(`   Error: ${error.response?.data?.message || error.message}`);
      if (error.response?.data?.error) {
        console.log(`   Details: ${error.response.data.error}`);
      }
    }
    
    // Test today's attendance
    console.log('\n6. 📅 Testing today\'s attendance...');
    try {
      const todayResponse = await axios.get(`${BASE_URL}/attendance/today`, { headers });
      console.log('✅ Today\'s attendance: SUCCESS');
      console.log(`   Today's record: ${todayResponse.data.data ? 'Found' : 'Not found'}`);
    } catch (error) {
      console.log('❌ Today\'s attendance: FAILED');
      console.log(`   Error: ${error.response?.data?.message || error.message}`);
      if (error.response?.data?.error) {
        console.log(`   Details: ${error.response.data.error}`);
      }
    }
    
  } catch (error) {
    console.error('\n💥 Critical Error:', error.message);
    if (error.response) {
      console.error('Response:', error.response.data);
    }
  }
}

// Run tests
testAPIs().then(() => {
  console.log('\n🏁 API testing completed');
}).catch(console.error);