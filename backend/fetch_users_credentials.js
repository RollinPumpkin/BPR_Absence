const admin = require('firebase-admin');
const path = require('path');

// Initialize Firebase Admin
const serviceAccountPath = path.join(__dirname, 'bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');
const serviceAccount = require(serviceAccountPath);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: `https://bpr-absens-default-rtdb.firebaseio.com/`
});

const db = admin.firestore();

async function fetchUsersCredentials() {
  try {
    console.log('🔍 Fetching users credentials from Firebase...');
    console.log('============================================');
    
    // Get all users from Firestore
    const usersSnapshot = await db.collection('users').get();
    
    if (usersSnapshot.empty) {
      console.log('❌ No users found in database');
      return;
    }
    
    console.log(`✅ Found ${usersSnapshot.size} users:`);
    console.log('');
    
    const users = [];
    usersSnapshot.forEach(doc => {
      const userData = doc.data();
      users.push({
        id: doc.id,
        email: userData.email || 'N/A',
        fullName: userData.fullName || userData.full_name || 'N/A',
        role: userData.role || 'employee',
        employeeId: userData.employeeId || userData.employee_id || 'N/A',
        isActive: userData.isActive !== false
      });
    });
    
    // Sort by role (admin first, then others)
    users.sort((a, b) => {
      if (a.role === 'admin' && b.role !== 'admin') return -1;
      if (a.role !== 'admin' && b.role === 'admin') return 1;
      return a.email.localeCompare(b.email);
    });
    
    console.log('📧 EMAIL CREDENTIALS FOR TESTING:');
    console.log('=================================');
    
    users.forEach((user, index) => {
      const roleIcon = user.role === 'admin' ? '👑' : 
                       user.role === 'hr' ? '📋' : '👤';
      const statusIcon = user.isActive ? '✅' : '❌';
      
      console.log(`${index + 1}. ${roleIcon} ${user.role.toUpperCase()}`);
      console.log(`   📧 Email: ${user.email}`);
      console.log(`   👤 Name: ${user.fullName}`);
      console.log(`   🆔 Employee ID: ${user.employeeId}`);
      console.log(`   ${statusIcon} Status: ${user.isActive ? 'Active' : 'Inactive'}`);
      console.log(`   🔒 Default Password: 123456 (or check user creation)`);
      console.log('   ----------------------------------------');
    });
    
    console.log('');
    console.log('💡 TESTING RECOMMENDATIONS:');
    console.log('============================');
    console.log('1. Try logging in with admin accounts first');
    console.log('2. Default password is usually "123456"');
    console.log('3. If password doesn\'t work, check if user was created with different password');
    console.log('4. Make sure Firebase Auth is properly configured');
    console.log('');
    
    // Get Firebase Auth users to compare
    console.log('🔐 Checking Firebase Auth users...');
    try {
      const authUsers = await admin.auth().listUsers();
      console.log(`✅ Firebase Auth has ${authUsers.users.length} users`);
      
      console.log('');
      console.log('🔗 FIREBASE AUTH USERS:');
      console.log('=======================');
      
      authUsers.users.forEach((authUser, index) => {
        console.log(`${index + 1}. ${authUser.email || 'No email'}`);
        console.log(`   🆔 UID: ${authUser.uid}`);
        console.log(`   ✅ Email Verified: ${authUser.emailVerified}`);
        console.log(`   📅 Created: ${authUser.metadata.creationTime}`);
        console.log('   ----------------------------------------');
      });
      
    } catch (authError) {
      console.log('❌ Error fetching Firebase Auth users:', authError.message);
    }
    
  } catch (error) {
    console.error('❌ Error fetching users:', error);
  }
}

// Run the function
fetchUsersCredentials().then(() => {
  console.log('✅ Done fetching user credentials');
  process.exit(0);
}).catch(error => {
  console.error('❌ Script failed:', error);
  process.exit(1);
});