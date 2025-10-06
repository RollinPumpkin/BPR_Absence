import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/core/services/location_service.dart';
import 'package:frontend/core/widgets/location_permission_widget.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class LocationTestPage extends StatefulWidget {
  const LocationTestPage({super.key});

  @override
  State<LocationTestPage> createState() => _LocationTestPageState();
}

class _LocationTestPageState extends State<LocationTestPage> {
  Position? currentPosition;
  String address = 'Getting address...';
  bool isLoading = false;
  final MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
  }

  void _onLocationGranted() {
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      isLoading = true;
      address = 'Getting location...';
    });

    try {
      Position? position = await LocationService.getCurrentLocation();
      if (position != null) {
        setState(() {
          currentPosition = position;
        });

        String? locationAddress = await LocationService.getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );

        setState(() {
          address = locationAddress ?? 'Address not found';
          isLoading = false;
        });

        // Move map to current location
        mapController.move(
          LatLng(position.latitude, position.longitude),
          15.0,
        );
      }
    } catch (e) {
      setState(() {
        address = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LocationPermissionWidget(
      onLocationGranted: _onLocationGranted,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Location Test'),
          backgroundColor: AppColors.pureWhite,
          foregroundColor: AppColors.black,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Current Location',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: isLoading ? null : _getCurrentLocation,
                            icon: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.refresh),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (currentPosition != null) ...[
                        Text('Latitude: ${currentPosition!.latitude.toStringAsFixed(6)}'),
                        Text('Longitude: ${currentPosition!.longitude.toStringAsFixed(6)}'),
                        Text('Accuracy: ${currentPosition!.accuracy.toStringAsFixed(2)}m'),
                        const SizedBox(height: 8),
                      ],
                      Text(
                        'Address: $address',
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Map
              const Text(
                'Live Map',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: currentPosition != null
                        ? FlutterMap(
                            mapController: mapController,
                            options: MapOptions(
                              initialCenter: LatLng(
                                currentPosition!.latitude,
                                currentPosition!.longitude,
                              ),
                              initialZoom: 15.0,
                              minZoom: 5.0,
                              maxZoom: 18.0,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.example.frontend',
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: LatLng(
                                      currentPosition!.latitude,
                                      currentPosition!.longitude,
                                    ),
                                    width: 40,
                                    height: 40,
                                    child: const Icon(
                                      Icons.location_on,
                                      color: AppColors.errorRed,
                                      size: 40,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_searching,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Waiting for location...',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}