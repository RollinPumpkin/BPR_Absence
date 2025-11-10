async function testLogin() {
  try {
    console.log('🧪 Testing login endpoint directly...\n');
    
    const response = await fetch('http://localhost:3000/api/auth/login', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        email: 'admin@gmail.com',
        password: '123456'
      })
    });

    const data = await response.json();

    console.log('📊 Response Status:', response.status);
    console.log('📦 Response Data:', JSON.stringify(data, null, 2));
    
    if (data.success) {
      console.log('\n✅ Login successful!');
      console.log('👤 User:', data.data.user.full_name);
      console.log('👑 Role:', data.data.user.role);
      console.log('🆔 Employee ID:', data.data.user.employee_id);
      console.log('🔑 Token:', data.data.token ? 'Received' : 'Missing');
    } else {
      console.log('\n❌ Login failed:', data.message);
    }
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  }
}

testLogin();
