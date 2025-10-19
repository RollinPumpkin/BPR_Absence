// Test API endpoints directly 
const axios = require('axios');

const baseUrl = 'http://localhost:3000/api';
const testEmail = 'admin@gmail.com';
const testPassword = '123456';

async function testApiEndpoints() {
  console.log('🧪 TESTING API ENDPOINTS');
  console.log('========================\n');

  try {
    // 1. Test Login
    console.log('1️⃣ Testing Login...');
    const loginResponse = await axios.post(`${baseUrl}/auth/login`, {
      email: testEmail,
      password: testPassword
    });
    
    if (loginResponse.data.success) {
      console.log('✅ Login successful');
      const token = loginResponse.data.data.token;
      console.log(`🔑 Token: ${token.substring(0, 20)}...`);
      
      // 2. Test Letters endpoint
      console.log('\n2️⃣ Testing Letters endpoint...');
      const lettersResponse = await axios.get(`${baseUrl}/letters`, {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      
      if (lettersResponse.data.success) {
        console.log('✅ Letters endpoint working');
        console.log(`📄 Found ${lettersResponse.data.data.letters?.length || 0} letters`);
      } else {
        console.log('❌ Letters endpoint failed:', lettersResponse.data.message);
      }
      
      // 3. Test Assignments endpoint 
      console.log('\n3️⃣ Testing Assignments endpoint...');
      const assignmentsResponse = await axios.get(`${baseUrl}/assignments`, {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      
      if (assignmentsResponse.data.success) {
        console.log('✅ Assignments endpoint working');
        console.log(`📋 Found ${assignmentsResponse.data.data.assignments?.length || 0} assignments`);
        
        // Show first assignment structure
        if (assignmentsResponse.data.data.assignments && assignmentsResponse.data.data.assignments.length > 0) {
          console.log('\n📋 First assignment structure:');
          const firstAssignment = assignmentsResponse.data.data.assignments[0];
          console.log(`Title: ${firstAssignment.title}`);
          console.log(`Status: ${firstAssignment.status}`);
          console.log(`Due Date: ${firstAssignment.dueDate}`);
        }
      } else {
        console.log('❌ Assignments endpoint failed:', assignmentsResponse.data.message);
      }
      
      // 4. Test Received Letters endpoint
      console.log('\n4️⃣ Testing Received Letters endpoint...');
      const receivedResponse = await axios.get(`${baseUrl}/letters/received`, {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      
      if (receivedResponse.data.success) {
        console.log('✅ Received letters endpoint working');
        console.log(`📨 Found ${receivedResponse.data.data.letters?.length || 0} received letters`);
      } else {
        console.log('❌ Received letters endpoint failed:', receivedResponse.data.message);
      }
      
    } else {
      console.log('❌ Login failed:', loginResponse.data.message);
    }
    
  } catch (error) {
    console.error('💥 API Test Error:', error.response?.data || error.message);
  }
}

testApiEndpoints();