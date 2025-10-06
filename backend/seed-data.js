require('dotenv').config();
const admin = require('firebase-admin');

if (!admin.apps.length) {
  const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

const db = admin.firestore();

async function seedData() {
  try {
    console.log('🌱 Seeding test data...');

    // Get test user ID
    const userSnapshot = await db.collection('users').where('email', '==', 'test@example.com').get();
    if (userSnapshot.empty) {
      console.log('❌ Test user not found!');
      return;
    }
    
    const testUser = userSnapshot.docs[0];
    const userId = testUser.id;
    console.log('✅ Found test user:', userId);

    // Create sample attendance records
    console.log('📊 Creating attendance records...');
    const today = new Date();
    
    for (let i = 0; i < 5; i++) {
      const date = new Date(today);
      date.setDate(today.getDate() - i);
      const dateStr = date.toISOString().split('T')[0];
      
      await db.collection('attendance').add({
        user_id: userId,
        date: dateStr,
        check_in_time: '09:00:00',
        check_out_time: '17:00:00',
        status: i < 3 ? 'present' : 'late',
        total_hours_worked: '8.0',
        overtime_hours: i === 0 ? '1.0' : '0.0',
        location: 'Office',
        notes: `Sample attendance for ${dateStr}`,
        created_at: admin.firestore.FieldValue.serverTimestamp(),
        updated_at: admin.firestore.FieldValue.serverTimestamp()
      });
    }
    console.log('✅ Created 5 attendance records');

    // Create sample leave requests
    console.log('📋 Creating leave requests...');
    for (let i = 0; i < 3; i++) {
      await db.collection('leave_requests').add({
        user_id: userId,
        leave_type: i === 0 ? 'annual' : 'sick',
        start_date: '2025-10-15',
        end_date: '2025-10-16',
        reason: `Sample leave request ${i + 1}`,
        status: i === 0 ? 'pending' : 'approved',
        created_at: admin.firestore.FieldValue.serverTimestamp(),
        updated_at: admin.firestore.FieldValue.serverTimestamp()
      });
    }
    console.log('✅ Created 3 leave requests');

    console.log('🎉 Data seeding completed!');

  } catch (error) {
    console.error('❌ Error seeding data:', error.message);
  }
}

seedData();