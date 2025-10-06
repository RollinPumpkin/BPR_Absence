import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../../attendance/attendance_form_page.dart';

class UserHeader extends StatefulWidget {
  const UserHeader({super.key});

  @override
  State<UserHeader> createState() => _UserHeaderState();
}

class _UserHeaderState extends State<UserHeader> {
  late Timer _timer;
  String _currentTime = '';
  String? _clockInTime;
  String? _clockOutTime;
  bool _hasClockIn = false;
  bool _hasClockOut = false;

  @override
  void initState() {
    super.initState();
    _loadAttendanceData();
    _updateTime();
    _checkMidnightReset();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
      _checkMidnightReset();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateTime() {
    if (mounted) {
      setState(() {
        _currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
      });
    }
  }

  // Check untuk reset di jam 23:59:59
  void _checkMidnightReset() async {
    final now = DateTime.now();
    if (now.hour == 23 && now.minute == 59 && now.second == 59) {
      await _resetAttendance();
    }
  }

  // Reset attendance data di midnight
  Future<void> _resetAttendance() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final userId = prefs.getString('user_id') ?? '';
    
    // Hapus data lama per user
    await prefs.remove('clock_in_${userId}_$today');
    await prefs.remove('clock_out_${userId}_$today');
    
    setState(() {
      _clockInTime = null;
      _clockOutTime = null;
      _hasClockIn = false;
      _hasClockOut = false;
    });
  }

  Future<void> _loadAttendanceData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final userId = prefs.getString('user_id') ?? '';
    
    final clockIn = prefs.getString('clock_in_${userId}_$today');
    final clockOut = prefs.getString('clock_out_${userId}_$today');
    
