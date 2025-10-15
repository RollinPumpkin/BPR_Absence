const admin = require('firebase-admin');
const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

const db = admin.firestore();

async function checkUserFields() {
  try {
    console.log('🔍 Checking user field names and search functionality...');
    
    const snapshot = await db.collection('users').limit(5).get();
    
    console.log(`📊 Found ${snapshot.size} users to analyze:`);
    
    snapshot.forEach((doc, index) => {
      const data = doc.data();
      console.log(`\n👤 User ${index + 1} (ID: ${doc.id}):`);
      console.log('📋 Available fields:', Object.keys(data));
      console.log('📝 Full Name variations:');
      console.log('  - full_name:', data.full_name || 'NOT FOUND');
      console.log('  - fullName:', data.fullName || 'NOT FOUND');
      console.log('  - name:', data.name || 'NOT FOUND');
      console.log('📧 Email:', data.email || 'NOT FOUND');
      console.log('🆔 Employee ID:', data.employee_id || data.employeeId || 'NOT FOUND');
      
      // Test search terms
      const testSearches = ['Bo', 'boh', 'bo'];
      testSearches.forEach(search => {
        const fullNameMatch = (data.full_name || data.fullName || '')
          .toLowerCase().includes(search.toLowerCase());
        const emailMatch = (data.email || '')
          .toLowerCase().includes(search.toLowerCase());
        const empIdMatch = (data.employee_id || data.employeeId || '')
          .toLowerCase().includes(search.toLowerCase());
        
        if (fullNameMatch || emailMatch || empIdMatch) {
          console.log(`🔍 "${search}" would match this user:`, {
            fullName: fullNameMatch,
            email: emailMatch,
            empId: empIdMatch
          });
        }
      });
    });
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  }
}

checkUserFields();