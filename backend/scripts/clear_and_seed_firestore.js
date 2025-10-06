const admin = require('firebase-admin');
const path = require('path');

// Initialize Firebase Admin
const serviceAccount = require('../bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://bpr-absens-default-rtdb.firebaseio.com"
});

const db = admin.firestore();

// Function to delete all documents in a collection
async function deleteCollection(collectionPath) {
  const collectionRef = db.collection(collectionPath);
  const snapshot = await collectionRef.get();
  
  console.log(`Deleting ${snapshot.size} documents from ${collectionPath}...`);
  
  const batch = db.batch();
  snapshot.docs.forEach((doc) => {
    batch.delete(doc.ref);
  });
  
  await batch.commit();
  console.log(`✅ Deleted all documents from ${collectionPath}`);
}

// Function to add multiple documents to a collection
async function addDocuments(collectionPath, documents) {
  console.log(`Adding ${documents.length} documents to ${collectionPath}...`);
  
  for (const doc of documents) {
    const docId = doc.id;
    delete doc.id; // Remove id from document data
    await db.collection(collectionPath).doc(docId).set(doc);
  }
  
  console.log(`✅ Added ${documents.length} documents to ${collectionPath}`);
}

// Users data
const users = [
  {
    id: 'FBRpLyTyvIpGqGYdNURK',
    employee_id: 'EMP001',
    full_name: 'Ahmad Wijaya',
    email: 'ahmad.wijaya@bpr.com',
    phone: '+62812345678',
    department: 'IT Department',
    position: 'Software Developer',
    role: 'user',
    profile_picture: null,
    address: 'Jl. Sudirman No. 123, Jakarta',
    date_of_birth: '1990-05-15',
    join_date: '2023-01-15',
    status: 'active',
    created_at: admin.firestore.Timestamp.fromDate(new Date('2023-01-15T00:00:00Z')),
    updated_at: admin.firestore.Timestamp.fromDate(new Date('2025-10-05T10:30:00Z')),
  },
  {
    id: 'admin_001',
    employee_id: 'ADM001',
    full_name: 'Dr. Sarah Manager',
    email: 'sarah.manager@bpr.com',
    phone: '+62811234567',
    department: 'Management',
    position: 'General Manager',
    role: 'admin',
    profile_picture: null,
    address: 'Jl. Thamrin No. 456, Jakarta',
    date_of_birth: '1985-03-20',
    join_date: '2020-06-01',
    status: 'active',
    created_at: admin.firestore.Timestamp.fromDate(new Date('2020-06-01T00:00:00Z')),
    updated_at: admin.firestore.Timestamp.fromDate(new Date('2025-10-05T10:30:00Z')),
  },
  {
    id: 'user_002',
    employee_id: 'EMP002',
    full_name: 'Siti Rahayu',
    email: 'siti.rahayu@bpr.com',
    phone: '+62813456789',
    department: 'Finance',
    position: 'Financial Analyst',
    role: 'user',
    profile_picture: null,
    address: 'Jl. Gatot Subroto No. 789, Jakarta',
    date_of_birth: '1992-08-10',
    join_date: '2023-03-01',
    status: 'active',
    created_at: admin.firestore.Timestamp.fromDate(new Date('2023-03-01T00:00:00Z')),
    updated_at: admin.firestore.Timestamp.fromDate(new Date('2025-10-05T10:30:00Z')),
  },
  {
    id: 'user_003',
    employee_id: 'EMP003',
    full_name: 'Budi Santoso',
    email: 'budi.santoso@bpr.com',
    phone: '+62814567890',
    department: 'Operations',
    position: 'Operations Manager',
    role: 'user',
    profile_picture: null,
    address: 'Jl. HR Rasuna Said No. 101, Jakarta',
    date_of_birth: '1988-12-25',
    join_date: '2022-11-15',
    status: 'active',
    created_at: admin.firestore.Timestamp.fromDate(new Date('2022-11-15T00:00:00Z')),
    updated_at: admin.firestore.Timestamp.fromDate(new Date('2025-10-05T10:30:00Z')),
  }
];

