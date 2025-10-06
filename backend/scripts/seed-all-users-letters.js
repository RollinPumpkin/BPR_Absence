const admin = require('firebase-admin');
const serviceAccount = require('../bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function seedAllUsersLetters() {
  console.log('Starting to seed letters for all users...');
  
  // Get all users
  const usersSnapshot = await db.collection('users').get();
  const users = [];
  usersSnapshot.forEach(doc => {
    users.push({
      id: doc.id,
      email: doc.data().email,
      name: doc.data().name || doc.data().fullName || 'Unknown User'
    });
  });

  console.log('Found users:', users.map(u => u.email));

  // Letter templates for different types
  const letterTemplates = [
    {
      subject: 'Cuti Tahunan',
      content: 'Saya mengajukan permohonan cuti tahunan selama 3 hari untuk keperluan keluarga.',
      letterType: 'Leave Request',
      status: 'waiting_approval',
      requiresResponse: true
    },
    {
      subject: 'Izin Sakit',
      content: 'Saya tidak dapat masuk kerja hari ini karena sedang sakit demam dan perlu istirahat.',
      letterType: 'Sick Leave',
      status: 'approved',
      requiresResponse: false
    },
    {
      subject: 'Laporan Keterlambatan',
      content: 'Saya terlambat masuk kerja pagi ini karena ada kendala transportasi umum.',
      letterType: 'Late Report',
      status: 'approved',
      requiresResponse: false
    },
    {
      subject: 'Permohonan WFH',
      content: 'Saya memohon untuk bekerja dari rumah selama 2 hari karena ada keperluan mendesak.',
      letterType: 'WFH Request',
      status: 'waiting_approval',
      requiresResponse: true
    },
    {
      subject: 'Izin Pulang Cepat',
      content: 'Saya memohon izin untuk pulang lebih awal hari ini karena ada keperluan keluarga yang mendesak.',
      letterType: 'Early Leave',
      status: 'rejected',
      requiresResponse: false
    },
    {
      subject: 'Surat Keterangan Sehat',
      content: 'Saya memohon surat keterangan sehat untuk keperluan administrasi kantor setelah masa sakit.',
      letterType: 'Health Certificate',
      status: 'approved',
      requiresResponse: false
    }
  ];

  // Create letters for each user
  for (const user of users) {
    console.log(`Creating letters for user: ${user.email}`);
    
    // Create 3-5 random letters for each user
    const numLetters = Math.floor(Math.random() * 3) + 3; // 3-5 letters
    
    for (let i = 0; i < numLetters; i++) {
      const template = letterTemplates[Math.floor(Math.random() * letterTemplates.length)];
      
      // Create unique dates in the past
      const daysAgo = Math.floor(Math.random() * 30) + 1; // 1-30 days ago
      const letterDate = new Date();
      letterDate.setDate(letterDate.getDate() - daysAgo);
      
      const letterData = {
        subject: template.subject,
        content: template.content,
        letterType: template.letterType,
        status: template.status,
        requiresResponse: template.requiresResponse,
        letterDate: admin.firestore.Timestamp.fromDate(letterDate),
        createdAt: admin.firestore.Timestamp.fromDate(letterDate),
        updatedAt: admin.firestore.Timestamp.fromDate(letterDate),
        recipientId: user.id,
        recipientEmail: user.email,
        senderName: 'HR Department',
        senderId: 'hr_system',
        urgency: Math.random() > 0.7 ? 'high' : 'normal'
      };

      try {
        await db.collection('letters').add(letterData);
        console.log(`  ✓ Created letter: ${template.subject} for ${user.email}`);
      } catch (error) {
        console.error(`  ✗ Failed to create letter for ${user.email}:`, error);
      }
    }
  }

  console.log('\n✅ Finished seeding letters for all users!');
}

seedAllUsersLetters()
  .then(() => {
    console.log('All letters seeded successfully!');
    process.exit(0);
  })
  .catch((error) => {
    console.error('Error seeding letters:', error);
    process.exit(1);
  });