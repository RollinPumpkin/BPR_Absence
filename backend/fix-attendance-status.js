const admin = require('firebase-admin');
const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-da2d17d44d.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function fixAttendanceStatus() {
  try {
    console.log('\n========================================');
    console.log('🔧 FIXING ATTENDANCE STATUS');
    console.log('========================================\n');

    // Get all attendance records
    const snapshot = await db.collection('attendance').get();
    
    console.log(`📊 Total records to check: ${snapshot.size}\n`);

    let updatedCount = 0;
    const batch = db.batch();

    for (const doc of snapshot.docs) {
      const data = doc.data();
      const checkInTime = data.check_in_time;
      
      if (!checkInTime) continue;

      // Parse check-in time (format: HH:mm:ss)
      const [hours, minutes] = checkInTime.split(':').map(Number);
      const checkInMinutes = hours * 60 + minutes;
      
      // Work start time: 08:00 + 15 minutes threshold = 08:15
      const workStartMinutes = 8 * 60; // 08:00
      const lateThresholdMinutes = 15;
      const lateThreshold = workStartMinutes + lateThresholdMinutes; // 08:15 = 495 minutes
      
      // Determine correct status
      const correctStatus = checkInMinutes > lateThreshold ? 'late' : 'present';
      const currentStatus = data.status;
      
      if (currentStatus !== correctStatus) {
        console.log(`🔄 Updating record: ${doc.id}`);
        console.log(`   Date: ${data.date}`);
        console.log(`   Check In: ${checkInTime}`);
        console.log(`   Current Status: ${currentStatus}`);
        console.log(`   Correct Status: ${correctStatus}`);
        console.log(`   Check-in minutes: ${checkInMinutes}, Late threshold: ${lateThreshold}\n`);
        
        batch.update(doc.ref, { status: correctStatus });
        updatedCount++;
      }
    }

    if (updatedCount > 0) {
      await batch.commit();
      console.log(`\n✅ Updated ${updatedCount} records successfully!\n`);
    } else {
      console.log(`\n✅ All records already have correct status!\n`);
    }

    // Show summary after update
    const updatedSnapshot = await db.collection('attendance')
      .orderBy('date', 'desc')
      .limit(10)
      .get();

    console.log('========================================');
    console.log('📊 UPDATED RECORDS (Last 10):');
    console.log('========================================\n');

    updatedSnapshot.forEach((doc, index) => {
      const data = doc.data();
      console.log(`📝 Record #${index + 1}:`);
      console.log(`   Date: ${data.date}`);
      console.log(`   Check In: ${data.check_in_time || 'N/A'}`);
      console.log(`   Status: ${data.status} ${data.status === 'late' ? '⏰' : data.status === 'present' ? '✅' : '❓'}\n`);
    });

    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

fixAttendanceStatus();
