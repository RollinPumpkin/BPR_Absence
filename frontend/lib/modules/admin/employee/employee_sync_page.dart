import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/user_provider.dart';
import '../../../data/services/employee_sync_service.dart';

class EmployeeSyncPage extends StatefulWidget {
  const EmployeeSyncPage({super.key});

  @override
  State<EmployeeSyncPage> createState() => _EmployeeSyncPageState();
}

class _EmployeeSyncPageState extends State<EmployeeSyncPage> {
  final EmployeeSyncService _syncService = EmployeeSyncService();
  bool _isLoading = false;
  bool _isSyncing = false;
  Map<String, dynamic>? _lastSyncResult;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSyncStatus();
  }

  Future<void> _loadSyncStatus() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _syncService.getSyncStatus();
      if (response.success) {
        // Process sync status if needed
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = 'Error loading sync status: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _syncAllUsers() async {
    // Confirm dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Sync'),
        content: const Text(
          'Apakah Anda yakin ingin melakukan sinkronisasi semua data USERS ke Employee Database?\n\n'
          'Proses ini akan:\n'
          '• Mengambil semua data user dari database\n'
          '• Memfilter hanya employee yang aktif\n'
          '• Menambahkan ke employee database\n'
          '• Admin users akan dilewati\n\n'
          'Proses ini mungkin membutuhkan waktu beberapa menit.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[800],
              foregroundColor: Colors.white,
            ),
            child: const Text('Ya, Sync Sekarang'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isSyncing = true;
      _errorMessage = null;
      _lastSyncResult = null;
    });

    try {
      final response = await _syncService.syncUsersToEmployeeDatabase();
      
      setState(() {
        if (response.success) {
          _lastSyncResult = response.data;
          _showSyncResultDialog(response.data!);
        } else {
          _errorMessage = response.message;
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error during sync: $e';
      });
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  void _showSyncResultDialog(Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎯 Hasil Sinkronisasi'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('📊 Total Users: ${result['totalUsers']}'),
              Text('✅ Berhasil Sync: ${result['syncedCount']}'),
              Text('⏭️ Dilewati: ${result['skippedCount']}'),
              Text('❌ Error: ${result['errorCount']}'),
              const SizedBox(height: 16),
              
              if (result['syncedUsers'] != null && (result['syncedUsers'] as List).isNotEmpty) ...[
                const Text('✅ Users yang berhasil di-sync:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                ...(result['syncedUsers'] as List).map<Widget>((user) => 
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text('• $user', style: const TextStyle(fontSize: 12)),
                  )
                ),
                const SizedBox(height: 8),
              ],
              
              if (result['skippedUsers'] != null && (result['skippedUsers'] as List).isNotEmpty) ...[
                const Text('⏭️ Users yang dilewati:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                ...(result['skippedUsers'] as List).map<Widget>((user) => 
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text('• $user', style: const TextStyle(fontSize: 12, color: Colors.orange)),
                  )
                ),
                const SizedBox(height: 8),
              ],
              
              if (result['errorUsers'] != null && (result['errorUsers'] as List).isNotEmpty) ...[
                const Text('❌ Users dengan error:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                ...(result['errorUsers'] as List).map<Widget>((user) => 
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text('• $user', style: const TextStyle(fontSize: 12, color: Colors.red)),
                  )
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _refreshUserData(); // Refresh data after sync
            },
            child: const Text('Refresh Data'),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshUserData() async {
    final userProvider = context.read<UserProvider>();
    await userProvider.refreshUsers();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data berhasil di-refresh'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync Users to Employee DB'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Auth status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('👤 Status Autentikasi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('User: ${authProvider.currentUser?.fullName ?? "Not logged in"}'),
                    Text('Role: ${authProvider.currentUser?.role ?? "No role"}'),
                    Text('Employee ID: ${authProvider.currentUser?.employeeId ?? "No ID"}'),
                    
                    if (authProvider.currentUser?.role != 'admin' && authProvider.currentUser?.role != 'super_admin')
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.red[300]!),
                        ),
                        child: const Text(
                          '⚠️ Hanya admin yang dapat melakukan sinkronisasi data',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // User data status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📊 Status Data Users', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Total Users: ${userProvider.totalUsers}'),
                    Text('Users Loaded: ${userProvider.users.length}'),
                    Text('Loading: ${userProvider.isLoading ? "Ya" : "Tidak"}'),
                    if (userProvider.errorMessage != null)
                      Text('Error: ${userProvider.errorMessage}', style: const TextStyle(color: Colors.red)),
                    
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: userProvider.isLoading ? null : () async {
                        await userProvider.refreshUsers();
                      },
                      child: userProvider.isLoading 
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Refresh User Data'),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Sync controls
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🔄 Kontrol Sinkronisasi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text(
                      'Sinkronisasi akan mengambil semua data USERS dari database dan memasukkannya '
                      'ke Employee Database. Hanya employee aktif yang akan di-sync.',
                    ),
                    const SizedBox(height: 16),
                    
                    ElevatedButton.icon(
                      onPressed: (_isSyncing || _isLoading || 
                                  (authProvider.currentUser?.role != 'admin' && 
                                   authProvider.currentUser?.role != 'super_admin')) 
                        ? null 
                        : _syncAllUsers,
                      icon: _isSyncing 
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.sync),
                      label: Text(_isSyncing ? 'Syncing...' : 'Sync All Users to Employee DB'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                    
                    if (_isSyncing)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Proses sinkronisasi sedang berjalan. Mohon tunggu...',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Error display
            if (_errorMessage != null)
              Card(
                color: Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('❌ Error', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
                      const SizedBox(height: 8),
                      Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _errorMessage = null;
                          });
                        },
                        child: const Text('Clear Error'),
                      ),
                    ],
                  ),
                ),
              ),
            
            // Last sync result
            if (_lastSyncResult != null)
              Card(
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('✅ Hasil Sync Terakhir', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                      const SizedBox(height: 8),
                      Text('Total Users: ${_lastSyncResult!['totalUsers']}'),
                      Text('Berhasil Sync: ${_lastSyncResult!['syncedCount']}'),
                      Text('Dilewati: ${_lastSyncResult!['skippedCount']}'),
                      Text('Error: ${_lastSyncResult!['errorCount']}'),
                      Text('Waktu: ${_lastSyncResult!['timestamp']}'),
                      
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => _showSyncResultDialog(_lastSyncResult!),
                        child: const Text('Lihat Detail'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}