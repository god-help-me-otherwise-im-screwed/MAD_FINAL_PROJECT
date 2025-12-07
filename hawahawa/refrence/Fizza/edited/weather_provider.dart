import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hawahawa/models/weather_model.dart';
import 'package:hawahawa/api/api_service.dart';
import 'package:hawahawa/models/location_model.dart';
import 'package:hawahawa/providers/settings_provider.dart';
import 'package:hawahawa/providers/location_provider.dart';

class WeatherNotifier extends StateNotifier<WeatherReport?> {
  final Ref ref;

  WeatherNotifier(this.ref) : super(null);

  // Main fetch method that checks settings
  Future<void> fetchWeather() async {
    final settings = ref.read(settingsProvider);

    if (settings.locationMode == 'Auto') {
      // Use auto location from location provider
      await fetchWeatherByAutoLocation();
    } else {
      // Use manual location - for now just use auto
      // You can implement geocoding later
      await fetchWeatherByAutoLocation();
    }
  }

  Future<void> fetchWeatherByAutoLocation() async {
    try {
      // Get current location from location provider
      final currentLocation = ref.read(locationProvider);

      if (currentLocation != null) {
        final report = await WeatherAPI.fetchWeather(currentLocation);
        state = report;
      }
    } catch (e) {
      print('Error fetching weather by auto location: $e');
    }
  }

  // Keep the original method for backward compatibility with other screens
  Future<void> fetchWeatherForLocation(LocationResult location) async {
    final report = await WeatherAPI.fetchWeather(location);
    state = report;
  }
}

final weatherProvider = StateNotifierProvider<WeatherNotifier, WeatherReport?>(
      (ref) {
    return WeatherNotifier(ref);
  },
);