const { initializeFirebase, getFirestore } = require('./config/database');

async function checkLetters() {
  try {
    await initializeFirebase();
    const db = getFirestore();
    
    console.log('🔍 Checking letters collection...');
    
    // Get all letters
    const allLettersSnapshot = await db.collection('letters').get();
    console.log(`📊 Found ${allLettersSnapshot.size} total letters`);
    
    // Get pending letters
    const pendingSnapshot = await db.collection('letters').where('status', '==', 'pending').get();
    console.log(`⏳ Found ${pendingSnapshot.size} pending letters`);
    
    pendingSnapshot.forEach(doc => {
      const data = doc.data();
      console.log(`📝 Letter ID: ${doc.id}`);
      console.log(`   Subject: ${data.subject}`);
      console.log(`   Status: ${data.status}`);
      console.log(`   Type: ${data.letter_type}`);
      console.log(`   Sender: ${data.sender_id}`);
      console.log(`   Created: ${data.created_at ? data.created_at.toDate() : 'N/A'}`);
      console.log('');
    });
    
  } catch (error) {
    console.error('❌ Error:', error);
  }
}

checkLetters();