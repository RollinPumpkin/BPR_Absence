// Test API response format
const axios = require('axios');

async function checkApiResponse() {
  try {
    console.log('🔍 CHECKING API RESPONSE FORMAT');
    console.log('================================');
    
    const response = await axios.post('http://localhost:3000/api/auth/login', {
      email: 'admin@gmail.com',
      password: '123456'
    });
    
    console.log('📋 Full Response:');
    console.log('Status:', response.status);
    console.log('Data:', JSON.stringify(response.data, null, 2));
    
  } catch (error) {
    if (error.response) {
      console.log('❌ Error Response:');
      console.log('Status:', error.response.status);
      console.log('Data:', JSON.stringify(error.response.data, null, 2));
    } else {
      console.log('❌ Error:', error.message);
    }
  }
}

checkApiResponse();