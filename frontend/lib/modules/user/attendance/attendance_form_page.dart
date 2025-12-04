import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/core/services/location_service.dart';
import 'package:frontend/data/services/attendance_service.dart';
// import '../../../services/leaflet_service.dart';

class AttendanceFormPage extends StatefulWidget {
  final String type;

  const AttendanceFormPage({super.key, required this.type});

  @override
  State<AttendanceFormPage> createState() => _AttendanceFormPageState();
}

class _AttendanceFormPageState extends State<AttendanceFormPage> {
  // State variables
  XFile? capturedImageFile;
  Uint8List? capturedImageBytes;
  bool isCapturingImage = false;
  bool hasCameraPermission = false;
  bool isRequestingPermission = false;
  bool isLoadingLocation = false;
  bool isSaving = false;
  Position? currentPosition;
  double? latitude;
  double? longitude;
  String detailAddress = '';
  String selectedLocation = 'Choose Location';
  String selectedAbsentType = 'Clock In';
  DateTime? startDate;
  DateTime? endDate;
  bool isUserClockedIn = false; // Track if user is currently clocked in
  
  // Separate options for Clock In and Clock Out
  final List<String> clockInTypes = [
    'Clock In',
    'Absent',
  ];
  
  final List<String> clockOutTypes = [
    'Clock Out',
    'Annual Leave',
    'Sick Leave',
  ];
  
  late Timer _timer;
  StreamSubscription<QuerySnapshot>? _attendanceListener;
  
  // Determine available options based on current clock status
  List<String> get availableOptions {
    if (isUserClockedIn) {
      return clockOutTypes;
    } else {
      return clockInTypes;
    }
  }
  String currentTime = '';
  String currentDate = '';
  final TextEditingController _notesController = TextEditingController();
  final _attendanceService = DummyAttendanceService();
  String? mapViewId; // Unique map view ID

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
    
    // Fallback: If page was opened from Clock Out button, set status directly FIRST
    if (widget.type == 'clock_out') {
      isUserClockedIn = true;
      selectedAbsentType = clockOutTypes.first;
      print('[AttendanceForm] OVERRIDE: Set to Clock Out mode based on widget.type');
    } else if (widget.type == 'clock_in') {
      isUserClockedIn = false;
      selectedAbsentType = clockInTypes.first;
      print('[AttendanceForm] OVERRIDE: Set to Clock In mode based on widget.type');
    }
    
    _initializeDatesBasedOnType();
    _getCurrentLocation();
    // Initialize camera permission (for web, this will be set to true automatically)
    _requestCameraPermission();
    
