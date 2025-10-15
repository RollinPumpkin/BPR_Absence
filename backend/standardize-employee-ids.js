const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://bpr-absens-default-rtdb.firebaseio.com"
});

const db = admin.firestore();

async function standardizeEmployeeIds() {
  try {
    console.log('🔧 Standardizing all employee IDs...');
    
    // Define the new standardized pattern
    const ROLE_PREFIX_MAP = {
      'super_admin': 'SUP',
      'admin': 'ADM', 
      'employee': 'EMP',
      'account_officer': 'AO',
      'office_boy': 'OB',
      'security': 'SCR'
    };
    
    console.log('\n📋 New Employee ID Standards:');
    Object.entries(ROLE_PREFIX_MAP).forEach(([role, prefix]) => {
      console.log(`   ${role.toUpperCase().padEnd(15)} → ${prefix}001, ${prefix}002, ${prefix}003...`);
    });
    
    // Get all users
    const usersRef = db.collection('users');
    const snapshot = await usersRef.get();
    
    if (snapshot.empty) {
      console.log('❌ No users found');
      return;
    }
    
    const allUsers = [];
    snapshot.forEach(doc => {
      const userData = { docId: doc.id, ...doc.data() };
      allUsers.push(userData);
    });
    
    // Group users by role to assign sequential numbers
    const usersByRole = {};
    allUsers.forEach(user => {
      const role = user.role || 'employee';
      if (!usersByRole[role]) usersByRole[role] = [];
      usersByRole[role].push(user);
    });
    
    // Sort users within each role by email for consistency
    Object.keys(usersByRole).forEach(role => {
      usersByRole[role].sort((a, b) => (a.email || '').localeCompare(b.email || ''));
    });
    
    const updates = [];
    
    console.log('\n🔄 ID Mapping and Updates:');
    
    // Generate new IDs for each role
    Object.entries(usersByRole).forEach(([role, users]) => {
      const prefix = ROLE_PREFIX_MAP[role] || 'EMP';
      
      console.log(`\n   ${role.toUpperCase()}:`);
      
      users.forEach((user, index) => {
        const newEmployeeId = `${prefix}${String(index + 1).padStart(3, '0')}`;
        const currentId = user.employee_id || 'no-id';
        
        if (currentId !== newEmployeeId) {
          console.log(`     📧 ${user.email || user.full_name}`);
          console.log(`        ${currentId} → ${newEmployeeId}`);
          
          updates.push({
            docId: user.docId,
            email: user.email,
            currentId: currentId,
            newId: newEmployeeId,
            role: role
          });
        } else {
          console.log(`     ✅ ${user.email || user.full_name} : ${currentId} (already correct)`);
        }
      });
    });
    
    console.log(`\n📊 Summary:`);
    console.log(`   Total users: ${allUsers.length}`);
    console.log(`   IDs to update: ${updates.length}`);
    console.log(`   IDs already correct: ${allUsers.length - updates.length}`);
    
    if (updates.length === 0) {
      console.log('✅ All employee IDs are already standardized!');
      return;
    }
    
    // Confirm before proceeding
    console.log('\n⚠️  Ready to update database with new employee IDs...');
    console.log('   This will modify user documents in Firestore.');
    
    // Update the database
    const batch = db.batch();
    
    updates.forEach(update => {
      const userRef = db.collection('users').doc(update.docId);
      batch.update(userRef, { employee_id: update.newId });
    });
    
    console.log('\n🚀 Executing batch update...');
    await batch.commit();
    
    console.log('✅ Batch update completed successfully!');
    
    // Verify updates
    console.log('\n🔍 Verifying updates...');
    for (const update of updates) {
      const userDoc = await db.collection('users').doc(update.docId).get();
      const userData = userDoc.data();
      const actualId = userData.employee_id;
      
      if (actualId === update.newId) {
        console.log(`   ✅ ${update.email}: ${actualId}`);
      } else {
        console.log(`   ❌ ${update.email}: Expected ${update.newId}, got ${actualId}`);
      }
    }
    
    console.log('\n🎯 New Standardized Employee ID Structure:');
    
    // Show final structure
    const finalSnapshot = await usersRef.get();
    const finalUsersByRole = {};
    
    finalSnapshot.forEach(doc => {
      const userData = doc.data();
      const role = userData.role || 'employee';
      if (!finalUsersByRole[role]) finalUsersByRole[role] = [];
      finalUsersByRole[role].push(userData);
    });
    
    Object.entries(finalUsersByRole).forEach(([role, users]) => {
      console.log(`\n   ${role.toUpperCase()}:`);
      users.sort((a, b) => (a.employee_id || '').localeCompare(b.employee_id || ''));
      users.forEach(user => {
        console.log(`     ${user.employee_id} | ${user.email || user.full_name}`);
      });
    });
    
  } catch (error) {
    console.error('❌ Error standardizing employee IDs:', error);
  }
}

// Run standardization
standardizeEmployeeIds().then(() => {
  console.log('\n✅ Employee ID standardization completed');
  process.exit(0);
}).catch((error) => {
  console.error('❌ Standardization failed:', error);
  process.exit(1);
});