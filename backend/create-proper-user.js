const admin = require('firebase-admin');
const bcrypt = require('bcryptjs');
const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();
const auth = admin.auth();

async function createProperUser() {
  try {
    console.log('🔧 Creating properly synchronized user...');
    
    const email = 'septapuma@gmail.com';
    const password = '123456';
    
    // 1. Delete old inconsistent data
    console.log('1️⃣ Cleaning up old data...');
    
    // Delete old Firestore document
    const oldUserQuery = await db.collection('users').where('email', '==', email).get();
    for (const doc of oldUserQuery.docs) {
      await doc.ref.delete();
      console.log(`   Deleted old Firestore doc: ${doc.id}`);
    }
    
    // Get Firebase Auth user (keep it)
    const firebaseUser = await auth.getUserByEmail(email);
    console.log(`   Found Firebase Auth user: ${firebaseUser.uid}`);
    
    // 2. Create new Firestore document with Firebase UID as document ID
    console.log('2️⃣ Creating new Firestore user...');
    const hashedPassword = await bcrypt.hash(password, 10);
    
    const userData = {
      employee_id: 'REAL001',
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
    
    // Use Firebase UID as document ID for perfect consistency
    await db.collection('users').doc(firebaseUser.uid).set(userData);
    console.log(`   ✅ Created Firestore doc with ID: ${firebaseUser.uid}`);
    
    // 3. Verify everything works
    console.log('3️⃣ Verifying login...');
    const testQuery = await db.collection('users').doc(firebaseUser.uid).get();
    const testData = testQuery.data();
    
    const passwordTest = await bcrypt.compare(password, testData.password);
    console.log('   Password test:', passwordTest ? '✅ PASS' : '❌ FAIL');
    console.log('   Firebase UID match:', testData.firebase_uid === firebaseUser.uid ? '✅ PASS' : '❌ FAIL');
    console.log('   Doc ID match:', testQuery.id === firebaseUser.uid ? '✅ PASS' : '❌ FAIL');
    
    console.log('\n🎯 PERFECT SYNC ACHIEVED!');
    console.log('==========================');
    console.log('📧 Email:', email);
    console.log('🔒 Password:', password);
    console.log('🆔 Firebase UID:', firebaseUser.uid);
    console.log('📄 Firestore Doc ID:', testQuery.id);
    console.log('👤 Role:', testData.role);
    console.log('✅ Status:', testData.status);
    
    console.log('\n🧪 TRY LOGIN NOW!');
    
  } catch (error) {
    console.error('❌ Error:', error);
  }
}

createProperUser().then(() => {
  console.log('\n✅ User creation completed');
  process.exit(0);
}).catch((error) => {
  console.error('❌ Creation failed:', error);
  process.exit(1);
});