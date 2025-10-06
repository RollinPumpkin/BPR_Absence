const { initializeFirebase, getFirestore, getServerTimestamp } = require('../config/database');

// Initialize Firebase
initializeFirebase();
const db = getFirestore();

const sampleLetters = [
  {
    letter_number: "DOC/001/X/2025",
    letter_type: "DOCTOR'S NOTE",
    subject: "Surat Keterangan Sakit",
    content: "Dengan ini kami menerangkan bahwa karyawan dengan nama dibawah ini telah diperiksa dan dinyatakan sakit sehingga memerlukan istirahat selama 3 hari untuk pemulihan kesehatan.",
    recipient_id: "user123", // You'll need to replace with actual user ID
    recipient_name: "Puma Ardiansyah",
    recipient_employee_id: "EMP001",
    recipient_department: "IT Department",
    sender_id: "admin123",
    sender_name: "Dr. Ahmad Susanto",
    sender_position: "Dokter Umum",
    status: "approved",
    priority: "medium",
    document_url: null,
    medical_info: {
      diagnosis: "Acute respiratory infection",
      treatment: "Rest and medication",
      rest_days: 3,
      next_checkup: null
    },
    approval_history: [
      {
        action: "submitted",
        timestamp: new Date("2025-10-04T08:00:00Z"),
        user_id: "user123",
        user_name: "Puma Ardiansyah",
        notes: "Submitted medical certificate request"
      },
      {
        action: "approved",
        timestamp: new Date("2025-10-04T10:30:00Z"),
        user_id: "admin123", 
        user_name: "Dr. Ahmad Susanto",
        notes: "Medical certificate approved - 3 days rest recommended"
      }
    ],
    created_at: new Date("2025-10-04T08:00:00Z"),
    updated_at: new Date("2025-10-04T10:30:00Z"),
    expires_at: new Date("2025-10-07T23:59:59Z")
  },
  {
    letter_number: "MED/002/X/2025",
    letter_type: "MEDICAL CERTIFICATE",
    subject: "Surat Keterangan Sehat",
    content: "Berdasarkan pemeriksaan kesehatan yang telah dilakukan, karyawan dengan identitas dibawah ini dinyatakan dalam keadaan sehat dan layak untuk bekerja kembali setelah masa pemulihan.",
    recipient_id: "user123",
    recipient_name: "Puma Ardiansyah", 
    recipient_employee_id: "EMP001",
    recipient_department: "IT Department",
    sender_id: "admin123",
    sender_name: "Dr. Sarah Wijaya",
    sender_position: "Dokter Okupasi",
    status: "approved",
    priority: "medium",
    document_url: null,
    medical_info: {
      diagnosis: "Fit for work",
      treatment: "Follow-up treatment completed",
      rest_days: 0,
      next_checkup: new Date("2025-11-04T09:00:00Z")
    },
    approval_history: [
      {
        action: "submitted",
        timestamp: new Date("2025-10-05T09:15:00Z"),
        user_id: "user123",
        user_name: "Puma Ardiansyah",
        notes: "Requested health certificate for return to work"
      },
      {
        action: "approved",
        timestamp: new Date("2025-10-05T14:20:00Z"),
        user_id: "admin123",
        user_name: "Dr. Sarah Wijaya", 
        notes: "Health certificate approved - employee fit for work"
      }
    ],
    created_at: new Date("2025-10-05T09:15:00Z"),
    updated_at: new Date("2025-10-05T14:20:00Z"),
    expires_at: new Date("2025-12-05T23:59:59Z")
  },
  {
    letter_number: "REF/003/X/2025", 
    letter_type: "REFERENCE LETTER",
    subject: "Surat Rekomendasi Karyawan",
    content: "Dengan ini kami memberikan rekomendasi untuk karyawan yang bersangkutan atas dedikasi dan kinerja yang baik selama bekerja di perusahaan kami.",
    recipient_id: "user123",
    recipient_name: "Puma Ardiansyah",
    recipient_employee_id: "EMP001", 
    recipient_department: "IT Department",
    sender_id: "admin123",
    sender_name: "Budi Santoso",
    sender_position: "HR Manager",
    status: "waiting_approval",
    priority: "low",
    document_url: null,
    approval_history: [
      {
        action: "submitted",
        timestamp: new Date("2025-10-06T10:00:00Z"),
        user_id: "user123",
        user_name: "Puma Ardiansyah",
        notes: "Submitted reference letter request for external application"
      }
    ],
    created_at: new Date("2025-10-06T10:00:00Z"),
    updated_at: new Date("2025-10-06T10:00:00Z"),
    expires_at: new Date("2025-11-06T23:59:59Z")
  },
  {
    letter_number: "VAC/004/X/2025",
    letter_type: "VACATION REQUEST", 
    subject: "Permohonan Cuti Tahunan",
    content: "Dengan hormat, saya mengajukan permohonan cuti tahunan untuk keperluan berlibur bersama keluarga. Mohon persetujuan dari pihak manajemen.",
    recipient_id: "user123",
    recipient_name: "Puma Ardiansyah",
    recipient_employee_id: "EMP001",
    recipient_department: "IT Department", 
    sender_id: "user123",
    sender_name: "Puma Ardiansyah",
    sender_position: "Software Developer",
    status: "rejected",
    priority: "medium",
    document_url: null,
    vacation_info: {
      start_date: new Date("2025-10-15T00:00:00Z"),
      end_date: new Date("2025-10-18T23:59:59Z"),
      total_days: 4,
      reason: "Family vacation",
      backup_person: "John Doe",
      backup_contact: "+62812345678"
    },
    approval_history: [
      {
        action: "submitted", 
        timestamp: new Date("2025-10-03T11:30:00Z"),
        user_id: "user123",
        user_name: "Puma Ardiansyah",
        notes: "Submitted vacation request for family time"
      },
      {
        action: "rejected",
        timestamp: new Date("2025-10-04T16:45:00Z"),
        user_id: "admin123",
        user_name: "Budi Santoso",
        notes: "Rejected - Project deadline conflict. Please reschedule after October 25th"
      }
    ],
    created_at: new Date("2025-10-03T11:30:00Z"),
    updated_at: new Date("2025-10-04T16:45:00Z"),
    expires_at: new Date("2025-11-03T23:59:59Z")
  },
  {
    letter_number: "WFH/005/X/2025",
    letter_type: "WORK FROM HOME",
    subject: "Permohonan Work From Home", 
    content: "Saya mengajukan permohonan untuk bekerja dari rumah selama 2 hari dalam rangka menghindari kemacetan dan meningkatkan produktivitas kerja.",
    recipient_id: "user123",
    recipient_name: "Puma Ardiansyah",
    recipient_employee_id: "EMP001",
    recipient_department: "IT Department",
    sender_id: "user123", 
    sender_name: "Puma Ardiansyah",
    sender_position: "Software Developer",
    status: "approved",
    priority: "low",
    document_url: null,
    wfh_info: {
      start_date: new Date("2025-10-07T00:00:00Z"),
      end_date: new Date("2025-10-08T23:59:59Z"),
      total_days: 2,
      reason: "Avoid traffic congestion and increase productivity",
      work_plan: "Continue development of attendance system features",
      contact_available: true
    },
    approval_history: [
      {
        action: "submitted",
        timestamp: new Date("2025-10-06T14:00:00Z"),
        user_id: "user123", 
        user_name: "Puma Ardiansyah",
        notes: "Submitted WFH request for better productivity"
      },
      {
        action: "approved",
        timestamp: new Date("2025-10-06T15:30:00Z"),
        user_id: "admin123",
        user_name: "Budi Santoso",
        notes: "WFH approved - maintain communication and deliverables"
      }
    ],
    created_at: new Date("2025-10-06T14:00:00Z"),
    updated_at: new Date("2025-10-06T15:30:00Z"),
    expires_at: new Date("2025-10-08T23:59:59Z")
  }
];

async function seedLetters() {
  try {
    console.log('Starting to seed letters data...');
    
    const batch = db.batch();
    
    for (const letter of sampleLetters) {
      const letterRef = db.collection('letters').doc();
      batch.set(letterRef, {
        ...letter,
        created_at: getServerTimestamp(),
        updated_at: getServerTimestamp()
      });
    }
    
    await batch.commit();
    console.log(`Successfully seeded ${sampleLetters.length} letters to database`);
    
    // Verify the data was inserted
    const lettersSnapshot = await db.collection('letters').get();
    console.log(`Total letters in database: ${lettersSnapshot.size}`);
    
    process.exit(0);
  } catch (error) {
    console.error('Error seeding letters:', error);
    process.exit(1);
  }
}

// Run the seed function
seedLetters();