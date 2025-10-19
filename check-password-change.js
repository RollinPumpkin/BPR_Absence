const { initializeFirebase, getFirestore } = require('./backend/config/database');

async function checkPasswordChange() {
  try {
    // Initialize Firebase
    initializeFirebase();
    const db = getFirestore();
    
    const email = 'septapuma@gmail.com';
    
    console.log('🔍 Checking password in database...');
    console.log(`📧 Email: ${email}`);
    
    // Get user document
    const usersSnapshot = await db.collection('users').where('email', '==', email).get();
    
    if (usersSnapshot.empty) {
      console.log('❌ User not found');
      return;
    }
    
    const userData = usersSnapshot.docs[0].data();
    
    console.log('📋 User Data:');
    console.log(`   Full Name: ${userData.full_name}`);
    console.log(`   Email: ${userData.email}`);
    console.log(`   Employee ID: ${userData.employee_id}`);
    console.log(`   Password Hash: ${userData.password?.substring(0, 20)}...`);
    console.log(`   Updated At: ${userData.updated_at?.toDate()}`);
    
    // Check if password was recently updated (within last 5 minutes)
    const updatedAt = userData.updated_at?.toDate();
    const fiveMinutesAgo = new Date(Date.now() - 5 * 60 * 1000);
    
    if (updatedAt && updatedAt > fiveMinutesAgo) {
      console.log('✅ Password was recently updated (within last 5 minutes)');
    } else {
      console.log('⚠️  Password update timestamp is older than 5 minutes');
    }
    
    // Test login with new password
    console.log('\n🧪 Testing login with new password...');
    
    const bcrypt = require('bcryptjs');
    const newPassword = 'newpassword123';
    const isMatch = await bcrypt.compare(newPassword, userData.password);
    
    if (isMatch) {
      console.log('✅ New password matches! Password change successful.');
    } else {
      console.log('❌ New password does not match. Password change failed.');
      
      // Test with old password to see if it still works
      console.log('\n🧪 Testing with old password (123456)...');
      const oldMatch = await bcrypt.compare('123456', userData.password);
      
      if (oldMatch) {
        console.log('❌ Old password still works. Password was not changed.');
      } else {
        console.log('✅ Old password no longer works.');
      }
    }
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  }
}

// Run the function
checkPasswordChange();