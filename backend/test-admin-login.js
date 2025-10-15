const axios = require('axios');

async function testAdminLogin() {
  try {
    console.log('🧪 Testing admin login...');
    
    const loginData = {
      email: 'admin@gmail.com',
      password: 'admin123'
    };
    
    console.log('📝 Login request:', loginData);
    
    const response = await axios.post('http://localhost:3000/api/auth/login', loginData);
    
    console.log('\n✅ Login successful!');
    console.log('Response data:', JSON.stringify(response.data, null, 2));
    
    if (response.data.data && response.data.data.token) {
      console.log('\n🎯 Login Summary:');
      console.log(`   User: ${response.data.data.user.full_name}`);
      console.log(`   Email: ${response.data.data.user.email}`);
      console.log(`   Role: ${response.data.data.user.role}`);
      console.log(`   Token: ${response.data.data.token.substring(0, 20)}...`);
    }
    
  } catch (error) {
    console.log('\n❌ Login failed:');
    
    if (error.response) {
      console.log('Status:', error.response.status);
      console.log('Response:', JSON.stringify(error.response.data, null, 2));
    } else {
      console.log('Error:', error.message);
    }
  }
}

testAdminLogin();