// Simple test without axios dependency
const https = require('https');
const http = require('http');

function testEndpoint() {
  const options = {
    hostname: 'localhost',
    port: 3000,
    path: '/api/admin/users?page=1&limit=5',
    method: 'GET',
    headers: {
      'Content-Type': 'application/json'
    }
  };

  const req = http.request(options, (res) => {
    console.log(`✅ Status: ${res.statusCode}`);
    console.log(`📋 Headers:`, res.headers);

    let data = '';
    res.on('data', (chunk) => {
      data += chunk;
    });

    res.on('end', () => {
      try {
        const jsonData = JSON.parse(data);
        console.log('📊 Response Data:');
        console.log(JSON.stringify(jsonData, null, 2));
        
        // Structure analysis
        console.log('\n🔍 Structure Analysis:');
        console.log('- Response type:', typeof jsonData);
        console.log('- Keys:', Object.keys(jsonData));
        
        if (jsonData.success !== undefined) {
          console.log('- Success field:', jsonData.success);
        }
        
        if (jsonData.data) {
          console.log('- Data field exists:', true);
          console.log('- Data field keys:', Object.keys(jsonData.data));
        }
        
        if (jsonData.users) {
          console.log('- Direct users array length:', jsonData.users.length);
        }
        
      } catch (e) {
        console.log('📋 Raw Response (not JSON):');
        console.log(data);
        console.log('❌ Parse Error:', e.message);
      }
    });
  });

  req.on('error', (e) => {
    console.error('❌ Request Error:', e.message);
  });

  req.end();
}

console.log('🔍 Testing /api/admin/users endpoint...');
testEndpoint();