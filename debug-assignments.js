// Quick test untuk assignments endpoint
const fetch = require('node-fetch');

async function testAssignments() {
  const token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1aWQiOiJnQUh3TWRKOFE4V09SRVZDeFVTeUduTUdmdTdwRzIiLCJ1c2VySWQiOiJnQUh3TWRKOFE4V09SRVZDeFVTeUduTUdmdTdwRzIiLCJlbXBsb3llZUlkIjoiU1VQMDAxIiwiZW1haWwiOiJhZG1pbkBnbWFpbC5jb20iLCJyb2xlIjoic3VwZXJfYWRtaW4iLCJpYXQiOjE3MzQyMzg4NzAsImV4cCI6MTczNDMyNTI3MH0.QW8q0OLY4FGzexxKCFAnLXY9wRhzPpNAkLgGW8noafg';
  
  try {
    const response = await fetch('http://localhost:3000/api/assignments/admin/dashboard/summary', {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });
    
    const data = await response.json();
    console.log('Status:', response.status);
    console.log('Response:', JSON.stringify(data, null, 2));
  } catch (error) {
    console.error('Error:', error.message);
  }
}

testAssignments();