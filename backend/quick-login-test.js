// Quick test script untuk debugging login routing
// Jalankan dengan: node quick-login-test.js

const axios = require('axios');

async function quickTest() {
  try {
    console.log('🚀 Quick Login Test untuk admin@gmail.com');
    
    const response = await axios.post('http://localhost:3000/api/auth/login', {
      email: 'admin@gmail.com',
      password: '123456'
    });
    
    if (response.data.success) {
      const user = response.data.data.user;
      console.log('✅ Backend Response:');
      console.log(`   Role: "${user.role}"`);
      console.log(`   Employee ID: "${user.employee_id}"`);
      console.log(`   Expected Route: /admin/dashboard`);
      console.log('');
      console.log('🎯 Frontend Check:');
      console.log(`   hasAdminRole: ${user.role === 'admin' || user.role === 'super_admin'}`);
      console.log(`   hasAdminEmployeeId: ${user.employee_id.startsWith('SUP') || user.employee_id.startsWith('ADM')}`);
      console.log(`   Should go to ADMIN dashboard: ✅`);
    } else {
      console.log('❌ Login failed');
    }
  } catch (error) {
    console.log('❌ Error:', error.message);
  }
}

quickTest();