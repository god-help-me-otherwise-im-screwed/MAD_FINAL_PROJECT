import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:hawahawa/models/location_model.dart';
import 'package:hawahawa/models/weather_model.dart';
import 'package:hawahawa/constants/app_constants.dart';

final List<String> requiredFields = [
  'temperature',
  'temperatureApparent',
  'humidity',
  'windSpeed',
  'windDirection',
  'sunriseTime',
  'sunsetTime',
  'visibility',
  'cloudCover',
  'moonPhase',
  'uvIndex',
  'weatherCode',
  'weatherCodeFullDay',
  'weatherCodeDay',
  'weatherCodeNight',
  'thunderstormProbability',
];

class LocationAPI {
  static Future<LocationResult?> getLocationFromGps() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationResult(
          lat: 31.5204,
          lon: 74.3587,
          displayName: 'Lahore, Pakistan (Default)',
        );
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationResult(
            lat: 31.5204,
            lon: 74.3587,
            displayName: 'Lahore, Pakistan (Default)',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationResult(
          lat: 31.5204,
          lon: 74.3587,
          displayName: 'Lahore, Pakistan (Default)',
        );
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      final locationName = await reverseGeocode(
        position.latitude,
        position.longitude,
      );

      return LocationResult(
        lat: position.latitude,
        lon: position.longitude,
        displayName: locationName,
      );
    } catch (e) {
      print('GPS Error: $e');
      return LocationResult(
        lat: 31.5204,
        lon: 74.3587,
        displayName: 'Lahore, Pakistan (Default)',
      );
    }
  }

  static Future<String> reverseGeocode(double lat, double lon) async {
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
        'lat': lat.toString(),
        'lon': lon.toString(),
        'format': 'json',
        'zoom': '18',
        'accept-language': 'en',
      });

      final response = await http
          .get(uri, headers: {'User-Agent': 'HahaweaWeather/1.0'})
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['display_name'] ?? 'Unknown Location';
      }
      return 'Current Location';
    } catch (e) {
      return 'Current Location';
    }
  }

  static Future<LocationResult?> searchLocationByName(String name) async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));

      final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'q': name,
        'format': 'json',
        'limit': '1',
        'addressdetails': '1',
        'accept-language': 'en',
      });

      final response = await http
          .get(uri, headers: {'User-Agent': 'HahaweaWeather/1.0'})
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List results = jsonDecode(response.body);
        if (results.isNotEmpty) {
          final first = results[0];
          final lat = double.parse(first['lat'].toString());
          final lon = double.parse(first['lon'].toString());
          return LocationResult(
            lat: lat,
            lon: lon,
            displayName: first['display_name'] ?? name,
            timeZoneId: _getTimezoneId(lat, lon),
          );
        }
      }

      return null;
    } catch (e) {
      print('Search Error: $e');
      return null;
    }
  }

  static Future<List<LocationResult>> searchLocations(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'q': query,
        'format': 'json',
        'limit': '10',
        'addressdetails': '1',
        'accept-language': 'en',
      });

      // Increased timeout to 15 seconds to handle rate limiting and slow responses
      final response = await http
          .get(uri, headers: {'User-Agent': 'HahaweaWeather/1.0'})
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 429) {
        // Rate limited - return empty list and let user retry
        print('Search Error: API Rate Limited (429)');
        return [];
      }

      if (response.statusCode != 200) {
        throw Exception('Search failed: ${response.statusCode}');
      }

      final List results = jsonDecode(response.body);
      return results.map((json) {
        final lat = double.parse(json['lat'].toString());
        final lon = double.parse(json['lon'].toString());
        return LocationResult(
          lat: lat,
          lon: lon,
          displayName: json['display_name'] ?? 'Unknown',
          timeZoneId: _getTimezoneId(lat, lon),
        );
      }).toList();
    } on TimeoutException {
      print('Search Error: Request timed out after 15 seconds');
      return [];
    } catch (e) {
      print('Search Error: $e');
      return [];
    }
  }

  /// Get approximate IANA timezone ID based on coordinates
  /// This is a simplified mapping - in production, use a proper timezone library
  static String _getTimezoneId(double latitude, double longitude) {
    // Simplified timezone mapping based on longitude
    if (longitude >= -180 && longitude < -165) return 'Pacific/Honolulu';
    if (longitude >= -165 && longitude < -150) return 'America/Anchorage';
    if (longitude >= -150 && longitude < -135) return 'America/Denver';
    if (longitude >= -135 && longitude < -120) return 'America/Los_Angeles';
    if (longitude >= -120 && longitude < -105) return 'America/Denver';
    if (longitude >= -105 && longitude < -90) return 'America/Chicago';
    if (longitude >= -90 && longitude < -75) return 'America/New_York';
    if (longitude >= -75 && longitude < -60) return 'America/Halifax';
    if (longitude >= -60 && longitude < -45)
      return 'America/Argentina/Buenos_Aires';
    if (longitude >= -45 && longitude < -30) return 'America/Sao_Paulo';
    if (longitude >= -30 && longitude < -15) return 'Atlantic/Azores';
    if (longitude >= -15 && longitude < 0) return 'Africa/Casablanca';
    if (longitude >= 0 && longitude < 15) return 'Europe/London';
    if (longitude >= 15 && longitude < 30) return 'Europe/Paris';
    if (longitude >= 30 && longitude < 45) return 'Europe/Moscow';
    if (longitude >= 45 && longitude < 60) return 'Asia/Dubai';
    if (longitude >= 60 && longitude < 75) return 'Asia/Kolkata';
    if (longitude >= 75 && longitude < 90) return 'Asia/Karachi';
    if (longitude >= 90 && longitude < 105) return 'Asia/Bangkok';
    if (longitude >= 105 && longitude < 120) return 'Asia/Bangkok';
    if (longitude >= 120 && longitude < 135) return 'Asia/Hong_Kong';
    if (longitude >= 135 && longitude < 150) return 'Asia/Tokyo';
    if (longitude >= 150 && longitude < 165) return 'Pacific/Auckland';
    if (longitude >= 165 && longitude <= 180) return 'Pacific/Fiji';
    return 'UTC';
  }
}

