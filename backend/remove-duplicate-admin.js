const admin = require('firebase-admin');
const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function removeDuplicateUser() {
  try {
    console.log('🔧 Removing duplicate admin@gmail.com user...');
    
    // Delete the user with invalid Firebase UID (SADM001)
    const docRef = db.collection('users').doc('SADM001');
    const doc = await docRef.get();
    
    if (doc.exists) {
      const userData = doc.data();
      console.log('📄 Found duplicate user to delete:');
      console.log(`   Name: ${userData.full_name}`);
      console.log(`   Email: ${userData.email}`);
      console.log(`   Firebase UID: ${userData.firebase_uid}`);
      console.log(`   Employee ID: ${userData.employee_id}`);
      
      // Delete the document
      await docRef.delete();
      console.log('✅ Duplicate user deleted successfully');
      
      // Verify the remaining user
      console.log('\n🔍 Verifying remaining admin@gmail.com user...');
      const remainingQuery = await db.collection('users')
        .where('email', '==', 'admin@gmail.com')
        .get();
        
      console.log(`✅ Found ${remainingQuery.size} admin@gmail.com user(s) remaining:`);
      remainingQuery.forEach(doc => {
        const data = doc.data();
        console.log(`   Name: ${data.full_name}`);
        console.log(`   Role: ${data.role}`);
        console.log(`   Firebase UID: ${data.firebase_uid}`);
        console.log(`   Firestore ID: ${doc.id}`);
      });
      
    } else {
      console.log('❌ Duplicate user document not found');
    }
  } catch (e) {
    console.error('❌ Error:', e.message);
  }
}

removeDuplicateUser();