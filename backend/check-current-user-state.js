const admin = require('firebase-admin');

// Initialize admin if not already done
if (!admin.apps.length) {
  const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

const db = admin.firestore();

async function checkCurrentUserState() {
  try {
    console.log('🔍 Checking what user is currently logged in based on role "employee"...');
    
    // Find users with role "employee" that might be confused with admin
    const employeeQuery = await db.collection('users')
      .where('role', '==', 'employee')
      .get();
    
    console.log(`\n📋 Found ${employeeQuery.size} users with role "employee":\n`);
    
    employeeQuery.forEach((doc, index) => {
      const data = doc.data();
      console.log(`${index + 1}. ${data.full_name}`);
      console.log(`   📧 Email: ${data.email}`);
      console.log(`   🆔 Employee ID: ${data.employee_id}`);
      console.log(`   👤 Role: ${data.role}`);
      console.log(`   📱 Status: ${data.status || 'undefined'} | Active: ${data.is_active}`);
      console.log(`   🔗 Firebase UID: ${data.firebase_uid || 'Not set'}`);
      
      // Check if this employee has admin-like employee ID
      if (data.employee_id?.startsWith('SUP') || data.employee_id?.startsWith('ADM')) {
        console.log(`   ⚠️  WARNING: Employee with admin-like ID pattern!`);
      }
      console.log('');
    });
    
    // Also check the specific user from console log
    console.log('\n🔍 Checking admin@gmail.com specifically...');
    const adminQuery = await db.collection('users')
      .where('email', '==', 'admin@gmail.com')
      .limit(1)
      .get();
    
    if (!adminQuery.empty) {
      const adminData = adminQuery.docs[0].data();
      console.log('\n✅ admin@gmail.com in database:');
      console.log(`   📧 Email: ${adminData.email}`);
      console.log(`   🆔 Employee ID: ${adminData.employee_id}`);
      console.log(`   👤 Role: ${adminData.role}`);
      console.log(`   📱 Status: ${adminData.status || 'undefined'} | Active: ${adminData.is_active}`);
      console.log(`   🔗 Firebase UID: ${adminData.firebase_uid || 'Not set'}`);
      
      console.log('\n🤔 Analysis:');
      if (adminData.role === 'super_admin' && adminData.employee_id === 'SUP001') {
        console.log('   ✅ Data is CORRECT - should route to admin dashboard');
        console.log('   ❗ If getting "employee" role in frontend, user is NOT logging in with this account');
      } else {
        console.log('   ❌ Data mismatch found');
      }
    }
    
  } catch (error) {
    console.error('❌ Error:', error);
  }
  
  process.exit(0);
}

checkCurrentUserState();