const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://bpr-absens-default-rtdb.firebaseio.com"
});

const db = admin.firestore();

async function auditEmployeeIds() {
  try {
    console.log('🔍 Auditing all employee IDs in database...');
    
    // Get all users from Firestore
    const usersRef = db.collection('users');
    const snapshot = await usersRef.get();
    
    if (snapshot.empty) {
      console.log('❌ No users found in database');
      return;
    }
    
    const allUsers = [];
    snapshot.forEach(doc => {
      const userData = { id: doc.id, ...doc.data() };
      allUsers.push(userData);
    });
    
    console.log(`\n📊 Total users found: ${allUsers.length}`);
    console.log('\n📋 Current Employee ID Patterns:');
    
    // Group by role and show patterns
    const roleGroups = {};
    const idPrefixes = {};
    
    allUsers.forEach(user => {
      const role = user.role || 'unknown';
      const employeeId = user.employee_id || 'no-id';
      const prefix = employeeId.length >= 3 ? employeeId.substring(0, 3) : employeeId;
      
      if (!roleGroups[role]) roleGroups[role] = [];
      roleGroups[role].push(user);
      
      if (!idPrefixes[prefix]) idPrefixes[prefix] = [];
      idPrefixes[prefix].push(user);
    });
    
    console.log('\n🏷️ Current Users by Role:');
    Object.keys(roleGroups).forEach(role => {
      console.log(`\n   ${role.toUpperCase()}:`);
      roleGroups[role].forEach(user => {
        console.log(`     📧 ${user.email || 'no-email'} | 🆔 ${user.employee_id || 'no-id'} | 👤 ${user.full_name || 'no-name'}`);
      });
    });
    
    console.log('\n🔤 Current ID Prefixes:');
    Object.keys(idPrefixes).forEach(prefix => {
      console.log(`\n   ${prefix}::`);
      idPrefixes[prefix].forEach(user => {
        console.log(`     📧 ${user.email || 'no-email'} | 👑 ${user.role || 'no-role'} | 👤 ${user.full_name || 'no-name'}`);
      });
    });
    
    console.log('\n💡 Proposed Standardization:');
    console.log('   SUP001, SUP002, ... : Super Admin');
    console.log('   ADM001, ADM002, ... : Admin');
    console.log('   EMP001, EMP002, ... : Employee');
    console.log('   AO001, AO002, ...   : Account Officer');
    console.log('   OB001, OB002, ...   : Office Boy');
    console.log('   SCR001, SCR002, ... : Security');
    
    console.log('\n📝 Suggested ID Mapping:');
    allUsers.forEach((user, index) => {
      const role = user.role || 'employee';
      const currentId = user.employee_id || 'no-id';
      
      let newPrefix = 'EMP';
      switch(role) {
        case 'super_admin': newPrefix = 'SUP'; break;
        case 'admin': newPrefix = 'ADM'; break;
        case 'account_officer': newPrefix = 'AO'; break;
        case 'security': newPrefix = 'SCR'; break;
        case 'office_boy': newPrefix = 'OB'; break;
        default: newPrefix = 'EMP'; break;
      }
      
      // Generate sequential number for each role
      const roleUsers = roleGroups[role] || [];
      const roleIndex = roleUsers.findIndex(u => u.email === user.email) + 1;
      const newId = `${newPrefix}${String(roleIndex).padStart(3, '0')}`;
      
      if (currentId !== newId) {
        console.log(`   🔄 ${user.email || user.full_name} : ${currentId} → ${newId}`);
      }
    });
    
  } catch (error) {
    console.error('❌ Error auditing employee IDs:', error);
  }
}

// Run audit
auditEmployeeIds().then(() => {
  console.log('\n✅ Employee ID audit completed');
  process.exit(0);
}).catch((error) => {
  console.error('❌ Audit failed:', error);
  process.exit(1);
});