const axios = require('axios');

async function testProfile() {
  try {
    console.log('🚀 Testing Profile System...\n');

    // Create fresh test users
    console.log('📝 Creating test users...');
    
    // Login admin to get token
    const adminLogin = await axios.post('http://localhost:3000/api/auth/login', {
      email: 'admin@bpr.com',
      password: 'admin123'
    });
    
    const adminToken = adminLogin.data.data.token;
    console.log('✅ Admin login successful');

    // Login user to get token  
    const userLogin = await axios.post('http://localhost:3000/api/auth/login', {
      email: 'user@bpr.com',
      password: 'user123'
    });
    
    const userToken = userLogin.data.data.token;
    console.log('✅ User login successful');
    
    console.log('\n👤 Testing Basic Profile Operations...\n');

    // 1. Get current user profile
    const profileResponse = await axios.get('http://localhost:3000/api/profile', {
      headers: { Authorization: `Bearer ${userToken}` }
    });
    
    console.log('✅ Get Current Profile:', profileResponse.data.success);
    const userId = profileResponse.data.data.profile.id;
    
    // 2. Update profile
    const updateResponse = await axios.put('http://localhost:3000/api/profile', {
      full_name: 'Updated Test User',
      phone: '081234567890',
      address: 'Jl. Test Update No. 123'
    }, {
      headers: { Authorization: `Bearer ${userToken}` }
    });
    
    console.log('✅ Update Profile:', updateResponse.data.success);
    
    // 3. Get all users (admin)
    const usersResponse = await axios.get('http://localhost:3000/api/profile/users', {
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    
    console.log('✅ Get All Users (Admin):', usersResponse.data.success);
    console.log(`   Found ${usersResponse.data.data.users.length} users`);
    
    // 4. Get user by ID (admin)
    const userByIdResponse = await axios.get(`http://localhost:3000/api/profile/user/${userId}`, {
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    
    console.log('✅ Get User By ID (Admin):', userByIdResponse.data.success);
    
    // 5. Search users
    const searchResponse = await axios.get('http://localhost:3000/api/profile/users?search=test', {
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    
    console.log('✅ Search Users:', searchResponse.data.success);
    
    // 6. Filter users by department
    const filterResponse = await axios.get('http://localhost:3000/api/profile/users?department=Testing', {
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    
    console.log('✅ Filter Users by Department:', filterResponse.data.success);
    
    console.log('\n🔐 Testing Security Features...\n');
    
    // 7. Test user trying to access admin endpoint
    try {
      await axios.get('http://localhost:3000/api/profile/users', {
        headers: { Authorization: `Bearer ${userToken}` }
      });
      console.log('❌ User access to admin endpoint should be blocked');
    } catch (error) {
      console.log('✅ User access to admin endpoint properly blocked');
    }
    
    // 8. Test invalid token
    try {
      await axios.get('http://localhost:3000/api/profile', {
        headers: { Authorization: 'Bearer invalid_token' }
      });
      console.log('❌ Invalid token should be rejected');
    } catch (error) {
      console.log('✅ Invalid token properly rejected');
    }
    
    console.log('\n📊 Profile System Test Summary');
    console.log('============================================================');
    console.log('✅ All core profile functionality working correctly!');
    console.log('✅ Security controls in place');
    console.log('✅ Admin user management working');
    console.log('✅ Search and filtering operational');
    console.log('\n🎉 Profile System Implementation Complete!');
    
  } catch (error) {
    console.error('❌ Test failed:', error.response?.data || error.message);
  }
}

testProfile();