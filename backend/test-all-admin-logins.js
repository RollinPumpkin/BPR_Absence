const axios = require('axios');

async function testAllAdminLogins() {
  console.log('🧪 TESTING ALL ADMIN LOGIN ACCOUNTS\n');
  
  const adminAccounts = [
    { email: 'admin@gmail.com', password: '123456', expected_id: 'SUP001', expected_role: 'super_admin' },
    { email: 'test@bpr.com', password: '123456', expected_id: 'ADM003', expected_role: 'admin' },
    { email: 'superadmin@bpr.com', password: '123456', expected_id: 'SUP002', expected_role: 'super_admin' },
    { email: 'superadmin@gmail.com', password: '123456', expected_id: 'SUP003', expected_role: 'super_admin' }
  ];
  
  for (const account of adminAccounts) {
    console.log(`🔍 Testing: ${account.email}`);
    
    try {
      const response = await axios.post('http://localhost:3000/api/auth/login', {
        email: account.email,
        password: account.password
      }, {
        headers: { 'Content-Type': 'application/json' }
      });
      
      if (response.data.success && response.data.data?.user) {
        const user = response.data.data.user;
        
        console.log(`   ✅ Login successful`);
        console.log(`   👤 Role: "${user.role}" (Expected: "${account.expected_role}")`);
        console.log(`   🆔 Employee ID: "${user.employee_id}" (Expected: "${account.expected_id}")`);
        console.log(`   📧 Email: "${user.email}"`);
        console.log(`   👨‍💼 Name: "${user.full_name}"`);
        
        // Verify routing logic
        const hasAdminEmployeeId = user.employee_id?.startsWith('SUP') || user.employee_id?.startsWith('ADM');
        const hasAdminRole = user.role === 'admin' || user.role === 'super_admin';
        const shouldAccessAdmin = hasAdminEmployeeId || hasAdminRole;
        const expectedRoute = shouldAccessAdmin ? '/admin/dashboard' : '/user/dashboard';
        
        console.log(`   🎯 Employee ID Pattern: ${hasAdminEmployeeId ? '✅ ADMIN' : '❌ NOT_ADMIN'}`);
        console.log(`   🎯 Role Check: ${hasAdminRole ? '✅ ADMIN' : '❌ NOT_ADMIN'}`);
        console.log(`   🧭 Expected Route: ${expectedRoute}`);
        
        if (expectedRoute === '/admin/dashboard') {
          console.log(`   🎉 ${account.email}: SHOULD ROUTE TO ADMIN DASHBOARD ✅`);
        } else {
          console.log(`   ❌ ${account.email}: WOULD ROUTE TO USER DASHBOARD`);
        }
        
      } else {
        console.log(`   ❌ Login failed: ${response.data.message || 'Unknown error'}`);
      }
      
    } catch (error) {
      console.log(`   ❌ API Error: ${error.response?.data?.message || error.message}`);
    }
    
    console.log('─'.repeat(50));
  }
  
  console.log('\n🎯 FRONTEND TEST RECOMMENDATIONS:');
  console.log('');
  console.log('Try these accounts in frontend to verify employee_id priority routing:');
  console.log('');
  adminAccounts.forEach((account, index) => {
    console.log(`${index + 1}. Email: ${account.email}`);
    console.log(`   Password: ${account.password}`);
    console.log(`   Expected: ${account.expected_id} → Admin Dashboard`);
    console.log('');
  });
  
  console.log('🔧 With the updated routing logic:');
  console.log('- Employee ID pattern (SUP*/ADM*) takes PRIORITY');
  console.log('- Role check is FALLBACK');
  console.log('- All these accounts should route to admin dashboard');
}

testAllAdminLogins();