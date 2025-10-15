const axios = require('axios');

async function testLettersAPI() {
  try {
    console.log('🔐 Step 1: Login to get token...');
    
    // Login first to get token
    const loginResponse = await axios.post('http://localhost:3000/api/auth/login', {
      email: 'admin@gmail.com',
      password: '123456'
    });
    
    if (!loginResponse.data.success) {
      console.log('❌ Login failed:', loginResponse.data.message);
      return;
    }
    
    const token = loginResponse.data.data.token;
    console.log('✅ Login successful! Token received');
    console.log('� Login response data:', JSON.stringify(loginResponse.data, null, 2));
    
    if (loginResponse.data.user) {
      console.log('�👤 User role:', loginResponse.data.user.role);
      console.log('🆔 Employee ID:', loginResponse.data.user.employee_id);
    }
    
    console.log('\n📬 Step 2: Fetching letters with authentication...');
    
    // Fetch letters with token
    const lettersResponse = await axios.get('http://localhost:3000/api/letters', {
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    });
    
    console.log('✅ Letters API Response:');
    console.log('📊 Total letters:', lettersResponse.data.length);
    
    if (lettersResponse.data.length > 0) {
      console.log('\n📄 First letter sample:');
      const firstLetter = lettersResponse.data[0];
      console.log(JSON.stringify({
        id: firstLetter.id,
        subject: firstLetter.subject,
        status: firstLetter.status,
        letterType: firstLetter.letterType || firstLetter.letter_type,
        senderName: firstLetter.senderName || firstLetter.sender_name,
        createdAt: firstLetter.createdAt || firstLetter.created_at
      }, null, 2));
      
      // Show status distribution
      const statusCount = {};
      lettersResponse.data.forEach(letter => {
        const status = letter.status;
        statusCount[status] = (statusCount[status] || 0) + 1;
      });
      
      console.log('\n📈 Status Distribution:');
      Object.entries(statusCount).forEach(([status, count]) => {
        console.log(`  ${status}: ${count} letters`);
      });
      
      // Show pending letters specifically
      const pendingLetters = lettersResponse.data.filter(letter => 
        letter.status === 'waiting_approval' || letter.status === 'pending'
      );
      console.log(`\n⏳ Pending letters for admin: ${pendingLetters.length}`);
      
      if (pendingLetters.length > 0) {
        console.log('📋 Pending letters list:');
        pendingLetters.forEach((letter, index) => {
          console.log(`  ${index + 1}. ${letter.subject} - ${letter.status}`);
        });
      }
    } else {
      console.log('📭 No letters found in database');
    }
    
  } catch (error) {
    console.log('❌ Error:', error.response?.data || error.message);
    if (error.response?.status) {
      console.log('📄 Status Code:', error.response.status);
    }
  }
}

testLettersAPI();