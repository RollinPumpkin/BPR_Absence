// Use built-in fetch for newer Node.js versions
// If this doesn't work, we'll use a different approach

async function testEndpoints() {
  try {
    console.log('🔍 Testing API endpoints after fixes...\n');
    
    // Test login with admin@gmail.com
    console.log('🔐 Testing login with admin@gmail.com...');
    const loginResponse = await fetch('http://localhost:3000/api/auth/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: 'admin@gmail.com',
        password: '123456'
      })
    });
    
    const loginData = await loginResponse.json();
    console.log('Login response:', loginData);
    
    if (!loginData.success) {
      console.log('❌ Login failed, trying different password...');
      
      // Try with different password
      const loginResponse2 = await fetch('http://localhost:3000/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          email: 'admin@gmail.com',
          password: 'password123'
        })
      });
      
      const loginData2 = await loginResponse2.json();
      console.log('Login response with password123:', loginData2);
      
      if (!loginData2.success) {
        console.log('❌ Still failed, trying superadmin@gmail.com...');
        
        const loginResponse3 = await fetch('http://localhost:3000/api/auth/login', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            email: 'superadmin@gmail.com',
            password: 'admin123'
          })
        });
        
        const loginData3 = await loginResponse3.json();
        console.log('Login response with superadmin@gmail.com:', loginData3);
        
        if (!loginData3.success) {
          console.log('❌ All login attempts failed. Stopping test.');
          return;
        }
        
        var token = loginData3.data.token;
        console.log('✅ Login successful with superadmin@gmail.com');
      } else {
        var token = loginData2.data.token;
        console.log('✅ Login successful with admin@gmail.com/password123');
      }
    } else {
      var token = loginData.data.token;
      console.log('✅ Login successful with admin@gmail.com/admin123');
    }
    
    console.log('\n📨 Testing /api/letters/received endpoint...');
    const receivedResponse = await fetch('http://localhost:3000/api/letters/received?limit=10', {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    
    const receivedData = await receivedResponse.json();
    console.log('Received letters status:', receivedResponse.status);
    console.log('Received letters response:', receivedData);
    
    console.log('\n📋 Testing /api/assignments endpoint...');
    const assignmentsResponse = await fetch('http://localhost:3000/api/assignments?limit=10', {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    
    const assignmentsData = await assignmentsResponse.json();
    console.log('Assignments status:', assignmentsResponse.status);
    console.log('Assignments response:', assignmentsData);
    
    console.log('\n✅ All tests completed!');
    
  } catch (error) {
    console.error('❌ Test error:', error.message);
  }
}

testEndpoints();