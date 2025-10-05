const admin = require('firebase-admin');
const path = require('path');

// Initialize Firebase Admin
const serviceAccount = require('../bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function deleteUserAttendanceData() {
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
    
    // Check attendance collection for any documents related to this user
    console.log('\n=== Checking attendance collection ===');
    const attendanceSnapshot = await db.collection('attendance').get();
    console.log(`Found ${attendanceSnapshot.docs.length} documents in attendance collection`);
    
    for (const doc of attendanceSnapshot.docs) {
      const data = doc.data();
      let shouldDelete = false;
      let reason = '';
      
      // Check various ways the user might be referenced
      if (doc.id.includes(userId)) {
        shouldDelete = true;
        reason = 'Document ID contains user ID';
      } else if (data.userId === userId) {
        shouldDelete = true;
        reason = 'Document data contains userId field';
      } else if (data.user_id === userId) {
        shouldDelete = true;
        reason = 'Document data contains user_id field';
      } else if (data.email === 'user@gmail.com') {
        shouldDelete = true;
        reason = 'Document data contains user email';
      } else if (data.user && data.user.id === userId) {
        shouldDelete = true;
        reason = 'Document data contains user object with matching ID';
      } else if (data.user && data.user.email === 'user@gmail.com') {
        shouldDelete = true;
        reason = 'Document data contains user object with matching email';
      }
      
      if (shouldDelete) {
        console.log(`\nFound attendance document: ${doc.id}`);
        console.log(`Reason: ${reason}`);
        console.log('Document data:', JSON.stringify(data, null, 2));
        
        // Delete the document
        await doc.ref.delete();
        deletedCount++;
        console.log(`✓ Deleted document: ${doc.id}`);
      }
    }
    
    // Check dashboard collection for attendance-related data
    console.log('\n=== Checking dashboard collection ===');
    try {
      const dashboardSnapshot = await db.collection('dashboard').get();
      console.log(`Found ${dashboardSnapshot.docs.length} documents in dashboard collection`);
      
      for (const doc of dashboardSnapshot.docs) {
        const data = doc.data();
        let shouldDelete = false;
        let reason = '';
        
        if (doc.id.includes(userId)) {
          shouldDelete = true;
          reason = 'Document ID contains user ID';
        } else if (data.userId === userId) {
          shouldDelete = true;
          reason = 'Document data contains userId field';
        } else if (data.user_id === userId) {
          shouldDelete = true;
          reason = 'Document data contains user_id field';
        } else if (data.email === 'user@gmail.com') {
          shouldDelete = true;
          reason = 'Document data contains user email';
        }
        
        if (shouldDelete) {
          console.log(`\nFound dashboard document: ${doc.id}`);
          console.log(`Reason: ${reason}`);
          console.log('Document data:', JSON.stringify(data, null, 2));
          
          // Delete the document
          await doc.ref.delete();
          deletedCount++;
          console.log(`✓ Deleted document: ${doc.id}`);
        }
      }
    } catch (error) {
      console.log('Dashboard collection does not exist or error accessing it:', error.message);
    }
    
    // Check for any other attendance-related collections
    const otherCollections = ['user_attendance', 'clock_records', 'time_tracking', 'work_logs'];
    
    for (const collectionName of otherCollections) {
      console.log(`\n=== Checking ${collectionName} collection ===`);
      try {
        const snapshot = await db.collection(collectionName).get();
        console.log(`Found ${snapshot.docs.length} documents in ${collectionName} collection`);
        
        for (const doc of snapshot.docs) {
          const data = doc.data();
          let shouldDelete = false;
          let reason = '';
          
          if (doc.id.includes(userId)) {
            shouldDelete = true;
            reason = 'Document ID contains user ID';
          } else if (data.userId === userId) {
            shouldDelete = true;
            reason = 'Document data contains userId field';
          } else if (data.user_id === userId) {
            shouldDelete = true;
            reason = 'Document data contains user_id field';
          } else if (data.email === 'user@gmail.com') {
            shouldDelete = true;
            reason = 'Document data contains user email';
          }
          
          if (shouldDelete) {
            console.log(`\nFound ${collectionName} document: ${doc.id}`);
            console.log(`Reason: ${reason}`);
            console.log('Document data:', JSON.stringify(data, null, 2));
            
            // Delete the document
            await doc.ref.delete();
            deletedCount++;
            console.log(`✓ Deleted document: ${doc.id}`);
          }
        }
      } catch (error) {
        console.log(`Collection ${collectionName} does not exist or error accessing it:`, error.message);
      }
    }

    console.log(`\n=== SUMMARY ===`);
    console.log(`User: ${userData.name || 'No name'} (${userData.email})`);
    console.log(`User ID: ${userId}`);
    console.log(`Total attendance documents deleted: ${deletedCount}`);
    
    if (deletedCount === 0) {
      console.log('✓ No attendance data found for user@gmail.com - database is already clean');
    } else {
      console.log(`✓ Successfully deleted all attendance data for user@gmail.com`);
    }

  } catch (error) {
    console.error('Error deleting attendance data:', error);
  }
}

deleteUserAttendanceData().then(() => {
  console.log('\nAttendance data deletion completed');
  process.exit(0);
}).catch(error => {
  console.error('Script failed:', error);
  process.exit(1);
});