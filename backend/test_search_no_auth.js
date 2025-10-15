// Test endpoint untuk debug search tanpa auth
const admin = require('firebase-admin');
const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

const db = admin.firestore();

async function testSearch(searchTerm) {
  try {
    console.log(`\n🔍 Testing search for: "${searchTerm}"`);
    
    // Simulate the same logic as the API endpoint
    const snapshot = await db.collection('users').get();
    const allUsers = [];
    
    console.log('📊 Total users in database:', snapshot.size);
    
    snapshot.forEach(doc => {
      const userData = doc.data();
      const user = { id: doc.id, ...userData };
      
      // Remove password from response
      delete user.password;
      
      // Check if user matches search criteria (same as API)
      const fullNameMatch = user.full_name?.toLowerCase().includes(searchTerm.toLowerCase());
      const emailMatch = user.email?.toLowerCase().includes(searchTerm.toLowerCase());
      const empIdMatch = user.employee_id?.toLowerCase().includes(searchTerm.toLowerCase());
      
      if (fullNameMatch || emailMatch || empIdMatch) {
        console.log('✅ Match found:', {
          id: user.id,
          name: user.full_name,
          email: user.email,
          empId: user.employee_id,
          matchType: {
            fullName: fullNameMatch,
            email: emailMatch,
            empId: empIdMatch
          }
        });
        allUsers.push(user);
      }
    });
    
    console.log(`🎯 Total matches for "${searchTerm}":`, allUsers.length);
    
    // Test the response structure that would be sent
    const response = {
      success: true,
      data: {
        users: allUsers,
        pagination: {
          current_page: 1,
          total_pages: Math.ceil(allUsers.length / 10),
          total_records: allUsers.length,
          limit: 10
        }
      }
    };
    
    console.log('📋 Response structure keys:', Object.keys(response));
    console.log('📋 Data keys:', Object.keys(response.data));
    console.log('📋 Users array length:', response.data.users.length);
    
    return response;
    
  } catch (error) {
    console.error('❌ Search test error:', error.message);
    return null;
  }
}

async function runSearchTests() {
  console.log('🧪 Running Search Tests...');
  
  const searchTerms = ['Bo', 'boh', 'bo', 'Boh', 'BOH', '', 'ahmad', 'budi'];
  
  for (const term of searchTerms) {
    await testSearch(term);
  }
}

runSearchTests();