const axios = require('axios');

const BASE_URL = 'http://localhost:3000/api';

async function debugLoginRouting() {
  try {
    console.log('🔍 Debugging Login Routing Issue');
    console.log('=' .repeat(50));
    
    // Test admin@gmail.com login
    console.log('1️⃣ Testing admin@gmail.com login...');
    const loginResponse = await axios.post(`${BASE_URL}/auth/login`, {
      email: 'admin@gmail.com',
      password: '123456'
    });
    
    if (loginResponse.data.success) {
      const { user, token } = loginResponse.data.data;
      
      console.log('✅ Backend login successful!');
      console.log(`   📧 Email: ${user.email}`);
      console.log(`   🆔 Employee ID: ${user.employee_id}`);
      console.log(`   👑 Role: "${user.role}"`);
      console.log(`   👤 Name: ${user.full_name}`);
      
      console.log('\n📋 Data Types:');
      console.log(`   Role type: ${typeof user.role}`);
      console.log(`   Employee ID type: ${typeof user.employee_id}`);
      console.log(`   Role length: ${user.role ? user.role.length : 'N/A'}`);
      console.log(`   Employee ID length: ${user.employee_id ? user.employee_id.length : 'N/A'}`);
      
      console.log('\n🧪 Frontend Routing Logic Simulation:');
      console.log('   Testing conditions...');
      
      const userRole = user.role;
      const employeeId = user.employee_id;
      
      console.log(`   userRole: "${userRole}"`);
      console.log(`   employeeId: "${employeeId}"`);
      console.log(`   employeeId prefix: "${employeeId.length >= 3 ? employeeId.substring(0, 3) : employeeId}"`);
      
      const hasAdminRole = userRole === 'admin' || userRole === 'super_admin';
      const hasAdminEmployeeId = employeeId.startsWith('SUP') || employeeId.startsWith('ADM');
      const shouldAccessAdmin = hasAdminRole || hasAdminEmployeeId;
      
      console.log(`\n   hasAdminRole: ${hasAdminRole}`);
      console.log(`   hasAdminEmployeeId: ${hasAdminEmployeeId}`);
      console.log(`   shouldAccessAdmin: ${shouldAccessAdmin}`);
      
      if (shouldAccessAdmin) {
        console.log(`   ✅ EXPECTED ROUTE: /admin/dashboard`);
      } else {
        console.log(`   ❌ WOULD ROUTE TO: /user/dashboard`);
      }
      
      // Test individual conditions
      console.log('\n🔍 Individual Condition Tests:');
      console.log(`   userRole === 'admin': ${userRole === 'admin'}`);
      console.log(`   userRole === 'super_admin': ${userRole === 'super_admin'}`);
      console.log(`   employeeId.startsWith('SUP'): ${employeeId.startsWith('SUP')}`);
      console.log(`   employeeId.startsWith('ADM'): ${employeeId.startsWith('ADM')}`);
      
      // Test string encoding/hidden characters
      console.log('\n🔍 String Analysis:');
      console.log(`   Role bytes: [${[...userRole].map(c => c.charCodeAt(0)).join(', ')}]`);
      console.log(`   Employee ID bytes: [${[...employeeId].map(c => c.charCodeAt(0)).join(', ')}]`);
      console.log(`   Role trimmed: "${userRole.trim()}"`);
      console.log(`   Employee ID trimmed: "${employeeId.trim()}"`);
      
    } else {
      console.log('❌ Backend login failed');
      console.log('Response:', loginResponse.data);
    }
    
    // Test test@bpr.com for comparison
    console.log('\n' + '=' .repeat(50));
    console.log('2️⃣ Testing test@bpr.com login...');
    
    try {
      const testResponse = await axios.post(`${BASE_URL}/auth/login`, {
        email: 'test@bpr.com',
        password: '123456'
      });
      
      if (testResponse.data.success) {
        const { user } = testResponse.data.data;
        
        console.log('✅ test@bpr.com login successful!');
        console.log(`   📧 Email: ${user.email}`);
        console.log(`   🆔 Employee ID: ${user.employee_id}`);
        console.log(`   👑 Role: "${user.role}"`);
        
        const userRole = user.role;
        const employeeId = user.employee_id;
        const hasAdminRole = userRole === 'admin' || userRole === 'super_admin';
        const hasAdminEmployeeId = employeeId.startsWith('SUP') || employeeId.startsWith('ADM');
        const shouldAccessAdmin = hasAdminRole || hasAdminEmployeeId;
        
        console.log(`   shouldAccessAdmin: ${shouldAccessAdmin}`);
        
        if (shouldAccessAdmin) {
          console.log(`   ✅ EXPECTED ROUTE: /admin/dashboard`);
        } else {
          console.log(`   ❌ WOULD ROUTE TO: /user/dashboard`);
        }
      }
    } catch (error) {
      console.log('❌ test@bpr.com login failed:', error.response?.data?.message || error.message);
    }
    
    console.log('\n' + '=' .repeat(50));
    console.log('📋 POTENTIAL ISSUES TO CHECK:');
    console.log('1. Check Flutter console for debug prints');
    console.log('2. Check if AuthProvider.currentUser is populated correctly');
    console.log('3. Check if there\'s cached route state');
    console.log('4. Check browser network tab for login response');
    console.log('5. Clear browser cache/localStorage');
    
  } catch (error) {
    console.error('❌ Error:', error.message);
    if (error.response) {
      console.error('Status:', error.response.status);
      console.error('Data:', error.response.data);
    }
  }
}

// Run debug
debugLoginRouting().then(() => {
  console.log('\n✅ Debug completed');
}).catch((error) => {
  console.error('❌ Debug failed:', error);
});