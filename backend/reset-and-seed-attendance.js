const admin = require('firebase-admin');

// Initialize Firebase Admin
const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-da2d17d44d.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function resetAndSeedAttendance() {
  try {
    console.log('\n========================================');
    console.log('🗑️  STEP 1: DELETING ALL ATTENDANCE RECORDS');
    console.log('========================================\n');
    
    // Delete all attendance records
    const attendanceSnapshot = await db.collection('attendance').get();
    const deletePromises = [];
    
    attendanceSnapshot.forEach(doc => {
      console.log(`Deleting attendance record: ${doc.id} (Date: ${doc.data().date})`);
      deletePromises.push(doc.ref.delete());
    });
    
    await Promise.all(deletePromises);
    console.log(`✅ Deleted ${deletePromises.length} attendance records\n`);

    console.log('========================================');
    console.log('👤 STEP 2: SETTING WORK SCHEDULE FOR EMPLOYEE');
    console.log('========================================\n');
    
    // Set work schedule for employee user
    const employeeRef = db.collection('users').doc('EMP001');
    await employeeRef.update({
      work_start_time: '08:00',
      work_end_time: '17:00',
      late_threshold_minutes: 15
    });
    
    console.log('✅ Updated work schedule for EMP001:');
    console.log('   Work Start: 08:00');
    console.log('   Work End: 17:00');
    console.log('   Late Threshold: 15 minutes\n');

    console.log('========================================');
    console.log('📝 STEP 3: CREATING NEW ATTENDANCE RECORD');
    console.log('========================================\n');
    
    // Create one attendance record for today
    const today = new Date();
    const dateStr = today.toISOString().split('T')[0]; // 2025-12-05
    const checkInTime = '10:30:00'; // This will be marked as "late"
    
    const attendanceData = {
      user_id: 'EMP001',
      employee_id: 'EMP001',
      date: dateStr,
      check_in_time: checkInTime,
      check_out_time: null,
      work_start_time: '08:00',
      work_end_time: '17:00',
      late_threshold_minutes: 15,
      status: 'late', // 10:30 > 08:15 = late
      location: {
        latitude: -7.250445,
        longitude: 112.768845,
        address: 'Jl. Raya Darmo No. 123, Surabaya'
      },
      created_at: admin.firestore.FieldValue.serverTimestamp(),
      updated_at: admin.firestore.FieldValue.serverTimestamp()
    };
    
    const newDoc = await db.collection('attendance').add(attendanceData);
    
    console.log('✅ Created attendance record:');
    console.log(`   ID: ${newDoc.id}`);
    console.log(`   User: EMP001 (Employee User)`);
    console.log(`   Date: ${dateStr}`);
    console.log(`   Check In: ${checkInTime}`);
    console.log(`   Status: late (10:30 > 08:15 threshold)`);
    console.log(`   Location: ${attendanceData.location.address}`);
    
    console.log('\n========================================');
    console.log('✅ RESET AND SEED COMPLETED SUCCESSFULLY');
    console.log('========================================\n');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

resetAndSeedAttendance();
