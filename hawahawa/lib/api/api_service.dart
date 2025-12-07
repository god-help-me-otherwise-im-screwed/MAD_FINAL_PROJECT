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
          return LocationResult(
            lat: double.parse(first['lat'].toString()),
            lon: double.parse(first['lon'].toString()),
            displayName: first['display_name'] ?? name,
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
      return results.map((json) => LocationResult.fromNominatim(json)).toList();
    } on TimeoutException {
      print('Search Error: Request timed out after 15 seconds');
      return [];
    } catch (e) {
      print('Search Error: $e');
      return [];
    }
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
        return WeatherReport.placeholder();
      }
    } catch (e) {
      print('Weather API Exception: $e');
      return WeatherReport.placeholder();
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

      return WeatherReport(
        locationName: location.displayName,
        current: current,
        hourly: hourly,
        daily: daily,
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
