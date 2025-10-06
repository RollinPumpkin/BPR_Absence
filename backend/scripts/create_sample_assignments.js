const admin = require('firebase-admin');

// Initialize Firebase Admin
const serviceAccount = require('../bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function createSampleAssignments() {
  try {
    const today = new Date();
    
    // Get user ID for user@gmail.com
    const usersSnapshot = await db.collection('users').where('email', '==', 'user@gmail.com').get();
    
    if (usersSnapshot.empty) {
      console.log('User not found with email: user@gmail.com');
      return;
    }

    const userDoc = usersSnapshot.docs[0];
    const userId = userDoc.id;
    
    console.log(`Creating assignments for user: ${userId}`);
    
    const sampleAssignments = [
      {
        title: 'Team Meeting',
        description: 'Weekly team sync meeting to discuss project progress',
        dueDate: admin.firestore.Timestamp.fromDate(new Date(today.getTime() + 2 * 60 * 60 * 1000)), // 2 hours from now
        assignedTo: [userId],
        priority: 'high',
        status: 'pending',
        createdBy: 'admin',
        createdAt: admin.firestore.Timestamp.now()
      },
      {
        title: 'Project Report',
        description: 'Submit monthly project status report to management',
        dueDate: admin.firestore.Timestamp.fromDate(new Date(today.getTime() + 24 * 60 * 60 * 1000)), // tomorrow
        assignedTo: [userId],
        priority: 'medium',
        status: 'pending',
        createdBy: 'admin',
        createdAt: admin.firestore.Timestamp.now()
      },
      {
        title: 'Code Review',
        description: 'Review pull requests from team members and provide feedback',
        dueDate: admin.firestore.Timestamp.fromDate(new Date(today.getTime() + 6 * 60 * 60 * 1000)), // 6 hours from now
        assignedTo: [userId],
        priority: 'low',
        status: 'pending',
        createdBy: 'admin',
        createdAt: admin.firestore.Timestamp.now()
      },
      {
        title: 'Client Presentation',
        description: 'Prepare and deliver quarterly presentation to client',
        dueDate: admin.firestore.Timestamp.fromDate(new Date(today.getTime() + 3 * 24 * 60 * 60 * 1000)), // 3 days from now
        assignedTo: [userId],
        priority: 'high',
        status: 'pending',
        createdBy: 'admin',
        createdAt: admin.firestore.Timestamp.now()
      },
      {
        title: 'Documentation Update',
        description: 'Update API documentation with latest changes',
        dueDate: admin.firestore.Timestamp.fromDate(new Date(today.getTime() + 8 * 60 * 60 * 1000)), // 8 hours from now
        assignedTo: [userId],
        priority: 'medium',
        status: 'pending',
        createdBy: 'admin',
        createdAt: admin.firestore.Timestamp.now()
      }
    ];

    const batch = db.batch();
    sampleAssignments.forEach(assignment => {
      const docRef = db.collection('assignments').doc();
      batch.set(docRef, assignment);
    });

    await batch.commit();

    console.log(`✓ Successfully created ${sampleAssignments.length} sample assignments`);
    
    // Display created assignments
    console.log('\nCreated assignments:');
    sampleAssignments.forEach((assignment, index) => {
      console.log(`${index + 1}. ${assignment.title} - Due: ${assignment.dueDate.toDate()} (${assignment.priority} priority)`);
    });

  } catch (error) {
    console.error('Error creating sample assignments:', error);
  }
}

createSampleAssignments().then(() => {
  console.log('\nScript completed');
  process.exit(0);
}).catch(error => {
  console.error('Script failed:', error);
  process.exit(1);
});