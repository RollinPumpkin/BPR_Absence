const http = require('http');

// Get token from localStorage or set manually
const token = 'YOUR_TOKEN_HERE'; // Replace with actual token from browser localStorage

const options = {
  hostname: 'localhost',
  port: 3000,
  path: '/api/assignments/upcoming',
  method: 'GET',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  }
};

const req = http.request(options, (res) => {
  let data = '';
  
  res.on('data', (chunk) => {
    data += chunk;
  });
  
  res.on('end', () => {
    try {
      const response = JSON.parse(data);
      console.log('📡 API Response:\n');
      console.log(JSON.stringify(response, null, 2));
      
      if (response.success && response.data && response.data.assignments) {
        console.log('\n📋 Assignments:');
        response.data.assignments.forEach((assignment, index) => {
          console.log(`\n${index + 1}. ${assignment.title}`);
          console.log(`   Status: ${assignment.status}`);
          console.log(`   CompletionTime: ${assignment.completionTime || 'null'}`);
          console.log(`   CompletionDate: ${assignment.completionDate || 'null'}`);
        });
      }
    } catch (error) {
      console.error('❌ Error parsing response:', error);
      console.log('Raw response:', data);
    }
  });
});

req.on('error', (error) => {
  console.error('❌ Request error:', error);
});

req.end();
