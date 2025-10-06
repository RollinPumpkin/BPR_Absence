const axios = require('axios');

async function checkEndpoints() {
  try {
    // Login to get token
    const login = await axios.post('http://localhost:3000/api/auth/login', {
      email: 'admin@bpr.com',
      password: 'admin123'
    });
    
    const token = login.data.data.token;
    console.log('✅ Login successful\n');
    
    const endpoints = [
      { name: 'Attendance', url: '/api/attendance' },
      { name: 'Attendance Statistics', url: '/api/attendance/statistics' },
      { name: 'Admin Attendance', url: '/api/attendance/admin/statistics' },
      { name: 'Users', url: '/api/users' },
      { name: 'Admin Dashboard', url: '/api/admin/dashboard' },
      { name: 'Admin Users', url: '/api/admin/users' },
      { name: 'Letters Statistics', url: '/api/letters/statistics' }
    ];
    
    console.log('Testing endpoints:');
    console.log(''.padEnd(50, '-'));
    
    for (const endpoint of endpoints) {
      try {
        const response = await axios.get(`http://localhost:3000${endpoint.url}`, {
          headers: { Authorization: `Bearer ${token}` }
        });
        console.log(`✅ ${endpoint.name.padEnd(25)} - Status: ${response.status}`);
      } catch (error) {
        console.log(`❌ ${endpoint.name.padEnd(25)} - Error: ${error.response?.status || error.message}`);
      }
    }
    
  } catch (error) {
    console.error('❌ Test failed:', error.response?.data || error.message);
  }
}

checkEndpoints();