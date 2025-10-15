// Quick test with valid credentials
const axios = require('axios');

async function quickTest() {
  const tests = [
    { email: 'admin@gmail.com', name: 'Super Admin' },
    { email: 'test@bpr.com', name: 'Regular Admin' },
    { email: 'user@gmail.com', name: 'Employee' }
  ];
  
  for (const test of tests) {
    try {
      const response = await axios.post('http://localhost:3000/api/auth/login', {
        email: test.email,
        password: '123456'
      });
      
      if (response.data.success) {
        const user = response.data.data.user;
        const route = (user.role === 'super_admin' || user.role === 'admin') 
          ? '/admin/dashboard' 
          : '/user/dashboard';
        
        console.log(`✅ ${test.name}: ${user.role} → ${route}`);
      }
    } catch (error) {
      console.log(`❌ ${test.name}: Login failed`);
    }
  }
}

quickTest();