    setState(() {
      _clockInTime = clockIn;
      _clockOutTime = clockOut;
      _hasClockIn = _clockInTime != null;
      _hasClockOut = _clockOutTime != null;
    });
  }

  String _getDisplayTime(String? savedTime, bool isClockOut) {
    // Jika clock out, hanya tampilkan jika sudah clock in
    if (isClockOut && !_hasClockIn) {
      return '--:--:--';
    }
    
    // Jika ada waktu tersimpan, tampilkan waktu tersimpan (berhenti)
    if (savedTime != null) {
      return savedTime;
    }
    
    // Jika clock in belum ada dan ini bukan clock out, tampilkan dash
    if (!isClockOut && !_hasClockIn) {
      return '--:--:--';
    }
    
    // Jika clock out belum ada tetapi clock in sudah ada, tampilkan dash
    if (isClockOut && !_hasClockOut) {
      return '--:--:--';
    }
    
    // Default case - seharusnya tidak pernah sampai sini
    return '--:--:--';
  }

  Future<void> _saveClockIn() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
    final userId = prefs.getString('user_id') ?? '';
    
    await prefs.setString('clock_in_${userId}_$today', currentTime);
    
    setState(() {
      _clockInTime = currentTime;
      _hasClockIn = true;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Clock In saved at $currentTime'),
          backgroundColor: AppColors.primaryGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _saveClockOut() async {
    if (!_hasClockIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please Clock In first'),
          backgroundColor: AppColors.errorRed,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
    final userId = prefs.getString('user_id') ?? '';
    
    await prefs.setString('clock_out_${userId}_$today', currentTime);
    
    setState(() {
      _clockOutTime = currentTime;
      _hasClockOut = true;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Clock Out saved at $currentTime'),
          backgroundColor: AppColors.errorRed,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _navigateToAttendanceForm(String type) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
<<<<<<< HEAD
        builder: (context) => AttendanceFormPage(type: type),
=======
        builder: (context) => const AttendanceFormPage(),
>>>>>>> b8402430cf2554874c13106363cb57eb110c9177
      ),
    );
    
    // Reload attendance data setelah kembali dari AttendanceFormPage
    if (result != null && result == true) {
      print('🔄 Reloading attendance data after form submission');
      await _loadAttendanceData();
    }
  }

  void _handleClockInSaved(String time) {
    setState(() {
      _clockInTime = time;
      _hasClockIn = true;
    });
    
    // Save to SharedPreferences
    _saveClockInTime(time);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Clock In saved at $time'),
          backgroundColor: AppColors.primaryGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleClockOutSaved(String time) {
    setState(() {
      _clockOutTime = time;
      _hasClockOut = true;
    });
    
    // Save to SharedPreferences
    _saveClockOutTime(time);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Clock Out saved at $time'),
          backgroundColor: AppColors.errorRed,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _saveClockInTime(String time) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final userId = prefs.getString('user_id') ?? '';
    await prefs.setString('clock_in_${userId}_$today', time);
  }

  Future<void> _saveClockOutTime(String time) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final userId = prefs.getString('user_id') ?? '';
    await prefs.setString('clock_out_${userId}_$today', time);
  }

  // Function to clear all local clock data for debugging/reset purposes
  Future<void> _clearAllLocalClockData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    // Clear today's data
    await prefs.remove('clock_in_${userId}_$today');
    await prefs.remove('clock_out_${userId}_$today');
    
    // Clear any other possible date formats that might exist
    final allKeys = prefs.getKeys();
    for (String key in allKeys) {
      if (key.contains('clock_in_$userId') || key.contains('clock_out_$userId')) {
        await prefs.remove(key);
        print('Removed local storage key: $key');
      }
    }
    
    // Reset state
    setState(() {
      _clockInTime = null;
      _clockOutTime = null;
      _hasClockIn = false;
      _hasClockOut = false;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Local clock data cleared successfully'),
          backgroundColor: AppColors.primaryGreen,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateFormatter = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');
    
    return Container(
      width: double.infinity,
      height: 350, // Increased height to accommodate all content
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF4A90E2),
            Color(0xFF357ABD),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date and Time Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${dateFormatter.format(now)}\n$_currentTime',
                    style: const TextStyle(
                      color: AppColors.pureWhite,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: AppColors.pureWhite,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: AppColors.pureWhite,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: AppColors.pureWhite,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Color(0xFF4A90E2),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Debug button to clear local storage
                      GestureDetector(
                        onTap: _clearAllLocalClockData,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.refresh,
                            color: AppColors.pureWhite,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Greeting
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good Morning, Puma',
                    style: TextStyle(
                      color: AppColors.pureWhite,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Have a Great Day!',
                    style: TextStyle(
                      color: AppColors.pureWhite,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 25),
              
              // Clock Card positioned within the blue background
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 0),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Clock In/Out Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'Clock In',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _getDisplayTime(_clockInTime, false),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: _hasClockIn ? AppColors.primaryGreen : AppColors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 60,
                          color: AppColors.neutral300,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'Clock out',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _getDisplayTime(_clockOutTime, true),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: _hasClockOut ? AppColors.errorRed : AppColors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 18),
                    
                    // Buttons Row
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ElevatedButton.icon(
                              onPressed: _hasClockIn ? null : () => _navigateToAttendanceForm('clock_in'),
                              icon: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: AppColors.pureWhite,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.login,
                                  color: AppColors.primaryGreen,
                                  size: 14,
                                ),
                              ),
                              label: Text(
                                _hasClockIn ? 'Clocked In' : 'In',
                                style: const TextStyle(
                                  color: AppColors.pureWhite,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _hasClockIn ? Colors.grey : AppColors.primaryGreen,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.errorRed,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ElevatedButton.icon(
                              onPressed: (!_hasClockIn || _hasClockOut) ? null : () => _navigateToAttendanceForm('clock_out'),
                              icon: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: AppColors.pureWhite,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.logout,
                                  color: AppColors.errorRed,
                                  size: 14,
                                ),
                              ),
                              label: Text(
                                _hasClockOut ? 'Clocked Out' : 'Out',
                                style: const TextStyle(
                                  color: AppColors.pureWhite,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _hasClockOut ? Colors.grey : AppColors.errorRed,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
