const admin = require('firebase-admin');
const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-da2d17d44d.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function checkUsers() {
  try {
    console.log('\n========================================');
    console.log('👥 CHECKING ALL USERS');
    console.log('========================================\n');

    const snapshot = await db.collection('users').get();
    
    console.log(`📊 Total users found: ${snapshot.size}\n`);

    const users = [];
    snapshot.forEach(doc => {
      const data = doc.data();
      users.push({
        id: doc.id,
        employee_id: data.employee_id,
        full_name: data.full_name,
        email: data.email,
        role: data.role,
        work_start_time: data.work_start_time,
        work_end_time: data.work_end_time,
        late_threshold_minutes: data.late_threshold_minutes
      });
    });

    users.forEach((user, index) => {
      console.log(`\n👤 User #${index + 1}:`);
      console.log(`   ID: ${user.id}`);
      console.log(`   Employee ID: ${user.employee_id}`);
      console.log(`   Name: ${user.full_name}`);
      console.log(`   Email: ${user.email}`);
      console.log(`   Role: ${user.role || 'employee'}`);
      console.log(`   Work Start: ${user.work_start_time || 'Not set'}`);
      console.log(`   Work End: ${user.work_end_time || 'Not set'}`);
      console.log(`   Late Threshold: ${user.late_threshold_minutes || 'Not set'} min`);
    });

    // Filter employees only (not admin)
    const employees = users.filter(u => u.role !== 'admin' && u.role !== 'super_admin');
    
    console.log('\n========================================');
    console.log(`📋 EMPLOYEE USERS (role != admin): ${employees.length}`);
    console.log('========================================\n');
    
    employees.forEach((user, index) => {
      console.log(`${index + 1}. ${user.full_name} (${user.employee_id}) - ${user.email}`);
    });

    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

checkUsers();
