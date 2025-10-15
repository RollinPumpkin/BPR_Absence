const { initializeFirebase, getFirestore } = require('./config/database');

async function diagnosePendingLettersAPI() {
  try {
    await initializeFirebase();
    const db = getFirestore();
    
    console.log('🔍 DIAGNOSING PENDING LETTERS API ISSUE');
    console.log('=====================================\n');
    
    // 1. Check Firestore connection
    console.log('1️⃣ Testing Firestore Connection...');
    const testCollection = await db.collection('users').limit(1).get();
    console.log(`✅ Firestore connected - ${testCollection.size} test document(s) found\n`);
    
    // 2. Check pending letters query
    console.log('2️⃣ Testing Pending Letters Query...');
    const pendingQuery = db.collection('letters').where('status', '==', 'pending');
    const pendingSnapshot = await pendingQuery.get();
    console.log(`📋 Found ${pendingSnapshot.size} pending letters\n`);
    
    if (pendingSnapshot.size > 0) {
      console.log('Pending letters details:');
      pendingSnapshot.docs.forEach((doc, index) => {
        const data = doc.data();
        console.log(`${index + 1}. ${doc.id}`);
        console.log(`   Subject: ${data.subject}`);
        console.log(`   Type: ${data.letter_type}`);
        console.log(`   Sender ID: ${data.sender_id}`);
        console.log(`   Status: ${data.status}`);
        console.log(`   Created: ${data.created_at ? data.created_at.toDate() : 'N/A'}`);
        console.log('   ---');
      });
    }
    
    // 3. Test user lookup for each pending letter
    console.log('\n3️⃣ Testing User Data Lookup...');
    for (const doc of pendingSnapshot.docs) {
      const letterData = doc.data();
      const senderId = letterData.sender_id || letterData.recipient_id;
      
      if (senderId) {
        try {
          console.log(`🔍 Looking up user: ${senderId}`);
          const userDoc = await db.collection('users').doc(senderId).get();
          
          if (userDoc.exists) {
            const userData = userDoc.data();
            console.log(`   ✅ Found: ${userData.full_name} (${userData.employee_id})`);
          } else {
            console.log(`   ❌ User not found: ${senderId}`);
          }
        } catch (error) {
          console.log(`   🚨 Error looking up user ${senderId}:`, error.message);
        }
      } else {
        console.log(`   ⚠️ No sender_id found for letter ${doc.id}`);
      }
    }
    
    // 4. Test the exact query that the API uses
    console.log('\n4️⃣ Simulating API Query (with limit and ordering)...');
    try {
      const apiQuery = db.collection('letters')
        .where('status', '==', 'pending')
        .orderBy('created_at', 'desc')
        .limit(20);
      
      const apiSnapshot = await apiQuery.get();
      console.log(`📊 API simulation returned ${apiSnapshot.size} letters`);
      
      // Process like the API does
      const processedLetters = [];
      for (const doc of apiSnapshot.docs) {
        const letterData = { id: doc.id, ...doc.data() };
        
        // Get sender details like API does
        try {
          const userDoc = await db.collection('users').doc(letterData.sender_id || letterData.recipient_id).get();
          if (userDoc.exists) {
            const userData = userDoc.data();
            letterData.requester = {
              id: userDoc.id,
              full_name: userData.full_name,
              email: userData.email,
              employee_id: userData.employee_id,
              department: userData.department,
              position: userData.position
            };
            letterData.senderName = userData.full_name;
            letterData.recipientName = userData.full_name;
            letterData.recipientEmployeeId = userData.employee_id;
          }
        } catch (userError) {
          console.log(`   ⚠️ User lookup error for ${letterData.sender_id}:`, userError.message);
        }
        
        // Convert timestamps like API does
        if (letterData.created_at && typeof letterData.created_at.toDate === 'function') {
          letterData.created_at = letterData.created_at.toDate();
        }
        if (letterData.updated_at && typeof letterData.updated_at.toDate === 'function') {
          letterData.updated_at = letterData.updated_at.toDate();
        }
        
        processedLetters.push(letterData);
      }
      
      console.log(`✅ Successfully processed ${processedLetters.length} letters`);
      console.log('\nFirst processed letter sample:');
      if (processedLetters.length > 0) {
        console.log(JSON.stringify(processedLetters[0], null, 2));
      }
      
    } catch (apiError) {
      console.log('🚨 API simulation failed:', apiError);
    }
    
    // 5. Check if there are any Firestore security rules issues
    console.log('\n5️⃣ Testing Collection Access Permissions...');
    try {
      // Test write access (this might fail if security rules are restrictive)
      console.log('Testing read access to letters collection...');
      const readTest = await db.collection('letters').limit(1).get();
      console.log(`✅ Read access working - ${readTest.size} document(s) accessible`);
    } catch (permissionError) {
      console.log('🚨 Permission error:', permissionError.message);
    }
    
    console.log('\n✅ Diagnosis complete!');
    process.exit(0);
    
  } catch (error) {
    console.error('🚨 Diagnosis failed:', error);
    process.exit(1);
  }
}

diagnosePendingLettersAPI();