const admin = require('firebase-admin');
const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-da2d17d44d.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function checkAttendanceData() {
  try {
    console.log('\n========================================');
    console.log('🔍 CHECKING ATTENDANCE DATA FROM FIRESTORE');
    console.log('========================================\n');

    // First, check user data
    console.log('👤 Checking user ADM001...');
    const userSnapshot = await db.collection('users')
      .where('employee_id', '==', 'ADM001')
      .get();
    
    if (userSnapshot.empty) {
      console.log('❌ User with employee_id ADM001 not found!');
      process.exit(1);
    }

    const userDoc = userSnapshot.docs[0];
    const userData = userDoc.data();
    const userId = userDoc.id;
    
    console.log(`✅ Found user:`);
    console.log(`   User ID: ${userId}`);
    console.log(`   Employee ID: ${userData.employee_id}`);
    console.log(`   Name: ${userData.full_name}`);
    console.log(`   Email: ${userData.email}`);
    console.log(`   Work Start Time: ${userData.work_start_time || 'Not set'}`);
    console.log(`   Work End Time: ${userData.work_end_time || 'Not set'}`);
    console.log(`   Late Threshold: ${userData.late_threshold_minutes || 'Not set'} minutes\n`);

    // Get attendance by user_id
    console.log(`🔍 Fetching attendance records for user_id: ${userId}...\n`);
    let snapshot = await db.collection('attendance')
      .where('user_id', '==', userId)
      .get();

    if (snapshot.empty) {
      console.log('⚠️ No records found with user_id, trying employee_id...\n');
      snapshot = await db.collection('attendance')
        .where('employee_id', '==', userData.employee_id)
        .get();
    }

    if (snapshot.empty) {
      console.log('⚠️ No records found with employee_id either. Checking ALL attendance records...\n');
      snapshot = await db.collection('attendance')
        .orderBy('date', 'desc')
        .limit(10)
        .get();
      console.log(`📊 Showing last 10 attendance records from ALL users:\n`);
    }

    console.log(`📊 Total records found: ${snapshot.size}\n`);

    const records = [];
    snapshot.forEach(doc => {
      const data = doc.data();
      records.push({
        id: doc.id,
        date: data.date,
        check_in_time: data.check_in_time,
        check_out_time: data.check_out_time,
        status: data.status,
        work_start_time: data.work_start_time,
        late_threshold_minutes: data.late_threshold_minutes
      });
    });

    // Sort by date
    records.sort((a, b) => b.date.localeCompare(a.date));

    // Display each record
    records.forEach((record, index) => {
      console.log(`\n📝 Record #${index + 1}:`);
      console.log(`   ID: ${record.id}`);
      console.log(`   Date: ${record.date}`);
      console.log(`   Check In: ${record.check_in_time || 'N/A'}`);
      console.log(`   Check Out: ${record.check_out_time || 'N/A'}`);
      console.log(`   Status: ${record.status} ${record.status === 'late' ? '⏰' : record.status === 'present' ? '✅' : '❓'}`);
      console.log(`   Work Start: ${record.work_start_time || 'N/A'}`);
      console.log(`   Late Threshold: ${record.late_threshold_minutes || 'N/A'} minutes`);
    });

    // Calculate stats for December 2025
    const decemberRecords = records.filter(r => r.date.startsWith('2025-12'));
    console.log('\n========================================');
    console.log('📊 DECEMBER 2025 STATISTICS:');
    console.log('========================================');
    console.log(`Total Days: ${decemberRecords.length}`);
    
    const stats = {
      present: decemberRecords.filter(r => r.status === 'present').length,
      late: decemberRecords.filter(r => r.status === 'late').length,
      absent: decemberRecords.filter(r => r.status === 'absent').length,
    };
    
    console.log(`Present: ${stats.present} ✅`);
    console.log(`Late: ${stats.late} ⏰`);
    console.log(`Absent: ${stats.absent} ❌`);
    console.log('========================================\n');

    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

checkAttendanceData();
