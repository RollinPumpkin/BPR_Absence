const { initializeFirebase, getFirestore } = require('./config/database');

async function checkAdditionalCollections() {
  try {
    await initializeFirebase();
    const db = getFirestore();
    
    console.log('🔍 DETAILED COLLECTION ANALYSIS');
    console.log('===============================\n');
    
    // 1. QR Codes Collection
    console.log('📱 QR_CODES COLLECTION:');
    const qrSnapshot = await db.collection('qr_codes').get();
    console.log(`Total QR codes: ${qrSnapshot.size}`);
    
    if (qrSnapshot.size > 0) {
      console.log('\nQR Codes:');
      qrSnapshot.docs.forEach((doc, index) => {
        const data = doc.data();
        console.log(`${index + 1}. ${doc.id}`);
        console.log(`   Code: ${data.code}`);
        console.log(`   Location: ${data.location}`);
        console.log(`   Active: ${data.is_active}`);
        console.log(`   Created: ${data.created_at ? data.created_at.toDate() : 'N/A'}`);
        console.log('   ---');
      });
    }
    
    // 2. Leave Requests Collection
    console.log('\n📋 LEAVE_REQUESTS COLLECTION:');
    const leaveSnapshot = await db.collection('leave_requests').get();
    console.log(`Total leave requests: ${leaveSnapshot.size}`);
    
    if (leaveSnapshot.size > 0) {
      console.log('\nLeave Requests:');
      leaveSnapshot.docs.slice(0, 3).forEach((doc, index) => {
        const data = doc.data();
        console.log(`${index + 1}. ${doc.id}`);
        console.log(`   Employee: ${data.employee_id}`);
        console.log(`   Type: ${data.leave_type}`);
        console.log(`   Start: ${data.start_date}`);
        console.log(`   End: ${data.end_date}`);
        console.log(`   Status: ${data.status}`);
        console.log(`   Reason: ${data.reason}`);
        console.log('   ---');
      });
    }
    
    // 3. Notifications Collection
    console.log('\n🔔 NOTIFICATIONS COLLECTION:');
    const notifSnapshot = await db.collection('notifications').get();
    console.log(`Total notifications: ${notifSnapshot.size}`);
    
    if (notifSnapshot.size > 0) {
      console.log('\nRecent Notifications:');
      notifSnapshot.docs.slice(0, 3).forEach((doc, index) => {
        const data = doc.data();
        console.log(`${index + 1}. ${doc.id}`);
        console.log(`   To: ${data.user_id}`);
        console.log(`   Type: ${data.type}`);
        console.log(`   Title: ${data.title}`);
        console.log(`   Read: ${data.is_read}`);
        console.log(`   Created: ${data.created_at ? data.created_at.toDate() : 'N/A'}`);
        console.log('   ---');
      });
    }
    
    // 4. Settings Collection
    console.log('\n⚙️ SETTINGS COLLECTION:');
    const settingsSnapshot = await db.collection('settings').get();
    console.log(`Total settings: ${settingsSnapshot.size}`);
    
    if (settingsSnapshot.size > 0) {
      console.log('\nApp Settings:');
      settingsSnapshot.docs.forEach((doc, index) => {
        const data = doc.data();
        console.log(`${index + 1}. ${doc.id}`);
        console.log(`   Value: ${JSON.stringify(data, null, 4)}`);
        console.log('   ---');
      });
    }
    
    // 5. Assignments Collection
    console.log('\n📝 ASSIGNMENTS COLLECTION:');
    const assignSnapshot = await db.collection('assignments').get();
    console.log(`Total assignments: ${assignSnapshot.size}`);
    
    if (assignSnapshot.size > 0) {
      console.log('\nAssignments:');
      assignSnapshot.docs.slice(0, 3).forEach((doc, index) => {
        const data = doc.data();
        console.log(`${index + 1}. ${doc.id}`);
        console.log(`   Title: ${data.title}`);
        console.log(`   Assigned to: ${data.assigned_to}`);
        console.log(`   Status: ${data.status}`);
        console.log(`   Due: ${data.due_date}`);
        console.log('   ---');
      });
    }
    
    // 6. Detailed User Analysis
    console.log('\n👥 DETAILED USER ANALYSIS:');
    const allUsers = await db.collection('users').get();
    
    console.log('\nAll Users:');
    allUsers.docs.forEach((doc, index) => {
      const data = doc.data();
      console.log(`${index + 1}. ${data.full_name} (${data.employee_id})`);
      console.log(`   Email: ${data.email}`);
      console.log(`   Role: ${data.role}`);
      console.log(`   Department: ${data.department}`);
      console.log(`   Position: ${data.position}`);
      console.log(`   Active: ${data.is_active}`);
      console.log(`   Firebase UID: ${data.firebase_uid || 'Not linked'}`);
      console.log('   ---');
    });
    
    process.exit(0);
  } catch (error) {
    console.error('Error checking additional collections:', error);
    process.exit(1);
  }
}

checkAdditionalCollections();