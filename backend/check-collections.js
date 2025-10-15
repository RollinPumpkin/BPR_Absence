const { initializeFirebase, getFirestore } = require('./config/database');

async function checkCollections() {
  try {
    // Initialize Firebase first
    initializeFirebase();
    const db = getFirestore();
    
    // Check assignments
    console.log('🔍 Checking assignments collection...');
    const assignmentsSnapshot = await db.collection('assignments').get();
    console.log(`📊 Found ${assignmentsSnapshot.size} assignments`);
    
    assignmentsSnapshot.forEach(doc => {
      const data = doc.data();
      console.log(`📝 Assignment: ${doc.id}`);
      console.log(`   Title: ${data.title || 'N/A'}`);
      console.log(`   Status: ${data.status || 'N/A'}`);
      console.log(`   Assigned To: ${data.assignedTo || 'N/A'}`);
      console.log(`   Due Date: ${data.dueDate || 'N/A'}`);
      console.log(`   Created: ${data.created_at ? (data.created_at.toDate ? data.created_at.toDate() : data.created_at) : 'N/A'}`);
      console.log('---');
    });
    
    // Check attendance
    console.log('\n🔍 Checking attendance collection...');
    const attendanceSnapshot = await db.collection('attendance').limit(10).get();
    console.log(`📊 Found ${attendanceSnapshot.size} attendance records (showing first 10)`);
    
    attendanceSnapshot.forEach(doc => {
      const data = doc.data();
      console.log(`⏰ Attendance: ${doc.id}`);
      console.log(`   User ID: ${data.user_id || 'N/A'}`);
      console.log(`   Date: ${data.date || 'N/A'}`);
      console.log(`   Status: ${data.status || 'N/A'}`);
      console.log(`   Clock In: ${data.clock_in_time || 'N/A'}`);
      console.log(`   Clock Out: ${data.clock_out_time || 'N/A'}`);
      console.log(`   Location: ${data.location || 'N/A'}`);
      console.log('---');
    });
    
    // Check letter templates if exists
    console.log('\n🔍 Checking letter templates...');
    const templatesSnapshot = await db.collection('letter_templates').get();
    console.log(`📊 Found ${templatesSnapshot.size} letter templates`);
    
    templatesSnapshot.forEach(doc => {
      const data = doc.data();
      console.log(`📄 Template: ${doc.id}`);
      console.log(`   Name: ${data.name || 'N/A'}`);
      console.log(`   Type: ${data.letter_type || 'N/A'}`);
      console.log(`   Active: ${data.is_active || false}`);
      console.log('---');
    });
    
  } catch (error) {
    console.error('Error checking collections:', error);
  }
}

checkCollections();