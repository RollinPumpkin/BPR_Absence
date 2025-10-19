async function testPendingEndpoint() {
  try {
    console.log('🔍 Testing /api/letters/pending endpoint...\n');
    
    // Login first
    const loginResponse = await fetch('http://localhost:3000/api/auth/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: 'admin@gmail.com',
        password: '123456'
      })
    });
    
    const loginData = await loginResponse.json();
    const token = loginData.data.token;
    console.log('✅ Login successful\n');
    
    // Test pending endpoint
    console.log('📨 Testing /api/letters/pending...');
    const pendingResponse = await fetch('http://localhost:3000/api/letters/pending?limit=3', {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    
    const pendingData = await pendingResponse.json();
    console.log('📨 Pending Response Status:', pendingResponse.status);
    console.log('📨 Pending Response Structure:');
    console.log(JSON.stringify(pendingData, null, 2));
    
  } catch (error) {
    console.error('❌ Test error:', error.message);
  }
}

testPendingEndpoint();