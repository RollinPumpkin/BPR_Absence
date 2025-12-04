import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:frontend/data/providers/auth_provider.dart';
import 'package:frontend/widgets/user_notification_bell.dart';
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
    
    if (mounted) {
      setState(() {
        _clockInTime = null;
        _clockOutTime = null;
        _hasClockIn = false;
        _hasClockOut = false;
      });
    }
  }

  String _getGreeting(int hour) {
    if (hour >= 5 && hour < 12) return "Good Morning";
    if (hour >= 12 && hour < 16) return "Good Afternoon";
    if (hour >= 16 && hour < 19) return "Good Evening";
    return "Good Night";
  }

  String _getFirstName(String fullName) {
    if (fullName.isEmpty) return "User";
    final parts = fullName.split(' ');
    return parts.first;
  }

  Future<void> _loadAttendanceData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final userId = prefs.getString('user_id') ?? '';
    
    final clockIn = prefs.getString('clock_in_${userId}_$today');
    final clockOut = prefs.getString('clock_out_${userId}_$today');
    
    if (mounted) {
      setState(() {
        _clockInTime = clockIn;
        _clockOutTime = clockOut;
        _hasClockIn = _clockInTime != null;
        _hasClockOut = _clockOutTime != null;
      });
    }
  }

  String _getDisplayTime(String? savedTime, bool isClockOut) {
    // If there's a saved time (user has clocked in/out), show the saved static time
    if (savedTime != null) {
      return savedTime;
    }
    
    // For Clock In: Show real-time clock if not yet clocked in
    if (!isClockOut && !_hasClockIn) {
      return _currentTime; // Live clock
    }
    
    // For Clock Out: Only show after clock in
    if (isClockOut) {
      if (!_hasClockIn) {
        // Don't show clock out if haven't clocked in
        return '--:--:--';
      }
      // Show real-time clock if clocked in but not clocked out yet
      if (!_hasClockOut) {
        return _currentTime; // Live clock
      }
    }
    
    // Default case
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
        builder: (context) => AttendanceFormPage(type: type),
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

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateFormatter = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive sizing based on screen width
        final isSmallScreen = constraints.maxWidth < 360;
        final cardPadding = isSmallScreen ? 8.0 : 14.0;
        final outerPadding = isSmallScreen ? 6.0 : 12.0;
        final fontSize = isSmallScreen ? 9.0 : 12.0;
        final timeFontSize = isSmallScreen ? 14.0 : 20.0;
        final iconSize = isSmallScreen ? 10.0 : 12.0;
        final buttonSpacing = isSmallScreen ? 6.0 : 12.0;
        
        return Container(
          width: double.infinity,
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
            bottom: false,
            child: Padding(
              padding: EdgeInsets.all(outerPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              // Date Row (removed time from top)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      dateFormatter.format(now),
                      style: const TextStyle(
                        color: AppColors.pureWhite,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const UserNotificationBell(),
                      const SizedBox(width: 8),
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, _) {
                          final currentUser = authProvider.currentUser;
                          final hasPhoto = currentUser?.profilePicture != null && 
                                          currentUser!.profilePicture!.isNotEmpty;
                          
                          return GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/user/profile');
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.pureWhite,
                                shape: BoxShape.circle,
                                image: hasPhoto
                                    ? DecorationImage(
                                        image: NetworkImage(currentUser.profilePicture!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: hasPhoto
                                  ? null
                                  : const Icon(
                                      Icons.person,
                                      color: Color(0xFF4A90E2),
                                      size: 18,
                                    ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              
              SizedBox(height: isSmallScreen ? 12.0 : 16.0),
              
              // Greeting - Dynamic berdasarkan waktu dan user login
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  final currentUser = authProvider.currentUser;
                  final fullName = currentUser?.fullName ?? "User";
                  final firstName = _getFirstName(fullName);
                  final hour = DateTime.now().hour;
                  final greeting = _getGreeting(hour);
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$greeting, $firstName',
                        style: TextStyle(
                          color: AppColors.pureWhite,
                          fontSize: isSmallScreen ? 16.0 : 18.0,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: isSmallScreen ? 2.0 : 4.0),
                      Text(
                        'Have a Great Day!',
                        style: TextStyle(
                          color: AppColors.pureWhite,
                          fontSize: isSmallScreen ? 12.0 : 14.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  );
                },
              ),
              
              SizedBox(height: isSmallScreen ? 12.0 : 16.0),
              
              // Clock Card positioned within the blue background
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(cardPadding),
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Clock In/Out Row
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'Clock In',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    _getDisplayTime(_clockInTime, false),
                                    style: TextStyle(
                                      fontSize: timeFontSize,
                                      fontWeight: FontWeight.bold,
                                      color: _hasClockIn ? AppColors.primaryGreen : AppColors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            color: AppColors.neutral300,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'Clock out',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    _getDisplayTime(_clockOutTime, true),
                                    style: TextStyle(
                                      fontSize: timeFontSize,
                                      fontWeight: FontWeight.bold,
                                      color: _hasClockOut ? AppColors.errorRed : AppColors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: isSmallScreen ? 8.0 : 12.0),
                    
                    // Buttons Row
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _hasClockIn ? null : () => _navigateToAttendanceForm('clock_in'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _hasClockIn ? Colors.grey : AppColors.primaryGreen,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(
                                vertical: isSmallScreen ? 6.0 : 8.0, 
                                horizontal: isSmallScreen ? 4.0 : 8.0,
                              ),
                              minimumSize: Size(0, isSmallScreen ? 28.0 : 36.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(isSmallScreen ? 2.0 : 3.0),
                                  decoration: const BoxDecoration(
                                    color: AppColors.pureWhite,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.login,
                                    color: AppColors.primaryGreen,
                                    size: iconSize,
                                  ),
                                ),
                                SizedBox(width: isSmallScreen ? 4.0 : 6.0),
                                Flexible(
                                  child: Text(
                                    _hasClockIn ? 'Clocked In' : 'In',
                                    style: TextStyle(
                                      color: AppColors.pureWhite,
                                      fontWeight: FontWeight.w600,
                                      fontSize: fontSize,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: buttonSpacing),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: (!_hasClockIn || _hasClockOut) ? null : () => _navigateToAttendanceForm('clock_out'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _hasClockOut ? Colors.grey : AppColors.errorRed,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(
                                vertical: isSmallScreen ? 6.0 : 8.0, 
                                horizontal: isSmallScreen ? 4.0 : 8.0,
                              ),
                              minimumSize: Size(0, isSmallScreen ? 28.0 : 36.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(isSmallScreen ? 2.0 : 3.0),
                                  decoration: const BoxDecoration(
                                    color: AppColors.pureWhite,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.logout,
                                    color: AppColors.errorRed,
                                    size: iconSize,
                                  ),
                                ),
                                SizedBox(width: isSmallScreen ? 4.0 : 6.0),
                                Flexible(
                                  child: Text(
                                    _hasClockOut ? 'Clocked Out' : 'Out',
                                    style: TextStyle(
                                      color: AppColors.pureWhite,
                                      fontWeight: FontWeight.w600,
                                      fontSize: fontSize,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
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
      },
    );
  }
}
