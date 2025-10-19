async function testAssignmentsStructure() {
  try {
    console.log('🔍 Testing assignments response structure...\n');
    
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
    
    // Test assignments endpoint
    console.log('📋 Testing /api/assignments...');
    const assignmentsResponse = await fetch('http://localhost:3000/api/assignments?limit=3', {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    
    const assignmentsData = await assignmentsResponse.json();
    console.log('📋 Assignments Response Structure:');
    console.log(JSON.stringify(assignmentsData, null, 2));
    
  } catch (error) {
    console.error('❌ Test error:', error.message);
  }
}

testAssignmentsStructure();