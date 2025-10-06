require('dotenv').config();
const bcrypt = require('bcrypt');
const admin = require('firebase-admin');

if (!admin.apps.length) {
  const serviceAccount = require('../bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

const db = admin.firestore();

async function createTestUser() {
  try {
    console.log('Creating test user...');

    const testUserData = {
      employee_id: 'TEST001',
      full_name: 'Test User',
      email: 'user@bpr.com',
      password: await bcrypt.hash('user123', 10),
      department: 'Testing',
      position: 'Test Engineer',
      phone: '081234567890',
      role: 'employee',
      status: 'active',
      is_active: true,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
      updated_at: admin.firestore.FieldValue.serverTimestamp()
    };

    // Check if user already exists
    const existingUserQuery = await db.collection('users')
      .where('email', '==', 'user@bpr.com')
      .get();

    if (!existingUserQuery.empty) {
      console.log('Test user already exists, updating...');
      for (const doc of existingUserQuery.docs) {
        await db.collection('users').doc(doc.id).update({
          status: 'active',
          is_active: true,
          password: await bcrypt.hash('user123', 10),
          updated_at: admin.firestore.FieldValue.serverTimestamp()
        });
      }
      console.log('✅ Test user updated successfully');
    } else {
      // Create test user
      await db.collection('users').add(testUserData);
      console.log('✅ Test user created successfully');
    }

    console.log('✅ Test user created successfully');
    console.log('Email: user@bpr.com');
    console.log('Password: user123');

  } catch (error) {
    console.error('❌ Error creating test user:', error);
  }

  console.log('Test user creation script completed');
}

createTestUser();