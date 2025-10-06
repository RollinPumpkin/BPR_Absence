const admin = require('firebase-admin');
const path = require('path');

// Initialize Firebase Admin
const serviceAccount = require('../bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function findAndDeleteAllUserClockData() {
  try {
    // First, let's find the user ID for user@gmail.com
    const usersSnapshot = await db.collection('users').where('email', '==', 'user@gmail.com').get();
    
    if (usersSnapshot.empty) {
      console.log('User not found with email: user@gmail.com');
      return;
    }

    const userDoc = usersSnapshot.docs[0];
    const userId = userDoc.id;
    const userData = userDoc.data();
    
    console.log(`Found user: ${userData.name || 'No name'} (${userData.email}) with ID: ${userId}`);

    let deletedCount = 0;
    
    // Check all collections for any documents containing this user ID
    const collections = ['attendance', 'dashboard', 'clock_records', 'user_attendance'];
    
    for (const collectionName of collections) {
      try {
        const snapshot = await db.collection(collectionName).get();
        console.log(`\nChecking collection: ${collectionName} (${snapshot.docs.length} documents)`);
        
        for (const doc of snapshot.docs) {
          // Check if document ID or data contains the user ID
          if (doc.id.includes(userId)) {
            console.log(`Found document in ${collectionName}: ${doc.id}`);
            console.log('Data:', doc.data());
            
            // Delete the document
            await doc.ref.delete();
            deletedCount++;
            console.log(`✓ Deleted document: ${doc.id}`);
          }
        }
      } catch (error) {
        if (error.code === 5) {
          console.log(`Collection ${collectionName} does not exist`);
        } else {
          console.error(`Error checking collection ${collectionName}:`, error);
        }
      }
    }

    // Also check for documents where the user ID might be in the data rather than the document ID
    const attendanceSnapshot = await db.collection('attendance').get();
    console.log(`\nChecking attendance data for userId in document content...`);
    
    for (const doc of attendanceSnapshot.docs) {
      const data = doc.data();
      if (data.userId === userId || data.user_id === userId) {
        console.log(`Found attendance document with userId in data: ${doc.id}`);
        console.log('Data:', data);
        
        // Delete the document
        await doc.ref.delete();
        deletedCount++;
        console.log(`✓ Deleted document: ${doc.id}`);
      }
    }

    console.log(`\n=== SUMMARY ===`);
    console.log(`Total documents deleted: ${deletedCount}`);
    
    if (deletedCount === 0) {
      console.log('No clock/attendance data found for user@gmail.com');
    } else {
      console.log(`Successfully deleted all clock/attendance data for user@gmail.com (${userId})`);
    }

  } catch (error) {
    console.error('Error deleting clock data:', error);
  }
}

findAndDeleteAllUserClockData().then(() => {
  console.log('\nClock data deletion completed');
  process.exit(0);
}).catch(error => {
  console.error('Script failed:', error);
  process.exit(1);
});