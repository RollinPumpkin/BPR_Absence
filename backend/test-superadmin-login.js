// Test specific superadmin@gmail.com login
const axios = require('axios');

async function testSpecificLogin() {
  try {
    console.log('🧪 TESTING superadmin@gmail.com LOGIN');
    console.log('====================================');
    
    const testAccounts = [
      { email: 'superadmin@gmail.com', password: '123456' },
      { email: 'superadmin@bpr.com', password: '123456' }
    ];
    
    for (const account of testAccounts) {
      console.log(`\n🔍 Testing: ${account.email}`);
      console.log('─'.repeat(40));
      
      try {
        const response = await axios.post('http://localhost:3000/api/auth/login', {
          email: account.email,
          password: account.password
        });
        
        if (response.data.success) {
          const userData = response.data.data.user;
          console.log('✅ Login Success');
          console.log('   Email:', userData.email);
          console.log('   Role:', userData.role);
          console.log('   Employee ID:', userData.employee_id);
          console.log('   Full Name:', userData.full_name);
        } else {
          console.log('❌ Login Failed:', response.data.message);
        }
        
      } catch (error) {
        if (error.response) {
          console.log('❌ Login Failed:', error.response.data.message);
          console.log('   Status:', error.response.status);
        } else {
          console.log('❌ Error:', error.message);
        }
      }
    }
    
  } catch (error) {
    console.error('Test Error:', error.message);
  }
}

testSpecificLogin();