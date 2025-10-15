const admin = require('firebase-admin');
const bcrypt = require('bcryptjs');
const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function debugUserLogin() {
  try {
    console.log('🔍 Debugging test@bpr.com login...');
    
    const email = 'test@bpr.com';
    const password = '123456';
    
    // 1. Find user in Firestore
    console.log('1️⃣ Finding user in Firestore...');
    const usersRef = db.collection('users');
    const userQuery = await usersRef.where('email', '==', email).get();
    
    if (userQuery.empty) {
      console.log('❌ User not found in Firestore');
      return;
    }
    
    const userDoc = userQuery.docs[0];
    const user = { id: userDoc.id, ...userDoc.data() };
    
    console.log('✅ User found:');
    console.log(`   📧 Email: ${user.email}`);
    console.log(`   👤 Name: ${user.full_name}`);
    console.log(`   🆔 ID: ${user.id}`);
    console.log(`   👑 Role: ${user.role}`);
    console.log(`   ✅ Active: ${user.is_active}`);
    console.log(`   🔑 Has password: ${user.password ? 'YES' : 'NO'}`);
    
    if (user.password) {
      console.log(`   🔑 Password hash: ${user.password.substring(0, 20)}...`);
    }
    
    // 2. Test bcrypt comparison
    console.log('\n2️⃣ Testing password comparison...');
    console.log(`   Original password: "${password}"`);
    console.log(`   Stored hash: "${user.password}"`);
    console.log(`   Password type: ${typeof password}`);
    console.log(`   Hash type: ${typeof user.password}`);
    console.log(`   Password length: ${password ? password.length : 'null'}`);
    console.log(`   Hash defined: ${user.password !== undefined}`);
    
    if (!user.password) {
      console.log('❌ Password hash is missing or undefined');
      return;
    }
    
    if (!password) {
      console.log('❌ Password is missing or undefined');
      return;
    }
    
    try {
      const isValidPassword = await bcrypt.compare(password, user.password);
      console.log(`   🧪 Password comparison result: ${isValidPassword ? '✅ VALID' : '❌ INVALID'}`);
      
      if (!isValidPassword) {
        // Try with different password variations
        console.log('\n3️⃣ Testing password variations...');
        const variations = ['123456', ' 123456', '123456 ', 'admin123', 'test123'];
        
        for (const variation of variations) {
          try {
            const result = await bcrypt.compare(variation, user.password);
            console.log(`   Testing "${variation}": ${result ? '✅ MATCH' : '❌ NO MATCH'}`);
          } catch (e) {
            console.log(`   Testing "${variation}": ❌ ERROR - ${e.message}`);
          }
        }
      }
      
    } catch (bcryptError) {
      console.log(`❌ bcrypt.compare error: ${bcryptError.message}`);
      console.log(`Error type: ${bcryptError.constructor.name}`);
    }
    
    // 3. Generate new hash and test
    console.log('\n4️⃣ Generating fresh hash for comparison...');
    const freshHash = await bcrypt.hash(password, 10);
    console.log(`   Fresh hash: ${freshHash}`);
    
    const freshTest = await bcrypt.compare(password, freshHash);
    console.log(`   Fresh hash test: ${freshTest ? '✅ VALID' : '❌ INVALID'}`);
    
  } catch (error) {
    console.error('❌ Debug error:', error);
    console.error('Error message:', error.message);
    console.error('Error stack:', error.stack);
  }
}

// Run debug
debugUserLogin().then(() => {
  console.log('\n✅ Debug completed');
  process.exit(0);
}).catch((error) => {
  console.error('❌ Debug failed:', error);
  process.exit(1);
});