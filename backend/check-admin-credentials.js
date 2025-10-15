const { getFirestore, initializeFirebase } = require('./config/database');
const bcrypt = require('bcryptjs');

async function checkAdminCredentials() {
  try {
    // Initialize Firebase first
    await initializeFirebase();
    
    const db = getFirestore();
    
    console.log('🔍 Checking admin@gmail.com credentials...');
    
    // Get user document for admin@gmail.com
    const usersSnapshot = await db.collection('users')
      .where('email', '==', 'admin@gmail.com')
      .get();
    
    if (usersSnapshot.empty) {
      console.log('❌ admin@gmail.com not found in database');
      
      // Check all emails with gmail.com domain
      console.log('\n🔍 Looking for users with gmail.com domain...');
      const gmailUsersSnapshot = await db.collection('users')
        .get();
      
      gmailUsersSnapshot.forEach(doc => {
        const userData = doc.data();
        if (userData.email && userData.email.includes('gmail.com')) {
          console.log(`   📧 Found: ${userData.email} (Role: ${userData.role})`);
        }
      });
      
      return;
    }
    
    const userDoc = usersSnapshot.docs[0];
    const userData = userDoc.data();
    
    console.log(`👤 Found user: ${userData.email}`);
    console.log(`   Name: ${userData.full_name}`);
    console.log(`   Role: ${userData.role}`);
    console.log(`   Status: ${userData.status}`);
    console.log(`   Active: ${userData.is_active}`);
    console.log(`   Disabled: ${userData.disabled}`);
    console.log(`   Password exists: ${userData.password ? 'Yes' : 'No'}`);
    console.log(`   Firebase UID: ${userData.firebase_uid}`);
    
    if (userData.password) {
      // Test password
      console.log('\n🔐 Testing passwords...');
      const passwords = ['123456', 'admin123', 'password123', 'admin123456'];
      
      for (const testPassword of passwords) {
        try {
          const isValid = await bcrypt.compare(testPassword, userData.password);
          console.log(`   ${testPassword}: ${isValid ? '✅ Valid' : '❌ Invalid'}`);
          
          if (isValid) {
            console.log(`\n✅ WORKING CREDENTIALS:`);
            console.log(`   Email: ${userData.email}`);
            console.log(`   Password: ${testPassword}`);
            break;
          }
        } catch (error) {
          console.log(`   ${testPassword}: ❌ Error - ${error.message}`);
        }
      }
    }
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  }
}

checkAdminCredentials();