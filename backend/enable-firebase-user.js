const { getAuth, initializeFirebase } = require('./config/database');

async function enableFirebaseUser() {
  try {
    // Initialize Firebase first
    await initializeFirebase();
    
    // We'll try to test login directly
    console.log('🧪 Testing direct login with Firebase Auth...');
    
    const auth = getAuth();
    
    // Create a new test user if needed
    const email = 'test@bpr.com';
    const password = '123456';
    
    try {
      // Try to get existing user
      const existingUser = await auth.getUserByEmail(email);
      console.log(`📍 User found: ${existingUser.uid}`);
      console.log(`   Disabled: ${existingUser.disabled}`);
      
      if (existingUser.disabled) {
        console.log('🔄 Enabling user...');
        await auth.updateUser(existingUser.uid, { disabled: false });
        console.log('✅ User enabled');
      } else {
        console.log('✅ User already enabled');
      }
      
    } catch (error) {
      if (error.code === 'auth/user-not-found') {
        console.log('📝 Creating new user...');
        const newUser = await auth.createUser({
          email: email,
          password: password,
          disabled: false
        });
        console.log(`✅ User created: ${newUser.uid}`);
      } else {
        throw error;
      }
    }
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  }
}

enableFirebaseUser();