class WeatherAPI {
  static Future<WeatherReport> fetchWeather(LocationResult location) async {
    try {
      final uri = Uri.https('api.tomorrow.io', '/v4/timelines', {
        'location': '${location.lat},${location.lon}',
        'fields': requiredFields.join(','),
        'timesteps': 'current,1h,1d',
        'units': 'metric',
        'apikey': kTomorrowIoApiKey,
      });

      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return _parseWeatherResponse(json, location);
      } else {
        print('Weather API Error: ${response.statusCode}');
        final tzOffset = location.lon / 15.0;
        final timezoneOffsetHours = (tzOffset * 2).round() / 2;
        return WeatherReport.placeholder(timezoneOffset: timezoneOffsetHours);
      }
    } catch (e) {
      print('Weather API Exception: $e');
      final tzOffset = location.lon / 15.0;
      final timezoneOffsetHours = (tzOffset * 2).round() / 2;
      return WeatherReport.placeholder(timezoneOffset: timezoneOffsetHours);
    }
  }

  static WeatherReport _parseWeatherResponse(
    Map<String, dynamic> json,
    LocationResult location,
  ) {
    try {
      final timelines = (json['data']?['timelines'] as List?) ?? [];

      WeatherData? current;
      List<WeatherData> hourly = [];
      List<WeatherData> daily = [];

      for (var timeline in timelines) {
        final timestep = timeline['timestep'] as String?;
        final intervals = timeline['intervals'] as List?;

        if (intervals == null || intervals.isEmpty) continue;

        switch (timestep) {
          case 'current':
            current = _parseInterval(intervals[0]);
            break;
          case '1h':
            hourly = intervals
                .map(_parseInterval)
                .whereType<WeatherData>()
                .toList();
            break;
          case '1d':
            daily = intervals
                .map(_parseInterval)
                .whereType<WeatherData>()
                .toList();
            break;
        }
      }

      // Calculate timezone offset from location coordinates
      final tzOffset = location.lon / 15.0;
      final timezoneOffsetHours = (tzOffset * 2).round() / 2;

      return WeatherReport(
        locationName: location.displayName,
        current: current,
        hourly: hourly,
        daily: daily,
        timezoneOffset: timezoneOffsetHours,
      );
    } catch (e) {
      print('Parse Error: $e');
      return WeatherReport.placeholder();
    }
  }

  static WeatherData? _parseInterval(dynamic interval) {
    try {
      final startTime = interval['startTime'] as String?;
      if (startTime == null) return null;

      final valuesMap = interval['values'] as Map<String, dynamic>?;
      if (valuesMap == null) return null;

      final extractedValues = <String, dynamic>{};
      for (var field in requiredFields) {
        extractedValues[field] = valuesMap[field];
      }

      return WeatherData(timestamp: startTime, values: extractedValues);
    } catch (e) {
      return null;
    }
  }
}
