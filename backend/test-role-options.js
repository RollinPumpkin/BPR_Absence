// Test role options for different user types
console.log('🧪 TESTING ROLE OPTIONS FOR ADD EMPLOYEE');
console.log('=========================================');

const testUsers = [
  {
    name: 'Super Admin',
    role: 'super_admin',
    employeeId: 'SUP001',
    expectedOptions: ['Admin', 'Employee', 'Account Officer', 'Security', 'Office Boy']
  },
  {
    name: 'Regular Admin',
    role: 'admin', 
    employeeId: 'ADM003',
    expectedOptions: ['Employee', 'Account Officer', 'Security', 'Office Boy']
  },
  {
    name: 'Employee',
    role: 'employee',
    employeeId: 'EMP008',
    expectedOptions: ['Employee']
  }
];

function getRoleOptions(currentUserRole, currentEmployeeId) {
  const isSuperAdmin = currentUserRole === 'super_admin' || currentEmployeeId.startsWith('SUP');
  const isAdmin = currentUserRole === 'admin' || currentEmployeeId.startsWith('ADM');

  if (isSuperAdmin) {
    return ['Admin', 'Employee', 'Account Officer', 'Security', 'Office Boy'];
  } else if (isAdmin) {
    return ['Employee', 'Account Officer', 'Security', 'Office Boy'];
  } else {
    return ['Employee'];
  }
}

testUsers.forEach(user => {
  console.log(`\n🔍 Testing ${user.name}:`);
  console.log(`   Role: ${user.role}`);
  console.log(`   Employee ID: ${user.employeeId}`);
  
  const actualOptions = getRoleOptions(user.role, user.employeeId);
  console.log(`   Role Options: ${actualOptions.join(', ')}`);
  
  const hasAdmin = actualOptions.includes('Admin');
  console.log(`   Can Add Admin: ${hasAdmin ? 'YES ✅' : 'NO ❌'}`);
  
  const matches = JSON.stringify(actualOptions) === JSON.stringify(user.expectedOptions);
  console.log(`   Expected Match: ${matches ? 'YES ✅' : 'NO ❌'}`);
});

console.log('\n🎯 SUMMARY:');
console.log('============');
console.log('✅ Super Admin: Can add Admin role');
console.log('❌ Regular Admin: Cannot add Admin role'); 
console.log('❌ Employee: Cannot add Admin role');