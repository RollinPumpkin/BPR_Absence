const axios = require('axios');

async function testLoginAPI() {
  try {
    console.log('🔍 Testing login API...');
    
    const response = await axios.post('http://localhost:3000/api/auth/login', {
      email: 'admin@gmail.com',
      password: '123456'  // Correct password based on hash test
    }, {
      headers: {
        'Content-Type': 'application/json'
      }
    });
    
    console.log('✅ API Response Status:', response.status);
    console.log('✅ API Response Data:');
    console.log(JSON.stringify(response.data, null, 2));
    
    if (response.data.user) {
      console.log('\n📋 User Data Analysis:');
      console.log('👤 Role:', response.data.user.role);
      console.log('🆔 Employee ID:', response.data.user.employee_id);
      console.log('📧 Email:', response.data.user.email);
    }
    
  } catch (error) {
    console.error('❌ API Error:', error.response?.data || error.message);
  }
}

testLoginAPI();