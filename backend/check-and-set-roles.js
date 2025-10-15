// Check and set roles for all users
const admin = require('firebase-admin');

// Initialize Firebase Admin
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json')
  });
}

const db = admin.firestore();

async function checkAndSetRoles() {
  try {
    console.log('\n🔍 CHECKING ALL USER ROLES');
    console.log('===========================');
    
    const usersRef = db.collection('users');
    const snapshot = await usersRef.get();
    
    if (snapshot.empty) {
      console.log('❌ No users found');
      return;
    }
    
    console.log(`📋 Found ${snapshot.size} users:`);
    
    let count = 1;
    for (const doc of snapshot.docs) {
      const userData = doc.data();
      console.log(`\n${count}. 👤 User: ${userData.email}`);
      console.log(`   Employee ID: ${userData.employee_id}`);
      console.log(`   Current Role: ${userData.role || 'NOT SET'}`);
      console.log(`   Full Name: ${userData.full_name}`);
      
      // Determine correct role based on employee_id pattern
      let correctRole = '';
      if (userData.employee_id?.startsWith('SUP')) {
        correctRole = 'super_admin';
      } else if (userData.employee_id?.startsWith('ADM')) {
        correctRole = 'admin';
      } else {
        correctRole = 'employee';
      }
      
      console.log(`   Expected Role: ${correctRole}`);
      
      // Update role if different
      if (userData.role !== correctRole) {
        console.log(`   🔄 UPDATING role from "${userData.role}" to "${correctRole}"`);
        
        await usersRef.doc(doc.id).update({
          role: correctRole,
          updated_at: admin.firestore.FieldValue.serverTimestamp()
        });
        
        console.log(`   ✅ Role updated successfully`);
      } else {
        console.log(`   ✅ Role already correct`);
      }
      
      count++;
    }
    
    console.log('\n🎯 ROLE ASSIGNMENT SUMMARY:');
    console.log('============================');
    console.log('SUP*** Employee IDs → super_admin role');
    console.log('ADM*** Employee IDs → admin role');
    console.log('EMP*** Employee IDs → employee role');
    console.log('Other Employee IDs → employee role');
    
    console.log('\n✅ All user roles verified and updated!');
    
  } catch (error) {
    console.error('Error checking/setting roles:', error);
  }
}

checkAndSetRoles();