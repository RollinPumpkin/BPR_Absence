const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

async function checkUser() {
  try {
    console.log('🔍 Checking user database...');
    
    // Check if user exists
    const userQuery = await db.collection('users')
      .where('email', '==', 'user@gmail.com')
      .get();
    
    if (userQuery.empty) {
      console.log('❌ User user@gmail.com not found in database');
    } else {
      console.log('✅ User found:');
      userQuery.forEach(doc => {
        const userData = doc.data();
        console.log('  ID:', doc.id);
        console.log('  Email:', userData.email);
        console.log('  Role:', userData.role);
        console.log('  Name:', userData.name);
      });
    }
    
    // Check assignments for this user
    console.log('\n🔍 Checking assignments...');
    const assignmentsQuery = await db.collection('assignments')
      .where('assignedTo', 'array-contains', userQuery.docs[0]?.id || 'user-id')
      .get();
    
    console.log(`📋 Found ${assignmentsQuery.docs.length} assignments for user`);
    
    assignmentsQuery.forEach(doc => {
      const assignment = doc.data();
      console.log(`  - ${assignment.title} (Due: ${assignment.dueDate.toDate()})`);
    });
    
  } catch (error) {
    console.error('❌ Error:', error);
  }
}

checkUser();