const axios = require('axios');

const BASE_URL = 'http://localhost:3000/api';

// Test credentials
const testUsers = [
  {
    email: 'user@gmail.com',
    password: 'user123',
    name: 'User Test'
  },
  {
    email: 'admin@bpr.com', 
    password: 'admin123',
    name: 'Admin User'
  }
];

async function testUserSpecificLetters() {
  console.log('🧪 Testing User-Specific Letter Functionality\n');

  for (const user of testUsers) {
    console.log(`\n👤 Testing for ${user.name} (${user.email})`);
    console.log('=' .repeat(50));

    try {
      // 1. Login
      console.log('1️⃣ Logging in...');
      const loginResponse = await axios.post(`${BASE_URL}/auth/login`, {
        email: user.email,
        password: user.password
      });

      if (!loginResponse.data.success) {
        console.log('❌ Login failed');
        continue;
      }

      const token = loginResponse.data.data.token;
      const userId = loginResponse.data.data.user.id;
      console.log(`✅ Login successful - User ID: ${userId}`);

      // 2. Get letters for this user
      console.log('2️⃣ Getting letters...');
      const lettersResponse = await axios.get(`${BASE_URL}/letters`, {
        headers: { Authorization: `Bearer ${token}` }
      });

      if (lettersResponse.data.success) {
        const letters = lettersResponse.data.data.letters;
        console.log(`✅ Found ${letters.length} letters for ${user.name}`);
        
        // Show letter details
        letters.forEach((letter, index) => {
          console.log(`   📋 Letter ${index + 1}: ${letter.subject} (Status: ${letter.status})`);
          console.log(`       Recipient: ${letter.recipient_name} (ID: ${letter.recipient_id})`);
        });
      } else {
        console.log('❌ Failed to get letters');
      }

      // 3. Test letter creation if user is admin
      if (user.email.includes('admin')) {
        console.log('3️⃣ Testing letter creation (Admin)...');
        
        const newLetter = {
          recipient_id: userId, // Create letter for self as test
          subject: `Test Letter from ${user.name}`,
          content: 'This is a test letter created by admin to verify user-specific functionality.',
          letter_type: 'memo',
          priority: 'normal'
        };

        const createResponse = await axios.post(`${BASE_URL}/letters`, newLetter, {
          headers: { Authorization: `Bearer ${token}` }
        });

        if (createResponse.data.success) {
          console.log('✅ Letter created successfully');
        } else {
          console.log('❌ Failed to create letter');
        }
      }

    } catch (error) {
      console.log(`❌ Error testing ${user.name}:`, error.response?.data?.message || error.message);
    }
  }
}

// Test cross-user access (security test)
async function testSecurityIsolation() {
  console.log('\n🔒 Testing Security Isolation');
  console.log('=' .repeat(50));

  try {
    // Login as regular user
    const userLogin = await axios.post(`${BASE_URL}/auth/login`, {
      email: 'user@gmail.com',
      password: 'user123'
    });

    const userToken = userLogin.data.data.token;

    // Try to access admin endpoints
    console.log('1️⃣ Testing user access to admin endpoints...');
    
    try {
      await axios.get(`${BASE_URL}/users`, {
        headers: { Authorization: `Bearer ${userToken}` }
      });
      console.log('❌ Security breach: User can access admin endpoint');
    } catch (error) {
      if (error.response?.status === 403) {
        console.log('✅ Security working: User blocked from admin endpoint');
      } else {
        console.log('⚠️ Unexpected error:', error.response?.data?.message);
      }
    }

    // Test letter filtering
    console.log('2️⃣ Testing letter filtering...');
    const lettersResponse = await axios.get(`${BASE_URL}/letters`, {
      headers: { Authorization: `Bearer ${userToken}` }
    });

    if (lettersResponse.data.success) {
      const letters = lettersResponse.data.data.letters;
      const userId = userLogin.data.data.user.id;
      
      const hasOtherUserLetters = letters.some(letter => 
        letter.recipient_id !== userId && letter.sender_id !== userId
      );
      
      if (hasOtherUserLetters) {
        console.log('❌ Security issue: User can see other users\' letters');
      } else {
        console.log('✅ Security working: User only sees own letters');
      }
    }

  } catch (error) {
    console.log('❌ Security test error:', error.response?.data?.message || error.message);
  }
}

async function runTests() {
  console.log('🚀 Starting User-Specific Letter System Tests\n');
  console.log('Backend URL:', BASE_URL);
  console.log('Time:', new Date().toLocaleString());
  console.log('\n');

  await testUserSpecificLetters();
  await testSecurityIsolation();

  console.log('\n🎉 Testing Complete!');
  console.log('\nTo test the frontend:');
  console.log('1. Open http://localhost:8080 in your browser');
  console.log('2. Login with user@gmail.com / user123');
  console.log('3. Navigate to Letters page');
  console.log('4. Create a new letter and verify it appears in your list');
  console.log('5. Login with a different user and verify you only see your own letters');
}

runTests().catch(console.error);