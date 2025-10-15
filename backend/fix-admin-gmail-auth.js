const admin = require('firebase-admin');
const bcrypt = require('bcryptjs');
const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();
const auth = admin.auth();

async function fixAdminGmailAuth() {
  try {
    console.log('🔧 Fixing admin@gmail.com authentication issue...');
    
    const email = 'admin@gmail.com';
    const password = '123456'; // Standard password for testing
    
    // 1. Get Firebase Auth user
    console.log('1️⃣ Getting Firebase Auth user...');
    const firebaseUser = await auth.getUserByEmail(email);
    console.log(`   ✅ Firebase UID: ${firebaseUser.uid}`);
    console.log(`   📧 Email: ${firebaseUser.email}`);
    console.log(`   🚫 Disabled: ${firebaseUser.disabled}`);
    
    // 2. Get current Firestore user
    console.log('\n2️⃣ Getting current Firestore user...');
    const userQuery = await db.collection('users').where('email', '==', email).get();
    
    if (userQuery.empty) {
      console.log('❌ No Firestore user found');
      return;
    }
    
    let currentUserDoc = null;
    let currentUserData = null;
    
    userQuery.forEach(doc => {
      currentUserDoc = doc;
      currentUserData = doc.data();
    });
    
    console.log(`   📄 Current Document ID: ${currentUserDoc.id}`);
    console.log(`   👤 Name: ${currentUserData.full_name}`);
    console.log(`   🆔 Employee ID: ${currentUserData.employee_id}`);
    console.log(`   👑 Role: ${currentUserData.role}`);
    
    // 3. Update Firebase Auth password
    console.log('\n3️⃣ Updating Firebase Auth password...');
    await auth.updateUser(firebaseUser.uid, {
      password: password,
      emailVerified: true,
      disabled: false
    });
    console.log('   ✅ Firebase Auth password updated');
    
    // 4. Create proper password hash
    console.log('\n4️⃣ Creating proper password hash...');
    const hashedPassword = await bcrypt.hash(password, 10);
    console.log('   ✅ Password hash created');
    
    // Test the hash
    const hashTest = await bcrypt.compare(password, hashedPassword);
    console.log(`   🧪 Hash verification: ${hashTest ? '✅ PASS' : '❌ FAIL'}`);
    
    // 5. Create new Firestore document with correct ID
    console.log('\n5️⃣ Creating new Firestore document with correct Firebase UID...');
    
    const correctUserData = {
      ...currentUserData,
      firebase_uid: firebaseUser.uid,
      password: hashedPassword,
      is_active: true,
      updated_at: admin.firestore.FieldValue.serverTimestamp()
    };
    
    // Create document with Firebase UID as document ID
    await db.collection('users').doc(firebaseUser.uid).set(correctUserData, { merge: true });
    console.log(`   ✅ New document created with ID: ${firebaseUser.uid}`);
    
    // 6. Delete old document if it has different ID
    if (currentUserDoc.id !== firebaseUser.uid) {
      console.log('\n6️⃣ Removing old document with incorrect ID...');
      await db.collection('users').doc(currentUserDoc.id).delete();
      console.log(`   ✅ Deleted old document: ${currentUserDoc.id}`);
    }
    
    // 7. Verify the fix
    console.log('\n7️⃣ Verifying the fix...');
    const verifyDoc = await db.collection('users').doc(firebaseUser.uid).get();
    
    if (verifyDoc.exists) {
      const verifyData = verifyDoc.data();
      console.log('   ✅ Verification successful:');
      console.log(`   📄 Document ID: ${verifyDoc.id}`);
      console.log(`   📧 Email: ${verifyData.email}`);
      console.log(`   👤 Name: ${verifyData.full_name}`);
      console.log(`   🆔 Employee ID: ${verifyData.employee_id}`);
      console.log(`   👑 Role: ${verifyData.role}`);
      console.log(`   🔥 Firebase UID: ${verifyData.firebase_uid}`);
      console.log(`   🔑 Has Password: ${verifyData.password ? 'YES' : 'NO'}`);
      console.log(`   ✅ Active: ${verifyData.is_active}`);
      
      // Test password
      if (verifyData.password) {
        const passwordTest = await bcrypt.compare(password, verifyData.password);
        console.log(`   🧪 Password test: ${passwordTest ? '✅ PASS' : '❌ FAIL'}`);
      }
      
      // Check consistency
      const isConsistent = verifyDoc.id === verifyData.firebase_uid;
      console.log(`   🔗 ID Consistency: ${isConsistent ? '✅ CONSISTENT' : '❌ INCONSISTENT'}`);
    }
    
    console.log('\n🎉 SUCCESS! admin@gmail.com authentication fixed!');
    console.log('\n📋 Updated Login Credentials:');
    console.log(`   📧 Email: ${email}`);
    console.log(`   🔑 Password: ${password}`);
    console.log(`   👑 Role: ${currentUserData.role}`);
    console.log('\n🚀 You can now login successfully!');
    
  } catch (error) {
    console.error('❌ Error fixing admin@gmail.com:', error);
    console.error('Error message:', error.message);
    if (error.code) {
      console.error('Error code:', error.code);
    }
  }
}

// Run the fix
fixAdminGmailAuth().then(() => {
  console.log('\n✅ Fix completed');
  process.exit(0);
}).catch((error) => {
  console.error('❌ Fix failed:', error);
  process.exit(1);
});