import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/core/services/location_service.dart';
import 'package:frontend/core/services/camera_service.dart';
import 'package:frontend/data/services/attendance_service.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

class AttendanceFormPage extends StatefulWidget {
  const AttendanceFormPage({super.key});

  @override
  State<AttendanceFormPage> createState() => _AttendanceFormPageState();
}

class _AttendanceFormPageState extends State<AttendanceFormPage> {
  Timer? _timer;
  String selectedAbsentType = 'Clock In';
  DateTime? endDate;
  String selectedLocation = 'Choose Location';
  String detailAddress = 'Getting location...';
  double? latitude;
  double? longitude;
  bool isLoadingLocation = false;
  Position? currentPosition;
  XFile? capturedImageFile; // Use XFile for web compatibility
  Uint8List? capturedImageBytes; // Store image bytes for web
  bool isCapturingImage = false;
  bool isSaving = false;
  bool hasCameraPermission = false;
  bool isRequestingPermission = false;
  
  final AttendanceService _attendanceService = AttendanceService();

  final List<String> absentTypes = [
    'Clock In',
    'Clock Out',
    'Absent',
    'Annual Leave',
    'Sick Leave',
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _setDefaultDates(); // Set tanggal default
    _requestCameraPermission(); // Request camera permission on init
  }

  /// Request camera permission when the page loads
  Future<void> _requestCameraPermission() async {
    if (kIsWeb) {
      // For web, we can't request permission until user interaction
      // We'll handle this when user actually tries to use camera
      print('📷 Web platform - camera permission will be requested on first use');
      setState(() {
        hasCameraPermission = true; // Assume available for web
      });
      return;
    }

    setState(() {
      isRequestingPermission = true;
    });

    try {
      print('📷 Checking camera permission status...');
      
      // Check current permission status (might already be granted from app startup)
      PermissionStatus cameraStatus = await Permission.camera.status;
      print('📷 Current camera permission status: $cameraStatus');

      if (cameraStatus.isGranted) {
        // Already granted (likely from app startup)
        print('📷 Camera permission already granted from app startup');
        setState(() {
          hasCameraPermission = true;
          isRequestingPermission = false;
        });
        return;
      }

      if (cameraStatus.isDenied) {
        // Request permission
        print('📷 Requesting camera permission...');
        cameraStatus = await Permission.camera.request();
        print('📷 Permission request result: $cameraStatus');
      }

      bool hasPermission = cameraStatus.isGranted;
      
      setState(() {
        hasCameraPermission = hasPermission;
        isRequestingPermission = false;
      });

      if (hasPermission) {
        print('📷 Camera permission granted');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📷 Camera access granted!'),
            backgroundColor: AppColors.primaryGreen,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        print('📷 Camera permission denied');
        _showPermissionDeniedDialog();
      }
    } catch (e) {
      print('📷 Error requesting camera permission: $e');
      setState(() {
        isRequestingPermission = false;
        hasCameraPermission = false;
      });
    }
  }

