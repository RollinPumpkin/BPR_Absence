const admin = require('firebase-admin');

// Initialize Firebase Admin SDK if not already initialized
if (!admin.apps.length) {
  admin.initializeApp({
    projectId: 'bpr-absens'
  });
}

const auth = admin.auth();
const db = admin.firestore();

async function enableUserAccount() {
  try {
    const email = 'test@bpr.com';
    
    console.log('🔄 Enabling user account...');
    
    // Get user by email
    const userRecord = await auth.getUserByEmail(email);
    
    // Enable the account
    await auth.updateUser(userRecord.uid, {
      disabled: false
    });
    
    // Update Firestore user document
    await db.collection('users').doc(userRecord.uid).update({
      status: 'active',
      disabled: false,
      updated_at: admin.firestore.FieldValue.serverTimestamp()
    });
    
    console.log('✅ User account enabled successfully');
    console.log(`   UID: ${userRecord.uid}`);
    console.log(`   Email: ${userRecord.email}`);
    console.log(`   Status: Active`);
    
  } catch (error) {
    console.error('❌ Error enabling user account:', error.message);
  }
}

enableUserAccount();