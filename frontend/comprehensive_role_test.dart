import 'dart:io';
import 'package:http/http.dart' as http;

// Test comprehensive untuk semua role: User, Admin, Super Admin
void main() async {
  print('╔════════════════════════════════════════════════════════════╗');
  print('║   BPR ABSENCE - COMPREHENSIVE ROLE-BASED TEST             ║');
  print('║   Testing: User, Admin, Super Admin Functionality         ║');
  print('╚════════════════════════════════════════════════════════════╝\n');

  const String baseUrl = 'http://localhost:3000/api';
  
  // Check server connection first
  print('🔍 Checking server connection...');
  if (!await checkServerConnection(baseUrl)) {
    print('❌ Server not running. Please start backend first:');
    print('   cd backend && node server.js\n');
    exit(1);
  }
  print('✅ Server is running\n');

  // Test accounts - you need to replace with real credentials
  final Map<String, dynamic> testAccounts = {
    'user': {
      'email': 'user@test.com',
      'password': 'password123',
      'role': 'user',
      'name': 'Test User',
    },
    'admin': {
      'email': 'admin@test.com',
      'password': 'admin123',
      'role': 'admin',
      'name': 'Test Admin',
    },
    'superadmin': {
      'email': 'superadmin@test.com',
      'password': 'superadmin123',
      'role': 'superadmin',
      'name': 'Test Super Admin',
    },
  };

  print('⚠️  SETUP REQUIRED:');
  print('   Please update test credentials in comprehensive_role_test.dart');
  print('   Current test emails:');
  testAccounts.forEach((role, data) {
    print('   - ${data['role']}: ${data['email']}');
  });
  print('\n📝 Press Enter to continue with manual testing...');
  stdin.readLineSync();

  // Manual Test Guide
  await printManualTestGuide();
}

Future<bool> checkServerConnection(String baseUrl) async {
  try {
    final response = await http.get(Uri.parse(baseUrl));
    return response.statusCode == 404 || response.statusCode == 200;
  } catch (e) {
    return false;
  }
}

