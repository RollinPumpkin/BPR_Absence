import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class CameraService {
  static final ImagePicker _imagePicker = ImagePicker();

  /// Request camera permission
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status == PermissionStatus.granted;
  }

  /// Check if camera permission is granted
  static Future<bool> hasCameraPermission() async {
    final status = await Permission.camera.status;
    return status == PermissionStatus.granted;
  }

  /// Capture photo from camera
  static Future<File?> capturePhoto({
    int imageQuality = 80,
    double? maxWidth,
    double? maxHeight,
    CameraDevice preferredCamera = CameraDevice.rear,
  }) async {
    try {
      // Check camera permission
      bool hasPermission = await hasCameraPermission();
      if (!hasPermission) {
        hasPermission = await requestCameraPermission();
        if (!hasPermission) {
          throw Exception('Camera permission denied');
        }
      }

      // Capture photo
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: imageQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        preferredCameraDevice: preferredCamera,
      );

      if (photo != null) {
        return File(photo.path);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to capture photo: $e');
    }
  }

  /// Capture photo with specific settings for attendance
  static Future<File?> captureAttendancePhoto() async {
    return await capturePhoto(
      imageQuality: 85,
      maxWidth: 1920,
      maxHeight: 1080,
      preferredCamera: CameraDevice.rear,
    );
  }

  /// Get file size in MB
  static double getFileSizeInMB(File file) {
    int fileSizeInBytes = file.lengthSync();
    return fileSizeInBytes / (1024 * 1024);
  }

  /// Compress image if needed
  static Future<File?> compressImageIfNeeded(File imageFile, {double maxSizeMB = 5.0}) async {
    double currentSizeMB = getFileSizeInMB(imageFile);
    
    if (currentSizeMB <= maxSizeMB) {
      return imageFile;
    }

    try {
      // If image is too large, we might need additional compression
      // For now, return the original file
      // You can implement additional compression logic here if needed
      return imageFile;
    } catch (e) {
      throw Exception('Failed to compress image: $e');
    }
  }
}