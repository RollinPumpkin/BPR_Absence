import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/data/models/user.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/data/services/user_service.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:io';

class ProfileInfoCard extends StatefulWidget {
  final User user;
  final VoidCallback? onEditPressed;
  final VoidCallback? onPhotoUpdated;

  const ProfileInfoCard({
    super.key,
    required this.user,
    this.onEditPressed,
    this.onPhotoUpdated,
  });

  @override
  State<ProfileInfoCard> createState() => _ProfileInfoCardState();
}

class _ProfileInfoCardState extends State<ProfileInfoCard> {
  final UserService _userService = UserService();
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image == null) return;

      setState(() {
        _isUploading = true;
      });

      // Get original file size
      final originalFile = File(image.path);
      final originalSize = await originalFile.length();
      const maxSize = 2 * 1024 * 1024; // 2MB in bytes

      String finalImagePath = image.path;

      // Auto-compress if file size > 2MB
      if (originalSize > maxSize) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image size is large, compressing...'),
              backgroundColor: AppColors.primaryBlue,
              duration: Duration(seconds: 2),
            ),
          );
        }

        // Generate output path
        final dir = originalFile.parent.path;
        final targetPath = '$dir/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

        // Compress image with progressive quality reduction
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
            if (compressedSize <= maxSize) {
              finalImagePath = compressedFile.path;
              
              if (mounted) {
                final sizeReduction = ((originalSize - compressedSize) / originalSize * 100).toInt();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Image compressed successfully ($sizeReduction% reduction)'),
                    backgroundColor: AppColors.primaryGreen,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
              break;
            }
          }
          
          // Reduce quality and try again
          quality -= 10;
        }

        // If still too large after maximum compression, show error
        if (compressedFile != null) {
          final finalSize = await File(compressedFile.path).length();
          if (finalSize > maxSize) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Unable to compress image below 2MB. Please choose a smaller image.'),
                  backgroundColor: AppColors.errorRed,
                  duration: Duration(seconds: 3),
                ),
              );
            }
            setState(() {
              _isUploading = false;
            });
            return;
          }
        }
      }

      // Upload to server
      final response = await _userService.uploadProfilePicture(finalImagePath);

      if (mounted) {
        if (response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully!'),
              backgroundColor: AppColors.primaryGreen,
              duration: Duration(seconds: 2),
            ),
          );
          
          // Notify parent to refresh
          if (widget.onPhotoUpdated != null) {
            widget.onPhotoUpdated!();
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Failed to upload profile picture'),
              backgroundColor: AppColors.errorRed,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.errorRed,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Picture and Basic Info
          Row(
            children: [
              // Profile Picture with Upload
              Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      gradient: widget.user.profilePicture != null && widget.user.profilePicture!.isNotEmpty
                          ? null
                          : const LinearGradient(
                              colors: [AppColors.primaryBlue, AppColors.primaryRed],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      image: widget.user.profilePicture != null && widget.user.profilePicture!.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(widget.user.profilePicture!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: widget.user.profilePicture == null || widget.user.profilePicture!.isEmpty
                        ? const Center(
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: AppColors.pureWhite,
                            ),
                          )
                        : null,
                  ),
                  // Upload button overlay
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _isUploading ? null : _pickAndUploadImage,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.pureWhite,
                            width: 2,
                          ),
                        ),
                        child: _isUploading
                            ? const Padding(
                                padding: EdgeInsets.all(6),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.pureWhite),
                                ),
                              )
                            : const Icon(
                                Icons.camera_alt,
                                size: 14,
                                color: AppColors.pureWhite,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Basic Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user.fullName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.neutral800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.user.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getRoleColor(widget.user.role).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getRoleText(widget.user.role),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getRoleColor(widget.user.role),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Edit Button
              if (widget.onEditPressed != null)
                IconButton(
                  onPressed: widget.onEditPressed,
                  icon: const Icon(Icons.edit),
                  color: AppColors.primaryBlue,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),
          
          // Detailed Information
          _buildInfoRow(Icons.badge, 'Employee ID', widget.user.employeeId.isNotEmpty ? widget.user.employeeId : 'Not Set'),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.work, 'Position', widget.user.position ?? 'Not Set'),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.business, 'Department', widget.user.department ?? 'Not Set'),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.phone, 'Phone', widget.user.phone ?? 'Not Set'),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.circle, 
            'Status', 
            widget.user.isActive ? 'Active' : 'Inactive',
            valueColor: widget.user.isActive ? AppColors.primaryGreen : AppColors.primaryRed,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryBlue,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppColors.neutral800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
      case 'super_admin':
        return AppColors.primaryRed;
      case 'manager':
        return AppColors.primaryBlue;
      default:
        return AppColors.primaryGreen;
    }
  }

  String _getRoleText(String role) {
    switch (role.toLowerCase()) {
      case 'super_admin':
        return 'Super Admin';
      case 'admin':
        return 'Admin';
      case 'manager':
        return 'Manager';
      default:
        return 'Employee';
    }
  }
}