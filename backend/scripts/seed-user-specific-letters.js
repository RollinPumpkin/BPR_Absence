const { initializeFirebase, getFirestore, getServerTimestamp } = require('../config/database');

// Initialize Firebase
initializeFirebase();
const db = getFirestore();

// Sample users (you can add more as needed)
const users = [
  {
    id: "puma_ardiansyah",
    name: "Puma Ardiansyah",
    employee_id: "EMP001",
    department: "IT Department"
  },
  {
    id: "john_doe",
    name: "John Doe", 
    employee_id: "EMP002",
    department: "Finance Department"
  },
  {
    id: "jane_smith",
    name: "Jane Smith",
    employee_id: "EMP003", 
    department: "HR Department"
  },
  {
    id: "test_user",
    name: "Test User",
    employee_id: "EMP004",
    department: "Marketing Department"
  }
];

// Letter templates for different types
const letterTemplates = [
  {
    letter_type: "DOCTOR'S NOTE",
    subject: "Surat Keterangan Sakit",
    content: "Dengan ini kami menerangkan bahwa karyawan dengan nama dibawah ini telah diperiksa dan dinyatakan sakit sehingga memerlukan istirahat untuk pemulihan kesehatan.",
    status: "approved",
    priority: "high"
  },
  {
    letter_type: "MEDICAL CERTIFICATE", 
    subject: "Surat Keterangan Sehat",
    content: "Berdasarkan pemeriksaan kesehatan yang telah dilakukan, karyawan dengan identitas dibawah ini dinyatakan dalam keadaan sehat dan layak untuk bekerja kembali.",
    status: "approved",
    priority: "medium"
  },
  {
    letter_type: "VACATION REQUEST",
    subject: "Permohonan Cuti Tahunan", 
    content: "Dengan hormat, saya mengajukan permohonan cuti tahunan untuk keperluan pribadi. Mohon persetujuan dari pihak manajemen.",
    status: "waiting_approval",
    priority: "medium"
  },
  {
    letter_type: "REFERENCE LETTER",
    subject: "Surat Rekomendasi Karyawan",
    content: "Dengan ini kami memberikan rekomendasi untuk karyawan yang bersangkutan atas dedikasi dan kinerja yang baik selama bekerja di perusahaan kami.",
    status: "waiting_approval", 
    priority: "low"
  },
  {
    letter_type: "OVERTIME REQUEST",
    subject: "Permohonan Lembur",
    content: "Dengan hormat, saya mengajukan permohonan untuk melakukan lembur dalam rangka menyelesaikan project yang sedang berjalan.",
    status: "rejected",
    priority: "medium"
  },
  {
    letter_type: "TRANSFER REQUEST",
    subject: "Permohonan Mutasi Departemen",
    content: "Saya mengajukan permohonan mutasi ke departemen lain untuk pengembangan karir dan pengalaman kerja yang lebih luas.",
    status: "waiting_approval",
    priority: "low"
  }
];

function generateLetters() {
  const letters = [];
  let letterCounter = 1;

  users.forEach(user => {
    // Generate 3-5 letters per user
    const letterCount = Math.floor(Math.random() * 3) + 3; // 3-5 letters
    
    for (let i = 0; i < letterCount; i++) {
      const template = letterTemplates[Math.floor(Math.random() * letterTemplates.length)];
      const letterNumber = `DOC/${String(letterCounter).padStart(3, '0')}/X/2025`;
      
      // Generate random dates within the last 30 days
      const daysAgo = Math.floor(Math.random() * 30);
      const createdDate = new Date();
      createdDate.setDate(createdDate.getDate() - daysAgo);
      
      const letter = {
        letter_number: letterNumber,
        letter_type: template.letter_type,
        subject: template.subject,
        content: template.content,
        recipient_id: user.id,
        recipient_name: user.name,
        recipient_employee_id: user.employee_id,
        recipient_department: user.department,
        sender_id: "admin123",
        sender_name: "HR System",
        sender_position: "Human Resources",
        status: template.status,
        priority: template.priority,
        document_url: null,
        approval_history: [
          {
            action: "submitted",
            timestamp: createdDate,
            user_id: user.id,
            user_name: user.name,
            notes: `Submitted ${template.letter_type.toLowerCase()} request`
          }
        ],
        created_at: createdDate,
        updated_at: createdDate,
        expires_at: new Date(createdDate.getTime() + (30 * 24 * 60 * 60 * 1000)) // 30 days from created
      };

      // Add approval history for approved/rejected letters
      if (template.status === "approved") {
        const approvedDate = new Date(createdDate.getTime() + (2 * 60 * 60 * 1000)); // 2 hours later
        letter.approval_history.push({
          action: "approved",
          timestamp: approvedDate,
          user_id: "admin123",
          user_name: "HR Manager",
          notes: `${template.letter_type} approved`
        });
        letter.updated_at = approvedDate;
      } else if (template.status === "rejected") {
        const rejectedDate = new Date(createdDate.getTime() + (24 * 60 * 60 * 1000)); // 1 day later
        letter.approval_history.push({
          action: "rejected",
          timestamp: rejectedDate,
          user_id: "admin123", 
          user_name: "HR Manager",
          notes: `${template.letter_type} rejected - insufficient documentation`
        });
        letter.updated_at = rejectedDate;
      }

      letters.push(letter);
      letterCounter++;
    }
  });

  return letters;
}

async function seedUserSpecificLetters() {
  try {
    console.log('Starting to seed user-specific letters data...');
    
    const letters = generateLetters();
    const batch = db.batch();
    
    for (const letter of letters) {
      const letterRef = db.collection('letters').doc();
      batch.set(letterRef, {
        ...letter,
        created_at: getServerTimestamp(),
        updated_at: getServerTimestamp()
      });
    }
    
    await batch.commit();
    console.log(`Successfully seeded ${letters.length} user-specific letters to database`);
    
    // Show distribution by user
    const userLetterCounts = {};
    letters.forEach(letter => {
      userLetterCounts[letter.recipient_name] = (userLetterCounts[letter.recipient_name] || 0) + 1;
    });
    
    console.log('\nLetters distribution by user:');
    Object.entries(userLetterCounts).forEach(([user, count]) => {
      console.log(`- ${user}: ${count} letters`);
    });
    
    // Verify total letters in database
    const lettersSnapshot = await db.collection('letters').get();
    console.log(`\nTotal letters in database: ${lettersSnapshot.size}`);
    
    process.exit(0);
  } catch (error) {
    console.error('Error seeding user-specific letters:', error);
    process.exit(1);
  }
}

// Run the seed function
seedUserSpecificLetters();