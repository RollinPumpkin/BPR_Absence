const admin = require('firebase-admin');
const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function deleteCompletedAssignments() {
  try {
    console.log('🔍 Mencari assignment dengan status completed...');
    
    // Query assignments with status 'completed'
    const completedAssignments = await db.collection('assignments')
      .where('status', '==', 'completed')
      .get();
    
    if (completedAssignments.empty) {
      console.log('✅ Tidak ada assignment completed yang perlu dihapus');
      process.exit(0);
      return;
    }
    
    console.log(`📋 Ditemukan ${completedAssignments.size} assignment completed`);
    
    // Show assignments before deletion
    console.log('\n📝 Assignment yang akan dihapus:');
    completedAssignments.forEach(doc => {
      const data = doc.data();
      console.log(`  - ${doc.id}: ${data.title} (Completed: ${data.completionTime || 'N/A'})`);
    });
    
    // Delete in batch
    const batch = db.batch();
    completedAssignments.forEach(doc => {
      batch.delete(doc.ref);
    });
    
    await batch.commit();
    
    console.log(`\n✅ Berhasil menghapus ${completedAssignments.size} assignment completed`);
    process.exit(0);
    
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

// Run the deletion
deleteCompletedAssignments();
