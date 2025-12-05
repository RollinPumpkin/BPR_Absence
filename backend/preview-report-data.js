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

async function previewReportData() {
  console.log('📊 Preview Report Data\n');
  console.log('Fetching attendance data for report...\n');
  
  const startDate = moment().subtract(6, 'days').format('YYYY-MM-DD');
  const endDate = moment().format('YYYY-MM-DD');
  
  console.log(`Period: ${startDate} to ${endDate} (Last 7 days)\n`);
  
  // Get attendance data
  const attendanceSnapshot = await db.collection('attendance')
    .where('date', '>=', startDate)
    .where('date', '<=', endDate)
    .get();
  
  // Get all users
  const usersSnapshot = await db.collection('users').get();
  const usersMap = new Map();
  
  usersSnapshot.docs.forEach(doc => {
    const userData = doc.data();
    usersMap.set(doc.id, {
      id: doc.id,
      full_name: userData.full_name,
      employee_id: userData.employee_id,
      department: userData.department,
      position: userData.position,
      status: userData.status
    });
  });
  
  const departmentStats = {};
  const departmentDailyStats = {};
  
  attendanceSnapshot.docs.forEach(doc => {
    const attendance = doc.data();
    const user = usersMap.get(attendance.user_id);
    
    if (user) {
      const dept = user.department || 'Unknown';
      const date = attendance.date;
      
      // Department stats
      if (!departmentStats[dept]) {
        departmentStats[dept] = {
          total_records: 0,
          present: 0,
          late: 0,
          absent: 0,
          sick: 0,
          employees: new Set()
        };
      }
      
      departmentStats[dept].total_records++;
      departmentStats[dept].employees.add(attendance.user_id);
      departmentStats[dept][attendance.status]++;
      
      // Department daily stats
      if (!departmentDailyStats[dept]) {
        departmentDailyStats[dept] = {};
      }
      
      if (!departmentDailyStats[dept][date]) {
        departmentDailyStats[dept][date] = {
          total: 0,
          present: 0,
          late: 0,
          absent: 0,
          sick: 0,
          employees: new Set()
        };
      }
      
      departmentDailyStats[dept][date].total++;
      departmentDailyStats[dept][date].employees.add(attendance.user_id);
      departmentDailyStats[dept][date][attendance.status]++;
    }
  });
  
  // Display chart preview for each department
  console.log('═'.repeat(100));
  console.log('CHART DATA PREVIEW - This is what will be shown in the graphs');
  console.log('═'.repeat(100));
  
  Object.keys(departmentStats).sort().forEach(dept => {
    const stats = departmentStats[dept];
    const dailyData = departmentDailyStats[dept];
    
    // Calculate overall attendance rate
    const uniqueEmployees = stats.employees.size;
    const attendanceRate = ((stats.present + stats.late) / stats.total_records * 100).toFixed(2);
    
    console.log(`\n${'─'.repeat(100)}`);
    console.log(`📊 ${dept}`);
    console.log(`${'─'.repeat(100)}`);
    console.log(`Summary: Present ${stats.present}/${stats.total_records} • ${uniqueEmployees} employees • ${attendanceRate}% rate`);
    console.log(`\nDaily Attendance Rate (Last 7 days):`);
    console.log('');
    
    // Get sorted dates
    const dates = Object.keys(dailyData).sort();
    const last7Days = dates.length > 7 ? dates.slice(-7) : dates;
    
    // Create bar chart visualization
    const dayAbbr = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    
    console.log('  Date       | Day | Rate | Chart (each █ = 10%)');
    console.log('  ' + '─'.repeat(80));
    
    last7Days.forEach(date => {
      const dayData = dailyData[date];
      const rate = ((dayData.present + dayData.late) / dayData.total * 100);
      const parsedDate = moment(date);
      const dayName = dayAbbr[parsedDate.day()];
      const bars = Math.round(rate / 10);
      const chart = '█'.repeat(bars) + '░'.repeat(10 - bars);
      
      console.log(`  ${date} | ${dayName} | ${rate.toFixed(1).padStart(4)}% | ${chart} ${rate.toFixed(1)}%`);
    });
    
    console.log('\n  Detail:');
    last7Days.forEach(date => {
      const dayData = dailyData[date];
      console.log(`    ${date}: Present=${dayData.present}, Late=${dayData.late}, Absent=${dayData.absent}, Sick=${dayData.sick}, Total=${dayData.total}`);
    });
  });
  
  console.log('\n' + '═'.repeat(100));
  console.log('✅ This data will be displayed as line charts in the Report page');
  console.log('═'.repeat(100));
  console.log('');
}

async function main() {
  try {
    await previewReportData();
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

main();
