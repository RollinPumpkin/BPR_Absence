const admin = require('firebase-admin');
const bcrypt = require('bcryptjs');

// Initialize Firebase Admin (menggunakan file yang sudah ada)
const serviceAccount = require('../bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

// Initialize if not already initialized
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: "https://bpr-absens-default-rtdb.firebaseio.com"
  });
}

const db = admin.firestore();
const auth = admin.auth();

// Function to create Firebase Auth user
async function createFirebaseAuthUser(email, password, displayName) {
  try {
    const userRecord = await auth.createUser({
      email: email,
      password: password,
      displayName: displayName,
      disabled: false
    });
    console.log(`✅ Firebase Auth user created: ${email} (UID: ${userRecord.uid})`);
    return userRecord.uid;
  } catch (error) {
    if (error.code === 'auth/email-already-exists') {
      console.log(`⚠️  User already exists in Firebase Auth: ${email}`);
      // Get existing user
      const existingUser = await auth.getUserByEmail(email);
      return existingUser.uid;
    } else {
      console.error(`❌ Error creating Firebase Auth user ${email}:`, error.message);
      return null;
    }
  }
}

// Function to create Firestore user document
async function createFirestoreUser(userData) {
  try {
    const docRef = await db.collection('users').add(userData);
    console.log(`✅ Firestore user document created with ID: ${docRef.id}`);
    return docRef.id;
  } catch (error) {
    console.error(`❌ Error creating Firestore user:`, error.message);
    return null;
  }
}

// New users data
const newUsers = [
  {
    email: 'user@gmail.com',
    password: 'user123',
    employee_id: 'EMP005',
    full_name: 'User Test',
    department: 'IT Department',
    position: 'Junior Developer',
    role: 'employee',
    phone: '+62815678901',
    address: 'Jl. Test User No. 123, Jakarta',
    date_of_birth: '1995-01-01',
    join_date: '2025-10-06',
  },
  {
    email: 'admin@gmail.com',
    password: 'admin123',
    employee_id: 'ADM002',
    full_name: 'Admin Test',
    department: 'Management',
    position: 'System Administrator',
    role: 'admin',
    phone: '+62816789012',
    address: 'Jl. Test Admin No. 456, Jakarta',
    date_of_birth: '1988-05-15',
    join_date: '2025-10-06',
  }
];

async function createNewUsers() {
  try {
    console.log('🚀 Creating new users...\n');

    for (const userData of newUsers) {
      console.log(`\n📝 Processing user: ${userData.email}`);
      
      // Create Firebase Auth user
      const firebaseUid = await createFirebaseAuthUser(
        userData.email, 
        userData.password, 
        userData.full_name
      );
      
      if (firebaseUid) {
        // Hash password for Firestore
        const hashedPassword = await bcrypt.hash(userData.password, 12);
        
        // Prepare Firestore user data
        const firestoreUserData = {
          employee_id: userData.employee_id,
          full_name: userData.full_name,
          email: userData.email,
          password: hashedPassword,
          phone: userData.phone,
          department: userData.department,
          position: userData.position,
          role: userData.role,
          profile_picture: null,
          address: userData.address,
          date_of_birth: userData.date_of_birth,
          join_date: userData.join_date,
          status: 'active',
          is_active: true,
          firebase_uid: firebaseUid,
          created_at: admin.firestore.Timestamp.now(),
          updated_at: admin.firestore.Timestamp.now()
        };
        
        // Create Firestore user document
        const firestoreId = await createFirestoreUser(firestoreUserData);
        
        if (firestoreId) {
          console.log(`✅ User ${userData.email} setup complete!`);
          console.log(`   - Firebase UID: ${firebaseUid}`);
          console.log(`   - Firestore ID: ${firestoreId}`);
          console.log(`   - Password: ${userData.password}`);
          console.log(`   - Role: ${userData.role}`);
        }
      }
    }

    console.log('\n🎉 All new users have been created successfully!');
    console.log('\n📋 New Login Credentials:');
    console.log('==========================================');
    
    newUsers.forEach(user => {
      console.log(`Email: ${user.email}`);
      console.log(`Password: ${user.password}`);
      console.log(`Name: ${user.full_name}`);
      console.log(`Role: ${user.role}`);
      console.log('------------------------------------------');
    });

  } catch (error) {
    console.error('❌ Error during user creation:', error);
  } finally {
    process.exit(0);
  }
}

createNewUsers();