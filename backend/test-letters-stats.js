const axios = require('axios');

async function testLetterStats() {
  try {
    // Login admin
    const login = await axios.post('http://localhost:3000/api/auth/login', {
      email: 'admin@bpr.com',
      password: 'admin123'
    });
    
    const token = login.data.data.token;
    console.log('✅ Login successful');
    
    // Test letters statistics
    try {
      const response = await axios.get('http://localhost:3000/api/letters/statistics', {
        headers: { Authorization: `Bearer ${token}` }
      });
      console.log('✅ Letters Statistics:', response.data.success);
      console.log('   Total Letters:', response.data.data.statistics.total_letters);
    } catch (error) {
      console.log('❌ Letters Statistics Error:', error.response?.status, error.response?.data?.message);
    }
    
  } catch (error) {
    console.error('❌ Test failed:', error.response?.data || error.message);
  }
}

testLetterStats();