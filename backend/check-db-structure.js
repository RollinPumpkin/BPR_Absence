const { initializeFirebase, getFirestore } = require('./config/database');

async function checkDatabaseStructure() {
  try {
    // Initialize Firebase first
    await initializeFirebase();
    const db = getFirestore();
    
    console.log('🗄️  CHECKING DATABASE STRUCTURE');
    console.log('================================\n');
    
    // 1. Check Users Collection
    console.log('👥 USERS COLLECTION:');
    const usersSnapshot = await db.collection('users').limit(5).get();
    console.log(`Total users: ${usersSnapshot.size}`);
    
    if (usersSnapshot.size > 0) {
      const firstUser = usersSnapshot.docs[0];
      console.log('\nSample user structure:');
      console.log('Document ID:', firstUser.id);
      console.log('Fields:', Object.keys(firstUser.data()));
      console.log('Sample data:', JSON.stringify(firstUser.data(), null, 2));
    }
    
    // 2. Check Letters Collection
    console.log('\n\n📄 LETTERS COLLECTION:');
    const lettersSnapshot = await db.collection('letters').limit(5).get();
    console.log(`Total letters: ${lettersSnapshot.size}`);
    
    if (lettersSnapshot.size > 0) {
      const firstLetter = lettersSnapshot.docs[0];
      console.log('\nSample letter structure:');
      console.log('Document ID:', firstLetter.id);
      console.log('Fields:', Object.keys(firstLetter.data()));
      console.log('Sample data:', JSON.stringify(firstLetter.data(), null, 2));
    }
    
    // 3. Check Letter Templates Collection
    console.log('\n\n📋 LETTER_TEMPLATES COLLECTION:');
    const templatesSnapshot = await db.collection('letter_templates').limit(5).get();
    console.log(`Total templates: ${templatesSnapshot.size}`);
    
    if (templatesSnapshot.size > 0) {
      const firstTemplate = templatesSnapshot.docs[0];
      console.log('\nSample template structure:');
      console.log('Document ID:', firstTemplate.id);
      console.log('Fields:', Object.keys(firstTemplate.data()));
      console.log('Sample data:', JSON.stringify(firstTemplate.data(), null, 2));
    }
    
    // 4. Check Attendance Collection (if exists)
    console.log('\n\n⏰ ATTENDANCE COLLECTION:');
    try {
      const attendanceSnapshot = await db.collection('attendance').limit(5).get();
      console.log(`Total attendance records: ${attendanceSnapshot.size}`);
      
      if (attendanceSnapshot.size > 0) {
        const firstAttendance = attendanceSnapshot.docs[0];
        console.log('\nSample attendance structure:');
        console.log('Document ID:', firstAttendance.id);
        console.log('Fields:', Object.keys(firstAttendance.data()));
        console.log('Sample data:', JSON.stringify(firstAttendance.data(), null, 2));
      }
    } catch (error) {
      console.log('No attendance collection found or access denied');
    }
    
    // 5. List all collections
    console.log('\n\n📚 ALL COLLECTIONS:');
    const collections = await db.listCollections();
    console.log('Available collections:');
    collections.forEach((collection, index) => {
      console.log(`${index + 1}. ${collection.id}`);
    });
    
    // 6. Check Letter Status Distribution
    console.log('\n\n📊 LETTER STATUS DISTRIBUTION:');
    const allLetters = await db.collection('letters').get();
    const statusCount = {};
    
    allLetters.docs.forEach(doc => {
      const status = doc.data().status || 'unknown';
      statusCount[status] = (statusCount[status] || 0) + 1;
    });
    
    console.log('Status distribution:');
    Object.entries(statusCount).forEach(([status, count]) => {
      console.log(`- ${status}: ${count}`);
    });
    
    // 7. Check User Roles Distribution
    console.log('\n\n👤 USER ROLES DISTRIBUTION:');
    const allUsers = await db.collection('users').get();
    const roleCount = {};
    
    allUsers.docs.forEach(doc => {
      const role = doc.data().role || 'unknown';
      roleCount[role] = (roleCount[role] || 0) + 1;
    });
    
    console.log('Role distribution:');
    Object.entries(roleCount).forEach(([role, count]) => {
      console.log(`- ${role}: ${count}`);
    });
    
    process.exit(0);
  } catch (error) {
    console.error('Error checking database structure:', error);
    process.exit(1);
  }
}

checkDatabaseStructure();