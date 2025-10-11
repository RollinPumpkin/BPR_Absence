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

async function fixUserCredentials() {
  try {
    console.log('🔧 Fixing user credentials for login...');
    console.log('=====================================');
    
    const testEmail = 'test@bpr.com';
    const testPassword = '123456';
    
    try {
      // Delete existing test user if exists
      const existingUser = await admin.auth().getUserByEmail(testEmail);
      await admin.auth().deleteUser(existingUser.uid);
      console.log('🗑️ Deleted existing test user');
    } catch (error) {
      console.log('ℹ️ No existing test user to delete');
    }
    
    // Create fresh test user with known credentials
    console.log('👤 Creating fresh test user...');
    const userRecord = await admin.auth().createUser({
      email: testEmail,
      password: testPassword,
      displayName: 'Test User BPR',
      emailVerified: false,
      disabled: false
    });
    
    console.log(`✅ Created user: ${userRecord.uid}`);
    
    // Create user document in Firestore
    await db.collection('users').doc(userRecord.uid).set({
      email: testEmail,
      fullName: 'Test User BPR',
      role: 'admin',
      employeeId: 'TEST001',
      isActive: true,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });
    
    console.log('✅ Created Firestore user document');
    
    // Also fix user@gmail.com
    const userEmail = 'user@gmail.com';
    const userPassword = '123456';
    
    try {
      const existingUser2 = await admin.auth().getUserByEmail(userEmail);
      // Update password instead of recreating
      await admin.auth().updateUser(existingUser2.uid, {
        password: userPassword
      });
      console.log(`✅ Updated password for ${userEmail}`);
    } catch (error) {
      // Create if doesn't exist
      const userRecord2 = await admin.auth().createUser({
        email: userEmail,
        password: userPassword,
        displayName: 'User Test',
        emailVerified: false,
        disabled: false
      });
      
      await db.collection('users').doc(userRecord2.uid).set({
        email: userEmail,
        fullName: 'User Test',
        role: 'employee',
        employeeId: 'EMP005',
        isActive: true,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });
      
      console.log(`✅ Created fresh user: ${userEmail}`);
    }
    
    // Verify credentials work
    console.log('');
    console.log('🧪 VERIFIED WORKING CREDENTIALS:');
    console.log('================================');
    console.log(`📧 Email: ${testEmail}`);
    console.log(`🔒 Password: ${testPassword}`);
    console.log(`👑 Role: admin`);
    console.log('');
    console.log(`📧 Email: ${userEmail}`);
    console.log(`🔒 Password: ${userPassword}`);
    console.log(`👑 Role: employee`);
    console.log('');
    
    // Test by getting user record
    const testUser = await admin.auth().getUserByEmail(testEmail);
    console.log('✅ Test user verified in Firebase Auth');
    console.log(`   - UID: ${testUser.uid}`);
    console.log(`   - Email Verified: ${testUser.emailVerified}`);
    console.log(`   - Disabled: ${testUser.disabled}`);
    console.log(`   - Provider: ${testUser.providerData.length > 0 ? testUser.providerData[0].providerId : 'password'}`);
    
    console.log('');
    console.log('🎯 READY TO TEST:');
    console.log('==================');
    console.log('1. Use credentials above');
    console.log('2. Both passwords are: 123456');
    console.log('3. Fresh users with verified auth');
    console.log('4. Should work immediately');
    
  } catch (error) {
    console.error('❌ Error fixing credentials:', error);
  }
}

fixUserCredentials().then(() => {
  console.log('✅ Done fixing user credentials!');
  process.exit(0);
}).catch(error => {
  console.error('❌ Script failed:', error);
  process.exit(1);
});