// Attendance data
const attendance = [
  // October 2025 data for Ahmad Wijaya (FBRpLyTyvIpGqGYdNURK)
  {
    id: '00L0w8P15DbF0cIdfJ7N',
    user_id: 'FBRpLyTyvIpGqGYdNURK',
    date: '2025-10-02',
    check_in_time: '08:00:00',
    check_out_time: '17:00:00',
    status: 'present',
    check_in_location: {
      latitude: -6.2088,
      longitude: 106.8456,
      address: 'Kantor Pusat BPR Adiarta Reksacipta'
    },
    check_out_location: {
      latitude: -6.2088,
      longitude: 106.8456,
      address: 'Kantor Pusat BPR Adiarta Reksacipta'
    },
    total_hours_worked: 8.0,
    overtime_hours: 0.0,
    notes: '',
    qr_code_used: 'BPR_MainOffice_1759584606',
    photo_check_in: null,
    photo_check_out: null,
    approved_by: null,
    created_at: admin.firestore.Timestamp.fromDate(new Date('2025-10-02T08:00:00Z')),
    updated_at: admin.firestore.Timestamp.fromDate(new Date('2025-10-02T17:00:00Z')),
  },
  {
    id: 'att_20251001_001',
    user_id: 'FBRpLyTyvIpGqGYdNURK',
    date: '2025-10-01',
    check_in_time: '08:00:00',
    check_out_time: '17:30:00',
    status: 'present',
    check_in_location: {
      latitude: -6.2088,
      longitude: 106.8456,
      address: 'Kantor Pusat BPR Adiarta Reksacipta'
    },
    check_out_location: {
      latitude: -6.2088,
      longitude: 106.8456,
      address: 'Kantor Pusat BPR Adiarta Reksacipta'
    },
    total_hours_worked: 8.5,
    overtime_hours: 0.5,
    notes: 'Completed daily tasks',
    qr_code_used: 'BPR_MainOffice_1759584606',
    photo_check_in: null,
    photo_check_out: null,
    approved_by: null,
    created_at: admin.firestore.Timestamp.fromDate(new Date('2025-10-01T08:00:00Z')),
    updated_at: admin.firestore.Timestamp.fromDate(new Date('2025-10-01T17:30:00Z')),
  },
  {
    id: 'att_20251003_001',
    user_id: 'FBRpLyTyvIpGqGYdNURK',
    date: '2025-10-03',
    check_in_time: '08:10:00',
    check_out_time: '17:00:00',
    status: 'late',
    check_in_location: {
      latitude: -6.2088,
      longitude: 106.8456,
      address: 'Kantor Pusat BPR Adiarta Reksacipta'
    },
    check_out_location: {
      latitude: -6.2088,
      longitude: 106.8456,
      address: 'Kantor Pusat BPR Adiarta Reksacipta'
    },
    total_hours_worked: 7.83,
    overtime_hours: 0.0,
    notes: 'Late due to traffic',
    qr_code_used: 'BPR_MainOffice_1759584606',
    photo_check_in: null,
    photo_check_out: null,
    approved_by: null,
    created_at: admin.firestore.Timestamp.fromDate(new Date('2025-10-03T08:10:00Z')),
    updated_at: admin.firestore.Timestamp.fromDate(new Date('2025-10-03T17:00:00Z')),
  },
  {
    id: 'att_20251004_001',
    user_id: 'FBRpLyTyvIpGqGYdNURK',
    date: '2025-10-04',
    check_in_time: '07:55:00',
    check_out_time: '18:00:00',
    status: 'present',
    check_in_location: {
      latitude: -6.2088,
      longitude: 106.8456,
      address: 'Kantor Pusat BPR Adiarta Reksacipta'
    },
    check_out_location: {
      latitude: -6.2088,
      longitude: 106.8456,
      address: 'Kantor Pusat BPR Adiarta Reksacipta'
    },
    total_hours_worked: 9.08,
    overtime_hours: 1.08,
    notes: 'Working on urgent project',
    qr_code_used: 'BPR_MainOffice_1759584606',
    photo_check_in: null,
    photo_check_out: null,
    approved_by: null,
    created_at: admin.firestore.Timestamp.fromDate(new Date('2025-10-04T07:55:00Z')),
    updated_at: admin.firestore.Timestamp.fromDate(new Date('2025-10-04T18:00:00Z')),
  },
  {
    id: 'att_20251005_001',
    user_id: 'FBRpLyTyvIpGqGYdNURK',
    date: '2025-10-05',
    check_in_time: '08:15:30',
    check_out_time: null,
    status: 'present',
    check_in_location: {
      latitude: -6.2088,
      longitude: 106.8456,
      address: 'Kantor Pusat BPR Adiarta Reksacipta'
    },
    check_out_location: null,
    total_hours_worked: null,
    overtime_hours: 0.0,
    notes: 'Normal check in',
    qr_code_used: 'BPR_MainOffice_1759584606',
    photo_check_in: null,
    photo_check_out: null,
    approved_by: null,
    created_at: admin.firestore.Timestamp.fromDate(new Date('2025-10-05T08:15:30Z')),
    updated_at: admin.firestore.Timestamp.fromDate(new Date('2025-10-05T08:15:30Z')),
  },
  // Data for other users
  {
    id: 'att_20251005_002',
    user_id: 'user_002',
    date: '2025-10-05',
    check_in_time: '08:05:00',
    check_out_time: '17:10:00',
    status: 'present',
    check_in_location: {
      latitude: -6.2088,
      longitude: 106.8456,
      address: 'Kantor Pusat BPR Adiarta Reksacipta'
    },
    check_out_location: {
      latitude: -6.2088,
      longitude: 106.8456,
      address: 'Kantor Pusat BPR Adiarta Reksacipta'
    },
    total_hours_worked: 8.08,
    overtime_hours: 0.08,
    notes: 'Regular work day',
    qr_code_used: 'BPR_MainOffice_1759584606',
    photo_check_in: null,
    photo_check_out: null,
    approved_by: null,
    created_at: admin.firestore.Timestamp.fromDate(new Date('2025-10-05T08:05:00Z')),
    updated_at: admin.firestore.Timestamp.fromDate(new Date('2025-10-05T17:10:00Z')),
  },
  {
    id: 'att_20251005_003',
    user_id: 'user_003',
    date: '2025-10-05',
    check_in_time: '08:20:00',
    check_out_time: null,
    status: 'late',
    check_in_location: {
      latitude: -6.2088,
      longitude: 106.8456,
      address: 'Kantor Pusat BPR Adiarta Reksacipta'
    },
    check_out_location: null,
    total_hours_worked: null,
    overtime_hours: 0.0,
    notes: 'Late arrival',
    qr_code_used: 'BPR_MainOffice_1759584606',
    photo_check_in: null,
    photo_check_out: null,
    approved_by: null,
    created_at: admin.firestore.Timestamp.fromDate(new Date('2025-10-05T08:20:00Z')),
    updated_at: admin.firestore.Timestamp.fromDate(new Date('2025-10-05T08:20:00Z')),
  }
];

