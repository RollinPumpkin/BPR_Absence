const admin = require('firebase-admin');
const bcrypt = require('bcryptjs');
const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();
const auth = admin.auth();

async function debugLogin() {
  const email = 'septapuma@gmail.com';
  const password = '123456';
  
  console.log('🔍 Debugging login for:', email);
  console.log('================================');
  
  // 1. Check Firebase Auth
  try {
    const authUser = await auth.getUserByEmail(email);
    console.log('✅ Firebase Auth user found:', authUser.uid);
    console.log('   Disabled:', authUser.disabled);
    console.log('   Email verified:', authUser.emailVerified);
    console.log('   Creation time:', authUser.metadata.creationTime);
  } catch (error) {
    console.log('❌ Firebase Auth error:', error.code);
    return;
  }
  
  // 2. Check Firestore user
  console.log('\n🔍 Checking Firestore user...');
  const userQuery = await db.collection('users').where('email', '==', email).get();
  if (userQuery.empty) {
    console.log('❌ No Firestore user found');
    return;
  }
  
  const userData = userQuery.docs[0].data();
  const docId = userQuery.docs[0].id;
  console.log('✅ Firestore user found:', docId);
  console.log('   Firebase UID:', userData.firebase_uid);
  console.log('   Has password:', !!userData.password);
  console.log('   Is active:', userData.is_active);
  console.log('   Status:', userData.status);
  console.log('   Role:', userData.role);
  
  // 3. Test password
  if (userData.password) {
    console.log('\n🔍 Testing password...');
    try {
      const passwordMatch = await bcrypt.compare(password, userData.password);
      console.log('   Password test:', passwordMatch ? '✅ MATCH' : '❌ NO MATCH');
      
      if (!passwordMatch) {
        console.log('   🔧 Fixing password...');
        const newHashedPassword = await bcrypt.hash(password, 10);
        await db.collection('users').doc(docId).update({
          password: newHashedPassword,
          updated_at: admin.firestore.FieldValue.serverTimestamp()
        });
        console.log('   ✅ Password updated');
      }
    } catch (bcryptError) {
      console.log('   ❌ Password test error:', bcryptError.message);
    }
  } else {
    console.log('\n🔧 Adding missing password...');
    const hashedPassword = await bcrypt.hash(password, 10);
    await db.collection('users').doc(docId).update({
      password: hashedPassword,
      updated_at: admin.firestore.FieldValue.serverTimestamp()
    });
    console.log('   ✅ Password added');
  }
  
  // 4. Check consistency
  console.log('\n🔍 Checking consistency...');
  const authUser = await auth.getUserByEmail(email);
  const isConsistent = docId === userData.firebase_uid;
  console.log('   Document ID matches Firebase UID:', isConsistent ? '✅ YES' : '❌ NO');
  
  if (!isConsistent) {
    console.log('   🔧 Fixing consistency...');
    await db.collection('users').doc(docId).update({
      firebase_uid: authUser.uid,
      updated_at: admin.firestore.FieldValue.serverTimestamp()
    });
    console.log('   ✅ Consistency fixed');
  }
  
  console.log('\n🎯 FINAL STATUS:');
  console.log('================');
  console.log('📧 Email:', email);
  console.log('🔒 Password:', password);
  console.log('🆔 Firebase UID:', authUser.uid);
  console.log('📄 Firestore Doc ID:', docId);
  console.log('✅ Ready to login!');
}

debugLogin().then(() => {
  console.log('\n✅ Debug completed');
  process.exit(0);
}).catch((error) => {
  console.error('❌ Debug failed:', error);
  process.exit(1);
});