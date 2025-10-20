// Scheduled cleanup script: Permanently delete employees soft-deleted over 1 year ago
// Usage: node backend/scripts/cleanup_terminated_employees.js

const admin = require('firebase-admin');
const path = require('path');

// Initialize Firebase Admin SDK
const serviceAccount = require(path.join(__dirname, '../bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json'));
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}
const db = admin.firestore();

async function cleanupTerminatedEmployees() {
  const oneYearAgo = new Date();
  oneYearAgo.setFullYear(oneYearAgo.getFullYear() - 1);

  // Firestore stores timestamps as admin.firestore.Timestamp
  // We'll compare using toDate()
  const usersRef = db.collection('users');
  const snapshot = await usersRef.where('status', '==', 'terminated').get();

  let deletedCount = 0;
  for (const doc of snapshot.docs) {
    const data = doc.data();
    if (data.deleted_at && data.deleted_at.toDate() < oneYearAgo) {
      await doc.ref.delete();
      deletedCount++;
      console.log(`Deleted user: ${doc.id} (${data.full_name || ''})`);
    }
  }
  console.log(`Cleanup complete. Total deleted: ${deletedCount}`);
}

cleanupTerminatedEmployees().catch(err => {
  console.error('Cleanup failed:', err);
  process.exit(1);
});