// Assignments data
const assignments = [
  {
    id: 'assign_001',
    user_id: 'FBRpLyTyvIpGqGYdNURK',
    title: 'Update Employee Management System',
    description: 'Implement new features for employee data management including real-time attendance tracking and reporting dashboard.',
    status: 'in_progress',
    priority: 'high',
    due_date: '2025-10-10',
    assigned_by: 'admin_001',
    progress: 65,
    created_at: admin.firestore.Timestamp.fromDate(new Date('2025-10-01T09:00:00Z')),
    updated_at: admin.firestore.Timestamp.fromDate(new Date('2025-10-05T14:30:00Z')),
  },
  {
    id: 'assign_002',
    user_id: 'FBRpLyTyvIpGqGYdNURK',
    title: 'Database Optimization',
    description: 'Optimize database queries for better performance and implement proper indexing strategies.',
    status: 'assigned',
    priority: 'medium',
    due_date: '2025-10-15',
    assigned_by: 'admin_001',
    progress: 0,
    created_at: admin.firestore.Timestamp.fromDate(new Date('2025-10-02T10:00:00Z')),
    updated_at: admin.firestore.Timestamp.fromDate(new Date('2025-10-02T10:00:00Z')),
  },
  {
    id: 'assign_003',
    user_id: 'FBRpLyTyvIpGqGYdNURK',
    title: 'Security Audit Report',
    description: 'Conduct comprehensive security audit and prepare detailed report with recommendations.',
    status: 'completed',
    priority: 'high',
    due_date: '2025-09-30',
    assigned_by: 'admin_001',
    progress: 100,
    created_at: admin.firestore.Timestamp.fromDate(new Date('2025-09-25T08:00:00Z')),
    updated_at: admin.firestore.Timestamp.fromDate(new Date('2025-09-29T16:00:00Z')),
  },
  {
    id: 'assign_004',
    user_id: 'user_002',
    title: 'Financial Analysis Q3',
    description: 'Prepare quarterly financial analysis report for Q3 2025 with budget variance analysis.',
    status: 'in_progress',
    priority: 'high',
    due_date: '2025-10-08',
    assigned_by: 'admin_001',
    progress: 80,
    created_at: admin.firestore.Timestamp.fromDate(new Date('2025-09-30T09:00:00Z')),
    updated_at: admin.firestore.Timestamp.fromDate(new Date('2025-10-05T11:30:00Z')),
  },
  {
    id: 'assign_005',
    user_id: 'user_003',
    title: 'Operations Process Review',
    description: 'Review current operational processes and recommend improvements for efficiency.',
    status: 'assigned',
    priority: 'medium',
    due_date: '2025-10-20',
    assigned_by: 'admin_001',
    progress: 15,
    created_at: admin.firestore.Timestamp.fromDate(new Date('2025-10-04T08:00:00Z')),
    updated_at: admin.firestore.Timestamp.fromDate(new Date('2025-10-05T09:00:00Z')),
  }
];

