const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
const initializeFirebase = () => {
  try {
    const serviceAccount = {
      type: "service_account",
      project_id: process.env.FIREBASE_PROJECT_ID,
      private_key_id: process.env.FIREBASE_PRIVATE_KEY_ID,
      private_key: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
      client_email: process.env.FIREBASE_CLIENT_EMAIL,
      client_id: process.env.FIREBASE_CLIENT_ID,
      auth_uri: process.env.FIREBASE_AUTH_URI || "https://accounts.google.com/o/oauth2/auth",
      token_uri: process.env.FIREBASE_TOKEN_URI || "https://oauth2.googleapis.com/token",
      auth_provider_x509_cert_url: "https://www.googleapis.com/oauth2/v1/certs",
      client_x509_cert_url: process.env.FIREBASE_CLIENT_X509_CERT_URL
    };

    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      projectId: process.env.FIREBASE_PROJECT_ID
    });

    console.log('✅ Firebase Admin SDK initialized successfully');
    return true;
  } catch (error) {
    console.error('❌ Firebase initialization failed:', error.message);
    return false;
  }
};

// Get Firestore instance
const getFirestore = () => {
  return admin.firestore();
};

// Get Firebase Auth instance
const getAuth = () => {
  return admin.auth();
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
