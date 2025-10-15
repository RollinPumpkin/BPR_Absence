const admin = require('firebase-admin');
const bcrypt = require('bcryptjs');
const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function findAndFixTestAdmin() {
  try {
    console.log('🔍 Finding all test@bpr.com users...');
    
    const email = 'test@bpr.com';
    const password = '123456';
    
    // 1. Find all users with this email
    console.log('1️⃣ Searching for users...');
    const usersRef = db.collection('users');
    const allUsersSnapshot = await usersRef.get();
    
    console.log(`📋 Total users in database: ${allUsersSnapshot.size}`);
    
    let testUsers = [];
    allUsersSnapshot.forEach(doc => {
      const data = doc.data();
      if (data.email === email) {
        testUsers.push({ id: doc.id, ...data });
      }
    });
    
    console.log(`👤 Found ${testUsers.length} users with email ${email}:`);
    
    testUsers.forEach((user, index) => {
      console.log(`\n   User ${index + 1}:`);
      console.log(`   📄 Document ID: ${user.id}`);
      console.log(`   📧 Email: ${user.email}`);
      console.log(`   👤 Name: ${user.full_name || 'undefined'}`);
      console.log(`   🆔 Employee ID: ${user.employee_id || 'undefined'}`);
      console.log(`   👑 Role: ${user.role || 'undefined'}`);
      console.log(`   🔥 Firebase UID: ${user.firebase_uid || 'undefined'}`);
      console.log(`   🔑 Has password: ${user.password ? 'YES' : 'NO'}`);
      console.log(`   ✅ Active: ${user.is_active}`);
    });
    
    // 2. Create proper hash for all test users
    console.log('\n2️⃣ Fixing password hash for all test@bpr.com users...');
    const hashedPassword = await bcrypt.hash(password, 10);
    console.log(`🔑 Generated hash: ${hashedPassword}`);
    
    // Test the hash
    const hashTest = await bcrypt.compare(password, hashedPassword);
    console.log(`🧪 Hash verification test: ${hashTest ? '✅ PASS' : '❌ FAIL'}`);
    
    // 3. Update all test users
    for (let i = 0; i < testUsers.length; i++) {
      const user = testUsers[i];
      console.log(`\n3️⃣ Updating user ${i + 1} (${user.id})...`);
      
      const updateData = {
        full_name: user.full_name || 'Test Admin',
        employee_id: user.employee_id || 'TADM001',
        role: 'admin',
        password: hashedPassword,
        is_active: true,
        updated_at: admin.firestore.FieldValue.serverTimestamp()
      };
      
      await db.collection('users').doc(user.id).update(updateData);
      console.log(`✅ Updated user ${user.id}`);
    }
    
    // 4. Verify updates
    console.log('\n4️⃣ Verifying updates...');
    const verifySnapshot = await usersRef.where('email', '==', email).get();
    
    verifySnapshot.forEach(doc => {
      const data = doc.data();
      console.log(`\n✅ Verified user ${doc.id}:`);
      console.log(`   📧 Email: ${data.email}`);
      console.log(`   👤 Name: ${data.full_name}`);
      console.log(`   🆔 Employee ID: ${data.employee_id}`);
      console.log(`   👑 Role: ${data.role}`);
      console.log(`   🔑 Has password: ${data.password ? 'YES' : 'NO'}`);
      console.log(`   ✅ Active: ${data.is_active}`);
    });
    
    console.log('\n🎉 SUCCESS! All test@bpr.com users fixed!');
    console.log('\n📋 Login Credentials:');
    console.log(`   📧 Email: ${email}`);
    console.log(`   🔑 Password: ${password}`);
    console.log(`   👑 Role: admin`);
    
  } catch (error) {
    console.error('❌ Error:', error);
    console.error('Error message:', error.message);
  }
}

// Run the function
findAndFixTestAdmin().then(() => {
  console.log('\n✅ Fix completed');
  process.exit(0);
}).catch((error) => {
  console.error('❌ Fix failed:', error);
  process.exit(1);
});