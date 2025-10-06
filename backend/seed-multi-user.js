const admin = require('firebase-admin');
const bcrypt = require('bcryptjs');
const path = require('path');

// Initialize Firebase Admin SDK
const serviceAccountPath = path.join(__dirname, 'bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');
const serviceAccount = require(serviceAccountPath);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://bpr-absens.firebaseio.com"
});

const db = admin.firestore();

// Function to hash password
async function hashPassword(password) {
  const saltRounds = 10;
  return await bcrypt.hash(password, saltRounds);
}

// Multi-user dummy data
const multiUserData = {
  users: [
    // Super Admin
    {
      id: 'SUP001',
      employee_id: 'SUP001',
      full_name: 'Super Administrator',
      email: 'superadmin@bpr.com',
      password: 'superadmin123', // Will be hashed
      role: 'super_admin',
      position: 'Super Administrator',
      department: 'Management',
      is_active: true,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    },
    
    // Admin
    {
      id: 'ADM001',
      employee_id: 'ADM001',
      full_name: 'Admin BPR',
      email: 'admin@bpr.com',
      password: 'admin123456', // Will be hashed
      role: 'admin',
      position: 'Administrator',
      department: 'Management',
      is_active: true,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    },
    
    // Employees
    {
      id: 'EMP001',
      employee_id: 'EMP001',
      full_name: 'Ahmad Wijaya',
      email: 'ahmad.wijaya@bpr.com',
      password: 'emp001',
      role: 'employee',
      position: 'Software Developer',
      department: 'IT Department',
      is_active: true,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    },
    {
      id: 'EMP002',
      employee_id: 'EMP002',
      full_name: 'Siti Rahayu',
      email: 'siti.rahayu@bpr.com',
      password: 'emp002',
      role: 'employee',
      position: 'Finance Staff',
      department: 'Finance',
      is_active: true,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    },
    {
      id: 'EMP003',
      employee_id: 'EMP003',
      full_name: 'Dewi Sartika',
      email: 'dewi.sartika@bpr.com',
      password: 'emp003',
      role: 'employee',
      position: 'HR Staff',
      department: 'HR',
      is_active: true,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    },
    
    // Account Officers
    {
      id: 'AC001',
      employee_id: 'AC001',
      full_name: 'Rizki Pratama',
      email: 'rizki.pratama@bpr.com',
      password: 'ac001',
      role: 'account_officer',
      position: 'Senior Account Officer',
      department: 'Credit',
      is_active: true,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    },
    {
      id: 'AC002',
      employee_id: 'AC002',
      full_name: 'Maya Indira',
      email: 'maya.indira@bpr.com',
      password: 'ac002',
      role: 'account_officer',
      position: 'Account Officer',
      department: 'Credit',
      is_active: true,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    },
    
    // Security
    {
      id: 'SCR001',
      employee_id: 'SCR001',
      full_name: 'Joko Susanto',
      email: 'joko.susanto@bpr.com',
      password: 'scr001',
      role: 'security',
      position: 'Security Supervisor',
      department: 'Security',
      is_active: true,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    },
    {
      id: 'SCR002',
      employee_id: 'SCR002',
      full_name: 'Budi Hartono',
      email: 'budi.hartono@bpr.com',
      password: 'scr002',
      role: 'security',
      position: 'Security Guard',
      department: 'Security',
      is_active: true,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    },
    
    // Office Boy Staff
    {
      id: 'OB001',
      employee_id: 'OB001',
      full_name: 'Agus Setiawan',
      email: 'agus.setiawan@bpr.com',
      password: 'password123',
      role: 'office_boy',
      position: 'Office Boy',
      department: 'General Affairs',
      is_active: true,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    },

    // Test accounts
    {
      id: 'SUP999',
      employee_id: 'SUP999',
      full_name: 'Super Admin Test',
      email: 'superadmin@gmail.com',
      password: 'superadmin123',
      role: 'super_admin',
      position: 'Test Super Admin',
      department: 'Test',
      is_active: true,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    },
    {
      id: 'SADM001',
      employee_id: 'SADM001',
      full_name: 'Super Admin',
      email: 'admin@gmail.com',
      password: 'admin123',
      role: 'super_admin',
      position: 'Super Administrator',
      department: 'Management',
      is_active: true,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    },
    {
      id: 'EMP999',
      employee_id: 'EMP999',
      full_name: 'User Test',
      email: 'user@gmail.com',
      password: 'user123',
      role: 'employee',
      position: 'Test User',
      department: 'Test',
      is_active: true,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    },
  ],

  attendance: [
    // EMP001 - Ahmad Wijaya
    {
      employee_id: 'EMP001',
      date: '2025-10-07',
      clock_in_time: '08:00',
      clock_out_time: '17:00',
      status: 'present',
      location: 'Office - Jakarta',
      notes: 'Normal working day',
      photo_url: null,
      created_at: '2025-10-07T08:00:00Z',
    },
    
    // EMP002 - Siti Rahayu
    {
      employee_id: 'EMP002',
      date: '2025-10-07',
      clock_in_time: '08:15',
      clock_out_time: '17:15',
      status: 'present',
      location: 'Office - Jakarta',
      notes: 'Sedikit terlambat karena macet',
      photo_url: null,
      created_at: '2025-10-07T08:15:00Z',
    },
    
    // EMP003 - Dewi Sartika (Sick leave)
    {
      employee_id: 'EMP003',
      date: '2025-10-07',
      clock_in_time: null,
      clock_out_time: null,
      status: 'sick_leave',
      location: null,
      notes: 'Sakit flu, istirahat di rumah',
      photo_url: null,
      created_at: '2025-10-07T07:00:00Z',
    },
    
    // AC001 - Rizki Pratama
    {
      employee_id: 'AC001',
      date: '2025-10-07',
      clock_in_time: '07:45',
      clock_out_time: '18:30',
      status: 'present',
      location: 'Client Visit - Surabaya',
      notes: 'Kunjungan klien di Surabaya',
      photo_url: null,
      created_at: '2025-10-07T07:45:00Z',
    },
    
    // SCR001 - Joko Susanto
    {
      employee_id: 'SCR001',
      date: '2025-10-07',
      clock_in_time: '22:00',
      clock_out_time: null,
      status: 'present',
      location: 'Office - Night Shift',
      notes: 'Shift malam keamanan',
      photo_url: null,
      created_at: '2025-10-07T22:00:00Z',
    },
  ],

  assignments: [
    // EMP001 assignments
    {
      employee_id: 'EMP001',
      title: 'Develop Mobile App Features',
      description: 'Mengembangkan fitur attendance tracking untuk aplikasi mobile',
      priority: 'high',
      status: 'in_progress',
      due_date: '2025-10-15',
      assigned_by: 'ADM001',
      created_at: '2025-10-01T10:00:00Z',
      updated_at: '2025-10-07T14:30:00Z',
    },
    
    // EMP002 assignments
    {
      employee_id: 'EMP002',
      title: 'Monthly Financial Report',
      description: 'Menyiapkan laporan keuangan bulanan untuk Oktober 2025',
      priority: 'high',
      status: 'pending',
      due_date: '2025-10-31',
      assigned_by: 'ADM001',
      created_at: '2025-10-01T09:00:00Z',
      updated_at: '2025-10-01T09:00:00Z',
    },
    
    // AC001 assignments
    {
      employee_id: 'AC001',
      title: 'Client Portfolio Review',
      description: 'Review portfolio klien untuk kuartal Q4 2025',
      priority: 'medium',
      status: 'completed',
      due_date: '2025-10-05',
      assigned_by: 'ADM001',
      created_at: '2025-09-25T08:00:00Z',
      updated_at: '2025-10-03T16:00:00Z',
    },
    
    // EMP003 assignments
    {
      employee_id: 'EMP003',
      title: 'Employee Performance Evaluation',
      description: 'Melakukan evaluasi performa karyawan untuk periode semester 2',
      priority: 'medium',
      status: 'in_progress',
      due_date: '2025-10-20',
      assigned_by: 'ADM001',
      created_at: '2025-10-01T11:00:00Z',
      updated_at: '2025-10-06T15:00:00Z',
    },
    
    // SCR001 assignments
    {
      employee_id: 'SCR001',
      title: 'Security System Maintenance',
      description: 'Pemeliharaan sistem keamanan dan CCTV bulanan',
      priority: 'high',
      status: 'pending',
      due_date: '2025-10-10',
      assigned_by: 'ADM001',
      created_at: '2025-10-01T07:00:00Z',
      updated_at: '2025-10-01T07:00:00Z',
    },
  ],

  letters: [
    // EMP001 letter
    {
      employee_id: 'EMP001',
      letterNumber: 'LTR/EMP001/001/2025',
      letterType: 'annual_leave',
      subject: 'Cuti Tahunan',
      content: 'Permohonan cuti tahunan untuk liburan keluarga ke Bali dari tanggal 15-17 Oktober 2025',
      status: 'pending',
      priority: 'medium',
      recipientName: 'Ahmad Wijaya',
      recipientEmail: 'ahmad.wijaya@bpr.com',
      recipientDepartment: 'IT Department',
      senderId: 'EMP001',
      senderName: 'Ahmad Wijaya',
      senderPosition: 'Software Developer',
      validUntil: '2025-10-31',
      createdAt: '2025-10-07T10:00:00Z',
      updatedAt: '2025-10-07T10:00:00Z',
    },
    
    // EMP002 letter
    {
      employee_id: 'EMP002',
      letterNumber: 'LTR/EMP002/001/2025',
      letterType: 'sick_leave',
      subject: 'Izin Sakit',
      content: 'Permohonan izin sakit karena demam dan flu, perlu istirahat di rumah',
      status: 'approved',
      priority: 'high',
      recipientName: 'Siti Rahayu',
      recipientEmail: 'siti.rahayu@bpr.com',
      recipientDepartment: 'Finance',
      senderId: 'EMP002',
      senderName: 'Siti Rahayu',
      senderPosition: 'Finance Staff',
      validUntil: '2025-10-15',
      createdAt: '2025-10-05T07:00:00Z',
      updatedAt: '2025-10-05T09:30:00Z',
    },
    
    // AC001 letter
    {
      employee_id: 'AC001',
      letterNumber: 'LTR/AC001/001/2025',
      letterType: 'business_trip',
      subject: 'Perjalanan Dinas',
      content: 'Permohonan perjalanan dinas ke Surabaya untuk kunjungan klien pada tanggal 7-8 Oktober 2025',
      status: 'approved',
      priority: 'high',
      recipientName: 'Rizki Pratama',
      recipientEmail: 'rizki.pratama@bpr.com',
      recipientDepartment: 'Credit',
      senderId: 'AC001',
      senderName: 'Rizki Pratama',
      senderPosition: 'Senior Account Officer',
      validUntil: '2025-10-20',
      createdAt: '2025-10-02T08:00:00Z',
      updatedAt: '2025-10-03T14:00:00Z',
    },
  ]
};

