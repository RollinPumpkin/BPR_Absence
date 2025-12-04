const admin = require('firebase-admin');
const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function deleteAllAssignments() {
  try {
    console.log('🗑️ Menghapus semua assignment...\n');

    const assignmentsSnapshot = await db.collection('assignments').get();
    
    if (assignmentsSnapshot.empty) {
      console.log('✅ Tidak ada assignment yang perlu dihapus');
      process.exit(0);
    }

    console.log(`📋 Ditemukan ${assignmentsSnapshot.size} assignment\n`);

    const batch = db.batch();
    assignmentsSnapshot.forEach(doc => {
      const data = doc.data();
      console.log(`  ❌ ${doc.id}: ${data.title} (${data.status})`);
      batch.delete(doc.ref);
    });

    await batch.commit();

    console.log(`\n✅ Berhasil menghapus ${assignmentsSnapshot.size} assignment`);
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

deleteAllAssignments();
