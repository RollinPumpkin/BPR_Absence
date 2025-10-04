const { initializeFirebase, getFirestore, getServerTimestamp, getAuth } = require('../config/database');
const bcrypt = require('bcryptjs');

// Initialize Firebase
initializeFirebase();
const db = getFirestore();
const auth = getAuth();

const createFirebaseUser = async (email, password, displayName) => {
  try {
    const userRecord = await auth.createUser({
      email: email,
      password: password,
      displayName: displayName,
      disabled: false
    });
    console.log(`✅ Firebase Auth user created: ${email}`);
    return userRecord.uid;
  } catch (error) {
    console.log(`⚠️ Firebase Auth user might already exist: ${email}`);
    return null;
  }
};

const seedData = async () => {
  try {
    console.log('🌱 Starting database seeding...');

    // Create admin user
    console.log('👤 Creating admin user...');
    const adminPassword = await bcrypt.hash('admin123456', 12);
    
    // Create in Firebase Auth first
    const adminUid = await createFirebaseUser('admin@bpr.com', 'admin123456', 'Administrator BPR');
    
    const adminData = {
      employee_id: 'ADMIN001',
      full_name: 'Administrator BPR',
      email: 'admin@bpr.com',
      password: adminPassword,
      role: 'admin',
      department: 'Management',
      position: 'System Administrator',
      phone: '081234567890',
      profile_image: '',
      is_active: true,
      firebase_uid: adminUid,
      created_at: getServerTimestamp(),
      updated_at: getServerTimestamp()
    };

    await db.collection('users').add(adminData);
    console.log('✅ Admin user created in Firestore');

    // Create sample employees
    console.log('👥 Creating sample employees...');
    const employees = [
      {
        employee_id: 'BPR001',
        full_name: 'Siti Nurhaliza',
        email: 'siti@bpr.com',
        department: 'Customer Service',
        position: 'CS Staff',
        phone: '081234567891'
      },
      {
        employee_id: 'BPR002',
        full_name: 'Ahmad Suryono',
        email: 'ahmad@bpr.com',
        department: 'Kredit',
        position: 'Account Officer',
        phone: '081234567892'
      },
      {
        employee_id: 'BPR003',
        full_name: 'Dewi Kartika',
        email: 'dewi@bpr.com',
        department: 'Operasional',
        position: 'Teller',
        phone: '081234567893'
      },
      {
        employee_id: 'BPR004',
        full_name: 'Budi Santoso',
        email: 'budi@bpr.com',
        department: 'Keuangan',
        position: 'Finance Staff',
        phone: '081234567894'
      }
    ];

    for (const employee of employees) {
      const employeePassword = await bcrypt.hash('password123', 12);
      
      // Create in Firebase Auth first
      const employeeUid = await createFirebaseUser(employee.email, 'password123', employee.full_name);
      
      const employeeData = {
        ...employee,
        password: employeePassword,
        role: 'employee',
        profile_image: '',
        is_active: true,
        firebase_uid: employeeUid,
        created_at: getServerTimestamp(),
        updated_at: getServerTimestamp()
      };
      
      await db.collection('users').add(employeeData);
    }
    console.log('✅ Sample employees created in Firestore');

    // Create QR codes for locations
    console.log('📱 Creating QR codes...');
    const qrCodes = [
      {
        code: 'BPR_MainOffice_' + Date.now(),
        location: 'Kantor Pusat BPR Adiartha Reksacipta',
        is_active: true,
        created_at: getServerTimestamp(),
        updated_at: getServerTimestamp()
      },
      {
        code: 'BPR_Branch1_' + (Date.now() + 1000),
        location: 'Cabang Denpasar',
        is_active: true,
        created_at: getServerTimestamp(),
        updated_at: getServerTimestamp()
      },
      {
        code: 'BPR_Branch2_' + (Date.now() + 2000),
        location: 'Cabang Ubud',
        is_active: true,
        created_at: getServerTimestamp(),
        updated_at: getServerTimestamp()
      }
    ];

    for (const qrCode of qrCodes) {
      await db.collection('qr_codes').add(qrCode);
    }
    console.log('✅ QR codes created');

    // Create sample attendance records
    console.log('📅 Creating sample attendance records...');
    const users = await db.collection('users').where('role', '==', 'employee').get();
    const userIds = users.docs.map(doc => doc.id);

    // Create attendance for last 7 days
    for (let i = 6; i >= 0; i--) {
      const date = new Date();
      date.setDate(date.getDate() - i);
      const dateString = date.toISOString().split('T')[0];

      for (const userId of userIds) {
        // Random attendance pattern (90% present, 10% other)
        const random = Math.random();
        let status = 'present';
        let checkInTime = '08:00:00';
        let checkOutTime = '17:00:00';

        if (random < 0.05) {
          status = 'late';
          checkInTime = '08:30:00';
        } else if (random < 0.08) {
          status = 'sick';
          checkInTime = null;
          checkOutTime = null;
        } else if (random < 0.1) {
          status = 'absent';
          checkInTime = null;
          checkOutTime = null;
        }

        if (checkInTime) {
          const attendanceData = {
            user_id: userId,
            date: dateString,
            check_in_time: checkInTime,
            check_out_time: checkOutTime,
            check_in_location: 'Kantor Pusat BPR Adiartha Reksacipta',
            check_out_location: checkOutTime ? 'Kantor Pusat BPR Adiartha Reksacipta' : null,
            status: status,
            notes: status === 'late' ? 'Terlambat karena macet' : '',
            qr_code_used: qrCodes[0].code,
            created_at: getServerTimestamp(),
            updated_at: getServerTimestamp()
          };

          await db.collection('attendance').add(attendanceData);
        }
      }
    }
    console.log('✅ Sample attendance records created');

    // Create sample leave requests
    console.log('🏖️ Creating sample leave requests...');
    const leaveRequests = [
      {
        user_id: userIds[0],
        leave_type: 'annual',
        start_date: '2025-09-01',
        end_date: '2025-09-03',
        reason: 'Liburan keluarga',
        status: 'pending'
      },
      {
        user_id: userIds[1],
        leave_type: 'sick',
        start_date: '2025-08-25',
        end_date: '2025-08-25',
        reason: 'Demam tinggi',
        status: 'approved'
      }
    ];

    for (const leaveRequest of leaveRequests) {
      const leaveData = {
        ...leaveRequest,
        created_at: getServerTimestamp(),
        updated_at: getServerTimestamp()
      };
      
      if (leaveRequest.status === 'approved') {
        leaveData.approved_at = getServerTimestamp();
        // Assume approved by admin (first user in the system)
        const adminUsers = await db.collection('users').where('role', '==', 'admin').limit(1).get();
        if (!adminUsers.empty) {
          leaveData.approved_by = adminUsers.docs[0].id;
        }
      }

      await db.collection('leave_requests').add(leaveData);
    }
    console.log('✅ Sample leave requests created');

    console.log('🎉 Database seeding completed successfully!');
    console.log('');
    console.log('🔑 Login credentials:');
    console.log('Admin: admin@bpr.com / admin123456');
    console.log('Employee: siti@bpr.com / password123');
    console.log('Employee: ahmad@bpr.com / password123');
    console.log('Employee: dewi@bpr.com / password123');
    console.log('Employee: budi@bpr.com / password123');
    console.log('');
    console.log('📱 QR Codes generated for check-in/check-out');
    console.log('📊 Sample attendance data for last 7 days');
    console.log('📋 Sample leave requests created');

  } catch (error) {
    console.error('❌ Seeding failed:', error);
  } finally {
    process.exit(0);
  }
};

// Run seeding
seedData();
