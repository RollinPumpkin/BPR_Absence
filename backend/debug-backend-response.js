// Test what backend actually returns
const axios = require('axios');

async function testBackendResponse() {
  try {
    console.log('🔥 TESTING BACKEND RESPONSE FOR admin@gmail.com');
    console.log('================================================');
    
    const response = await axios.post('http://localhost:3000/api/auth/login', {
      email: 'admin@gmail.com',
      password: '123456'
    });
    
    console.log('📋 RAW RESPONSE:');
    console.log(JSON.stringify(response.data, null, 2));
    
    if (response.data.success && response.data.data && response.data.data.user) {
      const user = response.data.data.user;
      console.log('\n🎯 USER OBJECT ANALYSIS:');
      console.log('Email:', user.email);
      console.log('Role:', user.role);
      console.log('Role type:', typeof user.role);
      console.log('Employee ID:', user.employee_id);
      console.log('Full Name:', user.full_name);
      
      // Test routing logic exactly as implemented
      console.log('\n🔥 ROUTING LOGIC TEST:');
      const userRole = user.role;
      console.log('userRole:', userRole);
      console.log('userRole === "admin":', userRole === 'admin');
      console.log('userRole === "super_admin":', userRole === 'super_admin');
      
      let route = '';
      switch (userRole.toLowerCase()) {
        case 'super_admin':
        case 'admin':
          route = '/admin/dashboard';
          break;
        default:
          route = '/user/dashboard';
          break;
      }
      
      console.log('FINAL ROUTE:', route);
    }
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  }
}

testBackendResponse();