import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hawahawa/models/weather_model.dart';
import 'package:hawahawa/api/api_service.dart';
import 'package:hawahawa/models/location_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:convert';

class WeatherNotifier extends StateNotifier<WeatherReport?> {
  WeatherNotifier() : super(null);

  /// Check if device has internet connection
  Future<bool> _hasInternetConnection() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    // FIX: Check the result directly against the online statuses
    return connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.ethernet;
  }

  /// Save weather report to persistent storage for offline access
  Future<void> _cacheWeatherReport(WeatherReport report) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Serialize weather data to JSON
      final weatherJson = jsonEncode({
        'locationName': report.locationName,
        'timezoneOffset': report.timezoneOffset,
        'current': report.current != null
            ? {
                'timestamp': report.current!.timestamp,
                'values': report.current!.values,
              }
            : null,
        'hourly': report.hourly
            .map((w) => {'timestamp': w.timestamp, 'values': w.values})
            .toList(),
        'daily': report.daily
            .map((w) => {'timestamp': w.timestamp, 'values': w.values})
            .toList(),
        'cachedAt': DateTime.now().toIso8601String(),
      });

      await prefs.setString('cached_weather', weatherJson);
      print('[WEATHER CACHE] Weather report cached successfully');
    } catch (e) {
      print('[WEATHER CACHE ERROR] Failed to cache weather: $e');
    }
  }

  /// Load cached weather report from persistent storage
  Future<WeatherReport?> _loadCachedWeatherReport() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final weatherJson = prefs.getString('cached_weather');

      if (weatherJson == null) {
        print('[WEATHER CACHE] No cached weather found');
        return null;
      }

      final decoded = jsonDecode(weatherJson);

      final current = decoded['current'] != null
          ? WeatherData(
              timestamp: decoded['current']['timestamp'],
              values: Map<String, dynamic>.from(decoded['current']['values']),
            )
          : null;

      final hourly = (decoded['hourly'] as List)
          .map(
            (w) => WeatherData(
              timestamp: w['timestamp'],
              values: Map<String, dynamic>.from(w['values']),
            ),
          )
          .toList();

      final daily = (decoded['daily'] as List)
          .map(
            (w) => WeatherData(
              timestamp: w['timestamp'],
              values: Map<String, dynamic>.from(w['values']),
            ),
          )
          .toList();

      final cachedReport = WeatherReport(
        locationName: decoded['locationName'],
        current: current,
        hourly: hourly,
        daily: daily,
        timezoneOffset: (decoded['timezoneOffset'] as num?)?.toDouble() ?? 0,
      );

      print('[WEATHER CACHE] Cached weather loaded successfully');
      return cachedReport;
    } catch (e) {
      print('[WEATHER CACHE ERROR] Failed to load cached weather: $e');
      return null;
    }
  }

  /// Fetch weather with offline fallback
  /// Returns weather data from API if online, from cache if offline, or default if neither
  Future<void> fetchWeather(LocationResult location) async {
    try {
      final isOnline = await _hasInternetConnection();

      if (isOnline) {
        print('[WEATHER] Online - fetching from API');
        try {
          final report = await WeatherAPI.fetchWeather(location);

          // Assuming WeatherAPI.fetchWeather returns non-nullable WeatherReport
          state = report;
          // Cache successful fetch for offline use
          await _cacheWeatherReport(report);
          // Mark data as fresh (not stale)
          await _setDataIsFresh(true);
          print('[WEATHER] Data fetched and cached');
        } catch (e) {
          print('[WEATHER ERROR] API call failed: $e');
          // Fall back to cached data on API error
          final cached = await _loadCachedWeatherReport();
          if (cached != null) {
            state = cached;
            await _setDataIsFresh(false);
            print('[WEATHER] Loaded from cache due to API error');
          } else {
            // No cache available, use default but preserve location name
            final placeholder = WeatherReport.placeholder();
            state = WeatherReport(
              locationName: location.displayName,
              current: placeholder.current,
              hourly: placeholder.hourly,
              daily: placeholder.daily,
              timezoneOffset: placeholder.timezoneOffset,
            );
            await _setDataIsFresh(false);
            print('[WEATHER] Using default weather (no cache available)');
          }
        }
      } else {
        // Device is offline
        print('[WEATHER] Offline - attempting to load from cache');
        final cached = await _loadCachedWeatherReport();
        if (cached != null) {
          state = cached;
          await _setDataIsFresh(false);
          print('[WEATHER] Loaded from cache (offline)');
        } else {
          // No cache available, use default but preserve location name
          final placeholder = WeatherReport.placeholder();
          state = WeatherReport(
            locationName: location.displayName,
            current: placeholder.current,
            hourly: placeholder.hourly,
            daily: placeholder.daily,
            timezoneOffset: placeholder.timezoneOffset,
          );
          await _setDataIsFresh(false);
          print('[WEATHER] Using default weather (offline, no cache)');
        }
      }
    } catch (e) {
      print('[WEATHER ERROR] Unexpected error in fetchWeather: $e');
      // Last resort: use default weather
      state = WeatherReport.placeholder();
      await _setDataIsFresh(false);
    }
  }

  /// Track if currently displayed weather is fresh (from API) or stale (from cache/default)
  Future<void> _setDataIsFresh(bool isFresh) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('weather_is_fresh', isFresh);
    } catch (e) {
      print('[WEATHER] Failed to save freshness status: $e');
    }
  }

  /// Clear cached weather data (e.g., on debug reset)
  Future<void> resetDebugData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cached_weather');
      await prefs.remove('weather_is_fresh');
      state = null;
      print('[WEATHER] Debug data cleared');
    } catch (e) {
      print('[WEATHER ERROR] Failed to clear debug data: $e');
    }
  }
}

final weatherProvider = StateNotifierProvider<WeatherNotifier, WeatherReport?>((
  ref,
) {
  return WeatherNotifier();
});

/// Provider to track if weather data is fresh (from API) or stale (from cache)
final weatherIsFreshProvider = FutureProvider<bool>((ref) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('weather_is_fresh') ?? false;
  } catch (e) {
    return false;
  }
});
