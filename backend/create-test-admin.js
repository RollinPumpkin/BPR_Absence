const admin = require('firebase-admin');
const bcrypt = require('bcryptjs');
const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();
const auth = admin.auth();

async function createTestAdmin() {
  try {
    console.log('🔧 Creating test@bpr.com admin user...');
    
    const email = 'test@bpr.com';
    const password = '123456';
    const employeeId = 'TADM001'; // Test Admin
    
    // 1. Create Firebase Authentication user
    console.log('1️⃣ Creating Firebase Auth user...');
    let firebaseUser;
    try {
      firebaseUser = await auth.createUser({
        email: email,
        password: password,
        displayName: 'Test Admin',
        emailVerified: true,
        disabled: false
      });
      console.log(`✅ Firebase Auth user created with UID: ${firebaseUser.uid}`);
    } catch (authError) {
      if (authError.code === 'auth/email-already-exists') {
        console.log('📧 Email already exists in Firebase Auth, getting existing user...');
        firebaseUser = await auth.getUserByEmail(email);
        console.log(`✅ Found existing Firebase user with UID: ${firebaseUser.uid}`);
        
        // Update password
        await auth.updateUser(firebaseUser.uid, {
          password: password
        });
        console.log('🔑 Password updated');
      } else {
        throw authError;
      }
    }
    
    // 2. Hash password for Firestore
    const hashedPassword = await bcrypt.hash(password, 12);
    
    // 3. Create or update Firestore user document
    console.log('2️⃣ Creating/updating Firestore user document...');
    
    const userData = {
      employee_id: employeeId,
      full_name: 'Test Admin',
      email: email,
      password: hashedPassword,
      department: 'Management',
      position: 'System Administrator',
      phone: '+62812345678',
      role: 'admin',
      place_of_birth: 'Jakarta',
      date_of_birth: '1990-01-01',
      nik: '1234567890123456',
      account_holder_name: 'Test Admin',
      account_number: '1234567890',
      division: 'IT',
      gender: 'male',
      contract_type: 'permanent',
      bank: 'BCA',
      last_education: 'S1',
      warning_letter_type: 'none',
      firebase_uid: firebaseUser.uid,
      is_active: true,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
      updated_at: admin.firestore.FieldValue.serverTimestamp()
    };
    
    // Use Firebase UID as document ID for consistency
    await db.collection('users').doc(firebaseUser.uid).set(userData, { merge: true });
    console.log(`✅ Firestore user document created/updated with ID: ${firebaseUser.uid}`);
    
    // 4. Verify the user was created correctly
    console.log('3️⃣ Verifying user creation...');
    const userDoc = await db.collection('users').doc(firebaseUser.uid).get();
    
    if (userDoc.exists) {
      const user = userDoc.data();
      console.log('✅ User verification successful:');
      console.log(`   📧 Email: ${user.email}`);
      console.log(`   👤 Name: ${user.full_name}`);
      console.log(`   🆔 Employee ID: ${user.employee_id}`);
      console.log(`   👑 Role: ${user.role}`);
      console.log(`   🔥 Firebase UID: ${user.firebase_uid}`);
      console.log(`   ✅ Active: ${user.is_active}`);
    }
    
    console.log('\n🎉 SUCCESS! Test admin user created successfully!');
    console.log('\n📋 Login Credentials:');
    console.log(`   📧 Email: ${email}`);
    console.log(`   🔑 Password: ${password}`);
    console.log(`   👑 Role: admin`);
    console.log(`   🆔 Employee ID: ${employeeId}`);
    
    console.log('\n🚀 You can now login with these credentials and access the admin dashboard!');
    
  } catch (error) {
    console.error('❌ Error creating test admin:', error);
    
    if (error.code) {
      console.error(`Error Code: ${error.code}`);
    }
    
    if (error.message) {
      console.error(`Error Message: ${error.message}`);
    }
  }
}

// Run the function
createTestAdmin().then(() => {
  console.log('\n✅ Script completed');
  process.exit(0);
}).catch((error) => {
  console.error('❌ Script failed:', error);
  process.exit(1);
});