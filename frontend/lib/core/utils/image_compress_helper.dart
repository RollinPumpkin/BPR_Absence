import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageCompressHelper {
  static const int maxSizeInBytes = 2 * 1024 * 1024; // 2MB

  /// Compress single image if it exceeds 2MB
  /// Returns the path to compressed image or original if already small enough
  static Future<String> compressImageIfNeeded(String imagePath) async {
    final originalFile = File(imagePath);
    final originalSize = await originalFile.length();

    // If already under 2MB, return original
    if (originalSize <= maxSizeInBytes) {
      return imagePath;
    }

    // Generate output path
    final dir = originalFile.parent.path;
    final targetPath = '$dir/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

    // Compress with progressive quality reduction
    int quality = 85;
    XFile? compressedFile;
    
    while (quality >= 50) {
      compressedFile = await FlutterImageCompress.compressAndGetFile(
        originalFile.absolute.path,
        targetPath,
        quality: quality,
        format: CompressFormat.jpeg,
      );

      if (compressedFile != null) {
        final compressedSize = await File(compressedFile.path).length();
        
        // If compressed size is under 2MB, use it
        if (compressedSize <= maxSizeInBytes) {
          return compressedFile.path;
        }
      }
      
      // Reduce quality and try again
      quality -= 10;
    }

    // If still too large after maximum compression, throw error
    if (compressedFile != null) {
      final finalSize = await File(compressedFile.path).length();
      if (finalSize > maxSizeInBytes) {
        throw Exception('Unable to compress image below 2MB');
      }
      return compressedFile.path;
    }

    throw Exception('Failed to compress image');
  }

  /// Compress multiple images
  /// Returns list of paths to compressed images
  static Future<List<String>> compressImagesIfNeeded(List<String> imagePaths) async {
    final List<String> compressedPaths = [];
    
    for (String path in imagePaths) {
      try {
        final compressedPath = await compressImageIfNeeded(path);
        compressedPaths.add(compressedPath);
      } catch (e) {
        // If compression fails, skip this image
        print('Failed to compress image $path: $e');
      }
    }
    
    return compressedPaths;
  }

  /// Check if file size exceeds limit
  static Future<bool> exceedsMaxSize(String imagePath) async {
    final file = File(imagePath);
    final size = await file.length();
    return size > maxSizeInBytes;
  }

  /// Get file size in MB
  static Future<double> getFileSizeInMB(String imagePath) async {
    final file = File(imagePath);
    final size = await file.length();
    return size / (1024 * 1024);
  }

  /// Calculate size reduction percentage
  static int calculateReduction(int originalSize, int compressedSize) {
    return ((originalSize - compressedSize) / originalSize * 100).toInt();
  }
}
