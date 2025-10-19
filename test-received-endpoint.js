async function testReceivedEndpoint() {
  try {
    console.log('🔍 Testing /api/letters/received endpoint...');
    
    // First login to get token
    const loginResponse = await fetch('http://localhost:3000/api/auth/login', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        email: 'user@gmail.com',
        password: 'user123'
      })
    });
    
    const loginData = await loginResponse.json();
    
    if (!loginData.success) {
      console.error('❌ Login failed:', loginData.message);
      return;
    }
    
    const token = loginData.data.token;
    console.log('✅ Login successful, token received');
    
    // Test the received endpoint
    const receivedResponse = await fetch('http://localhost:3000/api/letters/received?limit=50', {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });
    
    const receivedData = await receivedResponse.json();
    
    console.log('📨 Received Letters Response:');
    console.log('Status:', receivedResponse.status);
    console.log('Success:', receivedData.success);
    console.log('Data:', receivedData.data);
    console.log('Letters count:', receivedData.data?.letters?.length || 0);
    
    // Test assignments endpoint too
    const assignmentsResponse = await fetch('http://localhost:3000/api/assignments?limit=50', {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });
    
    const assignmentsData = await assignmentsResponse.json();
    
    console.log('\n📋 Assignments Response:');
    console.log('Status:', assignmentsResponse.status);
    console.log('Success:', assignmentsData.success);
    console.log('Data:', assignmentsData.data);
    console.log('Assignments count:', assignmentsData.data?.assignments?.length || 0);
    
  } catch (error) {
    console.error('❌ Error testing endpoints:', error.message);
  }
}

testReceivedEndpoint();