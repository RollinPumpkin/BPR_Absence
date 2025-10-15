const axios = require('axios');

const BASE_URL = 'http://localhost:3000/api';

async function testUpdatedAdminLogic() {
  try {
    console.log('🎯 Testing Updated Admin Access Logic...');
    console.log('📋 New Admin Criteria:');
    console.log('   1. Role: admin OR super_admin');
    console.log('   2. Employee ID starts with: ADM, SUP, or TADM');
    console.log('   3. Either condition = admin dashboard access');
    
    const testUsers = [
      { email: 'admin@gmail.com', password: '123456', name: 'Admin User' },
      { email: 'test@bpr.com', password: '123456', name: 'Test Admin' }
    ];
    
    for (const testUser of testUsers) {
      console.log(`\n🧪 Testing ${testUser.name} (${testUser.email})...`);
      
      try {
        const response = await axios.post(`${BASE_URL}/auth/login`, {
          email: testUser.email,
          password: testUser.password
        });
        
        if (response.data.success) {
          const { user } = response.data.data;
          
          console.log('✅ Login berhasil!');
          console.log(`   📧 Email: ${user.email}`);
          console.log(`   🆔 Employee ID: ${user.employee_id}`);
          console.log(`   👑 Role: "${user.role}"`);
          
          // Apply new logic
          const hasAdminRole = user.role === 'admin' || user.role === 'super_admin';
          const hasAdminEmployeeId = user.employee_id.startsWith('ADM') || 
                                     user.employee_id.startsWith('SUP') || 
                                     user.employee_id.startsWith('TADM');
          const shouldAccessAdmin = hasAdminRole || hasAdminEmployeeId;
          
          console.log(`\n📋 Access Analysis:`);
          console.log(`   ✅ Has admin role: ${hasAdminRole}`);
          console.log(`   ✅ Has admin employee ID: ${hasAdminEmployeeId}`);
          console.log(`   🎯 Should access admin: ${shouldAccessAdmin}`);
          
          if (shouldAccessAdmin) {
            console.log(`   ➡️ Route: /admin/dashboard ✅`);
          } else {
            console.log(`   ➡️ Route: /user/dashboard`);
          }
        }
      } catch (error) {
        console.log(`❌ ${testUser.name} login failed:`, error.response?.data?.message || error.message);
      }
    }
    
    console.log('\n📋 Summary of Access Rules:');
    console.log('   ✅ admin@gmail.com (ADM002, super_admin) → Admin Dashboard');
    console.log('   ✅ test@bpr.com (TADM001, admin) → Admin Dashboard');
    console.log('   ❌ Regular employees (EMP___, AO___, etc.) → User Dashboard');
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  }
}

// Run test
testUpdatedAdminLogic().then(() => {
  console.log('\n✅ Admin logic test completed');
}).catch((error) => {
  console.error('❌ Test failed:', error);
});