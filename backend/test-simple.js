const axios = require('axios');

async function testLogin() {
  try {
    console.log('Testing login...');
    
    const response = await axios.post('http://localhost:3000/api/auth/login', {
      email: 'user@bpr.com',
      password: 'user123'
    });
    
    console.log('Login response:', response.data);
    
    if (response.data.success) {
      const token = response.data.data.token;
      console.log('Login successful, token:', token);
      
      // Test profile endpoint
      const profileResponse = await axios.get('http://localhost:3000/api/profile', {
        headers: { Authorization: `Bearer ${token}` }
      });
      
      console.log('Profile response:', profileResponse.data);
    }
    
  } catch (error) {
    console.error('Error:', error.response?.data || error.message);
  }
}

testLogin();