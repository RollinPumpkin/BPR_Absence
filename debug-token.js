const { initializeFirebase, getFirestore } = require('./backend/config/database');

async function checkToken() {
  try {
    // Initialize Firebase
    initializeFirebase();
    const db = getFirestore();
    
    const email = 'septapuma@gmail.com';
    const token = 't0ljqeh6cb8netryhlicb';
    
    console.log('🔍 Checking token validation...');
    console.log(`📧 Email: ${email}`);
    console.log(`🔑 Token: ${token}`);
    console.log('');
    
    // Check exact query that backend uses
    const resetDoc = await db.collection('password_resets')
      .where('email', '==', email)
      .where('token', '==', token)
      .get();
    
    console.log(`📊 Query results: ${resetDoc.size} documents found`);
    
    if (resetDoc.empty) {
      console.log('❌ No documents match the query');
      
      // Let's check all tokens for this email
      console.log('\n🔍 Checking all tokens for this email...');
      const allTokens = await db.collection('password_resets')
        .where('email', '==', email)
        .get();
      
      console.log(`📊 Found ${allTokens.size} tokens for ${email}:`);
      
      allTokens.forEach((doc, index) => {
        const data = doc.data();
        const isExpired = data.expires_at && new Date() > data.expires_at.toDate();
        
        console.log(`\n${index + 1}. Token: ${data.token}`);
        console.log(`   Used: ${data.used}`);
        console.log(`   Expires: ${data.expires_at?.toDate()}`);
        console.log(`   Is Expired: ${isExpired}`);
        console.log(`   Matches: ${data.token === token}`);
      });
      
    } else {
      console.log('✅ Token found in database');
      
      resetDoc.forEach((doc) => {
        const data = doc.data();
        const isExpired = data.expires_at && new Date() > data.expires_at.toDate();
        
        console.log('\n📋 Token Details:');
        console.log(`   Email: ${data.email}`);
        console.log(`   Token: ${data.token}`);
        console.log(`   Used: ${data.used}`);
        console.log(`   Created: ${data.created_at?.toDate()}`);
        console.log(`   Expires: ${data.expires_at?.toDate()}`);
        console.log(`   Current Time: ${new Date()}`);
        console.log(`   Is Expired: ${isExpired}`);
        
        if (data.used) {
          console.log('❌ Token has been used');
        } else if (isExpired) {
          console.log('❌ Token has expired');
        } else {
          console.log('✅ Token is valid');
        }
      });
    }
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  }
}

// Run the function
checkToken();