const axios = require('axios');

async function testStatsEndpoint() {
  try {
    const loginRes = await axios.post('http://localhost:3000/api/auth/login', {
      email: 'admin@gmail.com', 
      password: '123456'
    });
    
    const token = loginRes.data.data.token;
    
    const statsRes = await axios.get('http://localhost:3000/api/dashboard/stats', {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    
    console.log('✅ Dashboard stats endpoint working!');
    console.log('📊 Response keys:', Object.keys(statsRes.data.data));
    console.log('📊 Today stats:', statsRes.data.data.today_stats);
  } catch (error) {
    console.log('❌ Error:', error.response?.data || error.message);
  }
}

testStatsEndpoint();