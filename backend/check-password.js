const { getFirestore, initializeFirebase } = require('./config/database');
const bcrypt = require('bcryptjs');

async function checkUserPassword() {
  try {
    // Initialize Firebase first
    await initializeFirebase();
    
    const db = getFirestore();
    
    console.log('🔍 Checking password field for user@gmail.com...');
    
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
    console.log(`   Password field exists: ${userData.password ? 'Yes' : 'No'}`);
    console.log(`   Password type: ${typeof userData.password}`);
    console.log(`   Password length: ${userData.password ? userData.password.length : 0}`);
    
    if (!userData.password) {
      console.log('🔄 Creating hashed password...');
      const hashedPassword = await bcrypt.hash('123456', 12);
      
      await db.collection('users').doc(userDoc.id).update({
        password: hashedPassword,
        updated_at: new Date()
      });
      console.log('✅ Password created and hashed');
    } else {
      console.log('✅ Password exists');
      
      // Test bcrypt compare
      try {
        const isValid = await bcrypt.compare('123456', userData.password);
        console.log(`   Password validation: ${isValid ? 'Valid' : 'Invalid'}`);
      } catch (error) {
        console.log(`   Password validation error: ${error.message}`);
      }
    }
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  }
}

checkUserPassword();