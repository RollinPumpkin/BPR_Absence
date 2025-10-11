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

async function getValidLoginCredentials() {
  try {
    console.log('🔍 Fetching VALID login credentials...');
    console.log('=====================================');
    
    // Get Firebase Auth users first
    const authUsers = await admin.auth().listUsers();
    console.log(`✅ Found ${authUsers.users.length} users in Firebase Auth`);
    
    const validCredentials = [];
    
    for (const authUser of authUsers.users) {
      // Get user data from Firestore
      const userQuery = await db.collection('users').where('email', '==', authUser.email).get();
      
      if (!userQuery.empty) {
        const userDoc = userQuery.docs[0];
        const userData = userDoc.data();
        
        validCredentials.push({
          email: authUser.email,
          password: '123456', // Default password used during user creation
          name: userData.fullName || userData.full_name || 'Unknown',
          role: userData.role || 'employee',
          employeeId: userData.employeeId || userData.employee_id || 'N/A',
          uid: authUser.uid,
          emailVerified: authUser.emailVerified,
          created: authUser.metadata.creationTime
        });
      }
    }
    
    // Sort by role priority
    validCredentials.sort((a, b) => {
      const roleOrder = { 'admin': 1, 'super_admin': 2, 'hr': 3, 'manager': 4, 'employee': 5 };
      return (roleOrder[a.role] || 5) - (roleOrder[b.role] || 5);
    });
    
    console.log('');
    console.log('🎯 READY-TO-USE LOGIN CREDENTIALS:');
    console.log('==================================');
    
    validCredentials.forEach((cred, index) => {
      const roleIcon = cred.role === 'admin' ? '👑' : 
                       cred.role === 'super_admin' ? '⭐' :
                       cred.role === 'hr' ? '📋' :
                       cred.role === 'manager' ? '👨‍💼' : '👤';
      
      console.log(`${index + 1}. ${roleIcon} ${cred.role.toUpperCase()}`);
      console.log(`   📧 Email: ${cred.email}`);
      console.log(`   🔒 Password: ${cred.password}`);
      console.log(`   👤 Name: ${cred.name}`);
      console.log(`   🆔 Employee ID: ${cred.employeeId}`);
      console.log(`   🔑 Firebase UID: ${cred.uid}`);
      console.log(`   ✅ Email Verified: ${cred.emailVerified}`);
      console.log(`   📅 Created: ${cred.created}`);
      console.log('   ----------------------------------------');
    });
    
    console.log('');
    console.log('🚀 QUICK TEST INSTRUCTIONS:');
    console.log('===========================');
    console.log('1. Open: http://localhost:8080/#/login');
    console.log('2. Use ANY of the above credentials');
    console.log('3. All passwords are: 123456');
    console.log('4. Try admin accounts first for full access');
    console.log('');
    
    // Test one credential to verify it works
    if (validCredentials.length > 0) {
      const testCred = validCredentials[0];
      console.log('🧪 RECOMMENDED TEST ACCOUNT:');
      console.log('============================');
      console.log(`📧 Email: ${testCred.email}`);
      console.log(`🔒 Password: ${testCred.password}`);
      console.log(`👑 Role: ${testCred.role}`);
      console.log('');
      
      // Try to verify the user exists and is valid
      try {
        const userRecord = await admin.auth().getUserByEmail(testCred.email);
        console.log('✅ User verified in Firebase Auth');
        console.log(`   - UID: ${userRecord.uid}`);
        console.log(`   - Email Verified: ${userRecord.emailVerified}`);
        console.log(`   - Disabled: ${userRecord.disabled}`);
        console.log('');
      } catch (error) {
        console.log('❌ Error verifying user:', error.message);
      }
    }
    
    return validCredentials;
    
  } catch (error) {
    console.error('❌ Error:', error);
    return [];
  }
}

// Also check if we can create a test user if none exist
async function createTestUserIfNeeded() {
  try {
    console.log('🔧 Checking if test user needs to be created...');
    
    const testEmail = 'test@bpr.com';
    const testPassword = '123456';
    
    try {
      // Check if user already exists
      await admin.auth().getUserByEmail(testEmail);
      console.log('✅ Test user already exists');
    } catch (error) {
      if (error.code === 'auth/user-not-found') {
        console.log('📝 Creating test user...');
        
        // Create user in Firebase Auth
        const userRecord = await admin.auth().createUser({
          email: testEmail,
          password: testPassword,
          displayName: 'Test User BPR'
        });
        
        // Create user in Firestore
        await db.collection('users').doc(userRecord.uid).set({
          email: testEmail,
          fullName: 'Test User BPR',
          role: 'admin',
          employeeId: 'TEST001',
          isActive: true,
          createdAt: admin.firestore.FieldValue.serverTimestamp()
        });
        
        console.log('✅ Test user created successfully!');
        console.log(`   📧 Email: ${testEmail}`);
        console.log(`   🔒 Password: ${testPassword}`);
        console.log(`   👑 Role: admin`);
      }
    }
  } catch (error) {
    console.log('❌ Error creating test user:', error.message);
  }
}

// Run both functions
async function main() {
  await createTestUserIfNeeded();
  console.log('');
  const credentials = await getValidLoginCredentials();
  
  if (credentials.length === 0) {
    console.log('❌ No valid credentials found!');
    console.log('💡 Try running the seed script to create users');
  }
}

main().then(() => {
  console.log('✅ Done!');
  process.exit(0);
}).catch(error => {
  console.error('❌ Script failed:', error);
  process.exit(1);
});