const admin = require('firebase-admin');
const axios = require('axios');
const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

// Initialize Firebase Admin SDK
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

const db = admin.firestore();

async function testRealAdminLogin() {
  try {
    console.log('🔍 REAL ADMIN LOGIN FLOW TEST');
    console.log('=============================');
    
    const testCredentials = [
      {
        email: 'admin@gmail.com',
        password: '123456',
        description: 'Super Admin Test'
      },
      {
        email: 'test@bpr.com',
        password: '123456',
        description: 'Test Admin'
      }
    ];

    // Test server availability first
    try {
      console.log('🌐 Testing backend server availability...');
      const healthResponse = await axios.get('http://localhost:3000/health', { timeout: 5000 });
      console.log('✅ Backend server is running');
    } catch (error) {
      console.log('❌ Backend server is not available. Testing database only.');
      console.log('Please start the backend server with: node server.js');
    }

    for (const cred of testCredentials) {
      console.log(`\n🧪 TESTING: ${cred.description}`);
      console.log(`📧 Email: ${cred.email}`);
      console.log('─'.repeat(50));
      
      // Step 1: Check user exists in database
      console.log('1️⃣ Checking user in Firestore database...');
      
      const userQuery = await db.collection('users')
        .where('email', '==', cred.email)
        .get();
      
      if (userQuery.empty) {
        console.log('❌ User not found in database');
        continue;
      }
      
      const userData = userQuery.docs[0].data();
      console.log('✅ User found in database');
      console.log(`   Name: ${userData.full_name}`);
      console.log(`   Employee ID: ${userData.employee_id}`);
      console.log(`   Role: "${userData.role}"`);
      console.log(`   Status: ${userData.status || 'active'}`);
      
      // Step 2: Test API login endpoint
      console.log('\n2️⃣ Testing API login endpoint...');
      
      try {
        const loginResponse = await axios.post('http://localhost:3000/api/auth/login', {
          email: cred.email,
          password: cred.password
        }, {
          timeout: 10000,
          headers: {
            'Content-Type': 'application/json'
          }
        });
        
        console.log('✅ API login successful');
        console.log(`   Status: ${loginResponse.status}`);
        
        const responseData = loginResponse.data;
        console.log(`   Response keys: [${Object.keys(responseData).join(', ')}]`);
        
        if (responseData.success) {
          console.log('✅ Login marked as successful in response');
          
          if (responseData.data) {
            const apiUserData = responseData.data.user || responseData.data;
            console.log('📋 API User Data:');
            console.log(`   ID: ${apiUserData.id}`);
            console.log(`   Employee ID: "${apiUserData.employee_id}"`);
            console.log(`   Full Name: ${apiUserData.full_name}`);
            console.log(`   Email: ${apiUserData.email}`);
            console.log(`   Role: "${apiUserData.role}"`);
            console.log(`   Role Type: ${typeof apiUserData.role}`);
            console.log(`   Role Length: ${apiUserData.role?.length}`);
            
            // Step 3: Simulate Flutter User.fromJson parsing
            console.log('\n3️⃣ Simulating Flutter User.fromJson parsing...');
            
            const parsedEmployeeId = apiUserData.employee_id?.toString() || '';
            const parsedRole = apiUserData.role?.toString() || 'employee';
            
            console.log(`   Parsed Employee ID: "${parsedEmployeeId}"`);
            console.log(`   Parsed Role: "${parsedRole}"`);
            
            // Step 4: Simulate Flutter routing logic
            console.log('\n4️⃣ Simulating Flutter routing logic...');
            
            let routeDestination;
            const normalizedRole = parsedRole.toLowerCase().trim();
            
            console.log(`   Normalized Role: "${normalizedRole}"`);
            
            switch (normalizedRole) {
              case 'super_admin':
              case 'admin':
              case 'hr':
              case 'manager':
                routeDestination = '/admin/dashboard';
                console.log(`🎯 ROLE ROUTING: ${parsedRole} → Admin Dashboard`);
                break;
              
              case 'employee':
              case 'account_officer':
              case 'security':
              case 'office_boy':
              default:
                routeDestination = '/user/dashboard';
                console.log(`🎯 ROLE ROUTING: ${parsedRole} → User Dashboard`);
                break;
            }
            
            console.log(`📍 Final Route: ${routeDestination}`);
            
            // Step 5: Check if routing matches expectation
            console.log('\n5️⃣ Verifying routing expectation...');
            
            const isAdminEmail = cred.email.includes('admin') || cred.email === 'test@bpr.com';
            const routesToAdmin = routeDestination === '/admin/dashboard';
            
            console.log(`   Is Admin Email: ${isAdminEmail}`);
            console.log(`   Routes to Admin: ${routesToAdmin}`);
            
            if (isAdminEmail && routesToAdmin) {
              console.log('✅ SUCCESS: Admin user correctly routed to admin dashboard');
            } else if (isAdminEmail && !routesToAdmin) {
              console.log('🚨 PROBLEM: Admin user incorrectly routed to user dashboard!');
              console.log('🔧 Debug Info:');
              console.log(`   - Raw Role from API: "${apiUserData.role}"`);
              console.log(`   - Parsed Role: "${parsedRole}"`);
              console.log(`   - Normalized Role: "${normalizedRole}"`);
              console.log(`   - Expected: /admin/dashboard`);
              console.log(`   - Actual: ${routeDestination}`);
            } else if (!isAdminEmail && !routesToAdmin) {
              console.log('✅ SUCCESS: Employee user correctly routed to user dashboard');
            } else {
              console.log('🚨 PROBLEM: Employee user incorrectly routed to admin dashboard!');
            }
            
            // Step 6: Check token
            if (responseData.data.token) {
              console.log('\n6️⃣ Token verification...');
              console.log(`   Token provided: Yes (${responseData.data.token.substring(0, 20)}...)`);
            } else {
              console.log('\n6️⃣ Token verification...');
              console.log('   Token provided: No');
            }
            
          } else {
            console.log('❌ No user data in API response');
          }
        } else {
          console.log('❌ API response marked as failed');
          console.log(`   Message: ${responseData.message}`);
        }
        
      } catch (apiError) {
        console.log('❌ API login failed');
        if (apiError.response) {
          console.log(`   Status: ${apiError.response.status}`);
          console.log(`   Error: ${apiError.response.data?.message || apiError.message}`);
        } else {
          console.log(`   Error: ${apiError.message}`);
        }
      }
      
      console.log(`\n🏁 RESULT: ${cred.description} - ${cred.email}`);
      console.log('='.repeat(50));
    }
    
    console.log('\n📊 DEBUGGING SUMMARY');
    console.log('===================');
    console.log('If admin users are being routed to user dashboard, check:');
    console.log('1. ✅ Database role values (verified above)');
    console.log('2. ✅ API response structure (tested above)');
    console.log('3. ✅ User.fromJson parsing (simulated above)');
    console.log('4. ✅ Routing logic (simulated above)');
    console.log('5. ❓ AuthProvider.login implementation');
    console.log('6. ❓ Navigator.pushReplacementNamed execution');
    console.log('7. ❓ Route registration in main.dart');
    console.log('8. ❓ Build context or navigation timing issues');
    
    console.log('\n💡 NEXT STEPS:');
    console.log('- Add more debug prints in Flutter login_page.dart');
    console.log('- Check if Navigator.pushReplacementNamed is actually called');
    console.log('- Verify route names match exactly');
    console.log('- Check for navigation context issues');
    
  } catch (error) {
    console.error('❌ Error in real admin login test:', error);
  } finally {
    process.exit(0);
  }
}

// Run the test
testRealAdminLogin();