// Test Login and Check Routing Destination
const axios = require('axios');

async function testLoginRouting() {
  try {
    console.log('🧪 LOGIN ROUTING TEST');
    console.log('====================');
    
    // Test credentials (verified working accounts only)
    const testCredentials = [
      {
        name: 'Super Admin (SUP001)',
        email: 'admin@gmail.com',
        password: '123456',
        expectedEmployeeId: 'SUP001',
        expectedRoute: '/admin/dashboard'
      },
      {
        name: 'Regular Employee (EMP008)', 
        email: 'user@gmail.com',
        password: '123456',
        expectedEmployeeId: 'EMP008',
        expectedRoute: '/user/dashboard'
      },
      {
        name: 'Test Admin (TEST001)',
        email: 'test@bpr.com', 
        password: '123456',
        expectedEmployeeId: 'TEST001',
        expectedRoute: '/user/dashboard'  // TEST001 is not SUP/ADM pattern
      },
      {
        name: 'Ahmad Employee (EMP001)',
        email: 'ahmad.wijaya@bpr.com',
        password: '123456', 
        expectedEmployeeId: 'EMP001',
        expectedRoute: '/user/dashboard'
      }
    ];
    
    for (const cred of testCredentials) {
      console.log(`\n🔍 Testing ${cred.name} (${cred.email})`);
      console.log('─'.repeat(50));
      
      try {
        // Simulate login API call to backend
        const response = await axios.post('http://localhost:3000/api/auth/login', {
          email: cred.email,
          password: cred.password
        });
        
        if (response.data.success) {
          const userData = response.data.data.user;
          console.log('✅ Login Success');
          console.log('📋 User Data:');
          console.log('   Email:', userData.email);
          console.log('   Role:', userData.role);
          console.log('   Employee ID:', userData.employee_id);
          console.log('   Full Name:', userData.full_name);
          
          // Apply the same routing logic as frontend
          console.log('\n🎯 Routing Analysis:');
          const employeeId = userData.employee_id;
          let routeDestination = '';
          
          if (employeeId.startsWith('SUP') || employeeId.startsWith('ADM')) {
            routeDestination = '/admin/dashboard';
            console.log('   Decision: Employee ID starts with SUP/ADM → ADMIN');
          } else {
            routeDestination = '/user/dashboard';
            console.log('   Decision: Employee ID other pattern → USER');
          }
          
          console.log('   Route Destination:', routeDestination);
          console.log('   Expected Route:', cred.expectedRoute);
          console.log('   ✅ Match:', routeDestination === cred.expectedRoute ? 'YES' : 'NO');
          
        } else {
          console.log('❌ Login Failed:', response.data.message);
        }
        
      } catch (error) {
        if (error.response) {
          console.log('❌ Login Failed:', error.response.data.message);
        } else if (error.code === 'ECONNREFUSED') {
          console.log('❌ Backend server not running on port 3000');
        } else {
          console.log('❌ Error:', error.message);
        }
      }
    }
    
  } catch (error) {
    console.error('Test Error:', error.message);
  }
}

// Run the test
testLoginRouting();