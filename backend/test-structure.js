async function testLettersStructure() {
  try {
    console.log('🔍 Testing detailed letters response structure...\n');
    
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
    
    // Test received endpoint
    console.log('📨 Testing /api/letters/received...');
    const receivedResponse = await fetch('http://localhost:3000/api/letters/received?limit=3', {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    
    const receivedData = await receivedResponse.json();
    console.log('📨 Received Response Structure:');
    console.log(JSON.stringify(receivedData, null, 2));
    
    // Test base letters endpoint
    console.log('\n📨 Testing /api/letters (base endpoint)...');
    const baseResponse = await fetch('http://localhost:3000/api/letters?limit=3', {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    
    const baseData = await baseResponse.json();
    console.log('📨 Base Letters Response Structure:');
    console.log(JSON.stringify(baseData, null, 2));
    
  } catch (error) {
    console.error('❌ Test error:', error.message);
  }
}

testLettersStructure();