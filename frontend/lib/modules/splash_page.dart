import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/core/services/location_service.dart';
import 'package:frontend/core/services/notification_service.dart';
import 'package:geolocator/geolocator.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _timer;
  bool _locationPermissionRequested = false;

  @override
  void initState() {
    super.initState();
    _checkLocationPermissionAndProceed();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkLocationPermissionAndProceed() async {
    // Tunggu sebentar untuk menampilkan splash screen
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Setup complete location access (service + permission)
    LocationSetupResult result = await LocationService.setupLocationAccess();
    
    if (!result.isSuccess) {
      if (result.needsServiceEnable) {
        // Show dialog to enable location services
        _showLocationServiceDialog();
      } else if (result.needsPermission) {
        // Show permission dialog
        _showLocationPermissionDialog();
      } else {
        // Other error, but proceed anyway
        await _checkNotificationPermission();
      }
    } else {
      // Location setup successful, proceed to notification
      await _checkNotificationPermission();
    }
  }

  void _showLocationServiceDialog() {
    if (_locationPermissionRequested) return;
    _locationPermissionRequested = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.gps_off, color: AppColors.errorRed),
              SizedBox(width: 8),
              Text('Aktifkan Layanan Lokasi'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Layanan lokasi (GPS) tidak aktif. Aplikasi memerlukan layanan lokasi untuk:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              Text('• Verifikasi lokasi saat clock in/out'),
              Text('• Pencatatan attendance yang akurat'),
              Text('• Keamanan data kehadiran'),
              SizedBox(height: 12),
              Text(
                'Mohon aktifkan layanan lokasi di pengaturan perangkat Anda.',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _proceedToLogin(); // Tetap lanjut ke login
              },
              child: const Text(
                'Lewati',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _enableLocationService();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
              ),
              child: const Text(
                'Aktifkan Lokasi',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _enableLocationService() async {
    try {
      bool enabled = await LocationService.enableLocationService();
      
      if (enabled) {
        // Location service enabled, now check permission
        await _checkLocationPermissionAndProceed();
      } else {
        // Show instruction dialog
        _showLocationInstructionDialog();
      }
    } catch (e) {
      // Error occurred, proceed anyway
      await _checkNotificationPermission();
    }
  }

  void _showLocationInstructionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Instruksi Aktivasi Lokasi'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Untuk mengaktifkan layanan lokasi:'),
              SizedBox(height: 8),
              Text('1. Buka Pengaturan perangkat'),
              Text('2. Pilih "Lokasi" atau "Location"'),
              Text('3. Aktifkan layanan lokasi'),
              Text('4. Kembali ke aplikasi'),
              SizedBox(height: 12),
              Text(
                'Setelah diaktifkan, aplikasi akan bekerja dengan optimal.',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _checkLocationPermissionAndProceed(); // Check again
              },
              child: const Text('Coba Lagi'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _proceedToLogin(); // Proceed anyway
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
              ),
              child: const Text(
                'Lanjutkan',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _checkNotificationPermission() async {
    if (!mounted) return;
    
    // Check if should show notification permission dialog
    bool shouldShow = await NotificationService.shouldShowPermissionDialog();
    
    if (shouldShow) {
      // Mark that we requested permission today
      await NotificationService.markPermissionRequested();
      
      // Show notification permission dialog
      await NotificationService.showPermissionDialog(context);
      
      if (mounted) {
        _proceedToLogin();
      }
    } else {
      _proceedToLogin();
    }
  }

  void _showLocationPermissionDialog() {
    if (_locationPermissionRequested) return;
    _locationPermissionRequested = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.location_on, color: AppColors.primaryBlue),
              SizedBox(width: 8),
              Text('Izin Akses Lokasi'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Aplikasi ini memerlukan akses lokasi untuk:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              Text('• Verifikasi lokasi saat clock in/out'),
              Text('• Pencatatan attendance yang akurat'),
              Text('• Keamanan data kehadiran'),
              SizedBox(height: 12),
              Text(
                'Untuk pengalaman terbaik, mohon pilih "Selalu Izinkan" saat diminta.',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _proceedToLogin(); // Tetap lanjut ke login meski tidak izin
              },
              child: const Text(
                'Tidak Sekarang',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _requestLocationPermission();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
              ),
              child: const Text(
                'Izinkan Lokasi',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _requestLocationPermission() async {
    try {
      // Request always location permission
      bool hasPermission = await LocationService.requestAlwaysLocationPermission();
      
      if (!hasPermission) {
        // Show settings dialog if permission denied
        _showPermissionDeniedDialog();
      } else {
        // Permission granted, check notification permission next
        await _checkNotificationPermission();
      }
    } catch (e) {
      // Error occurred, proceed to login anyway
      _proceedToLogin();
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Izin Lokasi Diperlukan'),
          content: const Text(
            'Untuk menggunakan fitur attendance dengan maksimal, mohon aktifkan izin lokasi di pengaturan aplikasi.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _proceedToLogin();
              },
              child: const Text('Nanti Saja'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await Geolocator.openAppSettings();
                _proceedToLogin();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
              ),
              child: const Text(
                'Buka Pengaturan',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _proceedToLogin() {
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 150,
            ),
            const SizedBox(height: 16),
            const Text(
              "PT. BANK PERKREDITAN RAKYAT\nADIARTHA REKSACIPTA",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryRed,
              ),
            )
          ],
        ),
      ),
    );
  }
}
