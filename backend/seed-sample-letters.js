const { initializeFirebase, getFirestore, getServerTimestamp } = require('./config/database');

async function seedSampleLetters() {
  console.log('🌱 Seeding sample letters...');
  
  try {
    initializeFirebase();
    const db = getFirestore();
    
    // Get a regular user for sender_id
    const usersSnapshot = await db.collection('users').where('role', '==', 'employee').limit(1).get();
    let senderId = 'test_user_id';
    
    if (!usersSnapshot.empty) {
      senderId = usersSnapshot.docs[0].id;
      console.log('📧 Using sender:', usersSnapshot.docs[0].data().full_name);
    }
    
    // Sample letters data
    const sampleLetters = [
      {
        sender_id: senderId,
        recipient_id: 'admin_user_id', // This will be the admin who needs to approve
        subject: 'Permohonan Cuti Sakit',
        content: 'Dengan hormat, saya mengajukan permohonan cuti sakit selama 3 hari karena kondisi kesehatan yang tidak memungkinkan untuk bekerja. Mohon persetujuan dari atasan. Terima kasih.',
        letter_type: 'sick_leave',
        letter_number: 'SL/2025/001',
        letter_date: '2025-10-14',
        priority: 'normal',
        status: 'pending',
        requires_response: true,
        response_deadline: '2025-10-16',
        attachments: [],
        cc_recipients: [],
        template_used: null,
        reference_number: null,
        read_at: null,
        response_received: false,
        response_content: null,
        response_date: null,
        created_at: getServerTimestamp(),
        updated_at: getServerTimestamp()
      },
      {
        sender_id: senderId,
        recipient_id: 'admin_user_id',
        subject: 'Permohonan Izin Keperluan Keluarga',
        content: 'Mohon izin untuk tidak masuk kerja pada tanggal 15 Oktober 2025 karena ada keperluan keluarga yang mendesak. Saya akan mengganti jam kerja yang tertinggal. Terima kasih atas perhatiannya.',
        letter_type: 'family_leave',
        letter_number: 'FL/2025/001',
        letter_date: '2025-10-14',
        priority: 'high',
        status: 'pending',
        requires_response: true,
        response_deadline: '2025-10-15',
        attachments: [],
        cc_recipients: [],
        template_used: null,
        reference_number: null,
        read_at: null,
        response_received: false,
        response_content: null,
        response_date: null,
        created_at: getServerTimestamp(),
        updated_at: getServerTimestamp()
      },
      {
        sender_id: senderId,
        recipient_id: 'admin_user_id',
        subject: 'Permohonan Surat Keterangan Kerja',
        content: 'Saya memerlukan surat keterangan kerja untuk keperluan pengajuan kredit bank. Mohon bantuan untuk mengeluarkan surat keterangan kerja yang menyatakan bahwa saya masih aktif bekerja di perusahaan ini.',
        letter_type: 'work_certificate',
        letter_number: 'WC/2025/001',
        letter_date: '2025-10-14',
        priority: 'normal',
        status: 'pending',
        requires_response: false,
        response_deadline: null,
        attachments: [],
        cc_recipients: [],
        template_used: null,
        reference_number: null,
        read_at: null,
        response_received: false,
        response_content: null,
        response_date: null,
        created_at: getServerTimestamp(),
        updated_at: getServerTimestamp()
      }
    ];
    
    // Add letters to Firestore
    for (const letter of sampleLetters) {
      const docRef = await db.collection('letters').add(letter);
      console.log('✅ Added letter:', letter.subject, 'with ID:', docRef.id);
    }
    
    console.log('🎉 Sample letters seeded successfully!');
    console.log('📝 Added 3 pending letters for admin approval');
    
  } catch (error) {
    console.error('❌ Error seeding letters:', error);
  }
}

// Run the seeding
seedSampleLetters();