  /// Show dialog when camera permission is denied
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('📷 Camera Permission Required'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('This app needs camera access to take attendance photos.'),
              SizedBox(height: 12),
              Text('To enable camera access:'),
              SizedBox(height: 8),
              Text('1. Go to device Settings'),
              Text('2. Find this app in Apps/Applications'),
              Text('3. Enable Camera permission'),
              Text('4. Return to this app'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings(); // Open app settings
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
              ),
              child: const Text('Open Settings', style: TextStyle(color: AppColors.pureWhite)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _requestCameraPermission(); // Try again
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
              ),
              child: const Text('Try Again', style: TextStyle(color: AppColors.pureWhite)),
            ),
          ],
        );
      },
    );
  }

  void _setDefaultDates() {
    final now = DateTime.now();
    setState(() {
      switch (selectedAbsentType) {
        case 'Clock In':
        case 'Clock Out':
          // Untuk clock in/out, hanya hari ini
          startDate = now;
          endDate = now;
          break;
        case 'Absent':
          // Untuk absent, biasanya hari ini
          startDate = now;
          endDate = now;
          break;
        case 'Annual Leave':
          // Annual leave default 3 hari
          startDate = now;
          endDate = now.add(const Duration(days: 2));
          break;
        case 'Sick Leave':
          // Sick leave default 2 hari
          startDate = now;
          endDate = now.add(const Duration(days: 1));
          break;
        default:
          startDate = now;
          endDate = now;
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    print('📍 Starting _getCurrentLocation...');
    setState(() {
      isLoadingLocation = true;
      detailAddress = 'Getting location...';
    });

    try {
      print('📍 Calling LocationService.getCurrentLocation...');
      Position? position = await LocationService.getCurrentLocation();
      if (position != null) {
        print('📍 Position received: ${position.latitude}, ${position.longitude}');
        setState(() {
          currentPosition = position;
          latitude = position.latitude;
          longitude = position.longitude;
        });

        // Get address from coordinates
        print('📍 Getting address from coordinates...');
        String? address = await LocationService.getAddressFromCoordinates(
          position.latitude, 
          position.longitude
        );
        
        print('📍 Address received: $address');
        setState(() {
          detailAddress = address ?? 'Unknown location';
          isLoadingLocation = false;
        });

        print('📍 Location updated successfully');
      } else {
        print('📍 Position is null');
        setState(() {
          detailAddress = 'Failed to get location';
          isLoadingLocation = false;
        });
      }
    } catch (e) {
      print('📍 Error in _getCurrentLocation: $e');
      setState(() {
        detailAddress = 'Error getting location: $e';
        isLoadingLocation = false;
      });
    }
  }

  void _updateDatesBasedOnType(String absentType) {
    final now = DateTime.now();
    setState(() {
      switch (absentType) {
        case 'Clock In':
        case 'Clock Out':
          // Clock in/out selalu hari ini
          startDate = now;
          endDate = now;
          break;
        case 'Absent':
          // Absent biasanya hari ini, tapi bisa diubah manual
          startDate = now;
          endDate = now;
          break;
        case 'Annual Leave':
          // Annual leave default 3 hari (hari ini + 2 hari ke depan)
          startDate = now;
          endDate = now.add(const Duration(days: 2));
          break;
        case 'Sick Leave':
          // Sick leave default 2 hari (hari ini + besok)
          startDate = now;
          endDate = now.add(const Duration(days: 1));
          break;
        default:
          startDate = now;
          endDate = now;
      }
    });
  }

  void _refreshLocation() {
    print('📍 Refresh location requested');
    _getCurrentLocation();
  }

  Future<void> _capturePhoto() async {
    print('📷 _capturePhoto method called!');

    // Check camera permission first
    if (!kIsWeb && !hasCameraPermission) {
      print('📷 No camera permission, requesting...');
      await _requestCameraPermission();
      if (!hasCameraPermission) {
        print('📷 Permission denied, cannot proceed');
        return;
      }
    }

    setState(() {
      isCapturingImage = true;
    });

    try {
      print('📷 Initializing ImagePicker...');
      final ImagePicker picker = ImagePicker();
      
      print('📷 Platform: ${kIsWeb ? 'Web' : 'Mobile'}');
      
      XFile? photo;
      
      if (kIsWeb) {
        // For web, show guidance message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📷 Opening camera... Please allow camera access when prompted'),
            backgroundColor: AppColors.primaryBlue,
            duration: Duration(seconds: 3),
          ),
        );
        
        print('📷 Web platform - accessing camera with permission prompt...');
        photo = await picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 70,
          maxWidth: 1000,
          maxHeight: 1000,
        );
      } else {
        // For mobile, standard camera access
        print('📷 Mobile platform - accessing camera...');
        photo = await picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 70,
          maxWidth: 1000,
          maxHeight: 1000,
        );
      }

      print('📷 ImagePicker result: ${photo != null ? 'Success' : 'Null'}');

      if (photo != null) {
        print('📷 Reading image bytes...');
        // Read original image bytes
        final Uint8List originalBytes = await photo.readAsBytes();
        double originalSizeKB = originalBytes.length / 1024;
        
        print('📷 Original image: ${originalSizeKB.toStringAsFixed(1)} KB');
        
        // Resize image to 200KB target
        print('📷 Starting image compression...');
        final Uint8List compressedBytes = await _resizeImageToTarget(originalBytes, targetSizeKB: 200);
        double compressedSizeKB = compressedBytes.length / 1024;
        
        print('📷 Setting state with compressed image...');
        setState(() {
          capturedImageFile = photo;
          capturedImageBytes = compressedBytes;
        });
        
        print('📷 Showing success message...');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📷 Photo optimized successfully!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Original: ${originalSizeKB.toStringAsFixed(0)} KB'),
                Text('Optimized: ${compressedSizeKB.toStringAsFixed(0)} KB'),
                Text('Reduction: ${((originalSizeKB - compressedSizeKB) / originalSizeKB * 100).toStringAsFixed(0)}%'),
              ],
            ),
            backgroundColor: AppColors.primaryGreen,
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        print('📷 User cancelled camera or no photo selected');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📷 Camera access cancelled'),
            backgroundColor: AppColors.primaryYellow,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('📷 Error capturing photo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to capture photo: $e'),
          backgroundColor: AppColors.errorRed,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      print('📷 Setting isCapturingImage to false');
      setState(() {
        isCapturingImage = false;
      });
    }
  }

  void _removePhoto() {
    setState(() {
      capturedImageFile = null;
      capturedImageBytes = null;
    });
  }

  /// Alternative method for web camera access
  Future<void> _capturePhotoAlternative() async {
    try {
      // For web, we can try using HTML5 getUserMedia API through JavaScript
      if (kIsWeb) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📷 Accessing camera... Please allow camera permission when prompted'),
            backgroundColor: AppColors.primaryBlue,
            duration: Duration(seconds: 3),
          ),
        );
      }
      
      final ImagePicker picker = ImagePicker();
      
      // Try with different approaches for web
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        maxWidth: 1000,
        maxHeight: 1000,
      );
      
      if (photo != null) {
        final Uint8List originalBytes = await photo.readAsBytes();
        final Uint8List compressedBytes = await _resizeImageToTarget(originalBytes, targetSizeKB: 200);
        
        setState(() {
          capturedImageFile = photo;
          capturedImageBytes = compressedBytes;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📷 Photo captured successfully!'),
            backgroundColor: AppColors.primaryGreen,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('📷 Alternative capture failed: $e');
    }
  }

  /// Show camera options for web users with permission request
  void _showCameraOptions() {
    if (kIsWeb) {
      _requestWebCameraAccess();
    } else {
      _capturePhoto();
    }
  }

  /// Request camera access specifically for web with user interaction
  Future<void> _requestWebCameraAccess() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('📷 Camera Access'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('This app needs camera access to take attendance photos.'),
              const SizedBox(height: 12),
              const Text('Tips for web camera:'),
              const SizedBox(height: 8),
              const Text('• Allow camera permission when prompted by browser'),
              const Text('• Make sure camera is not used by other apps'),
              const Text('• Check browser camera settings if needed'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await _requestWebCameraPermission();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                    ),
                    child: const Text('📸 Allow Camera', style: TextStyle(color: AppColors.pureWhite)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Request camera permission for web by actually trying to access camera
  Future<void> _requestWebCameraPermission() async {
    setState(() {
      isCapturingImage = true;
    });

    try {
      print('📷 Web - Requesting camera permission via getUserMedia...');
      
      // Try to access camera - this will trigger browser permission popup
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo != null) {
        print('📷 Web - Camera permission granted, processing photo...');
        
        // Process the captured photo
        final Uint8List originalBytes = await photo.readAsBytes();
        double originalSizeKB = originalBytes.length / 1024;
        print('📷 Original image: ${originalSizeKB.toStringAsFixed(1)} KB');

        // Resize image to 200KB target
        print('📷 Starting image compression...');
        final Uint8List compressedBytes = await _resizeImageToTarget(originalBytes, targetSizeKB: 200);
        double compressedSizeKB = compressedBytes.length / 1024;
        
        print('📷 Setting state with compressed image...');
        setState(() {
          capturedImageFile = photo;
          capturedImageBytes = compressedBytes;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📷 Camera access granted! Photo captured successfully.'),
            backgroundColor: AppColors.primaryGreen,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        print('📷 Web - Camera access denied or cancelled');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📷 Camera access denied. Please allow camera permission in your browser.'),
            backgroundColor: AppColors.errorRed,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      print('📷 Web - Error accessing camera: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('📷 Error accessing camera: ${e.toString()}'),
          backgroundColor: AppColors.errorRed,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      setState(() {
        isCapturingImage = false;
      });
    }
  }

  /// Resize image to target size in KB
  Future<Uint8List> _resizeImageToTarget(Uint8List imageBytes, {required int targetSizeKB}) async {
    final targetSizeBytes = targetSizeKB * 1024;
    
    // If already smaller than target, return as is
    if (imageBytes.length <= targetSizeBytes) {
      print('📷 Image already small enough: ${(imageBytes.length / 1024).toStringAsFixed(1)} KB');
      return imageBytes;
    }

    print('📷 Original image size: ${(imageBytes.length / 1024).toStringAsFixed(1)} KB');
    
    try {
      // Decode the image
      final ui.Codec codec = await ui.instantiateImageCodec(imageBytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image originalImage = frameInfo.image;
      
      // Calculate scale factor to reduce file size
      double scaleFactor = 0.8;
      
      // Start with smaller dimensions
      int newWidth = (originalImage.width * scaleFactor).round();
      int newHeight = (originalImage.height * scaleFactor).round();
      
      // Ensure minimum size
      if (newWidth < 200) newWidth = 200;
      if (newHeight < 200) newHeight = 200;
      
      // Create resized image
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final ui.Canvas canvas = ui.Canvas(recorder);
      
      // Draw resized image
      canvas.drawImageRect(
        originalImage,
        ui.Rect.fromLTWH(0, 0, originalImage.width.toDouble(), originalImage.height.toDouble()),
        ui.Rect.fromLTWH(0, 0, newWidth.toDouble(), newHeight.toDouble()),
        ui.Paint(),
      );
      
      final ui.Picture picture = recorder.endRecording();
      final ui.Image resizedImage = await picture.toImage(newWidth, newHeight);
      
      // Convert to bytes using JPEG format for better compression
      final ByteData? byteData = await resizedImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      
      if (byteData != null) {
        final Uint8List resizedBytes = byteData.buffer.asUint8List();
        print('📷 Resized to: ${(resizedBytes.length / 1024).toStringAsFixed(1)} KB (${newWidth}x${newHeight})');
        
        // If still too large, try more aggressive resizing
        if (resizedBytes.length > targetSizeBytes && newWidth > 300) {
          return _resizeImageToTarget(resizedBytes, targetSizeKB: targetSizeKB);
        }
        
        return resizedBytes;
      }
    } catch (e) {
      print('📷 Error resizing image: $e');
    }
    
    // If resizing fails, return original
    return imageBytes;
  }

  Future<void> _saveAttendance() async {
    // Validate location data
    if (latitude == null || longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait for location to be obtained first'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    // Validate photo evidence
    if (capturedImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please take a photo for attendance verification'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    // Validate dates
    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select valid dates'),
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
      print('📷 Image: ${capturedImageFile!.name}');

      final response = await _attendanceService.submitAttendanceWithImage(
        type: selectedAbsentType,
        startDate: startDate!,
        endDate: endDate!,
        latitude: latitude!,
        longitude: longitude!,
        address: detailAddress,
        image: capturedImageFile!,
        notes: 'Submitted via mobile app',
      );

      if (response.success) {
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
                Text('Location: ${detailAddress.substring(0, detailAddress.length > 30 ? 30 : detailAddress.length)}...'),
                const Text('Photo: Uploaded successfully'),
              ],
            ),
            backgroundColor: AppColors.primaryGreen,
            duration: const Duration(seconds: 5),
          ),
        );

        // Navigate back to previous screen
        Navigator.pop(context, true); // Pass true to indicate successful save
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save attendance: ${response.message}'),
            backgroundColor: AppColors.errorRed,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      print('❌ Error saving attendance: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving attendance: ${e.toString()}'),
          backgroundColor: AppColors.errorRed,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTime = DateFormat('HH : mm : ss').format(DateTime.now());
    
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
                currentTime,
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
                    });
                    _updateDatesBasedOnType(newValue!); // Update tanggal otomatis
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Date Range
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
                            ? null // Disable untuk clock in/out
                            : () => _selectDate(context, true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: (selectedAbsentType == 'Clock In' || selectedAbsentType == 'Clock Out')
                                ? Colors.grey.shade100 // Gray background jika disabled
                                : AppColors.pureWhite,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today, 
                                size: 20, 
                                color: (selectedAbsentType == 'Clock In' || selectedAbsentType == 'Clock Out')
                                    ? Colors.grey.shade400
                                    : Colors.grey
                              ),
                              const SizedBox(width: 8),
                              Text(
                                startDate != null 
                                    ? DateFormat('dd/MM/yyyy').format(startDate!)
                                    : 'dd/mm/yyyy',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: startDate != null ? AppColors.black87 : Colors.grey,
                                ),
                              ),
                              if (selectedAbsentType == 'Clock In' || selectedAbsentType == 'Clock Out')
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Icon(
                                    Icons.lock,
                                    size: 14,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                            ],
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
                            ? null // Disable untuk clock in/out
                            : () => _selectDate(context, false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: (selectedAbsentType == 'Clock In' || selectedAbsentType == 'Clock Out')
                                ? Colors.grey.shade100 // Gray background jika disabled
                                : AppColors.pureWhite,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today, 
                                size: 20, 
                                color: (selectedAbsentType == 'Clock In' || selectedAbsentType == 'Clock Out')
                                    ? Colors.grey.shade400
                                    : Colors.grey
                              ),
                              const SizedBox(width: 8),
                              Text(
                                endDate != null 
                                    ? DateFormat('dd/MM/yyyy').format(endDate!)
                                    : 'dd/mm/yyyy',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: endDate != null ? AppColors.black87 : Colors.grey,
                                ),
                              ),
                              if (selectedAbsentType == 'Clock In' || selectedAbsentType == 'Clock Out')
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Icon(
                                    Icons.lock,
                                    size: 14,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Duration indicator untuk cuti
            if (startDate != null && endDate != null && 
                (selectedAbsentType == 'Annual Leave' || selectedAbsentType == 'Sick Leave' || selectedAbsentType == 'Absent'))
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
                      Icons.info_outline,
                      size: 16,
                      color: AppColors.primaryBlue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getDurationText(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 30),
            
            // Take Photo Evidence
            const Text(
              'Take Photo Evidence',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.black87,
              ),
            ),
            const SizedBox(height: 12),
            
            // Photo Container
            GestureDetector(
              onTap: () {
                print('📷 Photo container tapped!');
                if (capturedImageFile == null && !isCapturingImage) {
                  print('📷 Calling camera method...');
                  
                  if (kIsWeb) {
                    _showCameraOptions();
                  } else if (!hasCameraPermission) {
                    print('📷 No permission, requesting...');
                    _requestCameraPermission();
                  } else {
                    _capturePhoto();
                  }
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
                    color: capturedImageFile == null 
                        ? AppColors.primaryBlue.withValues(alpha: 0.3)
                        : Colors.grey.shade300,
                    width: capturedImageFile == null ? 2 : 1,
                  ),
                ),
                child: capturedImageFile != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        children: [
                          // Display captured photo - use Image.memory for web compatibility
                          kIsWeb
                              ? Image.memory(
                                  capturedImageBytes!,
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  capturedImageFile!.path,
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                          // Remove photo button
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.errorRed,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: AppColors.pureWhite,
                                  size: 18,
                                ),
                                onPressed: _removePhoto,
                                padding: const EdgeInsets.all(4),
                                constraints: const BoxConstraints(),
                              ),
                            ),
                          ),
                          // Retake photo button
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.camera_alt,
                                  color: AppColors.pureWhite,
                                  size: 18,
                                ),
                                onPressed: isCapturingImage ? null : _capturePhoto,
                                padding: const EdgeInsets.all(8),
                                constraints: const BoxConstraints(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : MouseRegion(
                      cursor: capturedImageFile == null ? SystemMouseCursors.click : SystemMouseCursors.basic,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                size: 30,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              kIsWeb 
                                  ? (isCapturingImage 
                                      ? 'Capturing Photo...'
                                      : 'Tap to Enable Camera')
                                  : hasCameraPermission 
                                      ? (isCapturingImage 
                                          ? 'Capturing Photo...'
                                          : 'Tap to Capture Photo')
                                      : isRequestingPermission
                                          ? 'Requesting Permission...'
                                          : 'Camera Permission Required',
                              style: TextStyle(
                                fontSize: 14,
                                color: hasCameraPermission || kIsWeb
                                    ? AppColors.primaryBlue
                                    : isRequestingPermission
                                        ? AppColors.primaryYellow
                                        : AppColors.errorRed,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              kIsWeb 
                                  ? 'Browser will ask for camera permission'
                                  : hasCameraPermission
                                      ? 'Camera Only'
                                      : isRequestingPermission
                                          ? 'Please wait...'
                                          : 'Tap to grant permission',
                              style: TextStyle(
                                fontSize: 12,
                                color: hasCameraPermission || kIsWeb
                                    ? AppColors.primaryBlue
                                    : isRequestingPermission
                                        ? AppColors.primaryYellow
                                        : AppColors.errorRed,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              ),
            ),
            
            // Show photo requirement status
            if (capturedImageFile == null)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primaryYellow.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.primaryYellow,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Photo evidence is required for attendance verification',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppColors.primaryGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Photo evidence captured successfully',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 30),
            
            // Location Section
            const Text(
              'Location',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.black87,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Your location is automatically detected and cannot be moved. You can zoom in/out for better view.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            
            // Location Dropdown
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedLocation,
                    style: TextStyle(
                      fontSize: 16,
                      color: selectedLocation == 'Choose Location' ? Colors.grey : AppColors.black87,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Location Display Container
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: currentPosition != null
                    ? Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primaryBlue.withValues(alpha: 0.1),
                              AppColors.primaryGreen.withValues(alpha: 0.1),
                            ],
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Location Info Content
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppColors.pureWhite,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          color: AppColors.primaryBlue,
                                          size: 32,
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Current Location',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primaryBlue,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Lat: ${currentPosition!.latitude.toStringAsFixed(6)}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.black54,
                                          ),
                                        ),
                                        Text(
                                          'Lng: ${currentPosition!.longitude.toStringAsFixed(6)}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.black54,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Accuracy: ${currentPosition!.accuracy.toStringAsFixed(1)}m',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: AppColors.black38,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Refresh button overlay
                            Positioned(
                              right: 10,
                              top: 10,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.pureWhite,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: isLoadingLocation 
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Icon(Icons.my_location, color: AppColors.primaryBlue),
                                  onPressed: isLoadingLocation ? null : _refreshLocation,
                                  tooltip: 'Refresh Location',
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.grey.shade300,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (isLoadingLocation) ...[
                                const CircularProgressIndicator(),
                                const SizedBox(height: 16),
                                const Text(
                                  'Getting your location...',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.black54,
                                  ),
                                ),
                              ] else ...[
                                const Icon(
                                  Icons.location_off,
                                  color: AppColors.black54,
                                  size: 40,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Location not available',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.black54,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: _refreshLocation,
                                  icon: const Icon(Icons.refresh, size: 18),
                                  label: const Text('Retry'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryBlue,
                                    foregroundColor: AppColors.pureWhite,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Detail Address
            const Text(
              'Detail Address',
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
                  Expanded(
                    child: Text(
                      detailAddress,
                      style: TextStyle(
                        fontSize: 14,
                        color: isLoadingLocation ? Colors.grey : AppColors.black87,
                      ),
                    ),
                  ),
                  if (isLoadingLocation)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.refresh, color: AppColors.primaryBlue),
                      onPressed: _refreshLocation,
                      tooltip: 'Refresh Address',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Lat Long Section
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
            
            // Bottom Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey.shade400),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isSaving ? null : _saveAttendance,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSaving 
                          ? Colors.grey.shade400 
                          : AppColors.primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isSaving
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.pureWhite),
                                ),
                              ),
                              const SizedBox(width: 8),
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
                            'Save',
                            style: TextStyle(
                              color: AppColors.pureWhite,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  String _getDurationText() {
    if (startDate == null || endDate == null) return '';
    
    final difference = endDate!.difference(startDate!).inDays + 1;
    
    if (difference == 1) {
      return 'Duration: 1 day';
    } else {
      return 'Duration: $difference days';
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    // Jangan jalankan jika Clock In/Out
    if (selectedAbsentType == 'Clock In' || selectedAbsentType == 'Clock Out') {
      return;
    }

    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime(2020);
    DateTime lastDate = DateTime(2030);

    // Jika memilih end date, pastikan tidak lebih kecil dari start date
    if (!isStartDate && startDate != null) {
      initialDate = endDate ?? startDate!;
      firstDate = startDate!; // End date tidak boleh sebelum start date
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
          // Jika start date diubah dan lebih besar dari end date, update end date
          if (endDate != null && picked.isAfter(endDate!)) {
            endDate = picked;
          }
        } else {
          endDate = picked;
        }
      });
    }
  }
}