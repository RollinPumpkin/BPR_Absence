const admin = require('firebase-admin');
const path = require('path');

let firestore = null;
let auth = null;

// Initialize Firebase Admin SDK with optimized settings
const initializeFirebase = () => {
  try {
    // Use service account key file
    const serviceAccountPath = path.join(__dirname, '..', 'bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');
    const serviceAccount = require(serviceAccountPath);

    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      projectId: serviceAccount.project_id
    });

    // Initialize Firestore with performance settings
    firestore = admin.firestore();
    firestore.settings({
      ignoreUndefinedProperties: true,
      merge: true
    });

    // Initialize Auth
    auth = admin.auth();

    console.log('✅ Firebase Admin SDK initialized successfully');
    return true;
  } catch (error) {
    console.error('❌ Firebase initialization failed:', error.message);
    return false;
  }
};

// Get Firestore instance with singleton pattern
const getFirestore = () => {
  if (!firestore) {
    throw new Error('Firestore not initialized. Call initializeFirebase() first.');
  }
  return firestore;
};

// Get Firebase Auth instance with singleton pattern
const getAuth = () => {
  if (!auth) {
    throw new Error('Firebase Auth not initialized. Call initializeFirebase() first.');
  }
  return auth;
};

// Test Firebase connection
const testConnection = async () => {
  try {
    const db = getFirestore();
    await db.collection('test').doc('connection').set({
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      status: 'connected'
    });
    
    console.log('✅ Firebase Firestore connected successfully');
    
    // Clean up test document
    await db.collection('test').doc('connection').delete();
    
    return true;
  } catch (error) {
    console.error('❌ Firebase connection test failed:', error.message);
    return false;
  }
};

// Initialize collections structure (create indexes if needed)
const initializeCollections = async () => {
  try {
    const db = getFirestore();
    
    // Collections that will be created:
    // - users: User profiles and authentication data
    // - attendance: Daily attendance records
    // - leave_requests: Leave request submissions
    // - qr_codes: QR codes for check-in locations
    // - settings: App settings and configurations
    
    console.log('✅ Firebase collections structure ready');
    
    // Create a settings document if it doesn't exist
    const settingsRef = db.collection('settings').doc('app_config');
    const settingsDoc = await settingsRef.get();
    
    if (!settingsDoc.exists) {
      await settingsRef.set({
        app_name: 'BPR Absence Management',
        work_start_time: '08:00',
        work_end_time: '17:00',
        late_threshold_minutes: 15,
        created_at: admin.firestore.FieldValue.serverTimestamp(),
        updated_at: admin.firestore.FieldValue.serverTimestamp()
      });
      console.log('✅ App settings initialized');
    }
    
    return true;
  } catch (error) {
    console.error('❌ Collections initialization failed:', error.message);
    return false;
  }
};

// Helper function to generate custom IDs
const generateId = () => {
  return admin.firestore().collection('temp').doc().id;
};

// Helper function to get server timestamp
const getServerTimestamp = () => {
  return admin.firestore.FieldValue.serverTimestamp();
};

// Helper function to format date for Firestore
const formatDate = (date = new Date()) => {
  return date.toISOString().split('T')[0]; // YYYY-MM-DD format
};

module.exports = {
  initializeFirebase,
  getFirestore,
  getAuth,
  testConnection,
  initializeCollections,
  generateId,
  getServerTimestamp,
  formatDate,
  admin
};
