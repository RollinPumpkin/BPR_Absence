/**
 * Cleanup Script for Terminated Users
 * This script checks for users with status 'terminated' and optionally removes them
 * Run with: node cleanup-terminated-users.js [--dry-run | --delete]
 */

const { getFirestore } = require('./config/database');
const db = getFirestore();

async function checkTerminatedUsers() {
  try {
    console.log('🔍 Checking for terminated users in database...\n');
    
    // Get all users
    const usersSnapshot = await db.collection('users').get();
    
    const terminatedUsers = [];
    const allUsers = [];
    
    usersSnapshot.forEach(doc => {
      const data = doc.data();
      const user = {
        id: doc.id,
        employee_id: data.employee_id,
        full_name: data.full_name,
        email: data.email,
        role: data.role,
        status: data.status || 'active',
        department: data.department,
        deleted_at: data.deleted_at,
        deleted_by: data.deleted_by
      };
      
      allUsers.push(user);
      
      if (data.status === 'terminated') {
        terminatedUsers.push(user);
      }
    });
    
    console.log(`📊 Total users in database: ${allUsers.length}`);
    console.log(`🗑️  Terminated users found: ${terminatedUsers.length}\n`);
    
    if (terminatedUsers.length > 0) {
      console.log('📋 List of terminated users:\n');
      console.log('─'.repeat(100));
      terminatedUsers.forEach((user, index) => {
        console.log(`${index + 1}. ${user.full_name || 'No Name'}`);
        console.log(`   ID: ${user.id}`);
        console.log(`   Employee ID: ${user.employee_id || 'N/A'}`);
        console.log(`   Email: ${user.email || 'N/A'}`);
        console.log(`   Role: ${user.role || 'N/A'}`);
        console.log(`   Department: ${user.department || 'N/A'}`);
        console.log(`   Status: ${user.status}`);
        if (user.deleted_at) {
          console.log(`   Deleted At: ${user.deleted_at}`);
        }
        if (user.deleted_by) {
          console.log(`   Deleted By: ${user.deleted_by}`);
        }
        console.log('─'.repeat(100));
      });
    } else {
      console.log('✅ No terminated users found. Database is clean!\n');
    }
    
    return terminatedUsers;
    
  } catch (error) {
    console.error('❌ Error checking terminated users:', error);
    throw error;
  }
}

async function deleteTerminatedUsers(terminatedUsers) {
  try {
    console.log(`\n🗑️  Deleting ${terminatedUsers.length} terminated users...\n`);
    
    let deletedCount = 0;
    let failedCount = 0;
    
    for (const user of terminatedUsers) {
      try {
        await db.collection('users').doc(user.id).delete();
        console.log(`✅ Deleted: ${user.full_name} (${user.employee_id})`);
        deletedCount++;
      } catch (error) {
        console.error(`❌ Failed to delete ${user.full_name}:`, error.message);
        failedCount++;
      }
    }
    
    console.log('\n' + '═'.repeat(100));
    console.log(`📊 Deletion Summary:`);
    console.log(`   ✅ Successfully deleted: ${deletedCount}`);
    console.log(`   ❌ Failed to delete: ${failedCount}`);
    console.log('═'.repeat(100) + '\n');
    
  } catch (error) {
    console.error('❌ Error deleting terminated users:', error);
    throw error;
  }
}

async function main() {
  const args = process.argv.slice(2);
  const isDryRun = args.includes('--dry-run') || args.length === 0;
  const shouldDelete = args.includes('--delete');
  
  console.log('\n' + '═'.repeat(100));
  console.log('🧹 TERMINATED USERS CLEANUP SCRIPT');
  console.log('═'.repeat(100) + '\n');
  
  if (isDryRun) {
    console.log('ℹ️  Running in DRY RUN mode (no changes will be made)');
    console.log('ℹ️  Use --delete flag to actually delete terminated users\n');
  } else if (shouldDelete) {
    console.log('⚠️  Running in DELETE mode (terminated users will be permanently removed)');
    console.log('⚠️  This action cannot be undone!\n');
  }
  
  const terminatedUsers = await checkTerminatedUsers();
  
  if (shouldDelete && terminatedUsers.length > 0) {
    console.log('\n⏳ Starting deletion in 3 seconds...');
    console.log('   Press Ctrl+C to cancel\n');
    
    await new Promise(resolve => setTimeout(resolve, 3000));
    
    await deleteTerminatedUsers(terminatedUsers);
    console.log('✅ Cleanup completed!\n');
  } else if (terminatedUsers.length > 0) {
    console.log('\n💡 To delete these users, run:');
    console.log('   node cleanup-terminated-users.js --delete\n');
  }
  
  console.log('✅ Script completed successfully!\n');
  process.exit(0);
}

// Run the script
main().catch(error => {
  console.error('\n❌ Script failed:', error);
  process.exit(1);
});
