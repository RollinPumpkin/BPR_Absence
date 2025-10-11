const { getFirestore, initializeFirebase } = require('./config/database');
const bcrypt = require('bcryptjs');

async function updateUserPassword() {
  try {
    // Initialize Firebase first
    await initializeFirebase();
    
    const db = getFirestore();
    
    console.log('🔄 Updating password for user@gmail.com...');
    
    // Get user document for user@gmail.com
    const usersSnapshot = await db.collection('users')
      .where('email', '==', 'user@gmail.com')
      .get();
    
    if (usersSnapshot.empty) {
      console.log('❌ User user@gmail.com not found');
      return;
    }
    
    const userDoc = usersSnapshot.docs[0];
    const userData = userDoc.data();
    
    console.log(`👤 User: ${userData.email}`);
    console.log(`   UID: ${userDoc.id}`);
    console.log(`   Current status: ${userData.status}`);
    console.log(`   Current is_active: ${userData.is_active}`);
    
    // Create new hashed password
    const newPassword = '123456';
    const hashedPassword = await bcrypt.hash(newPassword, 12);
    
    // Update user document
    await db.collection('users').doc(userDoc.id).update({
      password: hashedPassword,
      is_active: true,
      status: 'active',
      disabled: false,
      updated_at: new Date()
    });
    
    console.log('✅ Password updated successfully');
    console.log(`   New password: ${newPassword}`);
    
    // Test the new password
    const isValid = await bcrypt.compare(newPassword, hashedPassword);
    console.log(`   Password validation: ${isValid ? 'Valid' : 'Invalid'}`);
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  }
}

updateUserPassword();