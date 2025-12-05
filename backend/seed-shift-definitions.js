const admin = require('firebase-admin');

// Initialize Firebase Admin
const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-da2d17d44d.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function seedShiftDefinitions() {
  try {
    console.log('\n========================================');
    console.log('🔄 SEEDING SHIFT DEFINITIONS');
    console.log('========================================\n');

    const shiftDefinitions = [
      {
        id: 'morning',
        name: 'Shift Pagi',
        start_time: '06:00',
        end_time: '14:00',
        color: '#FFA500',
        description: 'Shift pagi untuk Security dan Office Boy',
        applicable_roles: ['security', 'office_boy'],
        created_at: admin.firestore.FieldValue.serverTimestamp()
      },
      {
        id: 'evening',
        name: 'Shift Malam',
        start_time: '18:00',
        end_time: '02:00',
        color: '#4169E1',
        description: 'Shift malam untuk Security',
        applicable_roles: ['security'],
        created_at: admin.firestore.FieldValue.serverTimestamp()
      },
      {
        id: 'regular',
        name: 'Regular Office Hours',
        start_time: '08:00',
        end_time: '17:00',
        color: '#28A745',
        description: 'Jam kerja regular untuk employee dan account officer',
        applicable_roles: ['employee', 'account_officer'],
        created_at: admin.firestore.FieldValue.serverTimestamp()
      }
    ];

    for (const shift of shiftDefinitions) {
      const shiftRef = db.collection('shift_definitions').doc(shift.id);
      await shiftRef.set(shift);
      console.log(`✅ Created shift definition: ${shift.name} (${shift.start_time} - ${shift.end_time})`);
    }

    console.log('\n========================================');
    console.log('✅ SHIFT DEFINITIONS SEEDED SUCCESSFULLY');
    console.log('========================================\n');

    // Sample shift assignments for today and tomorrow
    console.log('========================================');
    console.log('📅 CREATING SAMPLE SHIFT ASSIGNMENTS');
    console.log('========================================\n');

    const today = new Date();
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    const formatDate = (date) => {
      const year = date.getFullYear();
      const month = String(date.getMonth() + 1).padLeft(2, '0');
      const day = String(date.getDate()).padLeft(2, '0');
      return `${year}-${month}-${day}`;
    };

    String.prototype.padLeft = function(length, char) {
      return char.repeat(Math.max(0, length - this.length)) + this;
    };

    const sampleAssignments = [
      // Today - SC001 morning, SC002 evening
      {
        date: formatDate(today),
        employee_id: 'SC001',
        employee_name: 'Security 1',
        role: 'security',
        shift_type: 'morning',
        shift_start_time: '06:00',
        shift_end_time: '14:00'
      },
      {
        date: formatDate(today),
        employee_id: 'SC002',
        employee_name: 'Security 2',
        role: 'security',
        shift_type: 'evening',
        shift_start_time: '18:00',
        shift_end_time: '02:00'
      },
      // Tomorrow - SC002 morning, SC001 evening (rotated)
      {
        date: formatDate(tomorrow),
        employee_id: 'SC002',
        employee_name: 'Security 2',
        role: 'security',
        shift_type: 'morning',
        shift_start_time: '06:00',
        shift_end_time: '14:00'
      },
      {
        date: formatDate(tomorrow),
        employee_id: 'SC001',
        employee_name: 'Security 1',
        role: 'security',
        shift_type: 'evening',
        shift_start_time: '18:00',
        shift_end_time: '02:00'
      }
    ];

    for (const assignment of sampleAssignments) {
      assignment.created_at = admin.firestore.FieldValue.serverTimestamp();
      assignment.updated_at = admin.firestore.FieldValue.serverTimestamp();
      assignment.created_by = 'SYSTEM';
      
      const docRef = await db.collection('shift_assignments').add(assignment);
      console.log(`✅ Created shift assignment: ${assignment.employee_name} - ${assignment.shift_type} shift on ${assignment.date}`);
    }

    console.log('\n========================================');
    console.log('✅ SAMPLE ASSIGNMENTS CREATED');
    console.log('========================================\n');

    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

seedShiftDefinitions();
