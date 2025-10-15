const admin = require('firebase-admin');
const bcrypt = require('bcryptjs');

// Initialize Firebase Admin SDK
const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();
const auth = admin.auth();

async function fixAdminRoles() {
  console.log('🔧 Fixing admin roles in database...');
  
  try {
    // 1. Fix admin@gmail.com role in Firestore
    console.log('\n📝 Step 1: Updating admin@gmail.com role...');
    
    const usersRef = db.collection('users');
    const adminQuery = await usersRef.where('email', '==', 'admin@gmail.com').get();
    
    if (!adminQuery.empty) {
      const adminDoc = adminQuery.docs[0];
      await adminDoc.ref.update({
        role: 'super_admin',
        full_name: 'Super Administrator',
        employee_id: 'SUP001',
        status: 'active',
        is_active: true,
        updated_at: admin.firestore.FieldValue.serverTimestamp()
      });
      console.log('✅ Updated admin@gmail.com to super_admin role');
    } else {
      console.log('❌ admin@gmail.com not found in users collection');
    }
    
    // 2. Fix test@bpr.com role
    console.log('\n📝 Step 2: Updating test@bpr.com role...');
    
    const testAdminQuery = await usersRef.where('email', '==', 'test@bpr.com').get();
    
    if (!testAdminQuery.empty) {
      const testDoc = testAdminQuery.docs[0];
      await testDoc.ref.update({
        role: 'admin',
        full_name: 'Test Administrator',
        employee_id: 'ADM001',
        status: 'active',
        is_active: true,
        updated_at: admin.firestore.FieldValue.serverTimestamp()
      });
      console.log('✅ Updated test@bpr.com to admin role');
    } else {
      console.log('❌ test@bpr.com not found in users collection');
    }
    
    // 3. Create fresh admin accounts with Firebase Auth
    console.log('\n📝 Step 3: Creating fresh admin accounts...');
    
    const adminAccounts = [
      {
        email: 'superadmin@test.com',
        password: 'admin123',
        role: 'super_admin',
        full_name: 'Super Administrator Test',
        employee_id: 'SUP999'
      },
      {
        email: 'admin@test.com', 
        password: 'admin123',
        role: 'admin',
        full_name: 'Administrator Test',
        employee_id: 'ADM999'
      }
    ];
    
    for (const account of adminAccounts) {
      try {
        // Check if user exists in Firebase Auth
        let firebaseUser;
        try {
          firebaseUser = await auth.getUserByEmail(account.email);
          console.log(`ℹ️ Firebase Auth user exists: ${account.email}`);
        } catch (error) {
          // Create Firebase Auth user
          firebaseUser = await auth.createUser({
            email: account.email,
            password: account.password,
            displayName: account.full_name
          });
          console.log(`✅ Created Firebase Auth user: ${account.email}`);
        }
        
        // Hash password for Firestore
        const hashedPassword = await bcrypt.hash(account.password, 12);
        
        // Create/update Firestore document
        await db.collection('users').doc(firebaseUser.uid).set({
          email: account.email,
          password: hashedPassword,
          role: account.role,
          full_name: account.full_name,
          employee_id: account.employee_id,
          status: 'active',
          is_active: true,
          firebase_uid: firebaseUser.uid,
          created_at: admin.firestore.FieldValue.serverTimestamp(),
          updated_at: admin.firestore.FieldValue.serverTimestamp()
        });
        
        console.log(`✅ Created/updated Firestore user: ${account.email} (${account.role})`);
        
      } catch (error) {
        console.error(`❌ Error creating account ${account.email}:`, error.message);
      }
    }
    
    // 4. List all admin accounts
    console.log('\n📋 Step 4: Listing all admin accounts...');
    
    const allAdminsQuery = await usersRef.where('role', 'in', ['super_admin', 'admin']).get();
    
    console.log(`\n🔍 Found ${allAdminsQuery.size} admin accounts:`);
    allAdminsQuery.forEach(doc => {
      const data = doc.data();
      console.log(`📧 ${data.email} | Role: ${data.role} | Name: ${data.full_name} | ID: ${data.employee_id}`);
    });
    
    console.log('\n✅ Admin role fix completed!');
    console.log('\n🧪 Test these credentials:');
    console.log('   superadmin@test.com / admin123 → super_admin');
    console.log('   admin@test.com / admin123 → admin');
    console.log('   admin@gmail.com / 123456 → super_admin');
    console.log('   test@bpr.com / 123456 → admin');
    
  } catch (error) {
    console.error('❌ Error fixing admin roles:', error);
  }
}

// Run the fix
fixAdminRoles().then(() => {
  console.log('\n🏁 Script completed');
  process.exit(0);
}).catch(error => {
  console.error('❌ Script failed:', error);
  process.exit(1);
});