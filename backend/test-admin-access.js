const axios = require('axios');

const BASE_URL = 'http://localhost:3000/api';

async function testAdminLogin() {
  try {
    console.log('🧪 Testing admin login for test@bpr.com...');
    console.log('🔗 Backend URL:', BASE_URL);
    
    // Test login
    console.log('\n1️⃣ Testing login...');
    const loginResponse = await axios.post(`${BASE_URL}/auth/login`, {
      email: 'test@bpr.com',
      password: '123456'
    });
    
    if (loginResponse.data.success) {
      const { token, user } = loginResponse.data.data;
      
      console.log('✅ Login successful!');
      console.log(`   👤 User: ${user.full_name}`);
      console.log(`   📧 Email: ${user.email}`);
      console.log(`   🆔 Employee ID: ${user.employee_id}`);
      console.log(`   👑 Role: ${user.role}`);
      console.log(`   🔑 Token: ${token.substring(0, 20)}...`);
      
      // Test admin dashboard access
      console.log('\n2️⃣ Testing admin dashboard access...');
      const dashboardResponse = await axios.get(`${BASE_URL}/dashboard/admin`, {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });
      
      if (dashboardResponse.data.success) {
        console.log('✅ Admin dashboard access successful!');
        console.log(`   📊 Dashboard data loaded`);
        
        // Test admin users endpoint
        console.log('\n3️⃣ Testing admin users access...');
        const usersResponse = await axios.get(`${BASE_URL}/admin/users`, {
          headers: {
            'Authorization': `Bearer ${token}`
          }
        });
        
        if (usersResponse.data.success) {
          const users = usersResponse.data.data;
          console.log('✅ Admin users access successful!');
          console.log(`   👥 Total users: ${users.length}`);
          
          users.forEach((user, index) => {
            console.log(`   ${index + 1}. ${user.full_name} (${user.role}) - ${user.email}`);
          });
        }
        
      } else {
        console.log('❌ Admin dashboard access failed');
        console.log('Response:', dashboardResponse.data);
      }
      
    } else {
      console.log('❌ Login failed');
      console.log('Response:', loginResponse.data);
    }
    
  } catch (error) {
    console.error('❌ Test failed:', error.message);
    
    if (error.response) {
      console.error('Status:', error.response.status);
      console.error('Data:', error.response.data);
    }
  }
}

// Test function
testAdminLogin().then(() => {
  console.log('\n✅ Test completed');
}).catch((error) => {
  console.error('❌ Test script failed:', error);
});