// Check assignments data structure
const { getFirestore } = require('./backend/config/database');

async function checkAssignments() {
  try {
    const db = getFirestore();
    const snapshot = await db.collection('assignments').limit(3).get();
    
    console.log('Total assignments:', snapshot.size);
    
    snapshot.forEach(doc => {
      const data = doc.data();
      console.log('\nAssignment:', doc.id);
      console.log('Data:', JSON.stringify(data, null, 2));
    });
  } catch (error) {
    console.error('Error:', error.message);
  }
}

checkAssignments();