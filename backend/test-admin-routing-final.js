// Test route navigation explicitly
const axios = require('axios');

async function testAdminRouting() {
  try {
    console.log('🧪 TESTING ADMIN ROUTING TO /admin/dashboard');
    console.log('===============================================');
    
    // Login as admin
    const response = await axios.post('http://localhost:3000/api/auth/login', {
      email: 'admin@gmail.com',
      password: '123456'
    });
    
    if (response.data.success) {
      const userData = response.data.data.user;
      console.log('✅ Login Success');
      console.log('📋 User Data:');
      console.log('   Email:', userData.email);
      console.log('   Role:', userData.role);
      console.log('   Employee ID:', userData.employee_id);
      
      // Apply routing logic
      const employeeId = userData.employee_id;
      console.log('\n🎯 ROUTING LOGIC:');
      console.log('   Employee ID:', employeeId);
      console.log('   Starts with SUP:', employeeId.startsWith('SUP'));
      console.log('   Starts with ADM:', employeeId.startsWith('ADM'));
      
      if (employeeId.startsWith('SUP') || employeeId.startsWith('ADM')) {
        console.log('✅ DECISION: Should route to /admin/dashboard');
        console.log('🎯 Expected URL: localhost:8081/#/admin/dashboard');
      } else {
        console.log('❌ DECISION: Would route to /user/dashboard');
      }
      
    } else {
      console.log('❌ Login failed');
    }
    
  } catch (error) {
    console.error('❌ Test failed:', error.message);
  }
}

testAdminRouting();