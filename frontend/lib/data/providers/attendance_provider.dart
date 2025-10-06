import 'package:flutter/foundation.dart';
import '../models/attendance.dart';
import '../services/attendance_service.dart';

class AttendanceProvider with ChangeNotifier {
  final AttendanceService _attendanceService = AttendanceService();
  
  Attendance? _currentAttendance;
  List<Attendance> _attendanceRecords = [];
  AttendanceStatistics? _statistics;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Pagination
  int _currentPage = 1;
  bool _hasMoreData = true;
  bool _isLoadingMore = false;

  // Getters
  Attendance? get currentAttendance => _currentAttendance;
  List<Attendance> get attendanceRecords => _attendanceRecords;
  AttendanceStatistics? get statistics => _statistics;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  bool get hasMoreData => _hasMoreData;
  
  // Check if user is currently checked in
  bool get isCheckedIn => _currentAttendance != null && 
                         _currentAttendance!.checkOutTime == null;

  // Check in
  Future<bool> checkIn({
    required double latitude,
    required double longitude,
    String? notes,
    String? photoUrl,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _attendanceService.checkIn(
        latitude: latitude,
        longitude: longitude,
        notes: notes,
        photoUrl: photoUrl,
      );

      if (response.success && response.data != null) {
        _currentAttendance = response.data;
        // Add to the beginning of records list
        _attendanceRecords.insert(0, response.data!);
        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? "Unknown error");
        return false;
      }
    } catch (e) {
      _setError('Check-in failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Check out
  Future<bool> checkOut({
    required double latitude,
    required double longitude,
    String? notes,
    String? photoUrl,
  }) async {
    if (_currentAttendance == null) {
      _setError('No active check-in found');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final response = await _attendanceService.checkOut(
        attendanceId: _currentAttendance!.id,
        latitude: latitude,
        longitude: longitude,
        notes: notes,
        photoUrl: photoUrl,
      );

      if (response.success && response.data != null) {
        _currentAttendance = response.data;
        // Update the record in the list
        final index = _attendanceRecords.indexWhere(
          (record) => record.id == response.data!.id,
        );
        if (index != -1) {
          _attendanceRecords[index] = response.data!;
        }
        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? "Unknown error");
        return false;
      }
    } catch (e) {
      _setError('Check-out failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Load current attendance status
  Future<void> loadCurrentAttendance() async {
    try {
      final response = await _attendanceService.getCurrentAttendance();

      if (response.success) {
        _currentAttendance = response.data;
        notifyListeners();
      } else {
        _setError(response.message ?? "Unknown error");
      }
    } catch (e) {
      _setError('Failed to load current attendance: ${e.toString()}');
    }
  }

  // Load attendance records
  Future<void> loadAttendanceRecords({
    bool refresh = false,
    String? startDate,
    String? endDate,
    String? status,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _hasMoreData = true;
      _attendanceRecords.clear();
    }

    if (!_hasMoreData || _isLoadingMore) return;

    if (_currentPage == 1) {
      _setLoading(true);
    } else {
      _isLoadingMore = true;
      notifyListeners();
    }

    _clearError();

    try {
      final response = await _attendanceService.getAttendanceRecords(
        page: _currentPage,
        limit: 20,
        startDate: startDate,
        endDate: endDate,
        status: status,
      );

      if (response.success && response.data != null) {
        final newRecords = response.data!.items;
        
        if (refresh) {
          _attendanceRecords = newRecords;
        } else {
          _attendanceRecords.addAll(newRecords);
        }

        // Check if there's more data
        _hasMoreData = newRecords.length == 20;
        _currentPage++;
        
        notifyListeners();
      } else {
        _setError(response.message ?? "Unknown error");
      }
    } catch (e) {
      _setError('Failed to load attendance records: ${e.toString()}');
    } finally {
      _setLoading(false);
      _isLoadingMore = false;
    }
  }

  // Load attendance statistics
  Future<void> loadStatistics({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final response = await _attendanceService.getAttendanceStatistics(
        startDate: startDate,
        endDate: endDate,
      );

      if (response.success && response.data != null) {
        _statistics = response.data;
        notifyListeners();
      } else {
        _setError(response.message ?? "Unknown error");
      }
    } catch (e) {
      _setError('Failed to load statistics: ${e.toString()}');
    }
  }

  // Get attendance by ID
  Future<Attendance?> getAttendanceById(String id) async {
    try {
      final response = await _attendanceService.getAttendanceById(id);

      if (response.success && response.data != null) {
        return response.data;
      } else {
        _setError(response.message ?? "Unknown error");
        return null;
      }
    } catch (e) {
      _setError('Failed to load attendance: ${e.toString()}');
      return null;
    }
  }

  // Update attendance record
  Future<bool> updateAttendance({
    required String id,
    String? notes,
    String? status,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _attendanceService.updateAttendance(
        id: id,
        notes: notes,
        status: status,
      );

      if (response.success && response.data != null) {
        // Update the record in the list
        final index = _attendanceRecords.indexWhere(
          (record) => record.id == id,
        );
        if (index != -1) {
          _attendanceRecords[index] = response.data!;
        }
        
        // Update current attendance if it's the same record
        if (_currentAttendance?.id == id) {
          _currentAttendance = response.data;
        }
        
        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? "Unknown error");
        return false;
      }
    } catch (e) {
      _setError('Failed to update attendance: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete attendance record
  Future<bool> deleteAttendance(String id) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _attendanceService.deleteAttendance(id);

      if (response.success) {
        // Remove from records list
        _attendanceRecords.removeWhere((record) => record.id == id);
        
        // Clear current attendance if it's the same record
        if (_currentAttendance?.id == id) {
          _currentAttendance = null;
        }
        
        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? "Unknown error");
        return false;
      }
    } catch (e) {
      _setError('Failed to delete attendance: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Load more records (for pagination)
  Future<void> loadMoreRecords({
    String? startDate,
    String? endDate,
    String? status,
  }) async {
    await loadAttendanceRecords(
      refresh: false,
      startDate: startDate,
      endDate: endDate,
      status: status,
    );
  }

  // Refresh all data
  Future<void> refreshData() async {
    await Future.wait([
      loadCurrentAttendance(),
      loadAttendanceRecords(refresh: true),
      loadStatistics(),
    ]);
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _clearError();
  }

  // Get total working hours for today
  Duration? get todayWorkingHours {
    if (_currentAttendance?.checkInTime == null) return null;
    
    final checkIn = DateTime.parse(_currentAttendance!.checkInTime!);
    final checkOut = _currentAttendance!.checkOutTime != null
        ? DateTime.parse(_currentAttendance!.checkOutTime!)
        : DateTime.now();
    
    return checkOut.difference(checkIn);
  }

  // Get working status
  String get workingStatus {
    if (_currentAttendance == null) {
      return 'Not checked in';
    }
    
    if (_currentAttendance!.checkOutTime == null) {
      return 'Working';
    } else {
      return 'Completed';
    }
  }

  // Check if user is late (assuming 9 AM is the standard start time)
  bool get isLateToday {
    if (_currentAttendance?.checkInTime == null) return false;
    
    final checkInTime = DateTime.parse(_currentAttendance!.checkInTime!);
    final standardStartTime = DateTime(
      checkInTime.year,
      checkInTime.month,
      checkInTime.day,
      9, // 9 AM
    );
    
    return checkInTime.isAfter(standardStartTime);
  }

  // Get attendance summary for current month
  Map<String, int> get monthlyAttendanceSummary {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);
    
    final monthlyRecords = _attendanceRecords.where((record) {
      if (record.checkInTime == null) return false;
      final checkInTime = DateTime.parse(record.checkInTime!);
      return checkInTime.isAfter(monthStart) &&
             checkInTime.isBefore(monthEnd.add(const Duration(days: 1)));
    }).toList();
    
    int present = 0;
    int late = 0;
    int absent = 0;
    
    for (final record in monthlyRecords) {
      if (record.checkOutTime != null) {
        present++;
        
        // Check if late (after 9 AM)
        final checkInTime = DateTime.parse(record.checkInTime!);
        final standardStartTime = DateTime(
          checkInTime.year,
          checkInTime.month,
          checkInTime.day,
          9,
        );
        
        if (checkInTime.isAfter(standardStartTime)) {
          late++;
        }
      }
    }
    
    // Calculate working days in month (rough estimation)
    final totalWorkingDays = monthEnd.day - 
        (monthEnd.weekday == 7 ? 1 : 0) - // Exclude Sundays
        ((monthEnd.day / 7).floor() * 2); // Rough weekend exclusion
    
    absent = totalWorkingDays - present;
    
    return {
      'present': present,
      'late': late,
      'absent': absent > 0 ? absent : 0,
    };
  }
}
