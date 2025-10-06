const admin = require('firebase-admin');
const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

if (!admin.apps.length) {
  admin.initializeApp({ 
    credential: admin.credential.cert(serviceAccount) 
  });
}

const db = admin.firestore();

async function checkUsers() {
  try {
    console.log('🔍 Checking users collection...');
    const snapshot = await db.collection('users').get();
    console.log(`📊 Found ${snapshot.size} users in database\n`);
    
    snapshot.forEach(doc => {
      const user = doc.data();
      console.log(`👤 User: ${doc.id}`);
      console.log(`   Employee ID: ${user.employee_id}`);
      console.log(`   Email: ${user.email}`);
      console.log(`   Name: ${user.full_name || user.name}`);
      console.log(`   Role: ${user.role}`);
      console.log(`   Position: ${user.position}`);
      console.log(`   Department: ${user.department}`);
      console.log(`   Active: ${user.is_active || user.status}`);
      console.log(`   Has Firebase UID: ${user.firebase_uid ? 'Yes' : 'No'}`);
      console.log(`   Has Password: ${user.password_hash ? 'Yes' : 'No'}`);
      console.log('');
    });
    
  } catch (error) {
    console.error('❌ Error checking users:', error);
  }
  
  process.exit(0);
}

checkUsers();