const admin = require('firebase-admin');
const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://bpr-absens-default-rtdb.firebaseio.com'
});

const db = admin.firestore();

async function fixUserData() {
  console.log('🔧 Fixing user@gmail.com data...\n');
  
  try {
    // Find all user@gmail.com records
    const duplicateQuery = await db.collection('users')
      .where('email', '==', 'user@gmail.com')
      .get();
    
    console.log(`Found ${duplicateQuery.size} records for user@gmail.com:`);
    
    let correctRecord = null;
    const recordsToDelete = [];
    
    duplicateQuery.forEach(doc => {
      const data = doc.data();
      console.log(`- ID: ${doc.id}, Firebase UID: ${data.firebase_uid || 'Not set'}`);
      
      if (data.firebase_uid === 'w64DcvH6PQM1aOR0VYoARqStjCW2') {
        correctRecord = { id: doc.id, data: data };
      } else {
        recordsToDelete.push(doc.id);
      }
    });
    
    // Delete duplicate records
    for (const recordId of recordsToDelete) {
      await db.collection('users').doc(recordId).delete();
      console.log(`✅ Deleted duplicate record: ${recordId}`);
    }
    
    // Update the correct record if needed
    if (correctRecord) {
      const updateData = {
        firebase_uid: 'w64DcvH6PQM1aOR0VYoARqStjCW2',
        updated_at: admin.firestore.FieldValue.serverTimestamp()
      };
      
      await db.collection('users').doc(correctRecord.id).update(updateData);
      console.log(`✅ Updated correct record: ${correctRecord.id}`);
    }
    
    // Verify fix
    console.log('\n🔍 Verifying fix...');
    const verifyQuery = await db.collection('users')
      .where('email', '==', 'user@gmail.com')
      .get();
    
    if (verifyQuery.size === 1) {
      const userData = verifyQuery.docs[0].data();
      console.log('✅ Fix successful!');
      console.log(`   Single record found: ${verifyQuery.docs[0].id}`);
      console.log(`   Firebase UID: ${userData.firebase_uid}`);
      console.log(`   Role: ${userData.role}`);
      console.log(`   Name: ${userData.full_name}`);
    } else {
      console.log(`❌ Still ${verifyQuery.size} records found`);
    }
    
  } catch (error) {
    console.error('❌ Error fixing user data:', error);
  }
  
  process.exit(0);
}

fixUserData();