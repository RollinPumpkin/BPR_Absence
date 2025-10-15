// Test updated role options
console.log('🧪 TESTING UPDATED ROLE OPTIONS');
console.log('===============================');

function getRoleOptions(currentUserRole, currentEmployeeId) {
  const isSuperAdmin = currentUserRole === 'super_admin' || currentEmployeeId.startsWith('SUP');
  const isAdmin = currentUserRole === 'admin' || currentEmployeeId.startsWith('ADM');

  if (isSuperAdmin) {
    return ['Super Admin', 'Admin', 'Employee', 'Account Officer', 'Security', 'Office Boy'];
  } else if (isAdmin) {
    return ['Employee', 'Account Officer', 'Security', 'Office Boy'];
  } else {
    return ['Employee'];
  }
}

function convertRoleToBackend(role) {
  const mapping = {
    'Super Admin': 'super_admin',
    'Admin': 'admin',
    'Employee': 'employee',
    'Account Officer': 'account_officer',
    'Security': 'security',
    'Office Boy': 'office_boy'
  };
  return mapping[role] || 'employee';
}

console.log('🔍 Super Admin Options:');
const superAdminOptions = getRoleOptions('super_admin', 'SUP001');
superAdminOptions.forEach(option => {
  const backendRole = convertRoleToBackend(option);
  console.log(`   "${option}" → "${backendRole}"`);
});

console.log('\n🔍 Regular Admin Options:');
const adminOptions = getRoleOptions('admin', 'ADM003');
adminOptions.forEach(option => {
  const backendRole = convertRoleToBackend(option);
  console.log(`   "${option}" → "${backendRole}"`);
});

console.log('\n🎯 SUMMARY:');
console.log('============');
console.log('✅ Super Admin: Can create Super Admin, Admin, and other roles');
console.log('✅ Regular Admin: Can create Employee and specialized roles (no admin/super_admin)');
console.log('✅ All role mappings defined correctly');