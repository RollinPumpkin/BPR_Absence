const admin = require('firebase-admin');
const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function checkUserMapping() {
  try {
    console.log('🔍 Checking admin@gmail.com mapping...');
    
    // Get Firebase Auth user
    const authUser = await admin.auth().getUserByEmail('admin@gmail.com');
    console.log(`🔑 Firebase UID: ${authUser.uid}`);
    
    // Find in Firestore by Firebase UID
    const uidQuery = await db.collection('users').where('firebase_uid', '==', authUser.uid).get();
    
    console.log('\n--- FOUND BY UID ---');
    if (!uidQuery.empty) {
      const data = uidQuery.docs[0].data();
      console.log(`✅ Found by UID`);
      console.log(`   Name: ${data.full_name}`);
      console.log(`   Role: ${data.role}`);
      console.log(`   Email: ${data.email}`);
      console.log(`   Firestore ID: ${uidQuery.docs[0].id}`);
    } else {
      console.log('❌ NOT found by UID');
      
      // Find by email instead
      const emailQuery = await db.collection('users').where('email', '==', 'admin@gmail.com').get();
      console.log('\n--- FOUND BY EMAIL ---');
      if (!emailQuery.empty) {
        const data = emailQuery.docs[0].data();
        console.log(`✅ Found by email`);
        console.log(`   Name: ${data.full_name}`);
        console.log(`   Role: ${data.role}`);
        console.log(`   Email: ${data.email}`);
        console.log(`   Firebase UID in doc: ${data.firebase_uid || 'NULL'}`);
        console.log(`   Firestore ID: ${emailQuery.docs[0].id}`);
        
        console.log('\n🔧 FIXING: Updating document with correct Firebase UID...');
        await emailQuery.docs[0].ref.update({
          firebase_uid: authUser.uid,
          updated_at: admin.firestore.Timestamp.now()
        });
        console.log('✅ Updated Firebase UID mapping');
      } else {
        console.log('❌ NOT found by email either!');
      }
    }
  } catch (e) {
    console.error('❌ Error:', e.message);
  }
}

checkUserMapping();