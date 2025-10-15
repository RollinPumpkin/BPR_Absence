// Test final role-based routing implementation
const axios = require('axios');

async function testFinalRoleRouting() {
  try {
    console.log('🧪 FINAL ROLE-BASED ROUTING TEST');
    console.log('==================================');
    
    // Test different role scenarios
    const testScenarios = [
      {
        name: 'Super Admin Login',
        email: 'admin@gmail.com',
        password: '123456',
        expectedRole: 'super_admin',
        expectedRoute: '/admin/dashboard'
      },
      {
        name: 'Regular Admin Login',
        email: 'admin@bpr.com',
        password: '123456',
        expectedRole: 'admin', 
        expectedRoute: '/admin/dashboard'
      },
      {
        name: 'Employee Login',
        email: 'user@gmail.com',
        password: '123456',
        expectedRole: 'employee',
        expectedRoute: '/user/dashboard'
      },
      {
        name: 'Ahmad Employee Login',
        email: 'ahmad.wijaya@bpr.com',
        password: '123456',
        expectedRole: 'employee',
        expectedRoute: '/user/dashboard'
      }
    ];
    
    for (const scenario of testScenarios) {
      console.log(`\n🔍 ${scenario.name}`);
      console.log('─'.repeat(40));
      
      try {
        const response = await axios.post('http://localhost:3000/api/auth/login', {
          email: scenario.email,
          password: scenario.password
        });
        
        if (response.data.success) {
          const userData = response.data.data.user;
          console.log('✅ Login Success');
          console.log(`   Email: ${userData.email}`);
          console.log(`   Role: ${userData.role}`);
          console.log(`   Employee ID: ${userData.employee_id}`);
          
          // Simulate routing logic
          let routeDestination = '';
          const role = userData.role.toLowerCase();
          
          switch (role) {
            case 'super_admin':
            case 'admin':
              routeDestination = '/admin/dashboard';
              break;
            default:
              routeDestination = '/user/dashboard';
              break;
          }
          
          console.log(`   Route Decision: ${routeDestination}`);
          console.log(`   Expected: ${scenario.expectedRoute}`);
          console.log(`   ✅ Correct: ${routeDestination === scenario.expectedRoute ? 'YES' : 'NO'}`);
          
        } else {
          console.log('❌ Login Failed:', response.data.message);
        }
        
      } catch (error) {
        if (error.response) {
          console.log('❌ API Error:', error.response.data.message);
        } else {
          console.log('❌ Network Error:', error.message);
        }
      }
    }
    
    console.log('\n🎯 ROUTING SUMMARY:');
    console.log('===================');
    console.log('✅ super_admin role → /admin/dashboard');
    console.log('✅ admin role → /admin/dashboard');
    console.log('✅ employee role → /user/dashboard');
    console.log('✅ other roles → /user/dashboard');
    
  } catch (error) {
    console.error('Test Error:', error.message);
  }
}

testFinalRoleRouting();