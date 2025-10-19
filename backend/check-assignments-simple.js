const admin = require('firebase-admin');

// Initialize Firebase if not already done
if (!admin.apps.length) {
  const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: 'https://bpr-absens-default-rtdb.firebaseio.com'
  });
}

const db = admin.firestore();

async function checkAssignments() {
  try {
    console.log('📋 CHECKING ASSIGNMENTS COLLECTION');
    console.log('================================\n');

    const assignmentsRef = db.collection('assignments');
    const snapshot = await assignmentsRef.get();

    console.log(`Total assignments: ${snapshot.size}\n`);

    if (snapshot.size > 0) {
      console.log('Sample assignment structure:');
      const firstDoc = snapshot.docs[0];
      console.log(`Document ID: ${firstDoc.id}`);
      console.log(`Fields: ${JSON.stringify(Object.keys(firstDoc.data()), null, 2)}`);
      console.log(`Sample data: ${JSON.stringify(firstDoc.data(), null, 2)}\n`);
    } else {
      console.log('❌ No assignments found in the database!\n');
    }

  } catch (error) {
    console.error('❌ Error checking assignments:', error);
  } finally {
    process.exit(0);
  }
}

checkAssignments();