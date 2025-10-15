const { initializeFirebase, getFirestore } = require('./config/database');

async function checkAllLetterStatuses() {
  try {
    await initializeFirebase();
    const db = getFirestore();
    
    console.log('📊 CHECKING ALL LETTER STATUSES');
    console.log('===============================\n');
    
    // Get all letters
    const allLettersSnapshot = await db.collection('letters').get();
    console.log(`Total letters in database: ${allLettersSnapshot.size}\n`);
    
    // Group by status
    const statusGroups = {};
    const lettersByStatus = {};
    
    allLettersSnapshot.docs.forEach(doc => {
      const data = doc.data();
      const status = data.status || 'unknown';
      
      if (!statusGroups[status]) {
        statusGroups[status] = 0;
        lettersByStatus[status] = [];
      }
      statusGroups[status]++;
      lettersByStatus[status].push({
        id: doc.id,
        subject: data.subject,
        type: data.letter_type,
        sender: data.sender_id,
        senderName: data.senderName,
        created: data.created_at ? data.created_at.toDate() : null,
        updated: data.updated_at ? data.updated_at.toDate() : null
      });
    });
    
    // Display status distribution
    console.log('📈 STATUS DISTRIBUTION:');
    Object.entries(statusGroups).forEach(([status, count]) => {
      const emoji = status === 'pending' ? '⏳' : 
                   status === 'approved' ? '✅' : 
                   status === 'rejected' ? '❌' : '❓';
      console.log(`${emoji} ${status.toUpperCase()}: ${count} letters`);
    });
    
    console.log('\n📋 DETAILED BREAKDOWN:\n');
    
    // Show details for each status
    Object.entries(lettersByStatus).forEach(([status, letters]) => {
      const emoji = status === 'pending' ? '⏳' : 
                   status === 'approved' ? '✅' : 
                   status === 'rejected' ? '❌' : '❓';
      
      console.log(`${emoji} ${status.toUpperCase()} LETTERS (${letters.length}):`);
      
      letters.forEach((letter, index) => {
        console.log(`   ${index + 1}. ${letter.subject}`);
        console.log(`      ID: ${letter.id}`);
        console.log(`      Type: ${letter.type || 'Unknown'}`);
        console.log(`      From: ${letter.senderName || 'Unknown'}`);
        console.log(`      Created: ${letter.created ? letter.created.toLocaleString('id-ID') : 'Unknown'}`);
        console.log(`      Updated: ${letter.updated ? letter.updated.toLocaleString('id-ID') : 'Unknown'}`);
        console.log('      ---');
      });
      console.log('');
    });
    
    // Summary for admin dashboard
    console.log('🎯 SUMMARY FOR ADMIN DASHBOARD:');
    console.log(`├─ Pending (requires action): ${statusGroups.pending || 0}`);
    console.log(`├─ Approved (completed): ${statusGroups.approved || 0}`);
    console.log(`├─ Rejected (declined): ${statusGroups.rejected || 0}`);
    console.log(`└─ Total processed: ${allLettersSnapshot.size}`);
    
    // Test recommendation
    if (statusGroups.pending > 0) {
      console.log(`\n💡 TESTING RECOMMENDATION:`);
      console.log(`Admin dashboard should display ${statusGroups.pending} pending letters for approval.`);
      console.log(`Letters can be approved/rejected via the web interface.`);
    } else {
      console.log(`\n✨ All letters have been processed! No pending approvals.`);
    }
    
    process.exit(0);
    
  } catch (error) {
    console.error('Error checking letter statuses:', error);
    process.exit(1);
  }
}

checkAllLetterStatuses();