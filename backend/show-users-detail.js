const admin = require('firebase-admin');

// Initialize Firebase Admin
const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function showUsers() {
  console.log('╔════════════════════════════════════════════════════════════╗');
  console.log('║          BPR ABSENCE - USER DETAILS                       ║');
  console.log('╚════════════════════════════════════════════════════════════╝\n');
  
  try {
    const usersSnapshot = await db.collection('users').get();
    
    if (usersSnapshot.empty) {
      console.log('❌ No users found in Firestore!');
      return;
    }
    
    console.log(`📊 Total users: ${usersSnapshot.size}\n`);
    
    let userCount = 0;
    let adminCount = 0;
    let superadminCount = 0;
    
    usersSnapshot.forEach((doc, index) => {
      const userData = doc.data();
      const role = userData.role?.toLowerCase() || 'user';
      
      // Count by role
      if (role === 'superadmin') superadminCount++;
      else if (role === 'admin') adminCount++;
      else userCount++;
      
      // Display user info
      console.log(`${'─'.repeat(60)}`);
      console.log(`User #${index + 1} - ${userData.role?.toUpperCase() || 'USER'}`);
      console.log(`${'─'.repeat(60)}`);
      console.log(`📧 Email      : ${userData.email}`);
      console.log(`👤 Name       : ${userData.name}`);
      console.log(`🏢 Division   : ${userData.division || 'N/A'}`);
      console.log(`🔑 Role       : ${userData.role}`);
      console.log(`✅ Status     : ${userData.status || 'active'}`);
      console.log(`📱 Phone      : ${userData.phone || 'N/A'}`);
      console.log(`🆔 User ID    : ${doc.id}`);
      console.log(`📅 Created    : ${userData.createdAt ? new Date(userData.createdAt._seconds * 1000).toLocaleString() : 'N/A'}`);
      
      // Show if password field exists (hashed)
      if (userData.password) {
        console.log(`🔒 Password   : [HASHED - ${userData.password.substring(0, 20)}...]`);
      } else {
        console.log(`🔒 Password   : [NOT SET - Uses Firebase Auth]`);
      }
      console.log();
    });
    
    console.log(`${'═'.repeat(60)}`);
    console.log(`📊 SUMMARY`);
    console.log(`${'═'.repeat(60)}`);
    console.log(`🔴 Super Admin : ${superadminCount}`);
    console.log(`🟡 Admin       : ${adminCount}`);
    console.log(`🟢 User        : ${userCount}`);
    console.log(`📝 Total       : ${usersSnapshot.size}`);
    console.log(`${'═'.repeat(60)}\n`);
    
    console.log(`💡 TESTING INSTRUCTIONS:`);
    console.log(`   1. If password field exists in Firestore → Try common passwords:`);
    console.log(`      - 123456`);
    console.log(`      - admin123`);
    console.log(`      - password`);
    console.log(`   2. If password NOT in Firestore → Uses Firebase Authentication`);
    console.log(`   3. You may need to reset password via Firebase Console`);
    console.log(`   4. Or create test users with known passwords\n`);
    
  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    await admin.app().delete();
  }
}

showUsers().catch(console.error);
