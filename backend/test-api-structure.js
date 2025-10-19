const axios = require('axios');

// Test API endpoints to see exact response structure
async function testApiStructure() {
  try {
    console.log('🧪 TESTING API RESPONSE STRUCTURE');
    console.log('=================================\n');

    // First login to get token
    const loginResponse = await axios.post('http://localhost:3000/api/auth/login', {
      email: 'admin@gmail.com',
      password: '123456'
    });

    if (!loginResponse.data.success) {
      console.log('❌ Login failed:', loginResponse.data);
      return;
    }

    const token = loginResponse.data.data.token;
    console.log('✅ Login successful\n');

    const headers = {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    };

    // Test assignments endpoint
    console.log('📋 Testing /api/assignments...');
    try {
      const assignmentsResponse = await axios.get('http://localhost:3000/api/assignments', { headers });
      console.log('Status:', assignmentsResponse.status);
      console.log('Response structure:');
      console.log('- success:', assignmentsResponse.data.success);
      console.log('- message:', assignmentsResponse.data.message);
      console.log('- data keys:', Object.keys(assignmentsResponse.data.data || {}));
      console.log('- assignment count:', assignmentsResponse.data.data?.assignments?.length || 0);
      if (assignmentsResponse.data.data?.assignments?.length > 0) {
        console.log('- first assignment keys:', Object.keys(assignmentsResponse.data.data.assignments[0]));
      }
    } catch (error) {
      console.log('❌ Assignments error:', error.response?.data || error.message);
    }

    console.log('\n📄 Testing /api/letters/pending...');
    try {
      const pendingResponse = await axios.get('http://localhost:3000/api/letters/pending', { headers });
      console.log('Status:', pendingResponse.status);
      console.log('Response structure:');
      console.log('- success:', pendingResponse.data.success);
      console.log('- message:', pendingResponse.data.message);
      console.log('- data keys:', Object.keys(pendingResponse.data.data || {}));
      console.log('- letter count:', pendingResponse.data.data?.letters?.length || 0);
    } catch (error) {
      console.log('❌ Pending letters error:', error.response?.data || error.message);
    }

    console.log('\n📨 Testing /api/letters/received...');
    try {
      const receivedResponse = await axios.get('http://localhost:3000/api/letters/received', { headers });
      console.log('Status:', receivedResponse.status);
      console.log('Response structure:');
      console.log('- success:', receivedResponse.data.success);
      console.log('- message:', receivedResponse.data.message);
      console.log('- data keys:', Object.keys(receivedResponse.data.data || receivedResponse.data));
      console.log('- letter count:', receivedResponse.data.data?.letters?.length || receivedResponse.data.letters?.length || 0);
    } catch (error) {
      console.log('❌ Received letters error:', error.response?.data || error.message);
    }

  } catch (error) {
    console.log('❌ Test failed:', error.message);
  }
}

testApiStructure();