import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hawahawa/api/api_service.dart';
import 'package:hawahawa/models/location_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocationNotifier extends StateNotifier<LocationResult?> {
  LocationNotifier() : super(null);

  /// Save location to persistent storage
  Future<void> saveLocation(LocationResult location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationJson = jsonEncode({
        'lat': location.lat,
        'lon': location.lon,
        'displayName': location.displayName,
      });
      await prefs.setString('saved_location', locationJson);
      state = location;
    } catch (e) {
      print('Error saving location: $e');
    }
  }

  /// Load location from persistent storage
  Future<LocationResult?> loadSavedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationJson = prefs.getString('saved_location');
      if (locationJson != null) {
        final decoded = jsonDecode(locationJson);
        final location = LocationResult(
          lat: decoded['lat'],
          lon: decoded['lon'],
          displayName: decoded['displayName'],
        );
        state = location;
        return location;
      }
    } catch (e) {
      print('Error loading location: $e');
    }
    return null;
  }

  /// Clear saved location from storage and reset state
  Future<void> resetDebugData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('saved_location');
      state = null;
    } catch (e) {
      print('Error resetting location debug data: $e');
    }
  }

  /// Request GPS location and RETURN it (do not set state yet)
  Future<LocationResult?> requestGpsLocation() async {
    final result = await LocationAPI.getLocationFromGps();
    return result;
  }

  Future<void> searchLocation(String query) async {
    final result = await LocationAPI.searchLocationByName(query);
    if (result != null) {
      state = result;
      await saveLocation(result);
    }
  }

  void setLocation(LocationResult location) {
    state = location;
    saveLocation(location);
  }

  void clearLocation() {
    state = null;
  }
}

final locationProvider =
    StateNotifierProvider<LocationNotifier, LocationResult?>((ref) {
  return LocationNotifier();
});