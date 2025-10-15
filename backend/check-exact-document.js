const admin = require('firebase-admin');
const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function checkCurrentUserData() {
  try {
    console.log('🔍 Checking exact document data for admin@gmail.com...');
    
    // Get the specific document that's being used for login
    const docRef = db.collection('users').doc('yhmBo28DqzXPLpx7XPxI');
    const doc = await docRef.get();
    
    if (doc.exists) {
      const data = doc.data();
      console.log('📄 EXACT DOCUMENT DATA:');
      console.log('   Document ID:', doc.id);
      console.log('   Full Name:', data.full_name);
      console.log('   Email:', data.email);
      console.log('   Role:', data.role);
      console.log('   Employee ID:', data.employee_id);
      console.log('   Firebase UID:', data.firebase_uid);
      console.log('   Updated At:', data.updated_at?.toDate());
      console.log('');
      console.log('📋 RAW JSON:');
      console.log(JSON.stringify(data, null, 2));
    } else {
      console.log('❌ Document not found');
    }
  } catch (e) {
    console.error('❌ Error:', e.message);
  }
}

checkCurrentUserData();