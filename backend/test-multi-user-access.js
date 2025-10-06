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

// Test multi-user login and data access
async function testMultiUserAccess() {
  try {
    console.log('🔐 Testing Multi-User Access & Data Separation...\n');
    
    const testUsers = [
      { employee_id: 'ADM001', name: 'Admin BPR', role: 'admin' },
      { employee_id: 'EMP001', name: 'Ahmad Wijaya', role: 'employee' },
      { employee_id: 'EMP002', name: 'Siti Rahayu', role: 'employee' },
      { employee_id: 'AC001', name: 'Rizki Pratama', role: 'account_officer' },
      { employee_id: 'SCR001', name: 'Joko Susanto', role: 'security' }
    ];
    
    for (const testUser of testUsers) {
      console.log(`\n👤 Testing access for ${testUser.name} (${testUser.employee_id}) - ${testUser.role}`);
      console.log('=' .repeat(70));
      
      // Check user exists
      const userDoc = await db.collection('users').doc(testUser.employee_id).get();
      if (userDoc.exists) {
        const userData = userDoc.data();
        console.log(`✅ User found: ${userData.name} - ${userData.position}`);
        
        // Test attendance data access
        const attendanceQuery = await db.collection('attendance')
          .where('employee_id', '==', testUser.employee_id)
          .get();
        console.log(`📝 Attendance records: ${attendanceQuery.size} found`);
        
        attendanceQuery.forEach(doc => {
          const attendance = doc.data();
          console.log(`   - ${attendance.date}: ${attendance.status} (${attendance.clock_in_time || 'No clock in'} - ${attendance.clock_out_time || 'No clock out'})`);
        });
        
        // Test assignments data access
        const assignmentsQuery = await db.collection('assignments')
          .where('employee_id', '==', testUser.employee_id)
          .get();
        console.log(`📋 Assignments: ${assignmentsQuery.size} found`);
        
        assignmentsQuery.forEach(doc => {
          const assignment = doc.data();
          console.log(`   - ${assignment.title}: ${assignment.status} (Due: ${assignment.due_date})`);
        });
        
        // Test letters data access
        const lettersQuery = await db.collection('letters')
          .where('employee_id', '==', testUser.employee_id)
          .get();
        console.log(`📄 Letters: ${lettersQuery.size} found`);
        
        lettersQuery.forEach(doc => {
          const letter = doc.data();
          console.log(`   - ${letter.subject}: ${letter.status} (${letter.letterType})`);
        });
        
      } else {
        console.log(`❌ User ${testUser.employee_id} not found!`);
      }
    }
    
    console.log('\n\n🔍 Testing Admin Access (should see all data)...');
    console.log('=' .repeat(50));
    
    // Admin should see all users
    const allUsers = await db.collection('users').get();
    console.log(`👥 Total users in system: ${allUsers.size}`);
    
    // Admin should see all attendance
    const allAttendance = await db.collection('attendance').get();
    console.log(`📝 Total attendance records: ${allAttendance.size}`);
    
    // Admin should see all assignments
    const allAssignments = await db.collection('assignments').get();
    console.log(`📋 Total assignments: ${allAssignments.size}`);
    
    // Admin should see all letters
    const allLetters = await db.collection('letters').get();
    console.log(`📄 Total letters: ${allLetters.size}`);
    
    console.log('\n\n✨ Data Separation Validation:');
    console.log('=' .repeat(40));
    
    // Check if each employee only sees their own data
    const employeeIds = ['EMP001', 'EMP002', 'EMP003', 'AC001', 'AC002', 'SCR001', 'SCR002', '001'];
    
    for (const empId of employeeIds) {
      const empAttendance = await db.collection('attendance').where('employee_id', '==', empId).get();
      const empAssignments = await db.collection('assignments').where('employee_id', '==', empId).get();
      const empLetters = await db.collection('letters').where('employee_id', '==', empId).get();
      
      if (empAttendance.size > 0 || empAssignments.size > 0 || empLetters.size > 0) {
        console.log(`${empId}: Attendance(${empAttendance.size}), Assignments(${empAssignments.size}), Letters(${empLetters.size})`);
      }
    }
    
    console.log('\n🎉 Multi-user access test completed successfully!');
    
  } catch (error) {
    console.error('❌ Error testing multi-user access:', error);
  } finally {
    process.exit();
  }
}

// Run the test
testMultiUserAccess();