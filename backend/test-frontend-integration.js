// Test script untuk memastikan frontend mendapat data dari backend
const http = require('http');

async function testFrontendAPI() {
  try {
    console.log('🧪 Testing frontend API integration...\n');
    
    // Test the debug endpoint yang digunakan frontend
    const options = {
      hostname: 'localhost',
      port: 3000,
      path: '/api/debug/stats',
      method: 'GET',
      headers: {
        'Content-Type': 'application/json'
      }
    };
    
    return new Promise((resolve, reject) => {
      const req = http.request(options, (res) => {
        let data = '';
        
        res.on('data', (chunk) => {
          data += chunk;
        });
        
        res.on('end', () => {
          try {
            const response = JSON.parse(data);
            console.log('✅ Backend API Response:');
            console.log('Status Code:', res.statusCode);
            console.log('Success:', response.success);
            console.log('Message:', response.message);
            console.log('Data:', JSON.stringify(response.data, null, 2));
            
            if (response.success && response.data) {
              console.log('\n📊 Parsed Statistics:');
              console.log(`  Total Employees: ${response.data.total}`);
              console.log(`  Active Employees: ${response.data.active}`);
              console.log(`  New Employees (1-3 months): ${response.data.new}`);
              console.log(`  Resigned Employees (non-active): ${response.data.resign}`);
              
              console.log('\n✅ Frontend should display these numbers now!');
            } else {
              console.error('❌ API returned error:', response.message);
            }
            
            resolve(response);
          } catch (parseError) {
            console.error('❌ Error parsing response:', parseError.message);
            console.log('Raw response:', data);
            reject(parseError);
          }
        });
      });
      
      req.on('error', (error) => {
        console.error('❌ Request error:', error.message);
        reject(error);
      });
      
      req.end();
    });
    
  } catch (error) {
    console.error('❌ Test error:', error.message);
  }
}

// Run the test
testFrontendAPI();