// Leave requests data
const leave_requests = [
  {
    id: 'leave_001',
    user_id: 'FBRpLyTyvIpGqGYdNURK',
    type: 'annual_leave',
    title: 'Cuti Tahunan',
    description: 'Cuti tahunan untuk liburan keluarga ke Bali',
    start_date: '2025-10-15',
    end_date: '2025-10-17',
    total_days: 3,
    status: 'pending',
    file_url: null,
    approved_by: null,
    approval_date: null,
    rejection_reason: null,
    created_at: admin.firestore.Timestamp.fromDate(new Date('2025-10-03T10:00:00Z')),
    updated_at: admin.firestore.Timestamp.fromDate(new Date('2025-10-03T10:00:00Z')),
  },
  {
    id: 'leave_002',
    user_id: 'FBRpLyTyvIpGqGYdNURK',
    type: 'sick_leave',
    title: 'Izin Sakit',
    description: 'Sakit demam dan flu, perlu istirahat di rumah',
    start_date: '2025-09-25',
    end_date: '2025-09-25',
    total_days: 1,
    status: 'approved',
    file_url: 'uploads/sick_certificate_20250925.pdf',
    approved_by: 'admin_001',
    approval_date: '2025-09-25',
    rejection_reason: null,
    created_at: admin.firestore.Timestamp.fromDate(new Date('2025-09-25T07:00:00Z')),
    updated_at: admin.firestore.Timestamp.fromDate(new Date('2025-09-25T09:30:00Z')),
  },
  {
    id: 'leave_003',
    user_id: 'user_002',
    type: 'annual_leave',
    title: 'Cuti Melahirkan',
    description: 'Cuti melahirkan sesuai dengan regulasi perusahaan',
    start_date: '2025-11-01',
    end_date: '2025-12-31',
    total_days: 60,
    status: 'pending',
    file_url: 'uploads/maternity_letter_20251001.pdf',
    approved_by: null,
    approval_date: null,
    rejection_reason: null,
    created_at: admin.firestore.Timestamp.fromDate(new Date('2025-10-01T08:00:00Z')),
    updated_at: admin.firestore.Timestamp.fromDate(new Date('2025-10-01T08:00:00Z')),
  }
];

