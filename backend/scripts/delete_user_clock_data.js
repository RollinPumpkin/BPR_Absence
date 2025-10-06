const admin = require('firebase-admin');
const path = require('path');

// Initialize Firebase Admin
const serviceAccount = require('../bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function deleteUserClockData() {
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
    
    console.log(`Found user: ${userData.name} (${userData.email}) with ID: ${userId}`);

    // Get today's date in YYYY-MM-DD format
    const today = new Date().toISOString().split('T')[0];
    
    // Check for clock in data with the user ID
    const clockInKey = `clock_in_${userId}_${today}`;
    
    console.log(`Looking for clock in data with key: ${clockInKey}`);
    
    // Query all collections to find clock in data
    const attendanceSnapshot = await db.collection('attendance').get();
    let deletedCount = 0;
    
    for (const doc of attendanceSnapshot.docs) {
      const data = doc.data();
      if (doc.id.includes(userId) && doc.id.includes('clock_in')) {
        console.log(`Found clock in document: ${doc.id}`);
        console.log('Data:', data);
        
        // Delete the document
        await doc.ref.delete();
        deletedCount++;
        console.log(`Deleted document: ${doc.id}`);
      }
    }
    
    // Also check for any other clock-related data
    const dashboardSnapshot = await db.collection('dashboard').get();
    
    for (const doc of dashboardSnapshot.docs) {
      const data = doc.data();
      if (doc.id.includes(userId) && (doc.id.includes('clock_in') || doc.id.includes('clock_out'))) {
        console.log(`Found dashboard clock document: ${doc.id}`);
        console.log('Data:', data);
        
        // Delete the document
        await doc.ref.delete();
        deletedCount++;
        console.log(`Deleted document: ${doc.id}`);
      }
    }

    console.log(`\nTotal documents deleted: ${deletedCount}`);
    
    if (deletedCount === 0) {
      console.log('No clock in data found for user@gmail.com');
    }

  } catch (error) {
    console.error('Error deleting clock data:', error);
  }
}

deleteUserClockData().then(() => {
  console.log('Clock data deletion completed');
  process.exit(0);
}).catch(error => {
  console.error('Script failed:', error);
  process.exit(1);
});