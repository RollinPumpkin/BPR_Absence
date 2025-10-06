const admin = require('firebase-admin');
const serviceAccount = require('../bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function seedWaitingApprovalLetters() {
  console.log('Creating waiting approval letters for user@gmail.com...');
  
  // Get the user ID for user@gmail.com
  const usersSnapshot = await db.collection('users')
    .where('email', '==', 'user@gmail.com')
    .get();
  
  if (usersSnapshot.empty) {
    console.error('User not found: user@gmail.com');
    return;
  }
  
  const userId = usersSnapshot.docs[0].id;
  console.log('Found user ID:', userId);

  // Letters specifically for waiting approval
  const waitingApprovalLetters = [
    {
      subject: 'Permohonan Cuti Melahirkan',
      content: 'Dengan hormat, saya mengajukan permohonan cuti melahirkan selama 3 bulan sesuai dengan peraturan perusahaan. Rencana cuti dimulai dari tanggal 15 November 2024.',
      letterType: 'Maternity Leave',
      status: 'waiting_approval',
      requiresResponse: true,
      urgency: 'high'
    },
    {
      subject: 'Pengajuan Kenaikan Gaji',
      content: 'Berdasarkan kinerja dan kontribusi saya selama 2 tahun terakhir, saya mengajukan permohonan kenaikan gaji sebesar 15%. Terlampir evaluasi kinerja dan pencapaian target.',
      letterType: 'Salary Increase',
      status: 'waiting_approval',
      requiresResponse: true,
      urgency: 'normal'
    },
    {
      subject: 'Permohonan Pelatihan Eksternal',
      content: 'Saya memohon izin untuk mengikuti pelatihan "Digital Banking Technology" yang akan diselenggarakan di Jakarta selama 5 hari. Pelatihan ini akan meningkatkan kemampuan teknis saya.',
      letterType: 'Training Request',
      status: 'waiting_approval',
      requiresResponse: true,
      urgency: 'normal'
    },
    {
      subject: 'Pengajuan Lembur Akhir Bulan',
      content: 'Dalam rangka menyelesaikan laporan bulanan dan persiapan audit, saya mengajukan permohonan lembur selama 3 hari berturut-turut minggu depan.',
      letterType: 'Overtime Request',
      status: 'waiting_approval',
      requiresResponse: true,
      urgency: 'high'
    },
    {
      subject: 'Permohonan Pindah Divisi',
      content: 'Saya mengajukan permohonan untuk dipindahkan ke divisi IT Development karena background pendidikan dan passion saya di bidang teknologi informasi.',
      letterType: 'Transfer Request',
      status: 'waiting_approval',
      requiresResponse: true,
      urgency: 'normal'
    },
    {
      subject: 'Izin Tidak Masuk - Keperluan Keluarga',
      content: 'Saya memohon izin tidak masuk kerja selama 2 hari (5-6 November) karena ada acara pernikahan keluarga di luar kota yang harus saya hadiri.',
      letterType: 'Personal Leave',
      status: 'waiting_approval',
      requiresResponse: true,
      urgency: 'normal'
    }
  ];

  // Create the letters
  for (const letterTemplate of waitingApprovalLetters) {
    // Create date in the recent past (1-7 days ago)
    const daysAgo = Math.floor(Math.random() * 7) + 1;
    const letterDate = new Date();
    letterDate.setDate(letterDate.getDate() - daysAgo);
    
    const letterData = {
      ...letterTemplate,
      letterDate: admin.firestore.Timestamp.fromDate(letterDate),
      createdAt: admin.firestore.Timestamp.fromDate(letterDate),
      updatedAt: admin.firestore.Timestamp.fromDate(letterDate),
      recipientId: userId,
      recipientEmail: 'user@gmail.com',
      senderName: 'Employee',
      senderId: userId,
      submittedBy: 'user@gmail.com'
    };

    try {
      await db.collection('letters').add(letterData);
      console.log(`✓ Created waiting approval letter: ${letterTemplate.subject}`);
    } catch (error) {
      console.error(`✗ Failed to create letter: ${letterTemplate.subject}`, error);
    }
  }

  console.log('\n✅ Finished creating waiting approval letters!');
}

seedWaitingApprovalLetters()
  .then(() => {
    console.log('All waiting approval letters created successfully!');
    process.exit(0);
  })
  .catch((error) => {
    console.error('Error creating letters:', error);
    process.exit(1);
  });