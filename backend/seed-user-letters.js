require('dotenv').config();
const admin = require('firebase-admin');

if (!admin.apps.length) {
  const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

const db = admin.firestore();

async function seedUserSpecificLetters() {
  console.log('🌱 Seeding user-specific letters...');

  try {
    // Get some existing users first
    const usersSnapshot = await db.collection('users').limit(3).get();
    
    if (usersSnapshot.empty) {
      console.log('❌ No users found. Please seed users first.');
      return;
    }

    const users = [];
    usersSnapshot.forEach(doc => {
      users.push({ id: doc.id, ...doc.data() });
    });

    console.log(`📋 Found ${users.length} users to create letters for`);

    // Create letters for each user
    for (const user of users) {
      console.log(`\n🔄 Creating letters for ${user.full_name} (${user.id})`);
      
      const userLetters = [
        {
          letter_number: `LTR-${Date.now()}-${Math.random().toString(36).substring(7)}`,
          letter_type: 'sick_leave',
          subject: `Sick Leave Request - ${user.full_name}`,
          content: `I am requesting sick leave due to illness. I will provide medical certificate as soon as possible.`,
          recipient_id: user.id,
          recipient_name: user.full_name,
          recipient_employee_id: user.employee_id || 'EMP001',
          recipient_department: user.department || 'General',
          sender_id: user.id,
          sender_name: user.full_name,
          sender_position: user.position || 'Employee',
          status: 'waiting_approval',
          priority: 'medium',
          created_at: admin.firestore.FieldValue.serverTimestamp(),
          updated_at: admin.firestore.FieldValue.serverTimestamp(),
          expires_at: admin.firestore.Timestamp.fromDate(new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)), // 7 days from now
          approval_history: [{
            action: 'created',
            timestamp: admin.firestore.Timestamp.now(),
            user_id: user.id,
            user_name: user.full_name,
            notes: 'Letter submitted for approval'
          }]
        },
        {
          letter_number: `LTR-${Date.now()}-${Math.random().toString(36).substring(7)}`,
          letter_type: 'annual_leave',
          subject: `Annual Leave Request - ${user.full_name}`,
          content: `I would like to request annual leave for vacation. The dates are planned for next month.`,
          recipient_id: user.id,
          recipient_name: user.full_name,
          recipient_employee_id: user.employee_id || 'EMP001',
          recipient_department: user.department || 'General',
          sender_id: user.id,
          sender_name: user.full_name,
          sender_position: user.position || 'Employee',
          status: 'approved',
          priority: 'low',
          created_at: admin.firestore.FieldValue.serverTimestamp(),
          updated_at: admin.firestore.FieldValue.serverTimestamp(),
          expires_at: admin.firestore.Timestamp.fromDate(new Date(Date.now() + 30 * 24 * 60 * 60 * 1000)), // 30 days from now
          approval_history: [
            {
              action: 'created',
              timestamp: admin.firestore.Timestamp.now(),
              user_id: user.id,
              user_name: user.full_name,
              notes: 'Letter submitted for approval'
            },
            {
              action: 'approved',
              timestamp: admin.firestore.Timestamp.now(),
              user_id: 'admin',
              user_name: 'Admin User',
              notes: 'Leave approved - enjoy your vacation!'
            }
          ]
        },
        {
          letter_number: `LTR-${Date.now()}-${Math.random().toString(36).substring(7)}`,
          letter_type: 'permission_letter',
          subject: `Permission Letter - ${user.full_name}`,
          content: `I need permission to leave early today for a medical appointment.`,
          recipient_id: user.id,
          recipient_name: user.full_name,
          recipient_employee_id: user.employee_id || 'EMP001',
          recipient_department: user.department || 'General',
          sender_id: user.id,
          sender_name: user.full_name,
          sender_position: user.position || 'Employee',
          status: 'rejected',
          priority: 'high',
          created_at: admin.firestore.FieldValue.serverTimestamp(),
          updated_at: admin.firestore.FieldValue.serverTimestamp(),
          expires_at: admin.firestore.Timestamp.fromDate(new Date(Date.now() + 1 * 24 * 60 * 60 * 1000)), // 1 day from now
          approval_history: [
            {
              action: 'created',
              timestamp: admin.firestore.Timestamp.now(),
              user_id: user.id,
              user_name: user.full_name,
              notes: 'Letter submitted for approval'
            },
            {
              action: 'rejected',
              timestamp: admin.firestore.Timestamp.now(),
              user_id: 'admin',
              user_name: 'Admin User',
              notes: 'Insufficient notice provided. Please submit requests 24 hours in advance.'
            }
          ]
        }
      ];

      // Add letters to Firestore
      for (const letter of userLetters) {
        const docRef = await db.collection('letters').add(letter);
        console.log(`✅ Created letter: ${letter.subject} (${docRef.id})`);
      }
    }

    console.log('\n🎉 Successfully seeded user-specific letters!');
    console.log('📊 Each user now has:');
    console.log('  - 1 Waiting Approval letter (Sick Leave)');
    console.log('  - 1 Approved letter (Annual Leave)');
    console.log('  - 1 Rejected letter (Permission Letter)');

  } catch (error) {
    console.error('❌ Error seeding user-specific letters:', error);
  }
}

seedUserSpecificLetters();