// QR Codes data
const qr_codes = [
  {
    id: 'qr_main_office',
    code: 'BPR_MainOffice_1759584606',
    location_name: 'Kantor Pusat BPR Adiarta Reksacipta',
    address: 'Jl. Sudirman Kav. 10-11, Jakarta Pusat 10220',
    latitude: -6.2088,
    longitude: 106.8456,
    is_active: true,
    created_by: 'admin_001',
    created_at: admin.firestore.Timestamp.fromDate(new Date('2025-01-01T00:00:00Z')),
    updated_at: admin.firestore.Timestamp.fromDate(new Date('2025-10-01T10:00:00Z')),
  },
  {
    id: 'qr_branch_office',
    code: 'BPR_Branch_9876543210',
    location_name: 'Kantor Cabang BPR Adiarta Reksacipta',
    address: 'Jl. Gatot Subroto No. 15, Jakarta Selatan 12930',
    latitude: -6.2297,
    longitude: 106.8270,
    is_active: true,
    created_by: 'admin_001',
    created_at: admin.firestore.Timestamp.fromDate(new Date('2025-01-01T00:00:00Z')),
    updated_at: admin.firestore.Timestamp.fromDate(new Date('2025-10-01T10:00:00Z')),
  }
];

// Settings data
const settings = [
  {
    id: 'app_settings',
    work_start_time: '08:00',
    work_end_time: '17:00',
    late_tolerance_minutes: 15,
    overtime_start_minutes: 480, // 8 hours in minutes
    attendance_radius_meters: 100,
    qr_code_expiry_hours: 24,
    notification_enabled: true,
    auto_checkout_enabled: false,
    created_at: admin.firestore.Timestamp.fromDate(new Date('2025-01-01T00:00:00Z')),
    updated_at: admin.firestore.Timestamp.fromDate(new Date('2025-10-01T10:00:00Z')),
  }
];

// Notifications data
const notifications = [
  {
    id: 'notif_001',
    user_id: 'FBRpLyTyvIpGqGYdNURK',
    title: 'Assignment Updated',
    message: 'Your assignment "Update Employee Management System" has been updated.',
    type: 'assignment',
    read: false,
    created_at: admin.firestore.Timestamp.fromDate(new Date('2025-10-05T14:30:00Z')),
  },
  {
    id: 'notif_002',
    user_id: 'FBRpLyTyvIpGqGYdNURK',
    title: 'Leave Request Submitted',
    message: 'Your annual leave request has been submitted and is pending approval.',
    type: 'leave_request',
    read: false,
    created_at: admin.firestore.Timestamp.fromDate(new Date('2025-10-03T10:00:00Z')),
  },
  {
    id: 'notif_003',
    user_id: 'admin_001',
    title: 'New Leave Request',
    message: 'Ahmad Wijaya has submitted a new leave request for approval.',
    type: 'leave_request',
    read: false,
    created_at: admin.firestore.Timestamp.fromDate(new Date('2025-10-03T10:00:00Z')),
  }
];

async function main() {
  try {
    console.log('🚀 Starting Firestore cleanup and seeding...\n');

    // Clear existing data
    console.log('🗑️  Clearing existing data...');
    await deleteCollection('users');
    await deleteCollection('attendance');
    await deleteCollection('assignments');
    await deleteCollection('leave_requests');
    await deleteCollection('qr_codes');
    await deleteCollection('settings');
    await deleteCollection('notifications');
    
    console.log('\n📝 Adding new data...');
    
    // Add new data
    await addDocuments('users', users);
    await addDocuments('attendance', attendance);
    await addDocuments('assignments', assignments);
    await addDocuments('leave_requests', leave_requests);
    await addDocuments('qr_codes', qr_codes);
    await addDocuments('settings', settings);
    await addDocuments('notifications', notifications);

    console.log('\n✅ Firestore cleanup and seeding completed successfully!');
    console.log('\nSummary:');
    console.log(`- Users: ${users.length} documents`);
    console.log(`- Attendance: ${attendance.length} documents`);
    console.log(`- Assignments: ${assignments.length} documents`);
    console.log(`- Leave Requests: ${leave_requests.length} documents`);
    console.log(`- QR Codes: ${qr_codes.length} documents`);
    console.log(`- Settings: ${settings.length} documents`);
    console.log(`- Notifications: ${notifications.length} documents`);

  } catch (error) {
    console.error('❌ Error during seeding:', error);
  } finally {
    process.exit(0);
  }
}

main();