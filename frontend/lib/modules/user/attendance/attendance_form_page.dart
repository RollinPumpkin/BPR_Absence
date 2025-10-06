import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:html' as html;
import 'dart:js' as js;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final List<String> absentTypes = [
    'Clock In',
    'Clock Out',
    'Absent',
    'Annual Leave',
    'Sick Leave',
  ];
  late Timer _timer;
  String currentTime = '';
  String currentDate = '';
  final TextEditingController _notesController = TextEditingController();
  final _attendanceService = DummyAttendanceService();

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
    _getCurrentLocation();
    // Initialize camera permission (for web, this will be set to true automatically)
    _requestCameraPermission();
    _initializeDatesBasedOnType();
  }

  @override
  void dispose() {
    _timer.cancel();
    _notesController.dispose();
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
      
      setState(() {
        currentPosition = position;
        latitude = position.latitude;
        longitude = position.longitude;
      });

      final address = await _getAddressFromLatLng(
        position.latitude, 
        position.longitude
      );

      setState(() {
        detailAddress = address ?? 'Unknown location';
        isLoadingLocation = false;
      });

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
      setState(() {
        detailAddress = 'Failed to get location';
        isLoadingLocation = false;
      });
    } finally {
      setState(() {
        isLoadingLocation = false;
      });
    }
  }

  Future<String?> _getAddressFromLatLng(double latitude, double longitude) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude&zoom=18&addressdetails=1'
      );
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['display_name'] ?? 'Unknown location';
      }
    } catch (e) {
      print('Error getting address: $e');
    }
    return null;
  }

  Future<Uint8List?> _captureFromWebCamera() async {
    if (!kIsWeb) return null;
    
    try {
      print('📷 Attempting to access web camera directly...');
      
      // Call JavaScript function to access camera
      final completer = Completer<Uint8List?>();
      
      // Access camera through getUserMedia
      final mediaDevices = html.window.navigator.mediaDevices;
      if (mediaDevices != null) {
        final stream = await mediaDevices.getUserMedia({'video': true});
        
        // Create video element
        final video = html.VideoElement();
        video.srcObject = stream;
        video.autoplay = true;
        
        // Wait for video to be ready
        await video.onLoadedMetadata.first;
        
        // Create canvas to capture frame
        final canvas = html.CanvasElement(width: 1200, height: 1200);
        final ctx = canvas.context2D;
        
        // Draw video frame to canvas
        ctx.drawImageScaled(video, 0, 0, canvas.width!, canvas.height!);
        
        // Stop camera stream
        stream.getTracks().forEach((track) => track.stop());
        
        // Convert canvas to blob
        final blob = await canvas.toBlob('image/jpeg', 0.8);
        final reader = html.FileReader();
        reader.readAsArrayBuffer(blob);
        await reader.onLoad.first;
        
        final result = reader.result as List<int>;
        return Uint8List.fromList(result);
      }
      
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
      
      Uint8List? photoBytes;
      
      if (kIsWeb) {
        // Try web camera capture first
        photoBytes = await _captureFromWebCamera();
        
        if (photoBytes == null) {
          // Fallback to image picker
          print('📷 Fallback to image picker...');
          final picker = ImagePicker();
          final photo = await picker.pickImage(
            source: ImageSource.camera,
            maxWidth: 1200,
            maxHeight: 1200,
            imageQuality: 80,
          );
          
          if (photo != null) {
            photoBytes = await photo.readAsBytes();
          }
        }
      } else {
        // Mobile platform - use image picker
        final picker = ImagePicker();
        final photo = await picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1200,
          maxHeight: 1200,
          imageQuality: 80,
        );
        
        if (photo != null) {
          photoBytes = await photo.readAsBytes();
          setState(() {
            capturedImageFile = photo;
          });
        }
      }

      print('📷 Photo capture result: ${photoBytes != null ? "Success" : "Cancelled"}');

      if (photoBytes != null) {
        final compressedBytes = await _compressImage(photoBytes);
        
        setState(() {
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
      await prefs.setString('clock_in_${userId}_$today', currentTime);
      print('✅ Clock In time saved: $currentTime');
    } else if (selectedAbsentType == 'Clock Out') {
      await prefs.setString('clock_out_${userId}_$today', currentTime);
      print('✅ Clock Out time saved: $currentTime');
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
        
        if (mounted) {
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
                  Text('Type: $selectedAbsentType'),
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
      print('❌ Error saving attendance: $e');
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

  void _refreshLocation() {
    _getCurrentLocation();
  }

  void _initializeMap() {
    /*if (kIsWeb) {
      try {
        if (currentPosition != null) {
          LeafletService.initializeMap(
            'map-container',
            currentPosition!.latitude, 
            currentPosition!.longitude
          );
        }
      } catch (e) {
        print('Error initializing map: $e');
      }
    }*/
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
        padding: const EdgeInsets.all(16),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            
            // Absent Type Dropdown
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                  items: absentTypes.map((String type) {
                    Color? backgroundColor;
                    if (type == 'Absent') {
                      backgroundColor = AppColors.primaryYellow;
                    }
                    
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
                    setState(() {
                      selectedAbsentType = newValue!;
                      _initializeDatesBasedOnType();
                    });
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
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: (selectedAbsentType == 'Clock In' || selectedAbsentType == 'Clock Out') 
                            ? null 
                            : () => _selectDate(context, true),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                              fontSize: 16,
                              color: startDate != null ? AppColors.black87 : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      if (selectedAbsentType == 'Clock In' || selectedAbsentType == 'Clock Out')
                        const Text(
                          'Auto-selected for clock in/out',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'End Date',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: (selectedAbsentType == 'Clock In' || selectedAbsentType == 'Clock Out') 
                            ? null 
                            : () => _selectDate(context, false),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                              fontSize: 16,
                              color: endDate != null ? AppColors.black87 : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      if (selectedAbsentType == 'Clock In' || selectedAbsentType == 'Clock Out')
                        const Text(
                          'Auto-selected for clock in/out',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
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
                    Icon(
                      Icons.timer,
                      color: AppColors.primaryBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Duration: ${_calculateDuration()}',
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w500,
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
                height: capturedImageFile != null ? 200 : 110,
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
                            child: kIsWeb
                                ? Image.memory(
                                    capturedImageBytes!,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                : capturedImageBytes != null
                                    ? Image.memory(
                                        capturedImageBytes!,
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(),
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
                              child: Icon(
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
                child: Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: AppColors.primaryYellow,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
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
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: AppColors.primaryGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
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

            // Location Details Header
            const Text(
              'Location Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.black87,
              ),
            ),
            const SizedBox(height: 8),

            // Location dropdown (placeholder)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                selectedLocation,
                style: TextStyle(
                  fontSize: 16,
                  color: selectedLocation == 'Choose Location' ? Colors.grey : AppColors.black87,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Address display
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
              child: Text(
                detailAddress,
                style: TextStyle(
                  fontSize: 14,
                  color: isLoadingLocation ? Colors.grey : AppColors.black87,
                ),
              ),
            ),
            if (isLoadingLocation)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: _refreshLocation,
                      icon: const Icon(Icons.refresh, color: AppColors.primaryBlue),
                      label: const Text('Refresh'),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Coordinate display
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Latitude',
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
                        child: Text(
                          latitude != null ? latitude!.toStringAsFixed(6) : '-',
                          style: TextStyle(
                            fontSize: 14,
                            color: latitude != null ? AppColors.black87 : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Longitude',
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
                        child: Text(
                          longitude != null ? longitude!.toStringAsFixed(6) : '-',
                          style: TextStyle(
                            fontSize: 14,
                            color: longitude != null ? AppColors.black87 : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

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
                    ? Row(
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
                          const SizedBox(width: 12),
                          const Text(
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

// Dummy attendance service for testing
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
    await Future.delayed(const Duration(seconds: 1));
    return DummyAttendanceResponse(success: true, message: 'Success');
  }
}

class DummyAttendanceResponse {
  final bool success;
  final String message;
  DummyAttendanceResponse({required this.success, required this.message});
}