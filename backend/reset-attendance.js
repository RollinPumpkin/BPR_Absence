const admin = require('firebase-admin');
const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-da2d17d44d.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function resetAttendanceForUser() {
  try {
    console.log('\n========================================');
    console.log('🗑️ RESETTING ATTENDANCE DATA');
    console.log('========================================\n');

    // Step 1: Get user ADM001
    console.log('👤 Getting user ADM001...');
    const userSnapshot = await db.collection('users')
      .where('employee_id', '==', 'ADM001')
      .get();
    
    if (userSnapshot.empty) {
      console.log('❌ User ADM001 not found!');
      process.exit(1);
    }

    const userDoc = userSnapshot.docs[0];
    const userData = userDoc.data();
    const userId = userDoc.id;
    
    console.log(`✅ Found user:`);
    console.log(`   User ID: ${userId}`);
    console.log(`   Employee ID: ${userData.employee_id}`);
    console.log(`   Name: ${userData.full_name}`);
    console.log(`   Work Start Time: ${userData.work_start_time || '08:00'}\n`);

    // Step 2: Delete all existing attendance records
    console.log('🗑️ Deleting all existing attendance records...');
    const allAttendance = await db.collection('attendance').get();
    
    const deleteBatch = db.batch();
    allAttendance.forEach(doc => {
      deleteBatch.delete(doc.ref);
    });
    
    if (allAttendance.size > 0) {
      await deleteBatch.commit();
      console.log(`✅ Deleted ${allAttendance.size} attendance records\n`);
    } else {
      console.log('ℹ️ No attendance records to delete\n');
    }

    // Step 3: Create new attendance record for today
    console.log('📝 Creating new attendance record for December 5, 2025...');
    
    const today = '2025-12-05';
    const checkInTime = '10:30:00'; // Late check-in
    const workStartTime = userData.work_start_time || '08:00';
    const lateThreshold = userData.late_threshold_minutes || 15;
    
    // Calculate status
    const [checkHours, checkMinutes] = checkInTime.split(':').map(Number);
    const checkInMinutes = checkHours * 60 + checkMinutes;
    
    const [startHours, startMinutes] = workStartTime.split(':').map(Number);
    const workStartMinutes = startHours * 60 + startMinutes;
    const lateThresholdTotal = workStartMinutes + lateThreshold;
    
    const status = checkInMinutes > lateThresholdTotal ? 'late' : 'present';
    
    const attendanceData = {
      user_id: userId,
      employee_id: userData.employee_id,
      date: today,
      check_in_time: checkInTime,
      check_out_time: null,
      status: status,
      check_in_location: {
        address: 'Lowokwaru, Malang, Jawa Timur, Jawa',
        latitude: -7.936140931667892,
        longitude: 112.624634074651
      },
      check_out_location: null,
      work_start_time: workStartTime + ':00',
      work_end_time: (userData.work_end_time || '17:00') + ':00',
      late_threshold_minutes: lateThreshold,
      notes: '',
      qr_code_used: 'BPR_Office_QR',
      qr_location: 'Main Office',
      created_at: admin.firestore.FieldValue.serverTimestamp(),
      updated_at: admin.firestore.FieldValue.serverTimestamp()
    };

    const newAttendance = await db.collection('attendance').add(attendanceData);
    
    console.log(`\n✅ Created new attendance record:`);
    console.log(`   ID: ${newAttendance.id}`);
    console.log(`   Date: ${today}`);
    console.log(`   User: ${userData.full_name} (${userData.employee_id})`);
    console.log(`   Check In: ${checkInTime}`);
    console.log(`   Status: ${status} ${status === 'late' ? '⏰' : '✅'}`);
    console.log(`   Work Start: ${workStartTime}:00`);
    console.log(`   Late Threshold: ${lateThreshold} minutes`);
    console.log(`   Late Threshold Time: ${Math.floor(lateThresholdTotal / 60)}:${(lateThresholdTotal % 60).toString().padStart(2, '0')}`);
    console.log(`   Check-in minutes: ${checkInMinutes}, Threshold: ${lateThresholdTotal}`);
    
    console.log('\n========================================');
    console.log('✅ ATTENDANCE DATA RESET COMPLETE!');
    console.log('========================================\n');

    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

resetAttendanceForUser();
