const admin = require('firebase-admin');
const bcrypt = require('bcryptjs');
const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();
const auth = admin.auth();

async function fixTestAdminPassword() {
  try {
    console.log('🔧 Fixing test@bpr.com admin password...');
    
    const email = 'test@bpr.com';
    const password = '123456';
    
    // 1. Get Firebase user
    console.log('1️⃣ Getting Firebase Auth user...');
    const firebaseUser = await auth.getUserByEmail(email);
    console.log(`✅ Found Firebase user with UID: ${firebaseUser.uid}`);
    
    // 2. Update Firebase password
    console.log('2️⃣ Updating Firebase Auth password...');
    await auth.updateUser(firebaseUser.uid, {
      password: password,
      emailVerified: true,
      disabled: false
    });
    console.log('✅ Firebase password updated');
    
    // 3. Hash password correctly for Firestore
    console.log('3️⃣ Updating Firestore password hash...');
    const saltRounds = 10; // Use standard salt rounds
    const hashedPassword = await bcrypt.hash(password, saltRounds);
    
    console.log('🔍 Debug info:');
    console.log(`   Original password: ${password}`);
    console.log(`   Hashed password: ${hashedPassword}`);
    console.log(`   Salt rounds: ${saltRounds}`);
    
    // Test the hash
    const testVerify = await bcrypt.compare(password, hashedPassword);
    console.log(`   Hash verification test: ${testVerify ? '✅ PASS' : '❌ FAIL'}`);
    
    // 4. Update Firestore document
    await db.collection('users').doc(firebaseUser.uid).update({
      password: hashedPassword,
      updated_at: admin.firestore.FieldValue.serverTimestamp()
    });
    
    console.log('✅ Firestore password hash updated');
    
    // 5. Verify the update
    console.log('4️⃣ Verifying password update...');
    const userDoc = await db.collection('users').doc(firebaseUser.uid).get();
    
    if (userDoc.exists) {
      const userData = userDoc.data();
      console.log('✅ User data verified:');
      console.log(`   📧 Email: ${userData.email}`);
      console.log(`   👤 Name: ${userData.full_name}`);
      console.log(`   👑 Role: ${userData.role}`);
      console.log(`   🆔 Employee ID: ${userData.employee_id}`);
      console.log(`   🔑 Password hash updated: ${userData.password ? 'YES' : 'NO'}`);
      
      // Test password verification
      if (userData.password) {
        const passwordTest = await bcrypt.compare(password, userData.password);
        console.log(`   🧪 Password verification: ${passwordTest ? '✅ PASS' : '❌ FAIL'}`);
      }
    }
    
    console.log('\n🎉 SUCCESS! Password fixed successfully!');
    console.log('\n📋 Updated Login Credentials:');
    console.log(`   📧 Email: ${email}`);
    console.log(`   🔑 Password: ${password}`);
    console.log(`   👑 Role: admin`);
    console.log('\n🚀 Try logging in again now!');
    
  } catch (error) {
    console.error('❌ Error fixing password:', error);
    console.error('Error details:', error.message);
  }
}

// Run the function
fixTestAdminPassword().then(() => {
  console.log('\n✅ Password fix completed');
  process.exit(0);
}).catch((error) => {
  console.error('❌ Password fix failed:', error);
  process.exit(1);
});