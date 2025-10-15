const jwt = require('jsonwebtoken');

const token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJnQUh3TWRKOFdPUkVWQ3hVU3lHbk1HZnU3cEcyIiwiZW1wbG95ZWVJZCI6IlNVUDAwMSIsInJvbGUiOiJzdXBlcl9hZG1pbiIsImlhdCI6MTc2MDQ1NDgwNCwiZXhwIjoxNzYxMDU5NjA0fQ.5QTH8CqyvhYQCFAV5K4LoOfEHuUBp5epeqn0_v5Z7qc';

try {
  console.log('🔍 Decoding JWT Token without verification...');
  const decoded = jwt.decode(token);
  console.log('📄 Decoded JWT payload:', JSON.stringify(decoded, null, 2));
  
  console.log('\n🔍 Manual field check:');
  console.log('- userId:', decoded.userId);
  console.log('- employeeId:', decoded.employeeId);
  console.log('- role:', decoded.role);
  console.log('- iat:', decoded.iat);
  console.log('- exp:', decoded.exp);
  
} catch (error) {
  console.error('❌ Error decoding token:', error.message);
}