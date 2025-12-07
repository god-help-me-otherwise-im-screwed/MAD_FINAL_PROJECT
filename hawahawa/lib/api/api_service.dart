import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:hawahawa/models/location_model.dart';
import 'package:hawahawa/models/weather_model.dart';
import 'package:hawahawa/constants/app_constants.dart';

class LocationAPI {
  static Future<LocationResult?> getLocationFromGps() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const LocationResult(
          name: 'Lahore, Pakistan (Default)',
          coords: AppLatLng(31.5204, 74.3587),
        );
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return const LocationResult(
            name: 'Lahore, Pakistan (Default)',
            coords: AppLatLng(31.5204, 74.3587),
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return const LocationResult(
          name: 'Lahore, Pakistan (Default)',
          coords: AppLatLng(31.5204, 74.3587),
        );
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      final locationName = await reverseGeocode(position.latitude, position.longitude);
      
      return LocationResult(
        name: locationName,
        coords: AppLatLng(position.latitude, position.longitude),
      );
    } catch (e) {
      print('GPS Error: $e');
      return const LocationResult(
        name: 'Lahore, Pakistan (Default)',
        coords: AppLatLng(31.5204, 74.3587),
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
          .get(uri, headers: {'User-Agent': 'PixelWeatherSim/1.0'})
          .timeout(const Duration(seconds: 5));

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
          .get(uri, headers: {'User-Agent': 'PixelWeatherSim/1.0'})
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List results = jsonDecode(response.body);
        if (results.isNotEmpty) {
          final first = results[0];
          return LocationResult(
            name: first['display_name'] ?? name,
            coords: AppLatLng(
              double.parse(first['lat'].toString()),
              double.parse(first['lon'].toString()),
            ),
          );
        }
      }
      
      return null;
    } catch (e) {
      print('Search Error: $e');
      return null;
    }
  }
}

class WeatherAPI {
  static Future<WeatherReport> fetchWeather(AppLatLng coords) async {
    try {
      final uri = Uri.https('api.tomorrow.io', '/v4/timelines', {
        'location': '${coords.lat},${coords.lon}',
        'fields': 'temperature,temperatureApparent,humidity,windSpeed,windDirection,weatherCode,cloudCover,visibility,uvIndex',
        'timesteps': 'current,1h,1d',
        'units': 'metric',
        'apikey': kTomorrowIoApiKey,
      });

      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return _parseWeatherResponse(json);
      } else {
        print('Weather API Error: ${response.statusCode}');
        return WeatherReport.placeholder();
      }
    } catch (e) {
      print('Weather API Exception: $e');
      return WeatherReport.placeholder();
    }
  }

  static WeatherReport _parseWeatherResponse(Map<String, dynamic> json) {
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

      return WeatherData(
        temp: (valuesMap['temperature'] ?? 20.0).toDouble(),
        conditionCode: (valuesMap['weatherCode'] ?? 1000) as int,
        timestamp: DateTime.parse(startTime),
        humidity: valuesMap['humidity']?.toDouble(),
        windSpeed: valuesMap['windSpeed']?.toDouble(),
        cloudCover: valuesMap['cloudCover']?.toDouble(),
        precipitation: 0.0,
      );
    } catch (e) {
      return null;
    }
  }
}