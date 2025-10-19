const axios = require('axios');

async function testAttendanceEndpoint() {
  try {
    console.log('🔄 Testing attendance endpoint...');
    
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
    console.log('✅ Login successful, got token');

    // Test attendance endpoint
    const attendanceResponse = await axios.get('http://localhost:3000/api/attendance', {
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      },
      params: {
        limit: 10
      }
    });

    console.log('✅ Attendance endpoint response:');
    console.log('Status:', attendanceResponse.status);
    console.log('Success:', attendanceResponse.data.success);
    
    if (attendanceResponse.data.success && attendanceResponse.data.data) {
      const { attendance, pagination } = attendanceResponse.data.data;
      console.log(`📊 Found ${attendance.length} attendance records`);
      console.log('Pagination:', pagination);
      
      if (attendance.length > 0) {
        console.log('📝 Sample attendance record:');
        console.log(JSON.stringify(attendance[0], null, 2));
      }
    } else {
      console.log('⚠️ No data found or failed response');
      console.log('Response:', JSON.stringify(attendanceResponse.data, null, 2));
    }

  } catch (error) {
    console.error('❌ Error testing attendance endpoint:', error.response?.data || error.message);
  }
}

testAttendanceEndpoint();