const admin = require('firebase-admin');
const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-da2d17d44d.json');
const moment = require('moment');

// Initialize Firebase Admin
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

const db = admin.firestore();

// Departments dan jumlah employees per department
const departments = [
  { name: 'IT Department', employeeCount: 15, prefix: 'IT' },
  { name: 'Finance', employeeCount: 12, prefix: 'FIN' },
  { name: 'Operations', employeeCount: 20, prefix: 'OPS' },
  { name: 'Management', employeeCount: 8, prefix: 'MGT' },
  { name: 'HR', employeeCount: 10, prefix: 'HR' }
];

// Status attendance dengan probabilitas
const attendanceStatuses = [
  { status: 'present', weight: 70 },
  { status: 'late', weight: 15 },
  { status: 'absent', weight: 10 },
  { status: 'sick', weight: 5 }
];

function getRandomStatus() {
  const random = Math.random() * 100;
  let cumulative = 0;
  
  for (const item of attendanceStatuses) {
    cumulative += item.weight;
    if (random <= cumulative) {
      return item.status;
    }
  }
  return 'present';
}

function getRandomTime(baseHour, variation) {
  const hour = baseHour + Math.floor(Math.random() * variation);
  const minute = Math.floor(Math.random() * 60);
  return `${hour.toString().padStart(2, '0')}:${minute.toString().padStart(2, '0')}:00`;
}

async function createUsers() {
  console.log('📝 Creating users...\n');
  const batch = db.batch();
  const users = [];
  
  for (const dept of departments) {
    for (let i = 1; i <= dept.employeeCount; i++) {
      const employeeId = `${dept.prefix}${i.toString().padStart(3, '0')}`;
      const userId = `user_${employeeId.toLowerCase()}`;
      
      const userData = {
        employee_id: employeeId,
        full_name: `Employee ${employeeId}`,
        email: `${employeeId.toLowerCase()}@bpr.com`,
        department: dept.name,
        position: i <= 2 ? 'Manager' : 'Staff',
        role: 'employee',
        status: 'active',
        hire_date: moment().subtract(Math.floor(Math.random() * 365), 'days').format('YYYY-MM-DD'),
        phone: `08${Math.floor(Math.random() * 1000000000).toString().padStart(9, '0')}`,
        address: `Jl. ${dept.name} No. ${i}`,
        created_at: admin.firestore.FieldValue.serverTimestamp(),
        updated_at: admin.firestore.FieldValue.serverTimestamp()
      };
      
      const userRef = db.collection('users').doc(userId);
      batch.set(userRef, userData);
      
      users.push({
        id: userId,
        employee_id: employeeId,
        department: dept.name,
        full_name: userData.full_name
      });
      
      console.log(`✅ Created user: ${userData.full_name} (${employeeId}) - ${dept.name}`);
    }
  }
  
  await batch.commit();
  console.log(`\n✅ Created ${users.length} users\n`);
  return users;
}

async function createAttendanceRecords(users) {
  console.log('📊 Creating attendance records for last 14 days...\n');
  
  // Get last 14 days
  const dates = [];
  for (let i = 13; i >= 0; i--) {
    dates.push(moment().subtract(i, 'days').format('YYYY-MM-DD'));
  }
  
  let totalRecords = 0;
  const batchSize = 500;
  let batch = db.batch();
  let batchCount = 0;
  
  for (const date of dates) {
    console.log(`\n📅 Creating attendance for ${date}...`);
    let dayCount = 0;
    
    for (const user of users) {
      // Random: 5% chance tidak ada attendance untuk hari ini
      if (Math.random() < 0.05) continue;
      
      const status = getRandomStatus();
      const checkInTime = getRandomTime(7, 3); // 07:00 - 09:59
      const checkOutTime = status === 'absent' ? null : getRandomTime(16, 3); // 16:00 - 18:59
      
      const attendanceId = `att_${user.employee_id}_${date.replace(/-/g, '')}`;
      const attendanceData = {
        user_id: user.id,
        employee_id: user.employee_id,
        date: date,
        status: status,
        check_in_time: status === 'absent' ? null : checkInTime,
        check_out_time: checkOutTime,
        check_in_location: status === 'absent' ? null : {
          address: 'PT. BPR Office',
          latitude: -6.2088,
          longitude: 106.8456
        },
        check_out_location: checkOutTime ? {
          address: 'PT. BPR Office',
          latitude: -6.2088,
          longitude: 106.8456
        } : null,
        notes: status === 'sick' ? 'Sakit' : (status === 'late' ? 'Terlambat' : null),
        timestamp: admin.firestore.Timestamp.fromDate(
          moment(`${date} ${checkInTime || '00:00:00'}`).toDate()
        ),
        created_at: admin.firestore.Timestamp.fromDate(
          moment(`${date} ${checkInTime || '00:00:00'}`).toDate()
        ),
        updated_at: admin.firestore.Timestamp.fromDate(
          moment(`${date} ${checkOutTime || checkInTime || '00:00:00'}`).toDate()
        )
      };
      
      const attendanceRef = db.collection('attendance').doc(attendanceId);
      batch.set(attendanceRef, attendanceData);
      
      batchCount++;
      dayCount++;
      totalRecords++;
      
      // Commit batch jika sudah mencapai limit
      if (batchCount >= batchSize) {
        await batch.commit();
        console.log(`  💾 Committed ${batchCount} records`);
        batch = db.batch();
        batchCount = 0;
      }
    }
    
    console.log(`  ✅ Created ${dayCount} attendance records for ${date}`);
  }
  
  // Commit remaining batch
  if (batchCount > 0) {
    await batch.commit();
    console.log(`  💾 Committed final ${batchCount} records`);
  }
  
  console.log(`\n✅ Total attendance records created: ${totalRecords}\n`);
}

