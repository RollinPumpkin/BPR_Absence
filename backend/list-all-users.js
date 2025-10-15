const admin = require('firebase-admin');
const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function listAllUsers() {
  try {
    console.log('👥 Listing all users in database...');
    
    const usersSnapshot = await db.collection('users').get();
    
    console.log(`✅ Found ${usersSnapshot.size} users:\n`);
    
    usersSnapshot.forEach((doc, index) => {
      const data = doc.data();
      console.log(`${index + 1}. 📧 ${data.email}`);
      console.log(`   👤 Name: ${data.full_name}`);
      console.log(`   🎭 Role: ${data.role}`);
      console.log(`   🆔 Employee ID: ${data.employee_id}`);
      console.log(`   🔑 Firebase UID: ${data.firebase_uid || 'NULL'}`);
      console.log(`   📄 Firestore ID: ${doc.id}`);
      console.log('');
    });
  } catch (e) {
    console.error('❌ Error:', e.message);
  }
}

listAllUsers();