const axios = require('axios');

async function testAPIEndpoint() {
  try {
    console.log('🔍 Testing admin users endpoint...');
    
    const response = await axios.get('http://localhost:3000/api/admin/users', {
      params: {
        page: 1,
        limit: 5
      },
      headers: {
        'Content-Type': 'application/json'
      }
    });
    
    console.log('✅ Response Status:', response.status);
    console.log('📋 Response Headers:', response.headers);
    console.log('📊 Response Data:');
    console.log(JSON.stringify(response.data, null, 2));
    
    // Check structure
    console.log('\n🔍 Structure Analysis:');
    console.log('- Response type:', typeof response.data);
    console.log('- Keys:', Object.keys(response.data));
    
    if (response.data.success) {
      console.log('- Success field:', response.data.success);
    }
    
    if (response.data.data) {
      console.log('- Data field keys:', Object.keys(response.data.data));
    }
    
    if (response.data.users) {
      console.log('- Direct users array length:', response.data.users.length);
    }
    
  } catch (error) {
    console.error('❌ Error testing endpoint:');
    console.error('- Status:', error.response?.status);
    console.error('- Data:', error.response?.data);
    console.error('- Message:', error.message);
  }
}

testAPIEndpoint();