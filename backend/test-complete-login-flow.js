const axios = require('axios');

async function testCompleteLoginFlow() {
  console.log('🧪 STARTING COMPLETE LOGIN FLOW TEST\n');
  
  // Test data
  const testCases = [
    {
      name: 'Admin Login',
      email: 'admin@gmail.com',
      password: '123456',
      expectedRole: 'super_admin',
      expectedEmployeeId: 'SUP001',
      expectedRoute: '/admin/dashboard'
    },
    {
      name: 'User Login', 
      email: 'user@gmail.com',
      password: '123456',
      expectedRole: 'employee',
      expectedRoute: '/user/dashboard'
    }
  ];
  
  for (const testCase of testCases) {
    console.log(`\n🔍 Testing: ${testCase.name}`);
    console.log(`📧 Email: ${testCase.email}`);
    console.log(`🔐 Password: ${testCase.password}`);
    
    try {
      const response = await axios.post('http://localhost:3000/api/auth/login', {
        email: testCase.email,
        password: testCase.password
      }, {
        headers: {
          'Content-Type': 'application/json'
        }
      });
      
      console.log(`✅ Status: ${response.status}`);
      
      if (response.data.success && response.data.data?.user) {
        const user = response.data.data.user;
        
        console.log(`👤 Role: "${user.role}"`);
        console.log(`🆔 Employee ID: "${user.employee_id}"`);
        console.log(`📧 Email: "${user.email}"`);
        console.log(`👨‍💼 Name: "${user.full_name}"`);
        
        // Verify expected data
        const roleMatch = user.role === testCase.expectedRole;
        const employeeIdMatch = !testCase.expectedEmployeeId || user.employee_id === testCase.expectedEmployeeId;
        
        console.log(`🎯 Role Match: ${roleMatch ? '✅' : '❌'} (Expected: ${testCase.expectedRole})`);
        if (testCase.expectedEmployeeId) {
          console.log(`🎯 Employee ID Match: ${employeeIdMatch ? '✅' : '❌'} (Expected: ${testCase.expectedEmployeeId})`);
        }
        
        // Determine expected routing
        const shouldRouteToAdmin = user.role === 'admin' || user.role === 'super_admin' || 
                                  user.employee_id?.startsWith('SUP') || user.employee_id?.startsWith('ADM');
        const expectedRoute = shouldRouteToAdmin ? '/admin/dashboard' : '/user/dashboard';
        
        console.log(`🧭 Should Route To: ${expectedRoute}`);
        console.log(`🎯 Route Match: ${expectedRoute === testCase.expectedRoute ? '✅' : '❌'}`);
        
        if (roleMatch && employeeIdMatch && expectedRoute === testCase.expectedRoute) {
          console.log(`🎉 ${testCase.name}: ALL TESTS PASSED ✅`);
        } else {
          console.log(`❌ ${testCase.name}: SOME TESTS FAILED`);
        }
        
      } else {
        console.log(`❌ No user data in response`);
      }
      
    } catch (error) {
      console.log(`❌ API Error: ${error.response?.data?.message || error.message}`);
    }
    
    console.log('─'.repeat(50));
  }
  
  console.log('\n🏁 BACKEND API TESTS COMPLETED');
  console.log('\n📋 NEXT STEPS:');
  console.log('1. Open frontend app: http://localhost:8080');
  console.log('2. Clear browser cache (F12 → Console → run cache clear script)');
  console.log('3. Test admin login: admin@gmail.com + 123456');
  console.log('4. Verify console logs and routing');
  console.log('5. Test user login: user@gmail.com + 123456');
}

testCompleteLoginFlow();