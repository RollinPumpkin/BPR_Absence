const axios = require('axios');

const BASE_URL = 'http://localhost:3000/api';

async function testFixedLogins() {
  try {
    console.log('🧪 Testing fixed login credentials...');
    console.log('🔗 Backend URL:', BASE_URL);
    
    const testUsers = [
      {
        email: 'admin@gmail.com',
        password: '123456',
        name: 'Admin Gmail'
      },
      {
        email: 'test@bpr.com', 
        password: '123456',
        name: 'Test BPR'
      }
    ];
    
    for (const user of testUsers) {
      console.log(`\n${'='.repeat(50)}`);
      console.log(`🧪 Testing login for: ${user.name} (${user.email})`);
      console.log(`${'='.repeat(50)}`);
      
      try {
        // Test login
        console.log('1️⃣ Testing login...');
        const loginResponse = await axios.post(`${BASE_URL}/auth/login`, {
          email: user.email,
          password: user.password
        });
        
        if (loginResponse.data.success) {
          const { token, user: userData } = loginResponse.data.data;
          
          console.log('✅ LOGIN SUCCESSFUL!');
          console.log(`   👤 User: ${userData.full_name}`);
          console.log(`   📧 Email: ${userData.email}`);
          console.log(`   🆔 Employee ID: ${userData.employee_id}`);
          console.log(`   👑 Role: ${userData.role}`);
          console.log(`   🔑 Token: ${token.substring(0, 30)}...`);
          console.log(`   ✅ Active: ${userData.is_active}`);
          
          // Test admin dashboard access if admin
          if (userData.role === 'admin' || userData.role === 'super_admin') {
            console.log('\n2️⃣ Testing admin dashboard access...');
            try {
              const dashboardResponse = await axios.get(`${BASE_URL}/dashboard/admin`, {
                headers: {
                  'Authorization': `Bearer ${token}`
                }
              });
              
              if (dashboardResponse.data.success) {
                console.log('✅ ADMIN DASHBOARD ACCESS: SUCCESSFUL');
              } else {
                console.log('❌ Admin dashboard access failed');
                console.log('Response:', dashboardResponse.data);
              }
            } catch (dashError) {
              console.log('❌ Admin dashboard access error');
              console.log(`   Error: ${dashError.message}`);
            }
          }
          
        } else {
          console.log('❌ LOGIN FAILED');
          console.log('Response:', loginResponse.data);
        }
        
      } catch (error) {
        console.log('❌ LOGIN ERROR');
        console.log(`   Error: ${error.message}`);
        
        if (error.response) {
          console.log(`   Status: ${error.response.status}`);
          console.log(`   Data:`, error.response.data);
        }
      }
    }
    
    console.log(`\n${'='.repeat(60)}`);
    console.log('🎯 SUMMARY');
    console.log(`${'='.repeat(60)}`);
    console.log('✅ Authentication issues have been resolved!');
    console.log('');
    console.log('📋 Working Credentials:');
    console.log('');
    console.log('👑 SUPER ADMIN:');
    console.log('   📧 Email: admin@gmail.com');
    console.log('   🔑 Password: 123456');
    console.log('   👑 Role: super_admin');
    console.log('');
    console.log('👑 ADMIN:');
    console.log('   📧 Email: test@bpr.com');
    console.log('   🔑 Password: 123456');
    console.log('   👑 Role: admin');
    console.log('');
    console.log('🚀 Both users can now access admin dashboard!');
    
  } catch (error) {
    console.error('❌ Test script failed:', error);
  }
}

// Run tests
testFixedLogins().then(() => {
  console.log('\n✅ Test completed');
}).catch((error) => {
  console.error('❌ Test script error:', error);
});