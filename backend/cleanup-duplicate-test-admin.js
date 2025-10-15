const admin = require('firebase-admin');
const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function removeDuplicateTestAdmin() {
  try {
    console.log('🔧 Removing duplicate test@bpr.com user...');
    
    const email = 'test@bpr.com';
    
    // Find all users with this email
    const usersRef = db.collection('users');
    const usersSnapshot = await usersRef.where('email', '==', email).get();
    
    console.log(`📋 Found ${usersSnapshot.size} users with email ${email}`);
    
    let usersToProcess = [];
    usersSnapshot.forEach(doc => {
      const data = doc.data();
      usersToProcess.push({
        id: doc.id,
        ...data
      });
    });
    
    // Sort by completeness - keep the most complete user
    usersToProcess.sort((a, b) => {
      // Prefer the one with Firebase UID as document ID (more consistent)
      if (a.firebase_uid === a.id && b.firebase_uid !== b.id) return -1;
      if (b.firebase_uid === b.id && a.firebase_uid !== a.id) return 1;
      
      // Prefer the one with more complete data
      const aScore = (a.full_name ? 1 : 0) + (a.employee_id ? 1 : 0) + (a.password ? 1 : 0);
      const bScore = (b.full_name ? 1 : 0) + (b.employee_id ? 1 : 0) + (b.password ? 1 : 0);
      
      return bScore - aScore; // Descending order
    });
    
    console.log('\n📊 Users analysis:');
    usersToProcess.forEach((user, index) => {
      console.log(`\n   User ${index + 1}: ${user.id}`);
      console.log(`   👤 Name: ${user.full_name || 'missing'}`);
      console.log(`   🆔 Employee ID: ${user.employee_id || 'missing'}`);
      console.log(`   🔥 Firebase UID: ${user.firebase_uid || 'missing'}`);
      console.log(`   🔑 Has password: ${user.password ? 'YES' : 'NO'}`);
      console.log(`   💎 ID matches Firebase UID: ${user.id === user.firebase_uid ? 'YES' : 'NO'}`);
    });
    
    // Keep the first (best) user, delete the rest
    const userToKeep = usersToProcess[0];
    const usersToDelete = usersToProcess.slice(1);
    
    console.log(`\n✅ Keeping user: ${userToKeep.id}`);
    console.log(`❌ Deleting ${usersToDelete.length} duplicate(s)`);
    
    // Delete duplicates
    for (const user of usersToDelete) {
      console.log(`🗑️ Deleting user: ${user.id}`);
      await db.collection('users').doc(user.id).delete();
      console.log(`✅ Deleted ${user.id}`);
    }
    
    // Verify final state
    console.log('\n🔍 Verifying final state...');
    const finalSnapshot = await usersRef.where('email', '==', email).get();
    
    if (finalSnapshot.size === 1) {
      const finalUser = finalSnapshot.docs[0];
      const finalData = finalUser.data();
      
      console.log('✅ Final user verified:');
      console.log(`   📄 Document ID: ${finalUser.id}`);
      console.log(`   📧 Email: ${finalData.email}`);
      console.log(`   👤 Name: ${finalData.full_name}`);
      console.log(`   🆔 Employee ID: ${finalData.employee_id}`);
      console.log(`   👑 Role: ${finalData.role}`);
      console.log(`   🔥 Firebase UID: ${finalData.firebase_uid}`);
      console.log(`   🔑 Has password: ${finalData.password ? 'YES' : 'NO'}`);
      console.log(`   ✅ Active: ${finalData.is_active}`);
      
      console.log('\n🎉 SUCCESS! Duplicate removed successfully!');
      console.log('\n📋 Ready to login with:');
      console.log(`   📧 Email: ${email}`);
      console.log(`   🔑 Password: 123456`);
      console.log(`   👑 Role: admin`);
      
    } else {
      console.log(`❌ Unexpected result: ${finalSnapshot.size} users remaining`);
    }
    
  } catch (error) {
    console.error('❌ Error removing duplicate:', error);
    console.error('Error message:', error.message);
  }
}

// Run the function
removeDuplicateTestAdmin().then(() => {
  console.log('\n✅ Cleanup completed');
  process.exit(0);
}).catch((error) => {
  console.error('❌ Cleanup failed:', error);
  process.exit(1);
});