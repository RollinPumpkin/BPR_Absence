// Test the exact response structure from the received endpoint
async function testResponseStructure() {
  try {
    console.log('🔍 Testing exact response structure...\n');
    
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
    
    // Test received endpoint
    const receivedResponse = await fetch('http://localhost:3000/api/letters/received?limit=5', {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    
    const receivedData = await receivedResponse.json();
    
    console.log('📨 RECEIVED LETTERS RESPONSE STRUCTURE:');
    console.log('='.repeat(50));
    console.log('Full response:', JSON.stringify(receivedData, null, 2));
    
    console.log('\n📊 Key Structure Check:');
    console.log('receivedData.success:', receivedData.success);
    console.log('receivedData.data exists:', !!receivedData.data);
    console.log('receivedData.data.letters exists:', !!receivedData.data?.letters);
    console.log('receivedData.data.letters length:', receivedData.data?.letters?.length);
    
    if (receivedData.data?.letters?.length > 0) {
      console.log('\n📝 First letter structure:');
      console.log(JSON.stringify(receivedData.data.letters[0], null, 2));
    }
    
  } catch (error) {
    console.error('❌ Test error:', error.message);
  }
}

testResponseStructure();