import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hawahawa/api/api_service.dart';
import 'package:hawahawa/models/location_model.dart';

class LocationNotifier extends StateNotifier<LocationResult?> {
  LocationNotifier() : super(null);

  Future<void> requestGpsLocation() async {
    final result = await LocationAPI.getLocationFromGps();
    if (result != null) {
      state = result;
    }
  }

  Future<void> searchLocation(String query) async {
    final result = await LocationAPI.searchLocationByName(query);
    if (result != null) {
      state = result;
    }
  }

  void setLocation(LocationResult location) {
    state = location;
  }

  void clearLocation() {
    state = null;
  }
}

final locationProvider = StateNotifierProvider<LocationNotifier, LocationResult?>((ref) {
  return LocationNotifier();
});