async function showStatistics() {
  console.log('\n📊 Attendance Statistics:\n');
  
  // Get all attendance
  const attendanceSnapshot = await db.collection('attendance').get();
  const attendanceRecords = attendanceSnapshot.docs.map(doc => doc.data());
  
  // Get all users
  const usersSnapshot = await db.collection('users').get();
  const usersMap = new Map();
  usersSnapshot.docs.forEach(doc => {
    const data = doc.data();
    usersMap.set(doc.id, data);
  });
  
  // Statistics by department
  const deptStats = {};
  
  attendanceRecords.forEach(record => {
    const user = usersMap.get(record.user_id);
    if (!user) return;
    
    const dept = user.department || 'Unknown';
    if (!deptStats[dept]) {
      deptStats[dept] = {
        total: 0,
        present: 0,
        late: 0,
        absent: 0,
        sick: 0,
        employees: new Set()
      };
    }
    
    deptStats[dept].total++;
    deptStats[dept].employees.add(record.user_id);
    deptStats[dept][record.status]++;
  });
  
  // Display statistics
  console.log('Department Statistics:');
  console.log('─'.repeat(80));
  
  Object.keys(deptStats).sort().forEach(dept => {
    const stats = deptStats[dept];
    const rate = ((stats.present + stats.late) / stats.total * 100).toFixed(1);
    
    console.log(`\n${dept}:`);
    console.log(`  Employees: ${stats.employees.size}`);
    console.log(`  Total Records: ${stats.total}`);
    console.log(`  Present: ${stats.present} (${(stats.present/stats.total*100).toFixed(1)}%)`);
    console.log(`  Late: ${stats.late} (${(stats.late/stats.total*100).toFixed(1)}%)`);
    console.log(`  Absent: ${stats.absent} (${(stats.absent/stats.total*100).toFixed(1)}%)`);
    console.log(`  Sick: ${stats.sick} (${(stats.sick/stats.total*100).toFixed(1)}%)`);
    console.log(`  Attendance Rate: ${rate}%`);
  });
  
  console.log('\n' + '─'.repeat(80));
  console.log(`\n✅ Total Users: ${usersMap.size}`);
  console.log(`✅ Total Attendance Records: ${attendanceRecords.length}\n`);
}

async function main() {
  console.log('🚀 Starting Attendance Data Seeding...\n');
  console.log('This will create:');
  console.log('- Users for 5 departments (65 employees total)');
  console.log('- Attendance records for last 14 days');
  console.log('- Realistic attendance patterns (70% present, 15% late, 10% absent, 5% sick)\n');
  
  try {
    // Check if data already exists
    const existingUsers = await db.collection('users')
      .where('role', '==', 'employee')
      .limit(1)
      .get();
    
    if (!existingUsers.empty) {
      console.log('⚠️  Warning: Employee users already exist in database!');
      console.log('This script will ADD MORE data. Continue? (Ctrl+C to cancel)\n');
      await new Promise(resolve => setTimeout(resolve, 3000));
    }
    
    // Create users
    const users = await createUsers();
    
    // Create attendance records
    await createAttendanceRecords(users);
    
    // Show statistics
    await showStatistics();
    
    console.log('✅ Seeding completed successfully!\n');
    console.log('You can now test the report page with real data from database.\n');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error during seeding:', error);
    process.exit(1);
  }
}

// Run the script
main();
