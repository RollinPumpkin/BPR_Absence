const axios = require('axios');

const BASE_URL = 'http://localhost:3000';

async function testStatsEndpoint() {
  try {
    console.log('🚀 Testing Employee Statistics Endpoint...\n');
    
    // First login with admin credentials
    console.log('📝 Logging in as admin...');
    const loginResponse = await axios.post(`${BASE_URL}/api/auth/login`, {
      email: 'admin@gmail.com',
      password: '123456'
    });
    
    if (!loginResponse.data.success) {
      console.error('❌ Login failed:', loginResponse.data.message);
      return;
    }
    
    console.log('✅ Login successful!');
    console.log('📄 Full login response:', JSON.stringify(loginResponse.data, null, 2));
    const token = loginResponse.data.data.token;
    console.log('🔑 Token received:', token ? 'YES' : 'NO');
    console.log('🔑 Token value:', token?.substring(0, 20) + '...');
    
    // Test the stats endpoint
    console.log('📊 Testing /users/stats endpoint...');
    const statsResponse = await axios.get(`${BASE_URL}/api/users/stats`, {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });
    
    console.log('✅ Stats Response:');
    console.log('Status:', statsResponse.status);
    console.log('Success:', statsResponse.data.success);
    console.log('Message:', statsResponse.data.message);
    console.log('Data:', JSON.stringify(statsResponse.data.data, null, 2));
    
  } catch (error) {
    console.error('❌ Error:', error.response?.data || error.message);
  }
}

// Run the test
testStatsEndpoint();