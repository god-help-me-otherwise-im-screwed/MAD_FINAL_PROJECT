import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as osm;
import 'package:hawahawa/constants/colors.dart';
import 'package:hawahawa/models/location_model.dart';
import 'package:hawahawa/providers/location_provider.dart';
import 'package:hawahawa/api/api_service.dart';

class MapPickerScreen extends ConsumerStatefulWidget {
  const MapPickerScreen({super.key});

  @override
  ConsumerState<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends ConsumerState<MapPickerScreen> {
  // 1. Map Controller to move the map programmatically
  final MapController _mapController = MapController();

  LocationResult? _selectedLocation;

  @override
  void initState() {
    super.initState();
    // Initialize with current location from provider if available
    final currentLocation = ref.read(locationProvider);
    if (currentLocation != null) {
      _selectedLocation = currentLocation;
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _confirmAndPop() {
    if (_selectedLocation != null) {
      // Returns the selected location to the StartupScreen
      Navigator.pop<LocationResult?>(context, _selectedLocation);
    }
  }

  // 2. Function to move map to user's current GPS location
  void _goToMyLocation() async {
    // Attempt to get the latest GPS location
    try {
      final gpsLocation = await LocationAPI.getLocationFromGps();
      if (gpsLocation != null && mounted) {
        final target = osm.LatLng(gpsLocation.lat, gpsLocation.lon);

        // Move the map camera to the GPS coordinates
        _mapController.move(target, 15.0);

        // Also update the selected location to the GPS one
        setState(() {
          _selectedLocation = gpsLocation;
        });

        // Optional: Show a confirmation toast
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Map centered on your GPS location.'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      // Handle case where GPS location could not be retrieved
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not get GPS location. Check permissions.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // 3. Update the selected location when user taps on the map
  void _handleMapTap(osm.LatLng point) {
    setState(() {
      _selectedLocation = LocationResult(
        lat: point.latitude,
        lon: point.longitude,
        displayName:
            '${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch location provider for initial center and current GPS location
    final currentLocation = ref.watch(locationProvider);
    final initialLat = currentLocation?.lat ?? 40.7128; // Default to NYC
    final initialLon = currentLocation?.lon ?? -74.0060;
    final initialPoint = osm.LatLng(initialLat, initialLon);

    // Calculate padding for the map widget to sit above the fixed button
    // The Confirm button has bottom: 24.0, height ~56.0. We reserve about 100.0 from the bottom.
    const mapBottomPadding = 100.0;

    return Scaffold(
      backgroundColor: kDarkPrimary,
      appBar: AppBar(
        title: const Text('Select Location on Map'),
        backgroundColor: kDarkPrimary,
        elevation: 0,
        foregroundColor: kDarkText,
      ),
      body: Stack(
        children: [
          // MAP WIDGET
          // 4. Map wrapped in padding to sit above the bottom button
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
            ).copyWith(top: 24.0, bottom: mapBottomPadding),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: initialPoint,
                  initialZoom: 13,
                  onTap: (tapPosition, point) {
                    // Update selected location when user taps on map
                    _handleMapTap(point);
                  },
                ),
                children: [
                  // OpenStreetMap Tile Layer
                  TileLayer(
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: const ["a", "b", "c"],
                    userAgentPackageName: "com.hawahawa.app",
                  ),
                  // Central Marker (Always visible at the calculated center)
                  if (_selectedLocation != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: osm.LatLng(
                            _selectedLocation!.lat,
                            _selectedLocation!.lon,
                          ),
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          // GO TO MY LOCATION BUTTON (FAB)
          // 5. Positioned FAB for 'Go to My Location' functionality
          Positioned(
            bottom: mapBottomPadding, // Above the map's bottom padding
            right: 24,
            child: FloatingActionButton(
              onPressed: _goToMyLocation,
              backgroundColor: kDarkAccent,
              foregroundColor: kDarkText,
              mini: true,
              heroTag: 'goToGps',
              child: const Icon(Icons.my_location),
            ),
          ),

          // CONFIRM LOCATION Button at bottom
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: ElevatedButton(
              onPressed: _selectedLocation != null ? _confirmAndPop : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedLocation != null
                    ? kDarkAccent
                    : kDarkAccent.withValues(alpha: 0.3),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: _selectedLocation != null ? 8 : 0,
              ),
              child: Text(
                'CONFIRM LOCATION',
                style: TextStyle(
                  color: _selectedLocation != null
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.5),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
