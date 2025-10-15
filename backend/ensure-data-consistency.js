const admin = require('firebase-admin');
const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

// Initialize Firebase Admin SDK if not already initialized
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

const db = admin.firestore();

async function ensureDataConsistency() {
  try {
    console.log('🔧 ENSURING COMPLETE DATA CONSISTENCY');
    console.log('====================================');
    
    // Get all users from Firestore
    const usersSnapshot = await db.collection('users').get();
    
    if (usersSnapshot.empty) {
      console.log('❌ No users found in Firestore');
      return;
    }

    console.log(`📋 Found ${usersSnapshot.size} users to check and standardize`);
    
    let updateCount = 0;
    const batch = db.batch();

    // Complete role standardization mapping
    const roleStandardization = {
      // All possible variations → standard format
      'Super Admin': 'super_admin',
      'SUPER ADMIN': 'super_admin', 
      'super_admin': 'super_admin',
      'super admin': 'super_admin',
      'SuperAdmin': 'super_admin',
      
      'Admin': 'admin',
      'ADMIN': 'admin',
      'admin': 'admin',
      
      'Employee': 'employee',
      'EMPLOYEE': 'employee',
      'employee': 'employee',
      
      'Account Officer': 'account_officer',
      'ACCOUNT OFFICER': 'account_officer',
      'account_officer': 'account_officer',
      'account officer': 'account_officer',
      'AccountOfficer': 'account_officer',
      
      'Security': 'security',
      'SECURITY': 'security',
      'security': 'security',
      
      'Office Boy': 'office_boy',
      'OFFICE BOY': 'office_boy',
      'office_boy': 'office_boy',
      'office boy': 'office_boy',
      'OfficeBoy': 'office_boy',
      
      // Legacy roles (maintain for existing users)
      'HR': 'hr',
      'hr': 'hr',
      'Manager': 'manager',
      'MANAGER': 'manager',
      'manager': 'manager'
    };

    console.log('\n📋 CHECKING EACH USER:');
    console.log('======================');

    usersSnapshot.forEach(doc => {
      const userData = doc.data();
      const currentRole = userData.role;
      const employeeId = userData.employee_id;
      const email = userData.email;
      
      console.log(`\n👤 User: ${userData.full_name}`);
      console.log(`   📧 Email: ${email}`);
      console.log(`   🆔 Employee ID: ${employeeId}`);
      console.log(`   🎯 Current Role: "${currentRole}"`);
      
      // Standardize role if needed
      if (roleStandardization[currentRole]) {
        const standardRole = roleStandardization[currentRole];
        
        if (currentRole !== standardRole) {
          console.log(`   🔄 Updating role: "${currentRole}" → "${standardRole}"`);
          
          batch.update(doc.ref, {
            role: standardRole,
            updated_at: admin.firestore.FieldValue.serverTimestamp()
          });
          
          updateCount++;
        } else {
          console.log(`   ✅ Role already standard: "${currentRole}"`);
        }
      } else {
        console.log(`   ⚠️ Unknown role: "${currentRole}" - setting to employee`);
        
        batch.update(doc.ref, {
          role: 'employee',
          updated_at: admin.firestore.FieldValue.serverTimestamp()
        });
        
        updateCount++;
      }
      
      // Check expected routing
      let expectedRoute;
      const roleForRouting = roleStandardization[currentRole] || 'employee';
      
      switch (roleForRouting.toLowerCase()) {
        case 'super_admin':
        case 'admin':
        case 'hr':
        case 'manager':
          expectedRoute = '/admin/dashboard';
          break;
        case 'employee':
        case 'account_officer':
        case 'security':
        case 'office_boy':
        default:
          expectedRoute = '/user/dashboard';
      }
      
      console.log(`   📍 Expected Route: ${expectedRoute}`);
    });

    // Commit updates if any
    if (updateCount > 0) {
      console.log(`\n🚀 Committing ${updateCount} role updates...`);
      await batch.commit();
      console.log('✅ All role updates committed successfully!');
    } else {
      console.log('\n✅ No updates needed - all roles already standardized');
    }

    // Final verification - show current state
    console.log('\n📊 FINAL VERIFICATION - CURRENT USER ROLES:');
    console.log('============================================');
    
    const finalSnapshot = await db.collection('users').get();
    
    let adminUsers = [];
    let employeeUsers = [];
    
    finalSnapshot.forEach(doc => {
      const userData = doc.data();
      const role = userData.role;
      const employeeId = userData.employee_id;
      const email = userData.email;
      
      if (['super_admin', 'admin', 'hr', 'manager'].includes(role)) {
        adminUsers.push({
          name: userData.full_name,
          email: email,
          role: role,
          employeeId: employeeId,
          route: '/admin/dashboard'
        });
      } else {
        employeeUsers.push({
          name: userData.full_name,
          email: email, 
          role: role,
          employeeId: employeeId,
          route: '/user/dashboard'
        });
      }
    });

    console.log('\n👑 ADMIN LEVEL USERS (→ Admin Dashboard):');
    adminUsers.forEach(user => {
      console.log(`   ${user.name} (${user.email}) - Role: ${user.role} - ID: ${user.employeeId}`);
    });

    console.log('\n👤 EMPLOYEE LEVEL USERS (→ User Dashboard):');
    employeeUsers.forEach(user => {
      console.log(`   ${user.name} (${user.email}) - Role: ${user.role} - ID: ${user.employeeId}`);
    });

    console.log('\n🎯 SUMMARY:');
    console.log(`   Admin Level Users: ${adminUsers.length}`);
    console.log(`   Employee Level Users: ${employeeUsers.length}`);
    console.log(`   Total Users: ${finalSnapshot.size}`);
    
    console.log('\n✅ DATA CONSISTENCY CHECK COMPLETED!');
    
  } catch (error) {
    console.error('❌ Error ensuring data consistency:', error);
  } finally {
    process.exit(0);
  }
}

// Run the consistency check
ensureDataConsistency();