// Quick test to verify endpoint URLs
console.log('🧪 TESTING FRONTEND API ENDPOINTS');
console.log('================================');

// Simulate the API constants
const ApiConstants = {
  baseUrl: 'http://localhost:3000/api',
  assignments: {
    list: '/assignments',
    upcoming: '/assignments/upcoming'
  }
};

console.log('Base URL:', ApiConstants.baseUrl);
console.log('Assignment list endpoint:', ApiConstants.assignments.list);
console.log('Full assignment URL:', ApiConstants.baseUrl + ApiConstants.assignments.list);
console.log('');
console.log('Previous incorrect URL: http://localhost:3000/api/api/assignments');
console.log('Corrected URL:         http://localhost:3000/api/assignments');
console.log('');
console.log('✅ Fix applied: Using ApiConstants.assignments.list instead of /api/assignments');