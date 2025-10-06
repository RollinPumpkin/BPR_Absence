import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static Future<bool> requestLocationPermission() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    // Check location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  static Future<bool> requestAlwaysLocationPermission() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Request to enable location services
      await Geolocator.openLocationSettings();
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return false;
      }
    }

    // First request basic location permission
    PermissionStatus status = await Permission.location.request();
    
    if (status == PermissionStatus.granted) {
      // Then request always location permission for background usage
      PermissionStatus alwaysStatus = await Permission.locationAlways.request();
      
      // Return true if we have at least basic location permission
      return status == PermissionStatus.granted;
    }

    return status == PermissionStatus.granted;
  }

  static Future<Position?> getCurrentLocation() async {
    try {
      bool hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return position;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  static Future<String?> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return '${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''}';
      }
      return null;
    } catch (e) {
      print('Error getting address: $e');
      return null;
    }
  }

  static Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }

  // Check if location services (GPS) are enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Prompt user to enable location services
  static Future<bool> enableLocationService() async {
    try {
      // Check if location services are already enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        return true;
      }

      // Open location settings to enable GPS
      await Geolocator.openLocationSettings();
      
      // Wait a bit and check again
      await Future.delayed(const Duration(seconds: 2));
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      
      return serviceEnabled;
    } catch (e) {
      print('Error enabling location service: $e');
      return false;
    }
  }

  // Complete location setup including service and permission
  static Future<LocationSetupResult> setupLocationAccess() async {
    // Step 1: Check if location services are enabled
    bool serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationSetupResult(
        isSuccess: false, 
        message: 'Location services are disabled',
        needsServiceEnable: true,
        needsPermission: false,
      );
    }

    // Step 2: Check and request location permission
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return LocationSetupResult(
          isSuccess: false, 
          message: 'Location permission denied',
          needsServiceEnable: false,
          needsPermission: true,
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationSetupResult(
        isSuccess: false, 
        message: 'Location permission denied forever',
        needsServiceEnable: false,
        needsPermission: true,
      );
    }

    // Step 3: Try to get current location to verify everything works
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      
      return LocationSetupResult(
        isSuccess: true, 
        message: 'Location access setup successfully',
        needsServiceEnable: false,
        needsPermission: false,
        position: position,
      );
    } catch (e) {
      return LocationSetupResult(
        isSuccess: false, 
        message: 'Failed to get location: ${e.toString()}',
        needsServiceEnable: false,
        needsPermission: false,
      );
    }
  }
}

class LocationSetupResult {
  final bool isSuccess;
  final String message;
  final bool needsServiceEnable;
  final bool needsPermission;
  final Position? position;

  LocationSetupResult({
    required this.isSuccess,
    required this.message,
    required this.needsServiceEnable,
    required this.needsPermission,
    this.position,
  });
}