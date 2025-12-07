import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as osm;
import 'package:hawahawa/constants/colors.dart';
import 'package:hawahawa/models/location_model.dart';
import 'package:hawahawa/providers/location_provider.dart';

class MapPickerScreen extends ConsumerStatefulWidget {
  const MapPickerScreen({super.key});

  @override
  ConsumerState<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends ConsumerState<MapPickerScreen> {
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

  void _confirmAndPop() {
    if (_selectedLocation != null) {
      Navigator.pop<LocationResult?>(context, _selectedLocation);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocation = ref.watch(locationProvider);
    final initialLat = currentLocation?.lat ?? 40.7128;
    final initialLon = currentLocation?.lon ?? -74.0060;
    final initialPoint = osm.LatLng(initialLat, initialLon);

    return Scaffold(
      backgroundColor: kDarkPrimary,
      appBar: AppBar(
        title: const Text('Select Location on Map'),
        backgroundColor: kDarkPrimary,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Map Widget with padding
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: initialPoint,
                  initialZoom: 13,
                  onTap: (tapPosition, point) {
                    // Update selected location when user taps on map
                    setState(() {
                      _selectedLocation = LocationResult(
                        lat: point.latitude,
                        lon: point.longitude,
                        displayName:
                            '${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}',
                      );
                    });
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
                  // Central Marker
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
