const axios = require('axios');

const BASE_URL = 'http://localhost:3000/api';

async function testEmployeeIdPattern() {
  try {
    console.log('🔍 Testing Employee ID Pattern untuk admin access...');
    console.log('📋 Expected Admin Patterns:');
    console.log('   - ADM___ : Admin');
    console.log('   - SUP___ : Super Admin');
    console.log('   - EMP___ : Employee');
    console.log('   - OB___  : Office Boy');
    console.log('   - SCR___ : Security');
    console.log('   - AO___  : Account Officer');
    
    // Test admin@gmail.com
    console.log('\n1️⃣ Testing admin@gmail.com...');
    const adminResponse = await axios.post(`${BASE_URL}/auth/login`, {
      email: 'admin@gmail.com',
      password: '123456'
    });
    
    if (adminResponse.data.success) {
      const { user } = adminResponse.data.data;
      
      console.log('✅ Login berhasil!');
      console.log(`   📧 Email: ${user.email}`);
      console.log(`   🆔 Employee ID: ${user.employee_id}`);
      console.log(`   👑 Role: "${user.role}"`);
      
      // Check pattern
      const empId = user.employee_id;
      const prefix = empId.substring(0, 3);
      
      console.log(`\n🔍 Employee ID Analysis:`);
      console.log(`   Full ID: ${empId}`);
      console.log(`   Prefix: ${prefix}`);
      
      let expectedRoute = '';
      if (prefix === 'ADM' || prefix === 'SUP') {
        expectedRoute = '/admin/dashboard';
        console.log(`   ✅ Expected route: ${expectedRoute} (Admin/Super Admin)`);
      } else {
        expectedRoute = '/user/dashboard';
        console.log(`   ➡️ Expected route: ${expectedRoute} (Regular user)`);
      }
      
      // Check current Flutter logic
      console.log(`\n🎯 Current Flutter Logic:`);
      console.log(`   if (userRole == 'admin' || userRole == 'super_admin')`);
      console.log(`   Current condition result: ${user.role === 'admin' || user.role === 'super_admin'}`);
      
      // Suggest new logic
      console.log(`\n💡 Suggested Flutter Logic:`);
      console.log(`   if (employeeId.startsWith('ADM') || employeeId.startsWith('SUP'))`);
      console.log(`   New condition result: ${empId.startsWith('ADM') || empId.startsWith('SUP')}`);
    }
    
    // Test test@bpr.com
    console.log('\n2️⃣ Testing test@bpr.com...');
    try {
      const testResponse = await axios.post(`${BASE_URL}/auth/login`, {
        email: 'test@bpr.com',
        password: '123456'
      });
      
      if (testResponse.data.success) {
        const { user } = testResponse.data.data;
        
        console.log('✅ Login berhasil!');
        console.log(`   📧 Email: ${user.email}`);
        console.log(`   🆔 Employee ID: ${user.employee_id}`);
        console.log(`   👑 Role: "${user.role}"`);
        
        // Check pattern
        const empId = user.employee_id;
        const prefix = empId.substring(0, 3);
        
        console.log(`\n🔍 Employee ID Analysis:`);
        console.log(`   Full ID: ${empId}`);
        console.log(`   Prefix: ${prefix}`);
        
        let expectedRoute = '';
        if (prefix === 'ADM' || prefix === 'SUP') {
          expectedRoute = '/admin/dashboard';
          console.log(`   ✅ Expected route: ${expectedRoute} (Admin/Super Admin)`);
        } else {
          expectedRoute = '/user/dashboard';
          console.log(`   ➡️ Expected route: ${expectedRoute} (Regular user)`);
        }
      }
    } catch (error) {
      console.log('❌ test@bpr.com login failed:', error.response?.data?.message || error.message);
    }
    
  } catch (error) {
    console.error('❌ Error:', error.message);
    
    if (error.response) {
      console.error('Status:', error.response.status);
      console.error('Data:', error.response.data);
    }
  }
}

// Run test
testEmployeeIdPattern().then(() => {
  console.log('\n✅ Test completed');
}).catch((error) => {
  console.error('❌ Test failed:', error);
});