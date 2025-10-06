import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class FigmaClockCard extends StatefulWidget {
  const FigmaClockCard({super.key});

  @override
  State<FigmaClockCard> createState() => _FigmaClockCardState();
}

class _FigmaClockCardState extends State<FigmaClockCard> {
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
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
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

  Future<void> _loadAttendanceData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final userId = prefs.getString('user_id') ?? '';
    
    setState(() {
      _clockInTime = prefs.getString('clock_in_${userId}_$today');
      _clockOutTime = prefs.getString('clock_out_${userId}_$today');
      _hasClockIn = _clockInTime != null;
      _hasClockOut = _clockOutTime != null;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clock In/Out'),
        backgroundColor: AppColors.pureWhite,
        foregroundColor: AppColors.black,
        elevation: 0,
      ),
      backgroundColor: AppColors.backgroundGray,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                      _hasClockIn ? _clockInTime! : '--:--:--',
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
                color: Colors.grey.shade300,
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
                      _hasClockOut ? _clockOutTime! : '--:--:--',
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
          
          const SizedBox(height: 20),
          
          // Buttons Row
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _hasClockIn ? null : _saveClockIn,
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.pureWhite,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.login,
                      color: AppColors.primaryGreen,
                      size: 16,
                    ),
                  ),
                  label: Text(
                    _hasClockIn ? 'Clocked In' : 'In',
                    style: const TextStyle(
                      color: AppColors.pureWhite,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _hasClockIn ? Colors.grey : AppColors.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _hasClockOut ? null : _saveClockOut,
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.pureWhite,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.logout,
                      color: AppColors.errorRed,
                      size: 16,
                    ),
                  ),
                  label: Text(
                    _hasClockOut ? 'Clocked Out' : 'Out',
                    style: const TextStyle(
                      color: AppColors.pureWhite,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _hasClockOut ? Colors.grey : AppColors.errorRed,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
            ],
          ),
        ),
      ),
    );
  }
}