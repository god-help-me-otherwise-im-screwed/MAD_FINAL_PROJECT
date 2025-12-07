import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hawahawa/models/weather_model.dart';
import 'package:hawahawa/api/api_service.dart';
import 'package:hawahawa/models/location_model.dart';

class WeatherNotifier extends StateNotifier<WeatherReport?> {
  WeatherNotifier() : super(null);

  Future<void> fetchWeather(AppLatLng coords) async {
    final report = await WeatherAPI.fetchWeather(coords);
    state = report;
  }
}

final weatherProvider = StateNotifierProvider<WeatherNotifier, WeatherReport?>((
  ref,
) {
  return WeatherNotifier();
});
