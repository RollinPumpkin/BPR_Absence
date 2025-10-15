const axios = require('axios');

const BASE_URL = 'http://localhost:3000/api';

async function testAllUserAccess() {
  try {
    console.log('🧪 Testing All User Access with Standardized Employee IDs');
    console.log('=' .repeat(60));
    
    // Test key users across different roles
    const testUsers = [
      // Super Admins
      { email: 'admin@gmail.com', password: '123456', expectedId: 'SUP001', expectedRole: 'super_admin', expectedRoute: 'admin' },
      { email: 'superadmin@bpr.com', password: '123456', expectedId: 'SUP002', expectedRole: 'super_admin', expectedRoute: 'admin' },
      { email: 'superadmin@gmail.com', password: '123456', expectedId: 'SUP003', expectedRole: 'super_admin', expectedRoute: 'admin' },
      
      // Admins
      { email: 'admin@bpr.com', password: '123456', expectedId: 'ADM001', expectedRole: 'admin', expectedRoute: 'admin' },
      { email: 'test@bpr.com', password: '123456', expectedId: 'ADM003', expectedRole: 'admin', expectedRoute: 'admin' },
      
      // Regular Employees
      { email: 'ahmad.wijaya@bpr.com', password: '123456', expectedId: 'EMP001', expectedRole: 'employee', expectedRoute: 'user' },
      { email: 'user@gmail.com', password: '123456', expectedId: 'EMP008', expectedRole: 'employee', expectedRoute: 'user' },
      
      // Account Officers
      { email: 'maya.indira@bpr.com', password: '123456', expectedId: 'AO001', expectedRole: 'account_officer', expectedRoute: 'user' },
      { email: 'rizki.pratama@bpr.com', password: '123456', expectedId: 'AO002', expectedRole: 'account_officer', expectedRoute: 'user' },
      
      // Office Boy
      { email: 'agus.setiawan@bpr.com', password: '123456', expectedId: 'OB001', expectedRole: 'office_boy', expectedRoute: 'user' },
      
      // Security
      { email: 'budi.hartono@bpr.com', password: '123456', expectedId: 'SCR001', expectedRole: 'security', expectedRoute: 'user' },
      { email: 'joko.susanto@bpr.com', password: '123456', expectedId: 'SCR002', expectedRole: 'security', expectedRoute: 'user' }
    ];
    
    const results = {
      total: testUsers.length,
      passed: 0,
      failed: 0,
      details: []
    };
    
    console.log(`\n📋 Testing ${testUsers.length} users...\n`);
    
    for (const testUser of testUsers) {
      try {
        console.log(`🔍 Testing: ${testUser.email}`);
        
        const response = await axios.post(`${BASE_URL}/auth/login`, {
          email: testUser.email,
          password: testUser.password
        });
        
        if (response.data.success) {
          const { user } = response.data.data;
          
          // Verify employee ID
          const employeeIdMatch = user.employee_id === testUser.expectedId;
          const roleMatch = user.role === testUser.expectedRole;
          
          // Apply routing logic
          const hasAdminRole = user.role === 'admin' || user.role === 'super_admin';
          const hasAdminEmployeeId = user.employee_id.startsWith('SUP') || user.employee_id.startsWith('ADM');
          const shouldAccessAdmin = hasAdminRole || hasAdminEmployeeId;
          const actualRoute = shouldAccessAdmin ? 'admin' : 'user';
          const routeMatch = actualRoute === testUser.expectedRoute;
          
          const allMatch = employeeIdMatch && roleMatch && routeMatch;
          
          if (allMatch) {
            console.log(`   ✅ PASS`);
            results.passed++;
          } else {
            console.log(`   ❌ FAIL`);
            results.failed++;
          }
          
          console.log(`      Employee ID: ${user.employee_id} ${employeeIdMatch ? '✅' : '❌ Expected: ' + testUser.expectedId}`);
          console.log(`      Role: ${user.role} ${roleMatch ? '✅' : '❌ Expected: ' + testUser.expectedRole}`);
          console.log(`      Route: /${actualRoute}/dashboard ${routeMatch ? '✅' : '❌ Expected: /' + testUser.expectedRoute + '/dashboard'}`);
          
          results.details.push({
            email: testUser.email,
            status: allMatch ? 'PASS' : 'FAIL',
            employeeId: user.employee_id,
            role: user.role,
            route: actualRoute,
            issues: [
              !employeeIdMatch ? `ID mismatch: got ${user.employee_id}, expected ${testUser.expectedId}` : null,
              !roleMatch ? `Role mismatch: got ${user.role}, expected ${testUser.expectedRole}` : null,
              !routeMatch ? `Route mismatch: got ${actualRoute}, expected ${testUser.expectedRoute}` : null
            ].filter(Boolean)
          });
          
        } else {
          console.log(`   ❌ FAIL - Login failed: ${response.data.message}`);
          results.failed++;
          results.details.push({
            email: testUser.email,
            status: 'FAIL',
            issues: ['Login failed: ' + response.data.message]
          });
        }
        
      } catch (error) {
        console.log(`   ❌ FAIL - Error: ${error.response?.data?.message || error.message}`);
        results.failed++;
        results.details.push({
          email: testUser.email,
          status: 'FAIL',
          issues: ['Error: ' + (error.response?.data?.message || error.message)]
        });
      }
      
      console.log(''); // Empty line for readability
    }
    
    // Summary
    console.log('=' .repeat(60));
    console.log('📊 TEST SUMMARY');
    console.log('=' .repeat(60));
    console.log(`Total Tests: ${results.total}`);
    console.log(`✅ Passed: ${results.passed}`);
    console.log(`❌ Failed: ${results.failed}`);
    console.log(`Success Rate: ${Math.round((results.passed / results.total) * 100)}%`);
    
    if (results.failed > 0) {
      console.log('\n❌ FAILED TESTS:');
      results.details.filter(d => d.status === 'FAIL').forEach(detail => {
        console.log(`   ${detail.email}:`);
        detail.issues.forEach(issue => console.log(`     - ${issue}`));
      });
    }
    
    console.log('\n🎯 STANDARDIZED EMPLOYEE ID PATTERNS:');
    console.log('   SUP001-003: Super Admins → Admin Dashboard');
    console.log('   ADM001-003: Admins → Admin Dashboard');
    console.log('   EMP001-008: Employees → User Dashboard');
    console.log('   AO001-002:  Account Officers → User Dashboard');
    console.log('   OB001:      Office Boy → User Dashboard');
    console.log('   SCR001-002: Security → User Dashboard');
    
    if (results.failed === 0) {
      console.log('\n🎉 ALL TESTS PASSED! Employee ID standardization is working correctly.');
    } else {
      console.log('\n⚠️  Some tests failed. Please check the issues above.');
    }
    
  } catch (error) {
    console.error('❌ Error in test suite:', error.message);
  }
}

// Run comprehensive test
testAllUserAccess().then(() => {
  console.log('\n✅ User access testing completed');
}).catch((error) => {
  console.error('❌ Testing failed:', error);
});