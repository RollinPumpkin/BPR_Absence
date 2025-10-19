const axios = require('axios');

async function testLateAttendanceData() {
  try {
    console.log('🔄 Testing for late attendance data...');
    
    // First login as admin
    const loginResponse = await axios.post('http://localhost:3000/api/auth/login', {
      email: 'admin@gmail.com',
      password: '123456'
    });

    if (!loginResponse.data.success) {
      console.error('❌ Login failed:', loginResponse.data.message);
      return;
    }

    const token = loginResponse.data.data.token;
    console.log('✅ Login successful');

    // Get ALL attendance records to look for "late" status
    let page = 1;
    const limit = 100;
    let totalRecords = 0;
    let lateRecords = 0;
    let allStatuses = new Set();

    while (true) {
      const attendanceResponse = await axios.get('http://localhost:3000/api/attendance', {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        params: {
          page: page,
          limit: limit,
        }
      });

      if (!attendanceResponse.data.success || !attendanceResponse.data.data) {
        break;
      }

      const { attendance, pagination } = attendanceResponse.data.data;
      totalRecords += attendance.length;

      console.log(`📄 Page ${page}: ${attendance.length} records`);

      attendance.forEach(record => {
        const status = record.status.toLowerCase();
        allStatuses.add(status);
        
        if (status === 'late') {
          lateRecords++;
          console.log(`⏰ LATE record found:`);
          console.log(`   Name: ${record.userName || 'N/A'}`);
          console.log(`   Department: ${record.department || 'N/A'}`);
          console.log(`   Date: ${record.date}`);
          console.log(`   Check In: ${record.checkInTime || 'N/A'}`);
        }
      });

      if (!pagination.has_next_page) {
        break;
      }
      page++;
    }

    console.log(`\n📊 SUMMARY:`);
    console.log(`Total records scanned: ${totalRecords}`);
    console.log(`Late records found: ${lateRecords}`);
    console.log(`\n📋 All unique statuses found:`);
    Array.from(allStatuses).sort().forEach(status => {
      console.log(`  - ${status}`);
    });

    if (lateRecords === 0) {
      console.log('\n⚠️ NO LATE RECORDS FOUND!');
      console.log('💡 Suggestion: Add some late records to Firestore for testing');
    }

  } catch (error) {
    console.error('❌ Error:', error.response?.data || error.message);
  }
}

testLateAttendanceData();