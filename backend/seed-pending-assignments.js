const admin = require('firebase-admin');
const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function seedPendingAssignments() {
  try {
    console.log('🌱 Memulai seeding assignment yang belum done...\n');

    // Get an EMPLOYEE user (not admin)
    const usersSnapshot = await db.collection('users')
      .where('role', '==', 'employee')
      .limit(1)
      .get();
    
    if (usersSnapshot.empty) {
      console.log('❌ Tidak ada employee di database. Harap tambahkan employee terlebih dahulu.');
      process.exit(1);
    }

    const userId = usersSnapshot.docs[0].id;
    const userName = usersSnapshot.docs[0].data().full_name || 'Employee';
    const userRole = usersSnapshot.docs[0].data().role;
    console.log(`👤 Menggunakan employee: ${userName} (${userId}) - Role: ${userRole}\n`);

    // Get an admin to be the creator
    const adminSnapshot = await db.collection('users')
      .where('role', '==', 'admin')
      .limit(1)
      .get();
    
    const adminId = adminSnapshot.empty ? userId : adminSnapshot.docs[0].id;
    const adminName = adminSnapshot.empty ? userName : adminSnapshot.docs[0].data().full_name;
    console.log(`👨‍💼 Assignment akan dibuat oleh: ${adminName} (${adminId})\n`);

    const today = new Date();
    
    // Dummy assignments yang belum done
    const pendingAssignments = [
      {
        title: 'Laporan Bulanan November',
        description: 'Buat laporan lengkap untuk bulan November 2025, termasuk analisis performa dan rekomendasi',
        dueDate: admin.firestore.Timestamp.fromDate(new Date(today.getTime() + 2 * 60 * 60 * 1000)), // 2 jam dari sekarang
        assignedTo: [userId],
        priority: 'high',
        status: 'pending',
        progress: 0,
        category: 'reporting',
        tags: ['laporan', 'bulanan', 'urgent'],
        createdBy: adminId,
        assignedBy: adminId,
        createdAt: admin.firestore.Timestamp.now(),
        updatedAt: admin.firestore.Timestamp.now(),
        // Completion fields are null/undefined for pending
        completedAt: null,
        completedBy: null,
        completionDate: null,
        completionTime: null
      },
      {
        title: 'Review Dokumen Kredit Nasabah',
        description: 'Periksa dan validasi dokumen kredit 5 nasabah baru yang masuk minggu ini',
        dueDate: admin.firestore.Timestamp.fromDate(new Date(today.getTime() + 4 * 60 * 60 * 1000)), // 4 jam dari sekarang
        assignedTo: [userId],
        priority: 'high',
        status: 'in-progress',
        progress: 35,
        category: 'credit',
        tags: ['kredit', 'nasabah', 'review'],
        createdBy: adminId,
        assignedBy: adminId,
        createdAt: admin.firestore.Timestamp.now(),
        updatedAt: admin.firestore.Timestamp.now(),
        completedAt: null,
        completedBy: null,
        completionDate: null,
        completionTime: null
      },
      {
        title: 'Meeting Koordinasi Tim',
        description: 'Meeting koordinasi dengan tim untuk membahas target Q4 dan persiapan akhir tahun',
        dueDate: admin.firestore.Timestamp.fromDate(new Date(today.getTime() + 6 * 60 * 60 * 1000)), // 6 jam dari sekarang
        assignedTo: [userId],
        priority: 'medium',
        status: 'pending',
        progress: 0,
        category: 'meeting',
        tags: ['meeting', 'koordinasi', 'tim'],
        createdBy: adminId,
        assignedBy: adminId,
        createdAt: admin.firestore.Timestamp.now(),
        updatedAt: admin.firestore.Timestamp.now(),
        completedAt: null,
        completedBy: null,
        completionDate: null,
        completionTime: null
      },
      {
        title: 'Update Database Nasabah',
        description: 'Update data nasabah yang belum lengkap, termasuk nomor telepon dan alamat email',
        dueDate: admin.firestore.Timestamp.fromDate(new Date(today.getTime() + 24 * 60 * 60 * 1000)), // besok
        assignedTo: [userId],
        priority: 'medium',
        status: 'in-progress',
        progress: 60,
        category: 'data-entry',
        tags: ['database', 'nasabah', 'update'],
        createdBy: adminId,
        assignedBy: adminId,
        createdAt: admin.firestore.Timestamp.now(),
        updatedAt: admin.firestore.Timestamp.now(),
        completedAt: null,
        completedBy: null,
        completionDate: null,
        completionTime: null
      },
      {
        title: 'Verifikasi Transaksi Harian',
        description: 'Verifikasi semua transaksi yang masuk hari ini dan pastikan semua sudah tercatat dengan benar',
        dueDate: admin.firestore.Timestamp.fromDate(new Date(today.getTime() + 3 * 60 * 60 * 1000)), // 3 jam dari sekarang
        assignedTo: [userId],
        priority: 'high',
        status: 'pending',
        progress: 0,
        category: 'verification',
        tags: ['transaksi', 'verifikasi', 'harian'],
        createdBy: adminId,
        assignedBy: adminId,
        createdAt: admin.firestore.Timestamp.now(),
        updatedAt: admin.firestore.Timestamp.now(),
        completedAt: null,
        completedBy: null,
        completionDate: null,
        completionTime: null
      },
      {
        title: 'Persiapan Audit Internal',
        description: 'Siapkan semua dokumen dan laporan yang diperlukan untuk audit internal bulan depan',
        dueDate: admin.firestore.Timestamp.fromDate(new Date(today.getTime() + 48 * 60 * 60 * 1000)), // 2 hari dari sekarang
        assignedTo: [userId],
        priority: 'medium',
        status: 'pending',
        progress: 0,
        category: 'audit',
        tags: ['audit', 'internal', 'persiapan'],
        createdBy: adminId,
        assignedBy: adminId,
        createdAt: admin.firestore.Timestamp.now(),
        updatedAt: admin.firestore.Timestamp.now(),
        completedAt: null,
        completedBy: null,
        completionDate: null,
        completionTime: null
      },
      {
        title: 'Follow Up Kredit Tertunda',
        description: 'Follow up dengan nasabah yang pengajuan kreditnya masih tertunda untuk melengkapi dokumen',
        dueDate: admin.firestore.Timestamp.fromDate(new Date(today.getTime() + 5 * 60 * 60 * 1000)), // 5 jam dari sekarang
        assignedTo: [userId],
        priority: 'high',
        status: 'in-progress',
        progress: 25,
        category: 'follow-up',
        tags: ['kredit', 'follow-up', 'nasabah'],
        createdBy: adminId,
        assignedBy: adminId,
        createdAt: admin.firestore.Timestamp.now(),
        updatedAt: admin.firestore.Timestamp.now(),
        completedAt: null,
        completedBy: null,
        completionDate: null,
        completionTime: null
      },
      {
        title: 'Training Product Knowledge',
        description: 'Ikuti sesi training tentang produk-produk baru yang akan diluncurkan',
        dueDate: admin.firestore.Timestamp.fromDate(new Date(today.getTime() + 72 * 60 * 60 * 1000)), // 3 hari dari sekarang
        assignedTo: [userId],
        priority: 'low',
        status: 'pending',
        progress: 0,
        category: 'training',
        tags: ['training', 'product', 'knowledge'],
        createdBy: adminId,
        assignedBy: adminId,
        createdAt: admin.firestore.Timestamp.now(),
        updatedAt: admin.firestore.Timestamp.now(),
        completedAt: null,
        completedBy: null,
        completionDate: null,
        completionTime: null
      }
    ];

    console.log(`📝 Akan menambahkan ${pendingAssignments.length} assignment yang belum done:\n`);

    const batch = db.batch();
    let count = 0;

    for (const assignment of pendingAssignments) {
      const docRef = db.collection('assignments').doc();
      batch.set(docRef, assignment);
      count++;
      
      const statusEmoji = assignment.status === 'pending' ? '⏸️' : '▶️';
      console.log(`  ${statusEmoji} ${assignment.title}`);
      console.log(`     Status: ${assignment.status} | Priority: ${assignment.priority} | Progress: ${assignment.progress}%`);
      console.log(`     Due: ${assignment.dueDate.toDate().toLocaleString('id-ID')}\n`);
    }

    await batch.commit();

    console.log(`✅ Berhasil menambahkan ${count} assignment yang belum done!`);
    console.log(`\n📊 Ringkasan:`);
    
    const pendingCount = pendingAssignments.filter(a => a.status === 'pending').length;
    const inProgressCount = pendingAssignments.filter(a => a.status === 'in-progress').length;
    
    console.log(`   - Pending: ${pendingCount} assignment`);
    console.log(`   - In Progress: ${inProgressCount} assignment`);
    console.log(`   - Total: ${count} assignment`);
    
    console.log(`\n💡 Semua assignment memiliki field completion (completedAt, completionDate, completionTime) = null`);

    process.exit(0);
  } catch (error) {
    console.error('❌ Error saat seeding:', error);
    process.exit(1);
  }
}

seedPendingAssignments();
