const axios = require('axios');

async function testLetters() {
  try {
    // Login first
    const loginResponse = await axios.post('http://localhost:3000/api/auth/login', {
      email: 'admin@bpr.com',
      password: 'admin123'
    });
    
    const token = loginResponse.data.data.token;
    console.log('✅ Login successful');
    
    // Test getting templates
    const templatesResponse = await axios.get('http://localhost:3000/api/letters/templates/list', {
      headers: { Authorization: `Bearer ${token}` }
    });
    
    console.log('\n📄 Available Templates:');
    templatesResponse.data.data.templates.forEach(template => {
      console.log(`- ${template.name} (${template.letter_type})`);
    });
    
    console.log(`\nTotal Templates: ${templatesResponse.data.data.templates.length}`);
    
    // Test getting letters
    const lettersResponse = await axios.get('http://localhost:3000/api/letters', {
      headers: { Authorization: `Bearer ${token}` }
    });
    
    console.log(`\n📮 Current Letters: ${lettersResponse.data.data.letters.length}`);
    
  } catch (error) {
    console.error('❌ Error:', error.response?.data || error.message);
  }
}

testLetters();