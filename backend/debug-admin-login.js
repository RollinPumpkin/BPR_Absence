const axios = require('axios');

const BASE_URL = 'http://localhost:3000/api';

async function debugAdminLogin() {
  try {
    console.log('🔍 Debug login untuk admin@gmail.com...');
    console.log('🔗 Backend URL:', BASE_URL);
    
    // Test login
    console.log('\n1️⃣ Testing login...');
    const loginResponse = await axios.post(`${BASE_URL}/auth/login`, {
      email: 'admin@gmail.com',
      password: '123456'
    });
    
    if (loginResponse.data.success) {
      const { token, user } = loginResponse.data.data;
      
      console.log('✅ Login berhasil!');
      console.log('\n📋 Data User yang diterima:');
      console.log(`   👤 Name: ${user.full_name}`);
      console.log(`   📧 Email: ${user.email}`);
      console.log(`   🆔 Employee ID: ${user.employee_id}`);
      console.log(`   👑 Role: "${user.role}"`);
      console.log(`   👑 Role Type: ${typeof user.role}`);
      console.log(`   ✅ Active: ${user.is_active}`);
      
      console.log('\n🎯 Flutter Routing Analysis:');
      console.log('Current routing condition:');
      console.log('   if (userRole == "admin" || userRole == "super_admin") {');
      console.log('     → /admin/dashboard');
      console.log('   } else {');
      console.log('     → /user/dashboard');
      console.log('   }');
      
      if (user.role === 'admin' || user.role === 'super_admin') {
        console.log(`\n✅ EXPECTED ROUTE: /admin/dashboard`);
        console.log(`   ✅ Role "${user.role}" SHOULD go to admin dashboard`);
      } else {
        console.log(`\n❌ ACTUAL ROUTE: /user/dashboard`);
        console.log(`   ❌ Role "${user.role}" does NOT match admin condition`);
      }
      
      // Check for any hidden characters or formatting issues
      console.log('\n🔍 Role String Analysis:');
      console.log(`   Raw role: "${user.role}"`);
      console.log(`   Role length: ${user.role ? user.role.length : 'undefined'}`);
      console.log(`   Role bytes: ${user.role ? JSON.stringify([...user.role].map(c => c.charCodeAt(0))) : 'N/A'}`);
      console.log(`   Trimmed role: "${user.role ? user.role.trim() : 'N/A'}"`);
      
      // Test exact matching
      console.log('\n🧪 Exact String Matching:');
      console.log(`   user.role === 'admin': ${user.role === 'admin'}`);
      console.log(`   user.role === 'super_admin': ${user.role === 'super_admin'}`);
      console.log(`   user.role == 'admin': ${user.role == 'admin'}`);
      console.log(`   user.role == 'super_admin': ${user.role == 'super_admin'}`);
      
    } else {
      console.log('❌ Login gagal');
      console.log('Response:', loginResponse.data);
    }
    
  } catch (error) {
    console.error('❌ Error:', error.message);
    
    if (error.response) {
      console.error('Status:', error.response.status);
      console.error('Data:', error.response.data);
    }
  }
}

// Run debug
debugAdminLogin().then(() => {
  console.log('\n✅ Debug completed');
}).catch((error) => {
  console.error('❌ Debug failed:', error);
});