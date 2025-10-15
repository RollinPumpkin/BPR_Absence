// Test role-based routing
const axios = require('axios');

async function testRoleBasedRouting() {
  try {
    console.log('🧪 TESTING ROLE-BASED ROUTING');
    console.log('==============================');
    
    // Test accounts with different roles
    const testAccounts = [
      {
        name: 'Super Admin',
        email: 'admin@gmail.com',
        password: '123456',
        expectedRole: 'super_admin',
        expectedRoute: '/admin/dashboard'
      },
      {
        name: 'Regular Admin',
        email: 'test@bpr.com',
        password: '123456', 
        expectedRole: 'admin',
        expectedRoute: '/admin/dashboard'
      },
      {
        name: 'Regular Employee',
        email: 'user@gmail.com',
        password: '123456',
        expectedRole: 'employee', 
        expectedRoute: '/user/dashboard'
      }
    ];
    
    for (const account of testAccounts) {
      console.log(`\n🔍 Testing ${account.name} (${account.email})`);
      console.log('─'.repeat(50));
      
      try {
        const response = await axios.post('http://localhost:3000/api/auth/login', {
          email: account.email,
          password: account.password
        });
        
        if (response.data.success) {
          const userData = response.data.data.user;
          console.log('✅ Login Success');
          console.log('📋 User Data:');
          console.log('   Email:', userData.email);
          console.log('   Role:', userData.role);
          console.log('   Employee ID:', userData.employee_id);
          
          // Apply new role-based routing logic
          console.log('\n🎯 Routing Analysis:');
          const userRole = userData.role;
          let routeDestination = '';
          
          if (userRole === 'super_admin' || userRole === 'admin') {
            routeDestination = '/admin/dashboard';
            console.log('   Decision: Admin role detected → ADMIN DASHBOARD');
          } else {
            routeDestination = '/user/dashboard';
            console.log('   Decision: Employee role → USER DASHBOARD');
          }
          
          console.log('   Route Destination:', routeDestination);
          console.log('   Expected Route:', account.expectedRoute);
          console.log('   ✅ Match:', routeDestination === account.expectedRoute ? 'YES' : 'NO');
          
        } else {
          console.log('❌ Login Failed:', response.data.message);
        }
        
      } catch (error) {
        if (error.response) {
          console.log('❌ Login Failed:', error.response.data.message);
        } else {
          console.log('❌ Error:', error.message);
        }
      }
    }
    
  } catch (error) {
    console.error('Test Error:', error.message);
  }
}

testRoleBasedRouting();