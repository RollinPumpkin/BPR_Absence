const admin = require('firebase-admin');
const bcrypt = require('bcryptjs');
const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

// Initialize Firebase Admin
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

const db = admin.firestore();
const auth = admin.auth();

async function registerRealEmail() {
  try {
    console.log('🔧 Registering your real Gmail account...');
    
    const email = 'septapuma@gmail.com';
    const password = '123456'; // Standard test password
    const employeeId = 'REAL001'; // Real user
    
    // 1. Create Firebase Authentication user
    console.log('1️⃣ Creating Firebase Auth user...');
    let firebaseUser;
    try {
      firebaseUser = await auth.createUser({
        email: email,
        password: password,
        displayName: 'Septa Puma',
        emailVerified: true, // Mark as verified for testing
        disabled: false
      });
      console.log(`✅ Firebase Auth user created with UID: ${firebaseUser.uid}`);
    } catch (authError) {
      if (authError.code === 'auth/email-already-exists') {
        console.log('📧 Email already exists in Firebase Auth, getting existing user...');
        firebaseUser = await auth.getUserByEmail(email);
        console.log(`✅ Found existing Firebase user with UID: ${firebaseUser.uid}`);
        
        // Update password and settings
        await auth.updateUser(firebaseUser.uid, {
          password: password,
          emailVerified: true,
          disabled: false
        });
        console.log('✅ Updated Firebase Auth user');
      } else {
        throw authError;
      }
    }
    
    // 2. Hash password for Firestore
    console.log('2️⃣ Creating Firestore user document...');
    const hashedPassword = await bcrypt.hash(password, 10);
    
    // 3. Create/Update Firestore user document
    const userDocRef = db.collection('users').doc(firebaseUser.uid);
    const userData = {
      employee_id: employeeId,
      full_name: 'Septa Puma',
      email: email,
      password: hashedPassword,
      phone: '+62812345678',
      department: 'IT Department',
      position: 'Software Developer',
      role: 'employee',
      profile_picture: null,
      address: 'Jakarta, Indonesia',
      date_of_birth: '1995-01-01',
      join_date: '2025-10-19',
      status: 'active',
      is_active: true,
      firebase_uid: firebaseUser.uid,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
      updated_at: admin.firestore.FieldValue.serverTimestamp()
    };
    
    await userDocRef.set(userData);
    console.log('✅ Firestore user document created');
    
    // 4. Verify the setup
    console.log('3️⃣ Verifying setup...');
    const userDoc = await userDocRef.get();
    const verifyData = userDoc.data();
    
    console.log('📋 User Registration Complete!');
    console.log('================================');
    console.log(`📧 Email: ${email}`);
    console.log(`🔒 Password: ${password}`);
    console.log(`👤 Name: ${verifyData.full_name}`);
    console.log(`🆔 Employee ID: ${verifyData.employee_id}`);
    console.log(`📱 Role: ${verifyData.role}`);
    console.log(`🔑 Firebase UID: ${verifyData.firebase_uid}`);
    console.log(`✅ Account Status: ${verifyData.status}`);
    
    console.log('\n🧪 READY TO TEST:');
    console.log('==================');
    console.log('1. ✅ You can now login with this account');
    console.log('2. ✅ You can test forgot password (mock version)');
    console.log('3. 📧 To enable REAL emails, follow the next steps...');
    
  } catch (error) {
    console.error('❌ Error registering email:', error);
  }
}

// Run the registration
registerRealEmail().then(() => {
  console.log('\n✅ Registration completed');
  process.exit(0);
}).catch((error) => {
  console.error('❌ Registration failed:', error);
  process.exit(1);
});