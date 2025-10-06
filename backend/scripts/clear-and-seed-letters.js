const admin = require('firebase-admin');
const serviceAccount = require('../bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

// Initialize Firebase Admin if not already initialized
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

const db = admin.firestore();

async function clearAndSeedLetters() {
  try {
    console.log('🗑️ Clearing existing letters...');
    
    // Delete all existing letters
    const lettersSnapshot = await db.collection('letters').get();
    console.log(`📄 Found ${lettersSnapshot.docs.length} existing letters to delete`);
    
    if (!lettersSnapshot.empty) {
      const batch = db.batch();
      lettersSnapshot.docs.forEach((doc) => {
        batch.delete(doc.ref);
      });
      await batch.commit();
      console.log('✅ All existing letters deleted');
    }

    console.log('🌱 Seeding new letters...');
    
    // Create new letters that match the form structure
    const newLetters = [
      {
        // Letter 1 - Waiting Approval
        subject: "Medical Leave Request",
        content: "I am requesting medical leave due to a minor surgical procedure that requires recovery time. The doctor has recommended 5 days of rest.",
        letterType: "Medical Leave",
        status: "waiting_approval",
        priority: "High",
        recipientId: "E8yHtkBnSFc6n9VZa9gE", // User ID from the login
        recipientEmail: "user@gmail.com",
        recipientEmployeeId: "EMP001",
        recipientName: "User Test",
        recipientDepartment: "IT Department",
        senderId: "admin123",
        senderName: "HR Manager",
        senderPosition: "Human Resources",
        letterNumber: "LTR-2024-001",
        createdAt: admin.firestore.Timestamp.fromDate(new Date('2024-10-06')),
        updatedAt: admin.firestore.Timestamp.fromDate(new Date('2024-10-06')),
        attachments: [],
        validUntil: admin.firestore.Timestamp.fromDate(new Date('2024-12-06')),
      },
      {
        // Letter 2 - Waiting Approval
        subject: "Sick Leave Application",
        content: "I need to take sick leave due to fever and flu symptoms. Doctor's certificate is attached for verification.",
        letterType: "Sick Leave",
        status: "waiting_approval",
        priority: "Medium",
        recipientId: "E8yHtkBnSFc6n9VZa9gE",
        recipientEmail: "user@gmail.com",
        recipientEmployeeId: "EMP001",
        recipientName: "User Test",
        recipientDepartment: "IT Department",
        senderId: "admin123",
        senderName: "HR Manager",
        senderPosition: "Human Resources",
        letterNumber: "LTR-2024-002",
        createdAt: admin.firestore.Timestamp.fromDate(new Date('2024-10-05')),
        updatedAt: admin.firestore.Timestamp.fromDate(new Date('2024-10-05')),
        attachments: [],
        validUntil: admin.firestore.Timestamp.fromDate(new Date('2024-11-05')),
      },
      {
        // Letter 3 - Waiting Approval
        subject: "Emergency Leave Request",
        content: "Family emergency requires immediate attention. I need to take 2 days of emergency leave to handle urgent family matters.",
        letterType: "Emergency Leave",
        status: "waiting_approval",
        priority: "High",
        recipientId: "E8yHtkBnSFc6n9VZa9gE",
        recipientEmail: "user@gmail.com",
        recipientEmployeeId: "EMP001",
        recipientName: "User Test",
        recipientDepartment: "IT Department",
        senderId: "admin123",
        senderName: "HR Manager",
        senderPosition: "Human Resources",
        letterNumber: "LTR-2024-003",
        createdAt: admin.firestore.Timestamp.fromDate(new Date('2024-10-04')),
        updatedAt: admin.firestore.Timestamp.fromDate(new Date('2024-10-04')),
        attachments: [],
        validUntil: admin.firestore.Timestamp.fromDate(new Date('2024-11-04')),
      },
      {
        // Letter 4 - Approved
        subject: "Annual Leave Application",
        content: "Request for annual leave for vacation purposes. Planning to take 7 days off for family vacation trip.",
        letterType: "Annual Leave",
        status: "approved",
        priority: "Medium",
        recipientId: "E8yHtkBnSFc6n9VZa9gE",
        recipientEmail: "user@gmail.com",
        recipientEmployeeId: "EMP001",
        recipientName: "User Test",
        recipientDepartment: "IT Department",
        senderId: "admin123",
        senderName: "HR Manager",
        senderPosition: "Human Resources",
        letterNumber: "LTR-2024-004",
        createdAt: admin.firestore.Timestamp.fromDate(new Date('2024-10-03')),
        updatedAt: admin.firestore.Timestamp.fromDate(new Date('2024-10-03')),
        attachments: [],
        validUntil: admin.firestore.Timestamp.fromDate(new Date('2024-12-03')),
      },
      {
        // Letter 5 - Approved
        subject: "Maternity Leave Request",
        content: "Requesting maternity leave as per company policy. Expected due date is approaching and need to prepare for childbirth.",
        letterType: "Maternity Leave",
        status: "approved",
        priority: "High",
        recipientId: "E8yHtkBnSFc6n9VZa9gE",
        recipientEmail: "user@gmail.com",
        recipientEmployeeId: "EMP001",
        recipientName: "User Test",
        recipientDepartment: "IT Department",
        senderId: "admin123",
        senderName: "HR Manager",
        senderPosition: "Human Resources",
        letterNumber: "LTR-2024-005",
        createdAt: admin.firestore.Timestamp.fromDate(new Date('2024-10-02')),
        updatedAt: admin.firestore.Timestamp.fromDate(new Date('2024-10-02')),
        attachments: [],
        validUntil: admin.firestore.Timestamp.fromDate(new Date('2025-04-02')),
      },
      {
        // Letter 6 - Rejected
        subject: "Special Leave Request",
        content: "Requesting special leave for personal reasons. Need time off to handle personal matters that cannot be scheduled outside work hours.",
        letterType: "Special Leave",
        status: "rejected",
        priority: "Low",
        recipientId: "E8yHtkBnSFc6n9VZa9gE",
        recipientEmail: "user@gmail.com",
        recipientEmployeeId: "EMP001",
        recipientName: "User Test",
        recipientDepartment: "IT Department",
        senderId: "admin123",
        senderName: "HR Manager",
        senderPosition: "Human Resources",
        letterNumber: "LTR-2024-006",
        createdAt: admin.firestore.Timestamp.fromDate(new Date('2024-10-01')),
        updatedAt: admin.firestore.Timestamp.fromDate(new Date('2024-10-01')),
        attachments: [],
        validUntil: admin.firestore.Timestamp.fromDate(new Date('2024-11-01')),
      },
      {
        // Letter 7 - Waiting Approval (Additional)
        subject: "Study Leave Application",
        content: "Applying for study leave to attend professional development course. This will enhance my skills and benefit the company.",
        letterType: "Study Leave",
        status: "waiting_approval",
        priority: "Medium",
        recipientId: "E8yHtkBnSFc6n9VZa9gE",
        recipientEmail: "user@gmail.com",
        recipientEmployeeId: "EMP001",
        recipientName: "User Test",
        recipientDepartment: "IT Department",
        senderId: "admin123",
        senderName: "HR Manager",
        senderPosition: "Human Resources",
        letterNumber: "LTR-2024-007",
        createdAt: admin.firestore.Timestamp.fromDate(new Date('2024-09-30')),
        updatedAt: admin.firestore.Timestamp.fromDate(new Date('2024-09-30')),
        attachments: [],
        validUntil: admin.firestore.Timestamp.fromDate(new Date('2024-12-30')),
      },
      {
        // Letter 8 - Approved (Additional)
        subject: "Conference Attendance Leave",
        content: "Request for leave to attend industry conference. This will provide valuable insights and networking opportunities.",
        letterType: "Conference Leave",
        status: "approved",
        priority: "Medium",
        recipientId: "E8yHtkBnSFc6n9VZa9gE",
        recipientEmail: "user@gmail.com",
        recipientEmployeeId: "EMP001",
        recipientName: "User Test",
        recipientDepartment: "IT Department",
        senderId: "admin123",
        senderName: "HR Manager",
        senderPosition: "Human Resources",
        letterNumber: "LTR-2024-008",
        createdAt: admin.firestore.Timestamp.fromDate(new Date('2024-09-29')),
        updatedAt: admin.firestore.Timestamp.fromDate(new Date('2024-09-29')),
        attachments: [],
        validUntil: admin.firestore.Timestamp.fromDate(new Date('2024-11-29')),
      }
    ];

    // Add all letters to Firestore
    let addedCount = 0;
    for (const letterData of newLetters) {
      const docRef = await db.collection('letters').add(letterData);
      console.log(`✅ Added letter: ${letterData.subject} (ID: ${docRef.id})`);
      addedCount++;
    }

    console.log(`🎉 Successfully seeded ${addedCount} letters!`);
    
    // Verify the data
    console.log('\n📊 Verifying seeded data...');
    const verifySnapshot = await db.collection('letters')
      .where('recipientEmail', '==', 'user@gmail.com')
      .get();
    
    console.log(`📄 Found ${verifySnapshot.docs.length} letters for user@gmail.com`);
    
    const statusCounts = {};
    verifySnapshot.docs.forEach(doc => {
      const data = doc.data();
      const status = data.status;
      statusCounts[status] = (statusCounts[status] || 0) + 1;
    });
    
    console.log('📈 Status distribution:');
    Object.entries(statusCounts).forEach(([status, count]) => {
      console.log(`  - ${status}: ${count} letters`);
    });
    
    console.log('\n✅ Letters seeding completed successfully!');
    
  } catch (error) {
    console.error('❌ Error clearing and seeding letters:', error);
    throw error;
  }
}

// Run the function
clearAndSeedLetters()
  .then(() => {
    console.log('🏁 Script completed successfully');
    process.exit(0);
  })
  .catch((error) => {
    console.error('💥 Script failed:', error);
    process.exit(1);
  });