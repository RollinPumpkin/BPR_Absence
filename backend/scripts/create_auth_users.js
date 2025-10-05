const admin = require('firebase-admin');
const bcrypt = require('bcryptjs');

// Initialize Firebase Admin (menggunakan file yang sudah ada)
const serviceAccount = require('../bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://bpr-absens-default-rtdb.firebaseio.com"
});

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

// Function to update Firestore user with Firebase UID and password hash
async function updateFirestoreUser(firestoreUserId, firebaseUid, hashedPassword) {
  try {
    await db.collection('users').doc(firestoreUserId).update({
      firebase_uid: firebaseUid,
      password: hashedPassword,
      updated_at: admin.firestore.Timestamp.now()
    });
    console.log(`✅ Updated Firestore user ${firestoreUserId} with Firebase UID`);
  } catch (error) {
    console.error(`❌ Error updating Firestore user ${firestoreUserId}:`, error.message);
  }
}

// User data with passwords
const usersWithPasswords = [
  {
    firestoreId: 'FBRpLyTyvIpGqGYdNURK',
    email: 'ahmad.wijaya@bpr.com',
    password: 'password123',
    displayName: 'Ahmad Wijaya'
  },
  {
    firestoreId: 'admin_001',
    email: 'sarah.manager@bpr.com',
    password: 'admin123456',
    displayName: 'Dr. Sarah Manager'
  },
  {
    firestoreId: 'user_002',
    email: 'siti.rahayu@bpr.com',
    password: 'password123',
    displayName: 'Siti Rahayu'
  },
  {
    firestoreId: 'user_003',
    email: 'budi.santoso@bpr.com',
    password: 'password123',
    displayName: 'Budi Santoso'
  }
];

async function createUsersWithAuth() {
  try {
    console.log('🚀 Creating Firebase Auth users for existing Firestore users...\n');

    for (const user of usersWithPasswords) {
      console.log(`\n📝 Processing user: ${user.email}`);
      
      // Create Firebase Auth user
      const firebaseUid = await createFirebaseAuthUser(
        user.email, 
        user.password, 
        user.displayName
      );
      
      if (firebaseUid) {
        // Hash password for Firestore
        const hashedPassword = await bcrypt.hash(user.password, 12);
        
        // Update Firestore user document
        await updateFirestoreUser(user.firestoreId, firebaseUid, hashedPassword);
        
        console.log(`✅ User ${user.email} setup complete!`);
        console.log(`   - Firebase UID: ${firebaseUid}`);
        console.log(`   - Password: ${user.password}`);
      }
    }

    console.log('\n🎉 All users have been created successfully!');
    console.log('\n📋 Login Credentials:');
    console.log('==========================================');
    
    usersWithPasswords.forEach(user => {
      console.log(`Email: ${user.email}`);
      console.log(`Password: ${user.password}`);
      console.log(`Name: ${user.displayName}`);
      console.log('------------------------------------------');
    });

  } catch (error) {
    console.error('❌ Error during user creation:', error);
  } finally {
    process.exit(0);
  }
}

createUsersWithAuth();