async function seedFirestore() {
  try {
    console.log('🌱 Starting multi-user Firestore seeding...');
    
    // Clear existing data
    console.log('🧹 Clearing existing data...');
    
    const collections = ['users', 'attendance', 'assignments', 'letters'];
    for (const collectionName of collections) {
      const snapshot = await db.collection(collectionName).get();
      const batch = db.batch();
      
      snapshot.docs.forEach(doc => {
        batch.delete(doc.ref);
      });
      
      if (snapshot.docs.length > 0) {
        await batch.commit();
        console.log(`   Cleared ${snapshot.docs.length} documents from ${collectionName}`);
      }
    }
    
    // Seed Users (with hashed passwords)
    console.log('👥 Seeding users...');
    for (const user of multiUserData.users) {
      const hashedPassword = await hashPassword(user.password);
      const userWithHashedPassword = { ...user, password: hashedPassword };
      await db.collection('users').doc(user.employee_id).set(userWithHashedPassword);
    }
    console.log(`   ✅ Added ${multiUserData.users.length} users`);
    
    // Seed Attendance
    console.log('📝 Seeding attendance records...');
    for (let i = 0; i < multiUserData.attendance.length; i++) {
      const attendance = multiUserData.attendance[i];
      await db.collection('attendance').add(attendance);
    }
    console.log(`   ✅ Added ${multiUserData.attendance.length} attendance records`);
    
    // Seed Assignments
    console.log('📋 Seeding assignments...');
    for (let i = 0; i < multiUserData.assignments.length; i++) {
      const assignment = multiUserData.assignments[i];
      await db.collection('assignments').add(assignment);
    }
    console.log(`   ✅ Added ${multiUserData.assignments.length} assignments`);
    
    // Seed Letters
    console.log('📄 Seeding letters...');
    for (let i = 0; i < multiUserData.letters.length; i++) {
      const letter = multiUserData.letters[i];
      await db.collection('letters').add(letter);
    }
    console.log(`   ✅ Added ${multiUserData.letters.length} letters`);
    
    console.log('\n🎉 Multi-user Firestore seeding completed successfully!');
    console.log('\n📊 Summary:');
    console.log(`   Users: ${multiUserData.users.length}`);
    console.log(`   Attendance Records: ${multiUserData.attendance.length}`);
    console.log(`   Assignments: ${multiUserData.assignments.length}`);
    console.log(`   Letters: ${multiUserData.letters.length}`);
    
    console.log('\n👤 Login Credentials:');
    console.log('   Admin: admin@bpr.com / admin123');
    console.log('   Employee: ahmad.wijaya@bpr.com / emp001');
    console.log('   Finance: siti.rahayu@bpr.com / emp002');
    console.log('   HR: dewi.sartika@bpr.com / emp003');
    console.log('   Account Officer: rizki.pratama@bpr.com / ac001');
    console.log('   Security: joko.susanto@bpr.com / scr001');
    
  } catch (error) {
    console.error('❌ Error seeding Firestore:', error);
  } finally {
    process.exit();
  }
}

// Run the seeding
seedFirestore();