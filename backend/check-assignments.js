const admin = require('firebase-admin');
const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function checkAssignments() {
  try {
    console.log('🔍 Memeriksa semua assignment di Firestore...\n');
    
    const assignmentsSnapshot = await db.collection('assignments').get();
    
    console.log(`📋 Total assignment: ${assignmentsSnapshot.docs.length}\n`);
    
    assignmentsSnapshot.forEach((doc, index) => {
      const data = doc.data();
      
      console.log(`${index + 1}. ID: ${doc.id}`);
      console.log(`   Title: ${data.title}`);
      console.log(`   Status: ${data.status}`);
      console.log(`   Priority: ${data.priority}`);
      
      if (data.dueDate) {
        const dueDate = data.dueDate.toDate ? data.dueDate.toDate() : new Date(data.dueDate);
        console.log(`   Due Date: ${dueDate.toLocaleString('id-ID')}`);
      }
      
      // Check completion data
      console.log(`   ✓ completionTime: ${data.completionTime || 'null'}`);
      console.log(`   ✓ completionDate: ${data.completionDate || 'null'}`);
      console.log(`   ✓ completedAt: ${data.completedAt ? (data.completedAt.toDate ? data.completedAt.toDate().toLocaleString('id-ID') : data.completedAt) : 'null'}`);
      console.log(`   ✓ completedBy: ${data.completedBy || 'null'}`);
      console.log('');
    });
    
    // Count by status
    const statuses = {};
    assignmentsSnapshot.forEach(doc => {
      const status = doc.data().status || 'unknown';
      statuses[status] = (statuses[status] || 0) + 1;
    });
    
    console.log('📊 Ringkasan Status:');
    Object.entries(statuses).forEach(([status, count]) => {
      console.log(`   ${status}: ${count}`);
    });
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

checkAssignments();
