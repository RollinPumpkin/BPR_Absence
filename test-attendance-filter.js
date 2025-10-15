// Test specific attendance filter endpoint
const fetch = require('node-fetch');

const API_BASE_URL = 'http://localhost:3000/api';
let adminToken = '';

async function testAttendanceFilter() {
  try {
    // First login to get token
    console.log('🔐 Logging in as admin...');
    const loginResponse = await fetch(`${API_BASE_URL}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: 'admin@gmail.com',
        password: '123456'
      })
    });
    
    const loginResult = await loginResponse.json();
    if (!loginResult.success) {
      console.error('❌ Login failed:', loginResult.message);
      return;
    }
    
    adminToken = loginResult.data.token;
    console.log('✅ Login successful');
    
    // Test the problematic endpoint
    console.log('\n🧪 Testing attendance filter endpoint...');
    const filterResponse = await fetch(`${API_BASE_URL}/attendance/admin/all?status=present&page=1&limit=5`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${adminToken}`
      }
    });
    
    console.log('Response status:', filterResponse.status);
    const filterResult = await filterResponse.json();
    console.log('Response body:', JSON.stringify(filterResult, null, 2));
    
  } catch (error) {
    console.error('❌ Test error:', error.message);
  }
}

testAttendanceFilter();