    // Setup realtime listener for clock status (but won't override widget.type)
    if (widget.type != 'clock_out' && widget.type != 'clock_in') {
      _setupRealtimeClockStatusListener();
    } else {
      // Even if widget.type is set, do initial check for data consistency
      _checkUserClockStatus();
    }
  }
  
  // Setup realtime listener for attendance status changes
  Future<void> _setupRealtimeClockStatusListener() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final employeeId = prefs.getString('employee_id') ?? '';
      final userId = prefs.getString('user_id') ?? '';
      
      if (employeeId.isEmpty && userId.isEmpty) {
        print('❌ No employee_id or user_id found for realtime listener');
        return;
      }

      // Get today's date
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      // Create Firestore query
      Query attendanceQuery = FirebaseFirestore.instance.collection('attendance');
      
      if (employeeId.isNotEmpty) {
        attendanceQuery = attendanceQuery.where('employee_id', isEqualTo: employeeId);
        print('🔄 Setting up realtime listener with employee_id: $employeeId');
      } else {
        attendanceQuery = attendanceQuery.where('user_id', isEqualTo: userId);
        print('🔄 Setting up realtime listener with user_id: $userId');
      }
      
      // Setup realtime listener
      _attendanceListener = attendanceQuery
          .where('date', isEqualTo: today)
          .orderBy('created_at', descending: true)
          .limit(1)
          .snapshots()
          .listen((snapshot) {
        if (!mounted) return;
        
        bool isCurrentlyClockedIn = false;
        
        if (snapshot.docs.isNotEmpty) {
          final attendanceData = snapshot.docs.first.data() as Map<String, dynamic>;
          final checkInTime = attendanceData['check_in_time'];
          final checkOutTime = attendanceData['check_out_time'];
          
          isCurrentlyClockedIn = checkInTime != null && checkOutTime == null;
          
          print('🔄 REALTIME UPDATE - Attendance changed:');
          print('🕐 Check in: $checkInTime');
          print('🕑 Check out: $checkOutTime');
          print('📊 Status: ${isCurrentlyClockedIn ? "Clocked In" : "Clocked Out"}');
        } else {
          print('🔄 REALTIME UPDATE - No attendance record for today');
        }
        
        setState(() {
          isUserClockedIn = isCurrentlyClockedIn;
          selectedAbsentType = isUserClockedIn ? clockOutTypes.first : clockInTypes.first;
        });
      }, onError: (error) {
        print('❌ Realtime listener error: $error');
      });
      
    } catch (e) {
      print('❌ Error setting up realtime listener: $e');
    }
  }
  
  // Check if user is currently clocked in (one-time check)
  Future<void> _checkUserClockStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final employeeId = prefs.getString('employee_id') ?? '';
      final userId = prefs.getString('user_id') ?? ''; // Fallback
      
      if (employeeId.isEmpty && userId.isEmpty) {
        print('❌ No employee_id or user_id found in SharedPreferences');
        setState(() {
          isUserClockedIn = false;
          selectedAbsentType = clockInTypes.first;
        });
        return;
      }

      // Get today's date
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      // Check Firestore for today's attendance record - prefer employee_id
      Query attendanceQuery = FirebaseFirestore.instance.collection('attendance');
      
      if (employeeId.isNotEmpty) {
        attendanceQuery = attendanceQuery.where('employee_id', isEqualTo: employeeId);
        print('📊 Checking attendance with employee_id: $employeeId');
      } else {
        attendanceQuery = attendanceQuery.where('user_id', isEqualTo: userId);
        print('📊 Checking attendance with user_id: $userId (fallback)');
      }
      
      final results = await attendanceQuery
          .where('date', isEqualTo: today)
          .orderBy('created_at', descending: true)
          .limit(1)
          .get();

      bool isCurrentlyClockedIn = false;
      
      if (results.docs.isNotEmpty) {
        final attendanceData = results.docs.first.data() as Map<String, dynamic>;
        final checkInTime = attendanceData['check_in_time'];
        final checkOutTime = attendanceData['check_out_time'];
        
        // User is clocked in if there's a check_in_time but no check_out_time
        isCurrentlyClockedIn = checkInTime != null && checkOutTime == null;
        
        print('📊 Found attendance record for today:');
        print('🕐 Check in time: $checkInTime');
        print('🕑 Check out time: $checkOutTime');
      } else {
        print('📊 No attendance record found for today');
      }
      
      setState(() {
        isUserClockedIn = isCurrentlyClockedIn;
        selectedAbsentType = isUserClockedIn ? clockOutTypes.first : clockInTypes.first;
      });
      
      print('[AttendanceForm] User clock status: ${isUserClockedIn ? "Clocked In" : "Clocked Out"}');
      print('[AttendanceForm] Default selected type: $selectedAbsentType');
      
    } catch (e) {
      print('[AttendanceForm] Error checking clock status from Firestore: $e');
      setState(() {
        isUserClockedIn = false;
        selectedAbsentType = clockInTypes.first;
      });
    }
  }
  
  // Update clock status after successful submission
  void _updateClockStatus() {
    setState(() {
      if (selectedAbsentType == 'Clock In') {
        isUserClockedIn = true;
        selectedAbsentType = clockOutTypes.first; // Set to first clock out option
      } else if (clockOutTypes.contains(selectedAbsentType)) {
        isUserClockedIn = false;
        selectedAbsentType = clockInTypes.first; // Set to first clock in option
      }
      // Reset dates when status changes
      _initializeDatesBasedOnType();
    });
    print('[AttendanceForm] Clock status updated: ${isUserClockedIn ? "Clocked In" : "Clocked Out"}');
    print('[AttendanceForm] New selected type: $selectedAbsentType');
  }

  @override
  void dispose() {
    _timer.cancel();
    _attendanceListener?.cancel();
    _notesController.dispose();
    print('🔄 Realtime listener cancelled');
    super.dispose();
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      currentTime = DateFormat('HH:mm:ss').format(now);
      currentDate = DateFormat('EEEE, dd MMMM yyyy').format(now);
    });
  }

  Future<void> _requestCameraPermission() async {
    setState(() {
      isRequestingPermission = true;
    });

    try {
      // For web platform, assume permission is granted as it's handled by browser
      if (kIsWeb) {
        setState(() {
          hasCameraPermission = true;
          isRequestingPermission = false;
        });
        print('📷 Web camera permission assumed granted');
        return;
      }

      // For mobile platforms, request actual permission
      PermissionStatus cameraStatus = await Permission.camera.request();
      bool hasPermission = cameraStatus.isGranted;
      
      setState(() {
        hasCameraPermission = hasPermission;
        isRequestingPermission = false;
      });

      if (hasPermission) {
        print('📷 Camera permission granted');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('📷 Camera access granted!'),
              backgroundColor: AppColors.primaryGreen,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        print('📷 Camera permission denied');
        _showPermissionDeniedDialog();
      }
    } catch (e) {
      print('📷 Error requesting camera permission: $e');
      setState(() {
        isRequestingPermission = false;
        hasCameraPermission = kIsWeb; // For web, set to true even on error
      });
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('📷 Camera Permission Required'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Camera access is required to take attendance photos.'),
              SizedBox(height: 8),
              Text('Please grant camera permission in the app settings.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
              ),
              child: const Text('Open Settings', style: TextStyle(color: AppColors.pureWhite)),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
              ),
              child: const Text('Try Again', style: TextStyle(color: AppColors.pureWhite)),
              onPressed: () {
                Navigator.of(context).pop();
                _requestCameraPermission();
              },
            ),
          ],
        );
      },
    );
  }

  void _initializeDatesBasedOnType() {
    final now = DateTime.now();
    setState(() {
      switch (selectedAbsentType) {
        case 'Clock In':
          startDate = now;
          endDate = now;
          break;
        case 'Clock Out':
          startDate = now;
          endDate = now;
          break;
        case 'Annual Leave':
          startDate = now;
          endDate = now.add(const Duration(days: 2));
          break;
        case 'Sick Leave':
          startDate = now;
          endDate = now.add(const Duration(days: 1));
          break;
        case 'Absent':
          startDate = now;
          endDate = now;
          break;
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;
    
    setState(() {
      isLoadingLocation = true;
      detailAddress = 'Getting location...';
    });

    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        throw Exception('Location permission denied');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      print('📍 Position received: ${position.latitude}, ${position.longitude}');
      
      if (!mounted) return;
      
      setState(() {
        currentPosition = position;
        latitude = position.latitude;
        longitude = position.longitude;
      });

      final address = await _getAddressFromLatLng(
        position.latitude, 
        position.longitude
      );

      if (!mounted) return;
      
      setState(() {
        detailAddress = address ?? 'Unable to get address';
        isLoadingLocation = false;
      });

      // Initialize map after getting location
      _initializeMap();

      // Initialize web map if running on web
      /* if (kIsWeb && currentPosition != null) {
        try {
          LeafletService.initializeMap(
            'map-container',
            currentPosition!.latitude, 
            currentPosition!.longitude
          );
        } catch (e) {
          print('Error initializing web map: $e');
        }
      } */
    } catch (e) {
      print('Error getting location: $e');
      if (!mounted) return;
      setState(() {
        detailAddress = 'Failed to get location';
        isLoadingLocation = false;
      });
    } finally {
      if (!mounted) return;
      setState(() {
        isLoadingLocation = false;
      });
    }
  }

  Future<String?> _getAddressFromLatLng(double latitude, double longitude) async {
    try {
      print('🗺️ Getting address for: $latitude, $longitude');
      
      // Use BigDataCloud reverse geocoding API (no CORS issues, free tier available)
      final url = Uri.parse(
        'https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=$latitude&longitude=$longitude&localityLanguage=id'
      );
      
      final response = await http.get(url);
      
      print('🗺️ Address API response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Build a readable address from components
        final List<String> addressParts = [];
        
        if (data['locality'] != null && data['locality'].toString().isNotEmpty) {
          addressParts.add(data['locality']);
        }
        
        // Safely access administrative levels
        if (data['localityInfo'] != null && data['localityInfo']['administrative'] != null) {
          final admin = data['localityInfo']['administrative'] as List<dynamic>?;
          if (admin != null && admin.length > 3 && admin[3]['name'] != null) {
            addressParts.add(admin[3]['name']);
          }
          if (admin != null && admin.length > 2 && admin[2]['name'] != null) {
            addressParts.add(admin[2]['name']);
          }
        }
        
        if (data['principalSubdivision'] != null && data['principalSubdivision'].toString().isNotEmpty) {
          addressParts.add(data['principalSubdivision']);
        }
        
        String address;
        if (addressParts.isNotEmpty) {
          address = addressParts.join(', ');
        } else {
          // Fallback to informative name
          if (data['localityInfo'] != null && data['localityInfo']['informative'] != null) {
            final informative = data['localityInfo']['informative'] as List<dynamic>?;
            address = (informative != null && informative.isNotEmpty && informative[0]['name'] != null)
                ? informative[0]['name']
                : 'Address not found';
          } else {
            address = 'Address not found';
          }
        }
        
        print('🗺️ Address found: $address');
        return address;
      } else {
        print('🗺️ Address API error: ${response.statusCode}');
      }
    } catch (e) {
      print('🗺️ Error getting address: $e');
    }
    return 'Address not available';
  }

  // Web camera capture method - not needed for mobile
  Future<Uint8List?> _captureFromWebCamera() async {
    if (!kIsWeb) return null;
    
    try {
      print('📷 Web camera not implemented for mobile build');
      return null;
    } catch (e) {
      print('📷 Web camera capture error: $e');
      return null;
    }
  }

  Future<void> _capturePhoto() async {
    // For web platform, skip permission check as it's handled by browser
    if (!kIsWeb && !hasCameraPermission) {
      await _requestCameraPermission();
      if (!hasCameraPermission) {
        return;
      }
    }

    setState(() {
      isCapturingImage = true;
    });

    try {
      print('📷 Starting camera capture...');
      print('📷 Platform: ${kIsWeb ? "Web" : "Mobile"}');
      print('📷 Has camera permission: $hasCameraPermission');
      
      final picker = ImagePicker();
      
      // Use camera directly for both web and mobile with square ratio
      final photo = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.front, // Use front camera for selfie
      );

      print('📷 Photo capture result: ${photo != null ? "Success" : "Cancelled"}');

      if (photo != null) {
        final photoBytes = await photo.readAsBytes();
        final compressedBytes = await _compressImageToSquare(photoBytes);
        
        setState(() {
          capturedImageFile = photo;
          capturedImageBytes = compressedBytes;
        });

        print('📷 Photo captured successfully - Size: ${compressedBytes.length} bytes');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('📷 Photo captured successfully!'),
              backgroundColor: AppColors.primaryGreen,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        print('📷 No photo selected or user cancelled');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('📷 No photo selected'),
              backgroundColor: AppColors.primaryYellow,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('📷 Error capturing photo: $e');
      print('📷 Error type: ${e.runtimeType}');
      print('📷 Stack trace: ${StackTrace.current}');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📷 Error capturing photo: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      print('📷 Setting isCapturingImage to false');
      setState(() {
        isCapturingImage = false;
      });
    }
  }

  void _deletePhoto() {
    setState(() {
      capturedImageFile = null;
      capturedImageBytes = null;
    });
  }

  void _showFullScreenPhoto() {
    if (capturedImageBytes == null && capturedImageFile == null) return;
    
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black87,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Stack(
            children: [
              // Full screen photo
              Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width - 40,
                    maxHeight: MediaQuery.of(context).size.height - 100,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: kIsWeb && capturedImageBytes != null
                        ? Image.memory(
                            capturedImageBytes!,
                            fit: BoxFit.contain,
                          )
                        : capturedImageBytes != null
                            ? Image.memory(
                                capturedImageBytes!,
                                fit: BoxFit.contain,
                              )
                            : Container(),
                  ),
                ),
              ),
              // Close button
              Positioned(
                top: 20,
                right: 20,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
              // Action buttons
              Positioned(
                bottom: 40,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Retake photo button
                    Container(
                      margin: const EdgeInsets.only(right: 16),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _capturePhoto();
                        },
                        icon: const Icon(Icons.camera_alt, color: Colors.white),
                        label: const Text(
                          'Retake Photo',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    // Delete photo button
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _deletePhoto();
                      },
                      icon: const Icon(Icons.delete, color: Colors.white),
                      label: const Text(
                        'Delete Photo',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.errorRed,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<Uint8List> _compressImageToSquare(Uint8List imageBytes) async {
    try {
      // Decode the image first
      ui.Codec codec = await ui.instantiateImageCodec(imageBytes);
      ui.FrameInfo frameInfo = await codec.getNextFrame();
      ui.Image originalImage = frameInfo.image;
      
      // Calculate square size (use the smaller dimension)
      int originalWidth = originalImage.width;
      int originalHeight = originalImage.height;
      int squareSize = originalWidth < originalHeight ? originalWidth : originalHeight;
      
      // Target size for square image
      int targetSize = 400; // 400x400 pixels for better performance
      
      // Create square canvas
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      
      // Calculate crop position to center the image
      double sourceX = (originalWidth - squareSize) / 2;
      double sourceY = (originalHeight - squareSize) / 2;
      
      // Draw the cropped and resized image
      canvas.drawImageRect(
        originalImage,
        Rect.fromLTWH(sourceX, sourceY, squareSize.toDouble(), squareSize.toDouble()),
        Rect.fromLTWH(0, 0, targetSize.toDouble(), targetSize.toDouble()),
        Paint(),
      );
      
      // Convert to image
      final picture = recorder.endRecording();
      final squareImage = await picture.toImage(targetSize, targetSize);
      
      // Convert to bytes
      final ByteData? byteData = await squareImage.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final compressedBytes = byteData.buffer.asUint8List();
        print('[AttendanceForm] Image compressed to square: ${targetSize}x$targetSize, size: ${compressedBytes.length} bytes');
        return compressedBytes;
      }
      
      // Fallback to original compression if square processing fails
      return await _compressImage(imageBytes);
    } catch (e) {
      print('[AttendanceForm] Error creating square image: $e');
      // Fallback to original compression
      return await _compressImage(imageBytes);
    }
  }

  Future<Uint8List> _compressImage(Uint8List imageBytes) async {
    try {
      // Compress the image using ui.instantiateImageCodec
      ui.Codec codec = await ui.instantiateImageCodec(
        imageBytes,
        targetWidth: 800,
        targetHeight: 800,
      );
      ui.FrameInfo frameInfo = await codec.getNextFrame();
      
      // Convert to bytes with PNG format first
      final ByteData? byteData = await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final compressedBytes = byteData.buffer.asUint8List();
        
        // If still too large, resize further
        if (compressedBytes.length > 200 * 1024) { // 200KB
          return await _resizeImageToTarget(imageBytes, targetSizeKB: 200);
        }
        
        return compressedBytes;
      }
      
      return imageBytes;
    } catch (e) {
      print('Error compressing image: $e');
      return imageBytes;
    }
  }

  Future<Uint8List> _resizeImageToTarget(Uint8List imageBytes, {required int targetSizeKB}) async {
    try {
      int quality = 90;
      Uint8List result = imageBytes;
      
      while (result.length > targetSizeKB * 1024 && quality > 10) {
        ui.Codec codec = await ui.instantiateImageCodec(
          imageBytes,
          targetWidth: (800 * quality / 100).round(),
          targetHeight: (800 * quality / 100).round(),
        );
        ui.FrameInfo frameInfo = await codec.getNextFrame();
        
        final ByteData? byteData = await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData != null) {
          result = byteData.buffer.asUint8List();
        }
        
        quality -= 10;
      }
      
      return result;
    } catch (e) {
      print('Error resizing image: $e');
      return imageBytes;
    }
  }

  Future<void> _saveTimeToSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
    final userId = prefs.getString('user_id') ?? '';
    
    if (selectedAbsentType == 'Clock In') {
      // Set clock in time and clear clock out time for the day
      await prefs.setString('clock_in_time', currentTime);
      await prefs.setString('clock_in_${userId}_$today', currentTime);
      await prefs.remove('clock_out_time'); // Clear clock out
      print('[AttendanceForm] Clock In time saved: $currentTime');
    } else if (clockOutTypes.contains(selectedAbsentType)) {
      // Set clock out time
      await prefs.setString('clock_out_time', currentTime);
      await prefs.setString('clock_out_${userId}_$today', currentTime);
      print('[AttendanceForm] Clock Out time saved: $currentTime for type: $selectedAbsentType');
    }
  }

  Future<void> _saveAttendance() async {
    if (latitude == null || longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Location is required'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    if (capturedImageFile == null && capturedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Photo is required'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Date selection is required'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      print('💾 Saving attendance...');
      print('📍 Type: $selectedAbsentType');
      print('📅 Dates: $startDate to $endDate');
      print('🌍 Location: $latitude, $longitude');
      print('📷 Image: ${capturedImageFile?.toString()}');

      final response = await _attendanceService.submitAttendanceWithImage(
        type: selectedAbsentType,
        startDate: startDate!,
        endDate: endDate!,
        latitude: latitude!,
        longitude: longitude!,
        address: detailAddress,
        image: capturedImageFile,
        notes: 'Submitted via mobile app',
      );

      if (response.success) {
        // Save clock in/out time to SharedPreferences for dashboard display
        await _saveTimeToSharedPreferences();
        
        // Update clock status based on the submitted type
        _updateClockStatus();
        
        if (mounted) {
          // Determine the display type based on widget.type or selectedAbsentType
          final displayType = widget.type == 'clock_in' ? 'Clock In' : 
                             widget.type == 'clock_out' ? 'Clock Out' : 
                             selectedAbsentType;
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '✅ Attendance saved successfully!',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('Type: $displayType'),
                  Text('Date: ${DateFormat('dd/MM/yyyy').format(startDate!)}'),
                  if (startDate != endDate)
                    Text('Until: ${DateFormat('dd/MM/yyyy').format(endDate!)}'),
                  Text('Location: ${detailAddress.length > 30 ? detailAddress.substring(0, 30) : detailAddress}...'),
                  const Text('Photo: Uploaded successfully'),
                ],
              ),
              backgroundColor: AppColors.primaryGreen,
              duration: const Duration(seconds: 5),
            ),
          );

          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save attendance: ${response.message}'),
              backgroundColor: AppColors.errorRed,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      print('[AttendanceForm] Error saving attendance: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving attendance: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  String _calculateDuration() {
    if (startDate == null || endDate == null) return '';
    
    final difference = endDate!.difference(startDate!).inDays + 1;
    return '$difference day${difference > 1 ? 's' : ''}';
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime(2020);
    DateTime lastDate = DateTime(2030);
    
    if (selectedAbsentType == 'Clock In' || selectedAbsentType == 'Clock Out') {
      return;
    }

    if (!isStartDate && startDate != null) {
      initialDate = endDate ?? startDate!;
      firstDate = startDate!;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
          if (endDate != null && picked.isAfter(endDate!)) {
            endDate = picked;
          }
        } else {
          endDate = picked;
        }
      });
    }
  }

  void _initializeMap() {
    if (!kIsWeb || latitude == null || longitude == null) return;

    // Generate unique view ID with timestamp to avoid collision
    mapViewId = 'map-view-${DateTime.now().millisecondsSinceEpoch}';
    
    // Check if already registered, if yes return early
    try {
      // Register view factory only once
      ui_web.platformViewRegistry.registerViewFactory(mapViewId!, (int viewId) {
        final mapDiv = html.DivElement()
          ..id = mapViewId!
          ..style.width = '100%'
          ..style.height = '100%';

        // Initialize Leaflet map after a short delay to ensure div is in DOM
        Future.delayed(const Duration(milliseconds: 300), () {
          final script = html.ScriptElement()
            ..text = '''
              if (typeof L !== 'undefined') {
                var map = L.map('$mapViewId', {
                  dragging: true,
                  touchZoom: true,
                  scrollWheelZoom: true,
                  doubleClickZoom: true,
                  boxZoom: false,
                  keyboard: false,
                  zoomControl: true
                }).setView([${latitude!}, ${longitude!}], 15);
                
                L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                  attribution: '© OpenStreetMap contributors'
                }).addTo(map);
                
                L.marker([${latitude!}, ${longitude!}], {
                  draggable: false
                }).addTo(map);
              }
            ''';
          html.document.body!.append(script);
        });

        return mapDiv;
      });
    } catch (e) {
      print('Map view already registered or error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTimeDisplay = DateFormat('HH : mm : ss').format(DateTime.now());
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Attendance Form',
          style: TextStyle(
            color: AppColors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time Section
            const Text(
              'Time',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                currentTimeDisplay,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.black87,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Clock Status Indicator
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isUserClockedIn ? AppColors.primaryGreen.withOpacity(0.1) : AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isUserClockedIn ? AppColors.primaryGreen : AppColors.primaryBlue,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isUserClockedIn ? Icons.check_circle : Icons.access_time,
                    color: isUserClockedIn ? AppColors.primaryGreen : AppColors.primaryBlue,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isUserClockedIn ? 'Currently Clocked In' : 'Ready to Clock In',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isUserClockedIn ? AppColors.primaryGreen : AppColors.primaryBlue,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Absent Type Dropdown
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedAbsentType,
                  hint: const Text(
                    'Choose Absent Type',
                    style: TextStyle(color: Colors.grey),
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: availableOptions.map((String type) {
                    Color? backgroundColor;
                    if (type == 'Absent') {
                      backgroundColor = AppColors.primaryYellow;
                    }
                    
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          type,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.black87,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null && availableOptions.contains(newValue)) {
                      setState(() {
                        selectedAbsentType = newValue;
                        _initializeDatesBasedOnType();
                      });
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Date pickers for start and end date
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Start Date',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: (selectedAbsentType == 'Clock In' || selectedAbsentType == 'Clock Out') 
                            ? null 
                            : () => _selectDate(context, true),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                          decoration: BoxDecoration(
                            color: (selectedAbsentType == 'Clock In' || selectedAbsentType == 'Clock Out') 
                                ? Colors.grey.shade200 
                                : AppColors.pureWhite,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            startDate != null 
                                ? DateFormat('dd/MM/yyyy').format(startDate!)
                                : 'Select start date',
                            style: TextStyle(
                              fontSize: 12,
                              color: startDate != null ? AppColors.black87 : Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      if (selectedAbsentType == 'Clock In' || selectedAbsentType == 'Clock Out')
                        const Text(
                          'Auto-selected for clock in/out',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'End Date',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: (selectedAbsentType == 'Clock In' || selectedAbsentType == 'Clock Out') 
                            ? null 
                            : () => _selectDate(context, false),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                          decoration: BoxDecoration(
                            color: (selectedAbsentType == 'Clock In' || selectedAbsentType == 'Clock Out') 
                                ? Colors.grey.shade200 
                                : AppColors.pureWhite,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            endDate != null 
                                ? DateFormat('dd/MM/yyyy').format(endDate!)
                                : 'Select end date',
                            style: TextStyle(
                              fontSize: 12,
                              color: endDate != null ? AppColors.black87 : Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      if (selectedAbsentType == 'Clock In' || selectedAbsentType == 'Clock Out')
                        const Text(
                          'Auto-selected for clock in/out',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                    ],
                  ),
                ),
              ],
            ),

            // Duration display
            if (startDate != null && endDate != null &&
                (selectedAbsentType == 'Annual Leave' || selectedAbsentType == 'Sick Leave' ||
                 selectedAbsentType == 'Absent'))
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.timer,
                      color: AppColors.primaryBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Duration: ${_calculateDuration()}',
                        style: const TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Photo Section
            const Text(
              'Photo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.black87,
              ),
            ),
            const SizedBox(height: 8),

            GestureDetector(
              onTap: () {
                if (capturedImageFile == null && !isCapturingImage) {
                  _capturePhoto();
                } else if (!hasCameraPermission) {
                  _requestCameraPermission();
                } else {
                  print('📷 Cannot capture: hasImage=${capturedImageFile != null}, isCapturing=$isCapturingImage');
                }
              },
              child: Container(
                width: double.infinity,
                height: 200, // Fixed height for 1:1 preview
                decoration: BoxDecoration(
                  color: capturedImageFile == null
                      ? AppColors.primaryBlue.withValues(alpha: 0.02)
                      : AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: (capturedImageFile == null && capturedImageBytes == null)
                        ? AppColors.primaryBlue.withValues(alpha: 0.3)
                        : Colors.grey.shade300,
                    width: (capturedImageFile == null && capturedImageBytes == null) ? 2 : 1,
                  ),
                ),
                child: (capturedImageFile != null || capturedImageBytes != null)
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(7),
                            child: Center(
                              child: AspectRatio(
                                aspectRatio: 1.0, // 1:1 aspect ratio
                                child: kIsWeb
                                    ? Image.memory(
                                        capturedImageBytes!,
                                        fit: BoxFit.cover,
                                      )
                                    : capturedImageBytes != null
                                        ? Image.memory(
                                            capturedImageBytes!,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: _deletePhoto,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: AppColors.errorRed,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: AppColors.pureWhite,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                Icons.fullscreen,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                '📷 Photo Captured',
                                style: TextStyle(
                                  color: AppColors.pureWhite,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: isCapturingImage ? null : () {
                                  print('📷 Photo preview tapped!');
                                  _showFullScreenPhoto();
                                },
                              ),
                            ),
                          ),
                        ],
                      )
                    : GestureDetector(
                        onTap: () {
                          print('📷 Camera button tapped (MouseRegion version)!');
                          print('📷 isCapturingImage: $isCapturingImage');
                          print('📷 hasCameraPermission: $hasCameraPermission');
                          if (!isCapturingImage) {
                            _capturePhoto();
                          }
                        },
                        child: MouseRegion(
                          cursor: (capturedImageFile == null && capturedImageBytes == null) ? SystemMouseCursors.click : SystemMouseCursors.basic,
                          child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: AppColors.primaryBlue,
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              !kIsWeb
                                  ? (isCapturingImage
                                      ? 'Capturing...'
                                      : hasCameraPermission 
                                          ? (isCapturingImage
                                              ? 'Capturing Photo...'
                                              : 'Tap to capture photo')
                                          : isRequestingPermission
                                              ? 'Requesting permission...'
                                              : 'Camera permission required')
                                  : (hasCameraPermission || kIsWeb
                                      ? 'Tap to capture photo'
                                      : isRequestingPermission
                                          ? 'Requesting permission...'
                                          : 'Camera permission required'),
                              style: TextStyle(
                                color: hasCameraPermission || kIsWeb
                                    ? AppColors.primaryBlue
                                    : isRequestingPermission
                                        ? AppColors.primaryYellow
                                        : AppColors.errorRed,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              !kIsWeb
                                  ? hasCameraPermission
                                      ? 'Required for attendance'
                                      : isRequestingPermission
                                          ? 'Please allow camera access'
                                          : 'Grant permission to continue'
                                  : 'Required for attendance',
                              style: TextStyle(
                                color: hasCameraPermission || kIsWeb
                                    ? AppColors.primaryBlue
                                    : isRequestingPermission
                                        ? AppColors.primaryYellow
                                        : AppColors.errorRed,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ),
              ),
            ),

            // Camera permission warning
            if (capturedImageFile == null && capturedImageBytes == null)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primaryYellow.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: AppColors.primaryYellow,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Photo is required for attendance submission',
                        style: TextStyle(
                          color: AppColors.black87,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Location Section
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: AppColors.primaryGreen,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Location detected automatically for attendance verification',
                      style: TextStyle(
                        color: AppColors.black87,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Address display only
            const Text(
              'Address',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  if (isLoadingLocation)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  Expanded(
                    child: Text(
                      detailAddress,
                      style: TextStyle(
                        fontSize: 14,
                        color: isLoadingLocation ? Colors.grey : AppColors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Map View
            if (latitude != null && longitude != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Location Map',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: kIsWeb && mapViewId != null
                          ? HtmlElementView(
                              viewType: mapViewId!,
                            )
                          : kIsWeb
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : Center(
                                child: Text(
                                  'Map view only available on web',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),

            const SizedBox(height: 10),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSaving
                      ? Colors.grey
                      : AppColors.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: isSaving ? null : _saveAttendance,
                child: isSaving
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.pureWhite),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Saving...',
                            style: TextStyle(
                              color: AppColors.pureWhite,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : const Text(
                        'Submit Attendance',
                        style: TextStyle(
                          color: AppColors.pureWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// Real attendance service that saves to Firestore
class DummyAttendanceService {
  Future<DummyAttendanceResponse> submitAttendanceWithImage({
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    required double latitude,
    required double longitude,
    required String address,
    required XFile? image,
    required String notes,
  }) async {
    try {
      // Get employee ID from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final employeeId = prefs.getString('employee_id') ?? '';
      final userId = prefs.getString('user_id') ?? ''; // Keep user_id as backup
      
      if (employeeId.isEmpty) {
        return DummyAttendanceResponse(success: false, message: 'Employee ID not found');
      }

      // Prepare data for Firestore
      final now = DateTime.now();
      final today = DateFormat('yyyy-MM-dd').format(now);
      final currentTime = DateFormat('HH:mm:ss').format(now);
      
      // Get current attendance record for today (if exists)
      final attendanceQuery = await FirebaseFirestore.instance
          .collection('attendance')
          .where('employee_id', isEqualTo: employeeId)
          .where('date', isEqualTo: today)
          .limit(1)
          .get();

      Map<String, dynamic> attendanceData = {
        'employee_id': employeeId,
        'user_id': userId, // Keep for backward compatibility
        'date': today,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      if (type == 'Clock In') {
        // Clock In
        attendanceData.addAll({
          'check_in_time': currentTime,
          'check_in_location': {
            'address': address,
            'latitude': latitude,
            'longitude': longitude,
          },
          'status': 'present', // Set status for clock in
          'type': 'clock_in',
        });
        
        if (attendanceQuery.docs.isNotEmpty) {
          // Update existing record
          await attendanceQuery.docs.first.reference.update(attendanceData);
        } else {
          // Create new record
          await FirebaseFirestore.instance.collection('attendance').add(attendanceData);
        }
        
      } else if (['Clock Out', 'Annual Leave', 'Sick Leave'].contains(type)) {
        // Clock Out (including leave types)
        final status = type == 'Clock Out' ? 'present' : 
                      type == 'Annual Leave' ? 'annual_leave' : 
                      type == 'Sick Leave' ? 'sick_leave' : 'present';
        
        attendanceData.addAll({
          'check_out_time': currentTime,
          'check_out_location': {
            'address': address,
            'latitude': latitude,
            'longitude': longitude,
          },
          'type': type, // Store the leave type if applicable
          'status': status, // Set appropriate status
        });
        
        if (attendanceQuery.docs.isNotEmpty) {
          // Update existing record
          await attendanceQuery.docs.first.reference.update(attendanceData);
        } else {
          // This shouldn't happen (clock out without clock in), but handle it
          attendanceData['check_in_time'] = '00:00:00'; // Default
          await FirebaseFirestore.instance.collection('attendance').add(attendanceData);
        }
        
      } else if (type == 'Absent') {
        // Absent - no check in/out times, just mark as absent
        attendanceData.addAll({
          'type': 'Absent',
          'status': 'absent', // Set status as absent
          'location': {
            'address': address,
            'latitude': latitude,
            'longitude': longitude,
          },
        });
        
        await FirebaseFirestore.instance.collection('attendance').add(attendanceData);
      }

      print('[AttendanceForm] Attendance saved to Firestore successfully');
      print('[AttendanceForm] Type: $type, Date: $today, Time: $currentTime');
      
      return DummyAttendanceResponse(success: true, message: 'Attendance saved successfully');
      
    } catch (e) {
      print('[AttendanceForm] Error saving attendance to Firestore: $e');
      return DummyAttendanceResponse(success: false, message: 'Error: $e');
    }
  }
}

class DummyAttendanceResponse {
  final bool success;
  final String message;
  DummyAttendanceResponse({required this.success, required this.message});
}