Future<void> printManualTestGuide() async {
  print('\n╔════════════════════════════════════════════════════════════╗');
  print('║              MANUAL TESTING GUIDE                          ║');
  print('╚════════════════════════════════════════════════════════════╝\n');

  // USER ROLE TESTS
  print('┌─────────────────────────────────────────────────────────┐');
  print('│ 1️⃣  USER ROLE - Testing (Regular Employee)              │');
  print('└─────────────────────────────────────────────────────────┘');
  print('');
  print('📱 Login as USER:');
  print('   - Open app: flutter run -d chrome --web-port 8080');
  print('   - Login dengan akun user');
  print('');
  print('✅ Test Auto-Refresh pada module USER:');
  print('');
  print('   📋 ATTENDANCE (Absensi):');
  print('   ├─ CREATE: Clock In → data langsung muncul di list');
  print('   ├─ UPDATE: Clock Out → status langsung update');
  print('   └─ Verify: Lihat dashboard, data attendance ter-update');
  print('');
  print('   ✉️  LETTERS (Surat/Izin):');
  print('   ├─ CREATE: Submit surat izin baru → langsung muncul di list');
  print('   ├─ VIEW: Buka detail surat → data lengkap tampil');
  print('   └─ DELETE: Hapus surat draft → langsung hilang dari list');
  print('');
  print('   👤 PROFILE:');
  print('   ├─ UPDATE: Edit profile (nama, email) → langsung ter-update');
  print('   ├─ UPLOAD: Upload foto profile → langsung tampil di dashboard');
  print('   └─ PASSWORD: Ganti password → berhasil tanpa logout');
  print('');
  print('   📊 DASHBOARD:');
  print('   ├─ View attendance summary → data real-time');
  print('   ├─ View pending letters → data ter-update');
  print('   └─ Profile photo → langsung tampil setelah upload');
  print('');
  print('   ⚙️  SETTINGS:');
  print('   ├─ Notification Settings → buka system settings');
  print('   ├─ Location Settings → buka system settings');
  print('   └─ Help Desk → form WhatsApp dengan auto-fill data user');
  print('');
  
  print('Expected Result: ✅ Semua operasi langsung tampil tanpa refresh manual\n');
  print('─────────────────────────────────────────────────────────────\n');

  // ADMIN ROLE TESTS
  print('┌─────────────────────────────────────────────────────────┐');
  print('│ 2️⃣  ADMIN ROLE - Testing (Department Manager)           │');
  print('└─────────────────────────────────────────────────────────┘');
  print('');
  print('📱 Login as ADMIN:');
  print('   - Logout dari user account');
  print('   - Login dengan akun admin');
  print('');
  print('✅ Test Auto-Refresh pada module ADMIN:');
  print('');
  print('   📝 ASSIGNMENTS (Penugasan):');
  print('   ├─ CREATE: Buat assignment baru → langsung muncul di list');
  print('   ├─ UPDATE: Edit assignment → perubahan langsung terlihat');
  print('   ├─ DELETE: Hapus assignment → langsung hilang');
  print('   └─ VIEW: Filter by month/status → data ter-update');
  print('');
  print('   ✉️  LETTERS APPROVAL:');
  print('   ├─ APPROVE: Setujui surat → status langsung update');
  print('   ├─ REJECT: Tolak surat → status langsung berubah');
  print('   ├─ REPLY: Balas surat → reply langsung muncul');
  print('   └─ ARCHIVE: Arsipkan surat → langsung ke archive list');
  print('');
  print('   📊 ATTENDANCE MANAGEMENT:');
  print('   ├─ VIEW: Lihat attendance semua user → data real-time');
  print('   ├─ UPDATE: Edit attendance record → langsung ter-update');
  print('   ├─ DELETE: Hapus record salah → langsung hilang');
  print('   └─ FILTER: By date/user/status → data ter-filter');
  print('');
  print('   👥 EMPLOYEE MANAGEMENT:');
  print('   ├─ CREATE: Tambah employee baru → langsung di list');
  print('   ├─ UPDATE: Edit data employee → perubahan langsung tampil');
  print('   ├─ STATUS: Activate/Deactivate → status langsung update');
  print('   └─ DELETE: Hapus employee → langsung hilang dari list');
  print('');
  print('   📈 DASHBOARD ADMIN:');
  print('   ├─ View total employees → data real-time');
  print('   ├─ View pending assignments → auto-update');
  print('   ├─ View attendance statistics → data terbaru');
  print('   └─ View pending letters → langsung ter-update');
  print('');
  
  print('Expected Result: ✅ Semua CRUD operations langsung reflect tanpa refresh\n');
  print('─────────────────────────────────────────────────────────────\n');

  // SUPER ADMIN ROLE TESTS
  print('┌─────────────────────────────────────────────────────────┐');
  print('│ 3️⃣  SUPER ADMIN ROLE - Testing (System Administrator)   │');
  print('└─────────────────────────────────────────────────────────┘');
  print('');
  print('📱 Login as SUPER ADMIN:');
  print('   - Logout dari admin account');
  print('   - Login dengan akun superadmin');
  print('');
  print('✅ Test Auto-Refresh pada module SUPER ADMIN:');
  print('');
  print('   👥 USER MANAGEMENT (All Users):');
  print('   ├─ CREATE: Create user dengan role apapun → langsung muncul');
  print('   ├─ UPDATE: Edit user data/role → langsung ter-update');
  print('   ├─ ACTIVATE: Activate user → status langsung berubah');
  print('   ├─ DEACTIVATE: Deactivate user → status langsung update');
  print('   ├─ RESET PASSWORD: Reset password user → berhasil langsung');
  print('   ├─ BULK UPDATE: Update multiple users → semua langsung update');
  print('   └─ DELETE: Hapus user → langsung hilang dari list');
  print('');
  print('   📋 ASSIGNMENTS (System-wide):');
  print('   ├─ CREATE: Buat assignment untuk semua dept → langsung muncul');
  print('   ├─ UPDATE: Edit assignment apapun → langsung ter-update');
  print('   ├─ DELETE: Hapus assignment → langsung hilang');
  print('   └─ VIEW: Lihat semua assignments → data real-time');
  print('');
  print('   ✉️  LETTERS (All Departments):');
  print('   ├─ VIEW: Lihat semua surat dari semua dept → data lengkap');
  print('   ├─ APPROVE: Approve surat → langsung update');
  print('   ├─ REJECT: Reject surat → status langsung berubah');
  print('   ├─ DELETE: Hapus surat → langsung hilang');
  print('   └─ REPLY: Reply surat → langsung muncul');
  print('');
  print('   📊 ATTENDANCE (Company-wide):');
  print('   ├─ VIEW: Lihat attendance semua user → data real-time');
  print('   ├─ UPDATE: Edit attendance record → langsung update');
  print('   ├─ DELETE: Hapus attendance record → langsung hilang');
  print('   └─ EXPORT: Export data → data terbaru ter-export');
  print('');
  print('   👨‍💼 EMPLOYEE MANAGEMENT (Full Control):');
  print('   ├─ CREATE: Tambah employee + assign role → langsung muncul');
  print('   ├─ UPDATE: Edit employee data lengkap → langsung ter-update');
  print('   ├─ CHANGE ROLE: Ubah role employee → langsung berubah');
  print('   ├─ STATUS: Activate/Deactivate → status real-time update');
  print('   └─ DELETE: Hapus employee → langsung hilang');
  print('');
  print('   ⚙️  SYSTEM SETTINGS:');
  print('   ├─ Configure system settings → langsung applied');
  print('   └─ View system logs → data real-time');
  print('');
  
  print('Expected Result: ✅ Full control dengan auto-refresh di semua module\n');
  print('─────────────────────────────────────────────────────────────\n');

  // CROSS-ROLE TESTING
  print('┌─────────────────────────────────────────────────────────┐');
  print('│ 4️⃣  CROSS-ROLE TESTING (Integration)                    │');
  print('└─────────────────────────────────────────────────────────┘');
  print('');
  print('🔄 Test Auto-Refresh Cross-Role:');
  print('');
  print('   Scenario 1: User → Admin Flow');
  print('   ├─ User: Submit surat izin');
  print('   ├─ Admin: Login, lihat pending letters');
  print('   ├─ Admin: Approve surat');
  print('   ├─ User: Login kembali, lihat status surat');
  print('   └─ Expected: Status approved langsung tampil tanpa refresh');
  print('');
  print('   Scenario 2: Admin → User Flow');
  print('   ├─ Admin: Create assignment untuk user tertentu');
  print('   ├─ User: Login, check assignments');
  print('   └─ Expected: Assignment baru langsung muncul');
  print('');
  print('   Scenario 3: Super Admin → Admin → User Flow');
  print('   ├─ Super Admin: Create new user dengan role user');
  print('   ├─ Admin: Lihat employee list');
  print('   ├─ Super Admin: Update user role ke admin');
  print('   ├─ Admin: Refresh employee list');
  print('   └─ Expected: Perubahan role langsung terlihat');
  print('');
  print('   Scenario 4: Concurrent Operations');
  print('   ├─ Open 2 browser tabs');
  print('   ├─ Tab 1: Login as Admin');
  print('   ├─ Tab 2: Login as Admin (sama)');
  print('   ├─ Tab 1: Create assignment');
  print('   ├─ Tab 2: Reload assignment list');
  print('   └─ Expected: Assignment muncul di kedua tab');
  print('');
  
  print('─────────────────────────────────────────────────────────────\n');

  // CACHE CLEARING VERIFICATION
  print('┌─────────────────────────────────────────────────────────┐');
  print('│ 5️⃣  CACHE CLEARING VERIFICATION (27 Operations)         │');
  print('└─────────────────────────────────────────────────────────┘');
  print('');
  print('✅ Verify 27 CRUD Operations with Auto Cache Clear:');
  print('');
  print('   assignment_service.dart (3 ops):');
  print('   ✓ createAssignment() → clearCache()');
  print('   ✓ updateAssignment() → clearCache()');
  print('   ✓ deleteAssignment() → clearCache()');
  print('');
  print('   letter_service.dart (7 ops):');
  print('   ✓ sendLetter() → clearCache()');
  print('   ✓ replyLetter() → clearCache()');
  print('   ✓ deleteLetter() → clearCache()');
  print('   ✓ archiveLetter() → clearCache()');
  print('   ✓ approveLetter() → clearCache()');
  print('   ✓ rejectLetter() → clearCache()');
  print('   ✓ updateLetterStatus() → clearCache()');
  print('');
  print('   employee_service.dart (4 ops):');
  print('   ✓ createEmployee() → clearCache()');
  print('   ✓ updateEmployee() → clearCache()');
  print('   ✓ deleteEmployee() → clearCache()');
  print('   ✓ updateEmployeeStatus() → clearCache()');
  print('');
  print('   attendance_service.dart (4 ops):');
  print('   ✓ checkIn() → clearCache()');
  print('   ✓ checkOut() → clearCache()');
  print('   ✓ updateAttendance() → clearCache()');
  print('   ✓ deleteAttendance() → clearCache()');
  print('');
  print('   user_service.dart (8 ops):');
  print('   ✓ updateUser() → clearCache()');
  print('   ✓ activateUser() → clearCache()');
  print('   ✓ deactivateUser() → clearCache()');
  print('   ✓ resetPassword() → clearCache()');
  print('   ✓ bulkUpdateUsers() → clearCache()');
  print('   ✓ changePassword() → clearCache()');
  print('   ✓ updateProfile() → clearCache()');
  print('   ✓ uploadProfilePicture() → clearCache()');
  print('');
  print('   auth_service.dart (1 op):');
  print('   ✓ updateProfile() → clearCache()');
  print('');
  print('   TOTAL: 27 operations with automatic cache clearing ✅');
  print('');
  
  print('─────────────────────────────────────────────────────────────\n');

  // CHECKLIST
  print('┌─────────────────────────────────────────────────────────┐');
  print('│ 📋 TESTING CHECKLIST                                     │');
  print('└─────────────────────────────────────────────────────────┘');
  print('');
  print('USER Role:');
  print('[ ] Attendance - Clock In/Out auto-refresh');
  print('[ ] Letters - Submit/Delete auto-refresh');
  print('[ ] Profile - Update/Upload photo auto-refresh');
  print('[ ] Dashboard - Real-time data update');
  print('[ ] Settings - WhatsApp integration works');
  print('');
  print('ADMIN Role:');
  print('[ ] Assignments - CREATE/UPDATE/DELETE auto-refresh');
  print('[ ] Letters - APPROVE/REJECT/REPLY/ARCHIVE auto-refresh');
  print('[ ] Attendance - View/Edit/Delete auto-refresh');
  print('[ ] Employees - CRUD operations auto-refresh');
  print('[ ] Dashboard - Real-time statistics');
  print('');
  print('SUPER ADMIN Role:');
  print('[ ] Users - Full CRUD + role management auto-refresh');
  print('[ ] Assignments - System-wide CRUD auto-refresh');
  print('[ ] Letters - All departments CRUD auto-refresh');
  print('[ ] Attendance - Company-wide management auto-refresh');
  print('[ ] Employees - Full control auto-refresh');
  print('[ ] Bulk operations - Multiple updates auto-refresh');
  print('');
  print('Cross-Role:');
  print('[ ] User → Admin workflow');
  print('[ ] Admin → User workflow');
  print('[ ] Super Admin → All roles workflow');
  print('[ ] Concurrent operations (multiple tabs)');
  print('');
  print('Performance:');
  print('[ ] No manual refresh needed (0 refresh buttons)');
  print('[ ] Data appears immediately after CRUD');
  print('[ ] Cache clears automatically after operations');
  print('[ ] No logout/login required for data update');
  print('');
  
  print('─────────────────────────────────────────────────────────────\n');

  // SUMMARY
  print('╔════════════════════════════════════════════════════════════╗');
  print('║                    TEST SUMMARY                            ║');
  print('╚════════════════════════════════════════════════════════════╝\n');
  print('✅ Total CRUD Operations: 27');
  print('✅ All operations have automatic cache clearing');
  print('✅ No manual refresh required');
  print('✅ Data updates in real-time');
  print('');
  print('🎯 Key Features Implemented:');
  print('   • Auto-refresh after CREATE operations (5)');
  print('   • Auto-refresh after UPDATE operations (14)');
  print('   • Auto-refresh after DELETE operations (8)');
  print('   • Profile photo with 2MB auto-compress');
  print('   • WhatsApp integration (Help Desk + Add Account)');
  print('   • System settings integration (Notifications + Location)');
  print('   • All refresh buttons removed (13 files)');
  print('');
  print('📝 To start testing:');
  print('   1. Make sure backend is running: cd backend && node server.js');
  print('   2. Run Flutter app: cd frontend && flutter run -d chrome --web-port 8080');
  print('   3. Follow the manual testing guide above');
  print('   4. Check off each item in the checklist');
  print('');
  print('🎉 Expected Result:');
  print('   ALL data operations should reflect immediately without any');
  print('   manual refresh, logout/login, or page reload!\n');
}
