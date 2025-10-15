const admin = require('firebase-admin');
const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

// Initialize Firebase Admin SDK
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function updateUserRoles() {
  try {
    console.log('🔥 Starting Firestore role update process...');
    
    // Get all users from Firestore
    const usersSnapshot = await db.collection('users').get();
    
    if (usersSnapshot.empty) {
      console.log('❌ No users found in Firestore');
      return;
    }

    console.log(`📋 Found ${usersSnapshot.size} users to check`);
    
    let updateCount = 0;
    const batch = db.batch();

    // Role mapping to standardize formats
    const roleMapping = {
      // Current possible formats to standardized format
      'Super Admin': 'super_admin',
      'SUPER ADMIN': 'super_admin',
      'super_admin': 'super_admin',
      'super admin': 'super_admin',
      
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
      
      'Security': 'security',
      'SECURITY': 'security',
      'security': 'security',
      
      'Office Boy': 'office_boy',
      'OFFICE BOY': 'office_boy',
      'office_boy': 'office_boy',
      'office boy': 'office_boy',
      
      // Legacy roles (if any exist)
      'HR': 'hr',
      'hr': 'hr',
      'Manager': 'manager',
      'MANAGER': 'manager',
      'manager': 'manager'
    };

    usersSnapshot.forEach(doc => {
      const userData = doc.data();
      const currentRole = userData.role;
      
      console.log(`👤 Checking user: ${userData.full_name} (${userData.email})`);
      console.log(`   Current role: "${currentRole}"`);
      
      // Check if role needs to be updated
      if (roleMapping[currentRole]) {
        const standardizedRole = roleMapping[currentRole];
        
        if (currentRole !== standardizedRole) {
          console.log(`   ✅ Updating role from "${currentRole}" to "${standardizedRole}"`);
          
          batch.update(doc.ref, {
            role: standardizedRole,
            updated_at: admin.firestore.FieldValue.serverTimestamp()
          });
          
          updateCount++;
        } else {
          console.log(`   ✓ Role already standardized: "${currentRole}"`);
        }
      } else {
        console.log(`   ⚠️ Unknown role format: "${currentRole}" - setting to employee`);
        
        batch.update(doc.ref, {
          role: 'employee',
          updated_at: admin.firestore.FieldValue.serverTimestamp()
        });
        
        updateCount++;
      }
    });

    if (updateCount > 0) {
      console.log(`\n🚀 Committing ${updateCount} role updates...`);
      await batch.commit();
      console.log('✅ All role updates committed successfully!');
    } else {
      console.log('\n✓ No role updates needed - all roles are already standardized');
    }

    // Verify updates
    console.log('\n📋 VERIFICATION - Current user roles after update:');
    const updatedSnapshot = await db.collection('users').get();
    
    updatedSnapshot.forEach(doc => {
      const userData = doc.data();
      console.log(`   ${userData.full_name} (${userData.email}): role = "${userData.role}"`);
    });

    console.log('\n🎉 Role standardization completed successfully!');
    
  } catch (error) {
    console.error('❌ Error updating user roles:', error);
  } finally {
    // Close the app
    process.exit(0);
  }
}

// Run the update
updateUserRoles();