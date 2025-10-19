const axios = require('axios');

async function testAttendanceStatusDistribution() {
  try {
    console.log('🔄 Testing attendance status distribution...');
    
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

    // Get ALL attendance records to see status distribution
    const attendanceResponse = await axios.get('http://localhost:3000/api/attendance', {
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      },
      params: {
        limit: 100, // Get more records
      }
    });

    if (attendanceResponse.data.success && attendanceResponse.data.data) {
      const { attendance } = attendanceResponse.data.data;
      console.log(`📊 Analyzing ${attendance.length} attendance records...`);
      
      // Count by status
      const statusCounts = {};
      attendance.forEach(record => {
        const status = record.status.toLowerCase();
        statusCounts[status] = (statusCounts[status] || 0) + 1;
      });

      console.log('\n📈 Status Distribution:');
      Object.entries(statusCounts).forEach(([status, count]) => {
        console.log(`  ${status}: ${count} records`);
      });

      console.log('\n📝 Sample records by status:');
      const sampleByStatus = {};
      attendance.forEach(record => {
        const status = record.status.toLowerCase();
        if (!sampleByStatus[status]) {
          sampleByStatus[status] = record;
        }
      });

      Object.entries(sampleByStatus).forEach(([status, record]) => {
        console.log(`\n${status.toUpperCase()} example:`);
        console.log(`  Name: ${record.userName || 'N/A'}`);
        console.log(`  Department: ${record.department || 'N/A'}`);
        console.log(`  Date: ${record.date}`);
        console.log(`  Check In: ${record.checkInTime || 'N/A'}`);
        console.log(`  Check Out: ${record.checkOutTime || 'N/A'}`);
      });

    } else {
      console.log('⚠️ No attendance data found');
    }

  } catch (error) {
    console.error('❌ Error:', error.response?.data || error.message);
  }
}

testAttendanceStatusDistribution();