const admin = require('firebase-admin');
const path = require('path');

// Initialize Firebase Admin SDK
const serviceAccountPath = path.join(__dirname, 'bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');
const serviceAccount = require(serviceAccountPath);

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: "https://bpr-absens.firebaseio.com"
  });
}

const db = admin.firestore();

// Test login credentials
async function testLogin() {
  try {
    console.log('🔑 Testing Login Credentials for Multi-User System...\n');
    
    const loginTests = [
      { email: 'admin@bpr.com', password: 'admin123', expected_role: 'admin', expected_id: 'ADM001' },
      { email: 'ahmad.wijaya@bpr.com', password: 'emp001', expected_role: 'employee', expected_id: 'EMP001' },
      { email: 'siti.rahayu@bpr.com', password: 'emp002', expected_role: 'employee', expected_id: 'EMP002' },
      { email: 'dewi.sartika@bpr.com', password: 'emp003', expected_role: 'employee', expected_id: 'EMP003' },
      { email: 'rizki.pratama@bpr.com', password: 'ac001', expected_role: 'account_officer', expected_id: 'AC001' },
      { email: 'maya.indira@bpr.com', password: 'ac002', expected_role: 'account_officer', expected_id: 'AC002' },
      { email: 'joko.susanto@bpr.com', password: 'scr001', expected_role: 'security', expected_id: 'SCR001' },
      { email: 'budi.hartono@bpr.com', password: 'scr002', expected_role: 'security', expected_id: 'SCR002' },
      { email: 'agus.setiawan@bpr.com', password: 'password123', expected_role: 'office_boy', expected_id: 'OB001' },
      { email: 'admin@gmail.com', password: 'admin123', expected_role: 'admin', expected_id: 'ADM999' },
      { email: 'user@gmail.com', password: 'user123', expected_role: 'employee', expected_id: 'EMP999' },
    ];
    
    for (const loginTest of loginTests) {
      console.log(`Testing login: ${loginTest.email}`);
      
      // Simulate login process
      const userQuery = await db.collection('users')
        .where('email', '==', loginTest.email)
        .where('password', '==', loginTest.password)
        .get();
      
      if (!userQuery.empty) {
        const userDoc = userQuery.docs[0];
        const userData = userDoc.data();
        
        if (userData.employee_id === loginTest.expected_id && userData.role === loginTest.expected_role) {
          console.log(`✅ Login SUCCESS: ${userData.name} (${userData.employee_id}) - ${userData.role}`);
          console.log(`   Position: ${userData.position}, Department: ${userData.department}`);
          
          // Test employee_id based data access
          const attendanceCount = await db.collection('attendance')
            .where('employee_id', '==', userData.employee_id)
            .get();
          
          const assignmentCount = await db.collection('assignments')
            .where('employee_id', '==', userData.employee_id)
            .get();
          
          const letterCount = await db.collection('letters')
            .where('employee_id', '==', userData.employee_id)
            .get();
            
          console.log(`   Data Access: ${attendanceCount.size} attendance, ${assignmentCount.size} assignments, ${letterCount.size} letters`);
          
        } else {
          console.log(`❌ ROLE MISMATCH: Expected ${loginTest.expected_role}/${loginTest.expected_id}, got ${userData.role}/${userData.employee_id}`);
        }
      } else {
        console.log(`❌ Login FAILED: Invalid credentials for ${loginTest.email}`);
      }
      
      console.log(''); // Empty line for readability
    }
    
    console.log('\n🔒 Testing Invalid Credentials...');
    console.log('=' .repeat(40));
    
    const invalidTests = [
      { email: 'admin@bpr.com', password: 'wrongpassword' },
      { email: 'nonexistent@bpr.com', password: 'anypassword' },
      { email: 'ahmad.wijaya@bpr.com', password: 'wrongpass' }
    ];
    
    for (const invalidTest of invalidTests) {
      const userQuery = await db.collection('users')
        .where('email', '==', invalidTest.email)
        .where('password', '==', invalidTest.password)
        .get();
      
      if (userQuery.empty) {
        console.log(`✅ Security Check PASSED: ${invalidTest.email} correctly rejected`);
      } else {
        console.log(`❌ Security BREACH: ${invalidTest.email} should have been rejected`);
      }
    }
    
    console.log('\n📊 System Summary:');
    console.log('=' .repeat(30));
    
    const allUsers = await db.collection('users').get();
    const roleDistribution = {};
    
    allUsers.forEach(doc => {
      const user = doc.data();
      roleDistribution[user.role] = (roleDistribution[user.role] || 0) + 1;
    });
    
    console.log('User Distribution by Role:');
    Object.entries(roleDistribution).forEach(([role, count]) => {
      console.log(`   ${role}: ${count} users`);
    });
    
    console.log(`\nTotal Active Users: ${allUsers.size}`);
    
    // Employee ID Pattern Analysis
    console.log('\nEmployee ID Patterns:');
    const patterns = {};
    allUsers.forEach(doc => {
      const user = doc.data();
      const prefix = user.employee_id.match(/^[A-Z]+/)?.[0] || 'OTHER';
      patterns[prefix] = (patterns[prefix] || 0) + 1;
    });
    
    Object.entries(patterns).forEach(([prefix, count]) => {
      console.log(`   ${prefix}*: ${count} employees`);
    });
    
    console.log('\n🎉 Login testing completed successfully!');
    
  } catch (error) {
    console.error('❌ Error testing login:', error);
  } finally {
    process.exit();
  }
}

// Run the login test
testLogin();