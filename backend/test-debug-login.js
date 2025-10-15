const axios = require('axios');

async function testAdminLogin() {
  try {
    console.log('🔐 Testing admin login with backend API...');
    const response = await axios.post('http://localhost:3000/api/auth/login', {
      email: 'admin@gmail.com',
      password: '123456'
    });
    
    console.log('✅ LOGIN SUCCESS');
    console.log('📋 Full Response:', JSON.stringify(response.data, null, 2));
    
    const userData = response.data.data.user;
    console.log('🎯 Role:', userData.role);
    console.log('🆔 Employee ID:', userData.employee_id);
    console.log('📧 Email:', userData.email);
    
    if (userData.role === 'super_admin') {
      console.log('✅ ROLE VERIFICATION: Correctly identified as super_admin');
      console.log('🎯 ROUTING: Should go to → /admin/dashboard');
    } else {
      console.log('❌ ROLE VERIFICATION: Expected super_admin, got', userData.role);
    }
    
    // Test user login too
    console.log('\n🔐 Testing user login...');
    const userResponse = await axios.post('http://localhost:3000/api/auth/login', {
      email: 'user@gmail.com',
      password: '123456'
    });
    
    console.log('✅ USER LOGIN SUCCESS');
    const userUserData = userResponse.data.data.user;
    console.log('🎯 User Role:', userUserData.role);
    console.log('🆔 User Employee ID:', userUserData.employee_id);
    
    if (userUserData.role === 'employee') {
      console.log('✅ USER ROLE VERIFICATION: Correctly identified as employee');
      console.log('🎯 USER ROUTING: Should go to → /user/dashboard');
    } else {
      console.log('❌ USER ROLE VERIFICATION: Expected employee, got', userUserData.role);
    }
    
  } catch (error) {
    console.log('❌ LOGIN FAILED:', error.response?.data || error.message);
  }
}

testAdminLogin();