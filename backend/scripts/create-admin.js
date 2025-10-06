const admin = require('firebase-admin');
const bcrypt = require('bcrypt');

// Initialize Firebase Admin SDK
const serviceAccount = require('../bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: `https://bpr-absens-default-rtdb.firebaseio.com/`
});

const db = admin.firestore();

const createAdminUser = async () => {
  try {
    console.log('Creating admin user...');
    
    // Check if admin already exists
    const adminSnapshot = await db.collection('users')
      .where('email', '==', 'admin@bpr.com')
      .get();
    
    if (!adminSnapshot.empty) {
      console.log('Admin user already exists, deleting and recreating...');
      // Delete existing admin
      const adminDoc = adminSnapshot.docs[0];
      await adminDoc.ref.delete();
    }
    
    // Hash password
    const hashedPassword = await bcrypt.hash('admin123', 10);
    
    // Create admin user
    const adminData = {
      full_name: 'System Administrator',
      email: 'admin@bpr.com',
      phone: '081234567890',
      employee_id: 'ADMIN001',
      password: hashedPassword,
      department: 'Management',
      position: 'System Administrator',
      role: 'admin',
      is_active: true,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
      updated_at: admin.firestore.FieldValue.serverTimestamp()
    };
    
    await db.collection('users').add(adminData);
    console.log('✅ Admin user created successfully');
    console.log('Email: admin@bpr.com');
    console.log('Password: admin123');
    
  } catch (error) {
    console.error('❌ Error creating admin user:', error);
  }
};

createAdminUser().then(() => {
  console.log('Admin creation script completed');
  process.exit(0);
}).catch(error => {
  console.error('Script error:', error);
  process.exit(1);
});