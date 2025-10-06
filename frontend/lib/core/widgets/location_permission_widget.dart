import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/core/services/location_service.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationPermissionWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onLocationGranted;

  const LocationPermissionWidget({
    super.key,
    required this.child,
    this.onLocationGranted,
  });

  @override
  State<LocationPermissionWidget> createState() => _LocationPermissionWidgetState();
}

class _LocationPermissionWidgetState extends State<LocationPermissionWidget> {
  bool _isCheckingPermission = true;
  bool _hasLocationPermission = false;
  String _permissionStatus = '';

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    setState(() {
      _isCheckingPermission = true;
    });

    try {
      final hasPermission = await LocationService.requestLocationPermission();
      setState(() {
        _hasLocationPermission = hasPermission;
        _isCheckingPermission = false;
        _permissionStatus = hasPermission ? 'Granted' : 'Denied';
      });

      if (hasPermission && widget.onLocationGranted != null) {
        widget.onLocationGranted!();
      }
    } catch (e) {
      setState(() {
        _isCheckingPermission = false;
        _permissionStatus = 'Error: $e';
      });
    }
  }

  Future<void> _openAppSettings() async {
    await openAppSettings();
    // Recheck permission after returning from settings
    _checkLocationPermission();
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingPermission) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Checking location permission...'),
            ],
          ),
        ),
      );
    }

    if (!_hasLocationPermission) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Location Permission Required'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.location_off,
                  size: 80,
                  color: AppColors.errorRed,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Location Access Required',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'This app needs location access to record your attendance location accurately. Please grant location permission to continue.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _checkLocationPermission,
                        child: const Text('Try Again'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _openAppSettings,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                        ),
                        child: const Text(
                          'Open Settings',
                          style: TextStyle(color: AppColors.pureWhite),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Status: $_permissionStatus',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return widget.child;
  }
}