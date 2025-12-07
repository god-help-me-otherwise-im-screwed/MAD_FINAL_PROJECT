import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hawahawa/providers/location_provider.dart';
import 'package:hawahawa/screens/startup_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationPermissionScreen extends ConsumerStatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  ConsumerState<LocationPermissionScreen> createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState
    extends ConsumerState<LocationPermissionScreen> {
  @override
  void initState() {
    super.initState();
    // Immediately request location permission on load
    _requestLocationPermissionSilently();
  }

  /// Request location permission silently without any UI popups
  /// Shows system permission dialog only once (first time)
  Future<void> _requestLocationPermissionSilently() async {
    try {
      print('[PERMISSION] Requesting location permission (silent)...');

      // Check current permission status
      LocationPermission permission = await Geolocator.checkPermission();
      print('[PERMISSION] Current permission status: $permission');

      if (permission == LocationPermission.denied) {
        // Request permission (shows system dialog)
        permission = await Geolocator.requestPermission();
        print('[PERMISSION] After request, permission: $permission');
      }

      // Mark that we've checked location permission at least once
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('location_permission_checked', true);

      if (mounted) {
        // If permission granted, try to get location and navigate to startup
        if (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always) {
          print('[PERMISSION] Location permission GRANTED');
          // Attempt to fetch location
          await ref.read(locationProvider.notifier).requestGpsLocation();
          _navigateToStartup();
        } else if (permission == LocationPermission.deniedForever ||
            permission == LocationPermission.denied) {
          // Permission denied - show system permission dialog again
          print(
            '[PERMISSION] Location permission DENIED - showing request again',
          );
          _showLocationPermissionDialog();
        } else {
          // Fallback: go to startup
          _navigateToStartup();
        }
      }
    } catch (e) {
      print('[PERMISSION] Error requesting location: $e');
      if (mounted) {
        _navigateToStartup();
      }
    }
  }

  /// Show the system permission request dialog (native)
  /// This is the default OS permission dialog, not our custom UI
  Future<void> _showLocationPermissionDialog() async {
    try {
      // Open app settings where user can enable location permission
      bool opened = await Geolocator.openLocationSettings();

      if (opened && mounted) {
        print('[PERMISSION] User opened location settings');
        // Check permission again after user returns from settings
        await Future.delayed(const Duration(milliseconds: 500));
        LocationPermission permission = await Geolocator.checkPermission();

        if (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always) {
          print('[PERMISSION] Permission granted after settings');
          await ref.read(locationProvider.notifier).requestGpsLocation();
        }
      }

      if (mounted) {
        _navigateToStartup();
      }
    } catch (e) {
      print('[PERMISSION] Error showing location settings: $e');
      if (mounted) {
        _navigateToStartup();
      }
    }
  }

  void _navigateToStartup() {
    print('[PERMISSION] Navigating to StartupScreen');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const StartupScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // While requesting permission, show loading splash
    return Scaffold(
      backgroundColor: const Color(0xFF1A0B2E),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}
