const admin = require('firebase-admin');
const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function checkUser() {
  try {
    console.log('🔍 Checking admin@gmail.com in database...');
    
    const snapshot = await db.collection('users')
      .where('email', '==', 'admin@gmail.com')
      .limit(1)
      .get();
    
    if (snapshot.empty) {
      console.log('❌ User not found!');
      return;
    }
    
    const userData = snapshot.docs[0].data();
    console.log('✅ User found in DB:');
    console.log('📧 Email:', userData.email);
    console.log('🆔 Employee ID:', userData.employee_id);
    console.log('👤 Role:', userData.role);
    console.log('📋 Full data:', JSON.stringify(userData, null, 2));
    
  } catch (error) {
    console.error('❌ Error:', error);
  }
  
  process.exit(0);
}

checkUser();