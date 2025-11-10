# Cleanup Terminated Users Script

This script helps you check for and clean up users with `status: 'terminated'` in the database.

## Usage

### 1. Check for terminated users (Dry Run - Safe)

```bash
cd backend
node cleanup-terminated-users.js
```

Or explicitly:

```bash
node cleanup-terminated-users.js --dry-run
```

This will:
- ✅ List all terminated users
- ✅ Show their details (name, email, employee ID, etc.)
- ✅ Show a count summary
- ❌ **NOT delete anything** (safe to run anytime)

### 2. Delete terminated users (Permanent)

```bash
node cleanup-terminated-users.js --delete
```

This will:
- ⚠️ **Permanently delete** all users with `status: 'terminated'`
- Show a 3-second countdown before deletion
- Display success/failure for each deletion
- Show a summary at the end

**Warning:** This action cannot be undone! Make sure you have a database backup if needed.

## Example Output

### Dry Run Mode:
```
═══════════════════════════════════════════════════════════════════════════
🧹 TERMINATED USERS CLEANUP SCRIPT
═══════════════════════════════════════════════════════════════════════════

ℹ️  Running in DRY RUN mode (no changes will be made)
ℹ️  Use --delete flag to actually delete terminated users

🔍 Checking for terminated users in database...

📊 Total users in database: 33
🗑️  Terminated users found: 1

📋 List of terminated users:

────────────────────────────────────────────────────────────────────────────
1. Budi Hartono
   ID: abc123xyz
   Employee ID: EMP002
   Email: budi@example.com
   Role: employee
   Department: Security
   Status: terminated
   Deleted At: 2025-11-10T10:30:00.000Z
   Deleted By: admin_user_id
────────────────────────────────────────────────────────────────────────────

💡 To delete these users, run:
   node cleanup-terminated-users.js --delete
```

### Delete Mode:
```
⚠️  Running in DELETE mode (terminated users will be permanently removed)
⚠️  This action cannot be undone!

[... same listing as above ...]

⏳ Starting deletion in 3 seconds...
   Press Ctrl+C to cancel

🗑️  Deleting 1 terminated users...

✅ Deleted: Budi Hartono (EMP002)

═══════════════════════════════════════════════════════════════════════════
📊 Deletion Summary:
   ✅ Successfully deleted: 1
   ❌ Failed to delete: 0
═══════════════════════════════════════════════════════════════════════════
```

## When to Use

1. **After fixing the backend filter** - Run once to clean up existing terminated users
2. **Regular maintenance** - Run periodically to keep the database clean
3. **After bulk deletions** - Clean up multiple soft-deleted users at once

## Safety Notes

- The dry run mode is completely safe and won't modify any data
- Delete mode gives you 3 seconds to cancel (press Ctrl+C)
- Each deletion is logged so you can see what was removed
- Failed deletions are reported separately

## What This Fixes

This addresses the issue where:
1. Admin deletes an employee → backend soft-deletes (sets `status: 'terminated'`)
2. Employee list still shows the deleted user
3. Need to manually clean up terminated users from the database

After running this script with `--delete`, all terminated users will be permanently removed from Firestore.
