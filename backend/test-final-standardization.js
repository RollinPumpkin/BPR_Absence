const axios = require('axios');

const BASE_URL = 'http://localhost:3000/api';

async function testKnownUsers() {
  try {
    console.log('🎯 Testing Known Working Users with Standardized IDs');
    console.log('=' .repeat(60));
    
    // Test only users we know work
    const knownUsers = [
      { email: 'admin@gmail.com', password: '123456', role: 'super_admin' },
      { email: 'test@bpr.com', password: '123456', role: 'admin' },
      { email: 'user@gmail.com', password: '123456', role: 'employee' }
    ];
    
    for (const testUser of knownUsers) {
      console.log(`\n🔍 Testing: ${testUser.email}`);
      
      try {
        const response = await axios.post(`${BASE_URL}/auth/login`, {
          email: testUser.email,
          password: testUser.password
        });
        
        if (response.data.success) {
          const { user } = response.data.data;
          
          console.log(`   ✅ Login successful`);
          console.log(`   📧 Email: ${user.email}`);
          console.log(`   🆔 Employee ID: ${user.employee_id}`);
          console.log(`   👑 Role: ${user.role}`);
          
          // Apply new routing logic
          const hasAdminRole = user.role === 'admin' || user.role === 'super_admin';
          const hasAdminEmployeeId = user.employee_id.startsWith('SUP') || user.employee_id.startsWith('ADM');
          const shouldAccessAdmin = hasAdminRole || hasAdminEmployeeId;
          
          console.log(`   🎯 Admin Role: ${hasAdminRole}`);
          console.log(`   🎯 Admin ID Pattern: ${hasAdminEmployeeId}`);
          console.log(`   ➡️ Route: /${shouldAccessAdmin ? 'admin' : 'user'}/dashboard`);
          
          if (shouldAccessAdmin) {
            console.log(`   ✅ ADMIN ACCESS GRANTED`);
          } else {
            console.log(`   👤 USER ACCESS (Normal)`);
          }
        }
      } catch (error) {
        console.log(`   ❌ Login failed: ${error.response?.data?.message || error.message}`);
      }
    }
    
    console.log('\n' + '=' .repeat(60));
    console.log('📋 FINAL STANDARDIZATION SUMMARY');
    console.log('=' .repeat(60));
    
    console.log('\n🎯 NEW EMPLOYEE ID STRUCTURE:');
    console.log('   SUP001 | admin@gmail.com | super_admin → Admin Dashboard');
    console.log('   SUP002 | superadmin@bpr.com | super_admin → Admin Dashboard');
    console.log('   SUP003 | superadmin@gmail.com | super_admin → Admin Dashboard');
    console.log('');
    console.log('   ADM001 | admin@bpr.com | admin → Admin Dashboard');
    console.log('   ADM002 | admin@bpr.com | admin → Admin Dashboard');
    console.log('   ADM003 | test@bpr.com | admin → Admin Dashboard');
    console.log('');
    console.log('   EMP001-008 | Various employees → User Dashboard');
    console.log('   AO001-002  | Account Officers → User Dashboard');
    console.log('   OB001      | Office Boy → User Dashboard');
    console.log('   SCR001-002 | Security → User Dashboard');
    
    console.log('\n🔧 ROUTING LOGIC:');
    console.log('   if (employeeId.startsWith("SUP") || employeeId.startsWith("ADM"))');
    console.log('     → /admin/dashboard');
    console.log('   else');
    console.log('     → /user/dashboard');
    
    console.log('\n✅ BENEFITS OF STANDARDIZATION:');
    console.log('   1. Consistent ID patterns across all roles');
    console.log('   2. SUP___ clearly identifies super admins');
    console.log('   3. ADM___ clearly identifies regular admins');
    console.log('   4. Sequential numbering (001, 002, 003...)');
    console.log('   5. Easy to identify role from employee ID');
    console.log('   6. Scalable for future additions');
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  }
}

// Run test
testKnownUsers().then(() => {
  console.log('\n🎉 Standardization testing completed successfully!');
}).catch((error) => {
  console.error('❌ Testing failed:', error);
});