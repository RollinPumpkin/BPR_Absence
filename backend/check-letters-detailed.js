const admin = require('firebase-admin');

// Initialize Firebase if not already done
if (!admin.apps.length) {
  const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: 'https://bpr-absens-default-rtdb.firebaseio.com'
  });
}

const db = admin.firestore();

async function checkLettersDetailed() {
  try {
    console.log('📄 CHECKING LETTERS COLLECTION DETAILED');
    console.log('======================================\n');

    const lettersRef = db.collection('letters');
    const snapshot = await lettersRef.get();

    console.log(`Total letters: ${snapshot.size}\n`);

    if (snapshot.size > 0) {
      console.log('All letters with their status:');
      snapshot.forEach(doc => {
        const data = doc.data();
        console.log(`ID: ${doc.id}`);
        console.log(`  Subject: ${data.subject}`);
        console.log(`  Status: ${data.status}`);
        console.log(`  Type: ${data.letterType || data.letter_type}`);
        console.log(`  Sender: ${data.senderName || data.sender_name}`);
        console.log(`  Recipient: ${data.recipientId || data.recipient_id}`);
        console.log('  ---');
      });
      
      // Check pending letters specifically
      const pendingQuery = lettersRef.where('status', 'in', ['pending', 'waiting_approval']);
      const pendingSnapshot = await pendingQuery.get();
      console.log(`\n📝 Pending letters: ${pendingSnapshot.size}`);
      
      // Check approved/rejected letters
      const receivedQuery = lettersRef.where('status', 'in', ['approved', 'rejected', 'processed']);
      const receivedSnapshot = await receivedQuery.get();
      console.log(`📨 Received letters: ${receivedSnapshot.size}`);
      
    } else {
      console.log('❌ No letters found in the database!\n');
    }

  } catch (error) {
    console.error('❌ Error checking letters:', error);
  } finally {
    process.exit(0);
  }
}

checkLettersDetailed();