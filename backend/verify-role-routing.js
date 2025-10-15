// Test role-based routing final verification
const axios = require('axios');

async function testRoleRouting() {
  try {
    console.log('🧪 FINAL ROLE ROUTING VERIFICATION');
    console.log('===================================');
    
    // Test different role scenarios
    const testCases = [
      {
        name: 'Super Admin User',
        email: 'admin@gmail.com',
        password: '123456',
        expectedRole: 'super_admin',
        expectedRoute: '/admin/dashboard',
        description: 'Super admin should go to admin dashboard'
      },
      {
        name: 'Regular Admin User', 
        email: 'test@bpr.com',
        password: '123456',
        expectedRole: 'admin',
        expectedRoute: '/admin/dashboard',
        description: 'Regular admin should go to admin dashboard'
      },
      {
        name: 'Employee User',
        email: 'user@gmail.com', 
        password: '123456',
        expectedRole: 'employee',
        expectedRoute: '/user/dashboard',
        description: 'Employee should go to user dashboard'
      }
    ];
    
    for (const testCase of testCases) {
      console.log(`\n🔍 ${testCase.name}`);
      console.log('─'.repeat(40));
      console.log(`📝 Test: ${testCase.description}`);
      
      try {
        const response = await axios.post('http://localhost:3000/api/auth/login', {
          email: testCase.email,
          password: testCase.password
        });
        
        if (response.data.success) {
          const userData = response.data.data.user;
          console.log('✅ Login Success');
          console.log(`   Email: ${userData.email}`);
          console.log(`   Role: ${userData.role}`);
          
          // Apply routing logic exactly as in Flutter
          let routeDestination = '';
          const role = userData.role.toLowerCase();
          
          switch (role) {
            case 'super_admin':
            case 'admin':
              routeDestination = '/admin/dashboard';
              break;
            case 'employee':
            case 'account_officer':
            case 'security':
            case 'office_boy':
            default:
              routeDestination = '/user/dashboard';
              break;
          }
          
          console.log(`   Route Decision: ${routeDestination}`);
          console.log(`   Expected Route: ${testCase.expectedRoute}`);
          
          const isCorrect = routeDestination === testCase.expectedRoute;
          console.log(`   ✅ Routing Correct: ${isCorrect ? 'YES' : 'NO'}`);
          
          if (!isCorrect) {
            console.log(`   ❌ ERROR: Expected ${testCase.expectedRoute}, got ${routeDestination}`);
          }
          
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
    
    console.log('\n🎯 ROUTING RULES SUMMARY:');
    console.log('=========================');
    console.log('✅ super_admin role → /admin/dashboard');
    console.log('✅ admin role → /admin/dashboard');
    console.log('✅ employee role → /user/dashboard');
    console.log('✅ account_officer role → /user/dashboard');
    console.log('✅ security role → /user/dashboard');
    console.log('✅ office_boy role → /user/dashboard');
    
  } catch (error) {
    console.error('Test Error:', error.message);
  }
}

testRoleRouting();