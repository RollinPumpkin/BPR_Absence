const axios = require('axios');
require('dotenv').config();

const BASE_URL = 'http://localhost:3000/api';

async function debugEndpoints() {
  try {
    console.log('🔍 Debugging Failed Endpoints...\n');

    // Get fresh tokens
    console.log('1. Getting fresh authentication tokens...');
    
    // User login
    const userLogin = await axios.post(`${BASE_URL}/auth/login`, {
      email: 'test@example.com',
      password: 'password123'
    });
    
    const userToken = userLogin.data.data.token;
    const userId = userLogin.data.data.user.id;
    console.log('✅ User token obtained:', userToken.substring(0, 20) + '...');
    console.log('✅ User ID:', userId);

    // Admin login
    const adminLogin = await axios.post(`${BASE_URL}/auth/login`, {
      email: 'admin@bpr.com',
      password: 'admin123'
    });
    
    const adminToken = adminLogin.data.data.token;
    console.log('✅ Admin token obtained:', adminToken.substring(0, 20) + '...');

    console.log('\n2. Testing failed endpoints one by one...\n');

    // Test 1: Attendance History
    console.log('🔸 Testing Attendance History...');
    try {
      const historyResponse = await axios.get(`${BASE_URL}/attendance/history`, {
        headers: { Authorization: `Bearer ${userToken}` }
      });
      console.log('✅ Attendance History: SUCCESS');
      console.log('   Records found:', historyResponse.data.data.attendance.length);
    } catch (error) {
      console.log('❌ Attendance History: FAILED');
      console.log('   Status:', error.response?.status);
      console.log('   Message:', error.response?.data?.message);
      console.log('   Details:', error.response?.data);
    }

    // Test 2: Attendance Summary
    console.log('\n🔸 Testing Attendance Summary...');
    try {
      const summaryResponse = await axios.get(`${BASE_URL}/attendance/summary`, {
        headers: { Authorization: `Bearer ${userToken}` }
      });
      console.log('✅ Attendance Summary: SUCCESS');
      console.log('   Total days:', summaryResponse.data.data.stats.total_days);
    } catch (error) {
      console.log('❌ Attendance Summary: FAILED');
      console.log('   Status:', error.response?.status);
      console.log('   Message:', error.response?.data?.message);
    }

    // Test 3: Admin Leave Requests
    console.log('\n🔸 Testing Admin Leave Requests...');
    try {
      const leaveResponse = await axios.get(`${BASE_URL}/admin/leave-requests`, {
        headers: { Authorization: `Bearer ${adminToken}` }
      });
      console.log('✅ Admin Leave Requests: SUCCESS');
      console.log('   Leave requests found:', leaveResponse.data.data.leave_requests.length);
    } catch (error) {
      console.log('❌ Admin Leave Requests: FAILED');
      console.log('   Status:', error.response?.status);
      console.log('   Message:', error.response?.data?.message);
    }

    // Test 4: User Dashboard
    console.log('\n🔸 Testing User Dashboard...');
    try {
      const dashboardResponse = await axios.get(`${BASE_URL}/dashboard/user`, {
        headers: { Authorization: `Bearer ${userToken}` }
      });
      console.log('✅ User Dashboard: SUCCESS');
    } catch (error) {
      console.log('❌ User Dashboard: FAILED');
      console.log('   Status:', error.response?.status);
      console.log('   Message:', error.response?.data?.message);
    }

    // Test 5: User Activity
    console.log('\n🔸 Testing User Activity...');
    try {
      const activityResponse = await axios.get(`${BASE_URL}/dashboard/user/activity?period=week`, {
        headers: { Authorization: `Bearer ${userToken}` }
      });
      console.log('✅ User Activity: SUCCESS');
    } catch (error) {
      console.log('❌ User Activity: FAILED');
      console.log('   Status:', error.response?.status);
      console.log('   Message:', error.response?.data?.message);
    }

    // Test 6: Recent Activities Widget
    console.log('\n🔸 Testing Recent Activities Widget...');
    try {
      const recentResponse = await axios.get(`${BASE_URL}/dashboard/widgets/recent-activities?limit=5`, {
        headers: { Authorization: `Bearer ${userToken}` }
      });
      console.log('✅ Recent Activities: SUCCESS');
    } catch (error) {
      console.log('❌ Recent Activities: FAILED');
      console.log('   Status:', error.response?.status);
      console.log('   Message:', error.response?.data?.message);
    }

    // Test 7: Admin Dashboard
    console.log('\n🔸 Testing Admin Dashboard...');
    try {
      const adminDashResponse = await axios.get(`${BASE_URL}/dashboard/admin`, {
        headers: { Authorization: `Bearer ${adminToken}` }
      });
      console.log('✅ Admin Dashboard: SUCCESS');
    } catch (error) {
      console.log('❌ Admin Dashboard: FAILED');
      console.log('   Status:', error.response?.status);
      console.log('   Message:', error.response?.data?.message);
    }

    console.log('\n🎯 Debug completed!');

  } catch (error) {
    console.error('Debug script error:', error.message);
  }
}

debugEndpoints();