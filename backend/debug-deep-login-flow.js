const axios = require('axios');

async function debugDeepLoginFlow() {
  console.log('🔍 DEEP DEBUG: Login Flow Analysis\n');
  
  try {
    console.log('1. Testing API Login with admin@gmail.com...');
    
    const response = await axios.post('http://localhost:3000/api/auth/login', {
      email: 'admin@gmail.com',
      password: '123456'
    });
    
    console.log('\n📦 FULL API RESPONSE:');
    console.log(JSON.stringify(response.data, null, 2));
    
    if (response.data.success && response.data.data?.user) {
      const user = response.data.data.user;
      
      console.log('\n🔍 CRITICAL FIELD ANALYSIS:');
      console.log(`Role Field: "${user.role}" (Type: ${typeof user.role})`);
      console.log(`Employee ID Field: "${user.employee_id}" (Type: ${typeof user.employee_id})`);
      console.log(`Email Field: "${user.email}"`);
      
      console.log('\n🎯 FRONTEND ROUTING SIMULATION:');
      
      // Simulate exact frontend logic
      const userRole = user.role?.toString() || 'employee';
      const employeeId = user.employee_id?.toString() || '';
      
      console.log(`Frontend userRole: "${userRole}"`);
      console.log(`Frontend employeeId: "${employeeId}"`);
      console.log(`Frontend employeeId.length: ${employeeId.length}`);
      console.log(`Frontend employeeId.isEmpty: ${employeeId.length === 0}`);
      
      // Test startsWith logic
      const startsWithSUP = employeeId.startsWith('SUP');
      const startsWithADM = employeeId.startsWith('ADM');
      
      console.log(`employeeId.startsWith('SUP'): ${startsWithSUP}`);
      console.log(`employeeId.startsWith('ADM'): ${startsWithADM}`);
      
      const hasAdminEmployeeId = startsWithSUP || startsWithADM;
      const hasAdminRole = userRole === 'admin' || userRole === 'super_admin';
      const shouldAccessAdmin = hasAdminEmployeeId || hasAdminRole;
      
      console.log(`\n🎯 DECISION PROCESS:`);
      console.log(`hasAdminEmployeeId: ${hasAdminEmployeeId}`);
      console.log(`hasAdminRole: ${hasAdminRole}`);
      console.log(`shouldAccessAdmin: ${shouldAccessAdmin}`);
      console.log(`Decision basis: ${hasAdminEmployeeId ? 'EMPLOYEE_ID_PATTERN' : 'ROLE_FALLBACK'}`);
      
      const expectedRoute = shouldAccessAdmin ? '/admin/dashboard' : '/user/dashboard';
      console.log(`Expected route: ${expectedRoute}`);
      
      if (expectedRoute === '/admin/dashboard') {
        console.log('\n✅ ANALYSIS: Should route to ADMIN dashboard');
      } else {
        console.log('\n❌ ANALYSIS: Would route to USER dashboard');
        console.log('🚨 This indicates a problem with the data or logic!');
      }
      
      console.log('\n🔍 POTENTIAL ISSUES TO CHECK:');
      console.log('1. Is employee_id field empty or null in API response?');
      console.log('2. Is role field not matching expected values?'); 
      console.log('3. Is there a routing override after navigation?');
      console.log('4. Is user actually logging in with different account?');
      
    } else {
      console.log('❌ API Login failed');
      console.log('Response:', response.data);
    }
    
  } catch (error) {
    console.error('❌ Error:', error.response?.data || error.message);
  }
}

debugDeepLoginFlow();