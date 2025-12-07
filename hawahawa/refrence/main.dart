// main.dart
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

// Flutter Map (OpenStreetMap)
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as osm;

// ============================================================================
// CONFIGURATION
// ============================================================================
const String apiKey = "tacR72uW5okh26wVgIplyAxSC1aOS6xd";

final List<String> requiredFields = [
  "temperature",
  "temperatureApparent",
  "humidity",
  "windSpeed",
  "windDirection",
  "sunriseTime",
  "sunsetTime",
  "visibility",
  "cloudCover",
  "moonPhase",
  "uvIndex",
  "weatherCode",
  "weatherCodeFullDay",
  "weatherCodeDay",
  "weatherCodeNight",
  "thunderstormProbability",
];

// ============================================================================
// WEATHER CODE MAPPER (kept as-is)
// ============================================================================
class WeatherCodeMapper {
  static const Map<int, String> weatherCode = {
    0: 'Unknown',
    1000: 'Clear, Sunny',
    1100: 'Mostly Clear',
    1101: 'Partly Cloudy',
    1102: 'Mostly Cloudy',
    1001: 'Cloudy',
    2000: 'Fog',
    2100: 'Light Fog',
    4000: 'Drizzle',
    4001: 'Rain',
    4200: 'Light Rain',
    4201: 'Heavy Rain',
    5000: 'Snow',
    5001: 'Flurries',
    5100: 'Light Snow',
    5101: 'Heavy Snow',
    6000: 'Freezing Drizzle',
    6001: 'Freezing Rain',
    6200: 'Light Freezing Rain',
    6201: 'Heavy Freezing Rain',
    7000: 'Ice Pellets',
    7101: 'Heavy Ice Pellets',
    7102: 'Light Ice Pellets',
    8000: 'Thunderstorm',
  };

  static const Map<int, String> weatherCodeFullDay = {
    // (same as your original mapping)...
    0: 'Unknown',
    1000: 'Clear, Sunny',
    1100: 'Mostly Clear',
    1101: 'Partly Cloudy',
    1102: 'Mostly Cloudy',
    1001: 'Cloudy',
    1103: 'Partly Cloudy and Mostly Clear',
    2100: 'Light Fog',
    2101: 'Mostly Clear and Light Fog',
    2102: 'Partly Cloudy and Light Fog',
    2103: 'Mostly Cloudy and Light Fog',
    2106: 'Mostly Clear and Fog',
    2107: 'Partly Cloudy and Fog',
    2108: 'Mostly Cloudy and Fog',
    2000: 'Fog',
    4204: 'Partly Cloudy and Drizzle',
    4203: 'Mostly Clear and Drizzle',
    4205: 'Mostly Cloudy and Drizzle',
    4000: 'Drizzle',
    4200: 'Light Rain',
    4213: 'Mostly Clear and Light Rain',
    4214: 'Partly Cloudy and Light Rain',
    4215: 'Mostly Cloudy and Light Rain',
    4209: 'Mostly Clear and Rain',
    4208: 'Partly Cloudy and Rain',
    4210: 'Mostly Cloudy and Rain',
    4001: 'Rain',
    4211: 'Mostly Clear and Heavy Rain',
    4202: 'Partly Cloudy and Heavy Rain',
    4212: 'Mostly Cloudy and Heavy Rain',
    4201: 'Heavy Rain',
    5115: 'Mostly Clear and Flurries',
    5116: 'Partly Cloudy and Flurries',
    5117: 'Mostly Cloudy and Flurries',
    5001: 'Flurries',
    5100: 'Light Snow',
    5102: 'Mostly Clear and Light Snow',
    5103: 'Partly Cloudy and Light Snow',
    5104: 'Mostly Cloudy and Light Snow',
    5122: 'Drizzle and Light Snow',
    5105: 'Mostly Clear and Snow',
    5106: 'Partly Cloudy and Snow',
    5107: 'Mostly Cloudy and Snow',
    5000: 'Snow',
    5101: 'Heavy Snow',
    5119: 'Mostly Clear and Heavy Snow',
    5120: 'Partly Cloudy and Heavy Snow',
    5121: 'Mostly Cloudy and Heavy Snow',
    5110: 'Drizzle and Snow',
    5108: 'Rain and Snow',
    5114: 'Snow and Freezing Rain',
    5112: 'Snow and Ice Pellets',
    6000: 'Freezing Drizzle',
    6003: 'Mostly Clear and Freezing drizzle',
    6002: 'Partly Cloudy and Freezing drizzle',
    6004: 'Mostly Cloudy and Freezing drizzle',
    6204: 'Drizzle and Freezing Drizzle',
    6206: 'Light Rain and Freezing Drizzle',
    6205: 'Mostly Clear and Light Freezing Rain',
    6203: 'Partly Cloudy and Light Freezing Rain',
    6209: 'Mostly Cloudy and Light Freezing Rain',
    6200: 'Light Freezing Rain',
    6213: 'Mostly Clear and Freezing Rain',
    6214: 'Partly Cloudy and Freezing Rain',
    6215: 'Mostly Cloudy and Freezing Rain',
    6001: 'Freezing Rain',
    6212: 'Drizzle and Freezing Rain',
    6220: 'Light Rain and Freezing Rain',
    6222: 'Rain and Freezing Rain',
    6207: 'Mostly Clear and Heavy Freezing Rain',
    6202: 'Partly Cloudy and Heavy Freezing Rain',
    6208: 'Mostly Cloudy and Heavy Freezing Rain',
    6201: 'Heavy Freezing Rain',
    7110: 'Mostly Clear and Light Ice Pellets',
    7111: 'Partly Cloudy and Light Ice Pellets',
    7112: 'Mostly Cloudy and Light Ice Pellets',
    7102: 'Light Ice Pellets',
    7108: 'Mostly Clear and Ice Pellets',
    7107: 'Partly Cloudy and Ice Pellets',
    7109: 'Mostly Cloudy and Ice Pellets',
    7000: 'Ice Pellets',
    7105: 'Drizzle and Ice Pellets',
    7106: 'Freezing Rain and Ice Pellets',
    7115: 'Light Rain and Ice Pellets',
    7117: 'Rain and Ice Pellets',
    7103: 'Freezing Rain and Heavy Ice Pellets',
    7113: 'Mostly Clear and Heavy Ice Pellets',
    7114: 'Partly Cloudy and Heavy Ice Pellets',
    7116: 'Mostly Cloudy and Heavy Ice Pellets',
    7101: 'Heavy Ice Pellets',
    8001: 'Mostly Clear and Thunderstorm',
    8003: 'Partly Cloudy and Thunderstorm',
    8002: 'Mostly Cloudy and Thunderstorm',
    8000: 'Thunderstorm',
  };

  static const Map<int, String> weatherCodeDay = {
    // (kept as original mapping)
    0: 'Unknown',
    10000: 'Clear, Sunny',
    11000: 'Mostly Clear',
    11010: 'Partly Cloudy',
    11020: 'Mostly Cloudy',
    10010: 'Cloudy',
    11030: 'Partly Cloudy and Mostly Clear',
    21000: 'Light Fog',
    21010: 'Mostly Clear and Light Fog',
    21020: 'Partly Cloudy and Light Fog',
    21030: 'Mostly Cloudy and Light Fog',
    21060: 'Mostly Clear and Fog',
    21070: 'Partly Cloudy and Fog',
    21080: 'Mostly Cloudy and Fog',
    20000: 'Fog',
    42040: 'Partly Cloudy and Drizzle',
    42030: 'Mostly Clear and Drizzle',
    42050: 'Mostly Cloudy and Drizzle',
    40000: 'Drizzle',
    42000: 'Light Rain',
    42130: 'Mostly Clear and Light Rain',
    42140: 'Partly Cloudy and Light Rain',
    42150: 'Mostly Cloudy and Light Rain',
    42090: 'Mostly Clear and Rain',
    42080: 'Partly Cloudy and Rain',
    42100: 'Mostly Cloudy and Rain',
    40010: 'Rain',
    42110: 'Mostly Clear and Heavy Rain',
    42020: 'Partly Cloudy and Heavy Rain',
    42120: 'Mostly Cloudy and Heavy Rain',
    42010: 'Heavy Rain',
    51150: 'Mostly Clear and Flurries',
    51160: 'Partly Cloudy and Flurries',
    51170: 'Mostly Cloudy and Flurries',
    50010: 'Flurries',
    51000: 'Light Snow',
    51020: 'Mostly Clear and Light Snow',
    51030: 'Partly Cloudy and Light Snow',
    51040: 'Mostly Cloudy and Light Snow',
    51220: 'Drizzle and Light Snow',
    51050: 'Mostly Clear and Snow',
    51060: 'Partly Cloudy and Snow',
    51070: 'Mostly Cloudy and Snow',
    50000: 'Snow',
    51010: 'Heavy Snow',
    51190: 'Mostly Clear and Heavy Snow',
    51200: 'Partly Cloudy and Heavy Snow',
    51210: 'Mostly Cloudy and Heavy Snow',
    51100: 'Drizzle and Snow',
    51080: 'Rain and Snow',
    51140: 'Snow and Freezing Rain',
    51120: 'Snow and Ice Pellets',
    60000: 'Freezing Drizzle',
    60030: 'Mostly Clear and Freezing drizzle',
    60020: 'Partly Cloudy and Freezing drizzle',
    60040: 'Mostly Cloudy and Freezing drizzle',
    62040: 'Drizzle and Freezing Drizzle',
    62060: 'Light Rain and Freezing Drizzle',
    62050: 'Mostly Clear and Light Freezing Rain',
    62030: 'Partly Cloudy and Light Freezing Rain',
    62090: 'Mostly Cloudy and Light Freezing Rain',
    62000: 'Light Freezing Rain',
    62130: 'Mostly Clear and Freezing Rain',
    62140: 'Partly Cloudy and Freezing Rain',
    62150: 'Mostly Cloudy and Freezing Rain',
    60010: 'Freezing Rain',
    62120: 'Drizzle and Freezing Rain',
    62200: 'Light Rain and Freezing Rain',
    62220: 'Rain and Freezing Rain',
    62070: 'Mostly Clear and Heavy Freezing Rain',
    62020: 'Partly Cloudy and Heavy Freezing Rain',
    62080: 'Mostly Cloudy and Heavy Freezing Rain',
    62010: 'Heavy Freezing Rain',
    71100: 'Mostly Clear and Light Ice Pellets',
    71110: 'Partly Cloudy and Light Ice Pellets',
    71120: 'Mostly Cloudy and Light Ice Pellets',
    71020: 'Light Ice Pellets',
    71080: 'Mostly Clear and Ice Pellets',
    71070: 'Partly Cloudy and Ice Pellets',
    71090: 'Mostly Cloudy and Ice Pellets',
    70000: 'Ice Pellets',
    71050: 'Drizzle and Ice Pellets',
    71060: 'Freezing Rain and Ice Pellets',
    71150: 'Light Rain and Ice Pellets',
    71170: 'Rain and Ice Pellets',
    71030: 'Freezing Rain and Heavy Ice Pellets',
    71130: 'Mostly Clear and Heavy Ice Pellets',
    71140: 'Partly Cloudy and Heavy Ice Pellets',
    71160: 'Mostly Cloudy and Heavy Ice Pellets',
    71010: 'Heavy Ice Pellets',
    80010: 'Mostly Clear and Thunderstorm',
    80030: 'Partly Cloudy and Thunderstorm',
    80020: 'Mostly Cloudy and Thunderstorm',
    80000: 'Thunderstorm',
  };

  static const Map<int, String> weatherCodeNight = {
    // (kept as original mapping)
    0: 'Unknown',
    10001: 'Clear',
    11001: 'Mostly Clear',
    11011: 'Partly Cloudy',
    11021: 'Mostly Cloudy',
    10011: 'Cloudy',
    11031: 'Partly Cloudy and Mostly Clear',
    21001: 'Light Fog',
    21011: 'Mostly Clear and Light Fog',
    21021: 'Partly Cloudy and Light Fog',
    21031: 'Mostly Cloudy and Light Fog',
    21061: 'Mostly Clear and Fog',
    21071: 'Partly Cloudy and Fog',
    21081: 'Mostly Cloudy and Fog',
    20001: 'Fog',
    42041: 'Partly Cloudy and Drizzle',
    42031: 'Mostly Clear and Drizzle',
    42051: 'Mostly Cloudy and Drizzle',
    40001: 'Drizzle',
    42001: 'Light Rain',
    42131: 'Mostly Clear and Light Rain',
    42141: 'Partly Cloudy and Light Rain',
    42151: 'Mostly Cloudy and Light Rain',
    42091: 'Mostly Clear and Rain',
    42081: 'Partly Cloudy and Rain',
    42101: 'Mostly Cloudy and Rain',
    40011: 'Rain',
    42111: 'Mostly Clear and Heavy Rain',
    42021: 'Partly Cloudy and Heavy Rain',
    42121: 'Mostly Cloudy and Heavy Rain',
    42011: 'Heavy Rain',
    51151: 'Mostly Clear and Flurries',
    51161: 'Partly Cloudy and Flurries',
    51171: 'Mostly Cloudy and Flurries',
    50011: 'Flurries',
    51001: 'Light Snow',
    51021: 'Mostly Clear and Light Snow',
    51031: 'Partly Cloudy and Light Snow',
    51041: 'Mostly Cloudy and Light Snow',
    51221: 'Drizzle and Light Snow',
    51051: 'Mostly Clear and Snow',
    51061: 'Partly Cloudy and Snow',
    51071: 'Mostly Cloudy and Snow',
    50001: 'Snow',
    51011: 'Heavy Snow',
    51191: 'Mostly Clear and Heavy Snow',
    51201: 'Partly Cloudy and Heavy Snow',
    51211: 'Mostly Cloudy and Heavy Snow',
    51101: 'Drizzle and Snow',
    51081: 'Rain and Snow',
    51141: 'Snow and Freezing Rain',
    51121: 'Snow and Ice Pellets',
    60001: 'Freezing Drizzle',
    60031: 'Mostly Clear and Freezing drizzle',
    60021: 'Partly Cloudy and Freezing drizzle',
    60041: 'Mostly Cloudy and Freezing drizzle',
    62041: 'Drizzle and Freezing Drizzle',
    62061: 'Light Rain and Freezing Drizzle',
    62051: 'Mostly Clear and Light Freezing Rain',
    62031: 'Partly cloudy and Light Freezing Rain',
    62091: 'Mostly Cloudy and Light Freezing Rain',
    62001: 'Light Freezing Rain',
    62131: 'Mostly Clear and Freezing Rain',
    62141: 'Partly Cloudy and Freezing Rain',
    62151: 'Mostly Cloudy and Freezing Rain',
    60011: 'Freezing Rain',
    62121: 'Drizzle and Freezing Rain',
    62201: 'Light Rain and Freezing Rain',
    62221: 'Rain and Freezing Rain',
    62071: 'Mostly Clear and Heavy Freezing Rain',
    62021: 'Partly Cloudy and Heavy Freezing Rain',
    62081: 'Mostly Cloudy and Heavy Freezing Rain',
    62011: 'Heavy Freezing Rain',
    71101: 'Mostly Clear and Light Ice Pellets',
    71111: 'Partly Cloudy and Light Ice Pellets',
    71121: 'Mostly Cloudy and Light Ice Pellets',
    71021: 'Light Ice Pellets',
    71081: 'Mostly Clear and Ice Pellets',
    71071: 'Partly Cloudy and Ice Pellets',
    71091: 'Mostly Cloudy and Ice Pellets',
    70001: 'Ice Pellets',
    71051: 'Drizzle and Ice Pellets',
    71061: 'Freezing Rain and Ice Pellets',
    71151: 'Light Rain and Ice Pellets',
    71171: 'Rain and Ice Pellets',
    71031: 'Freezing Rain and Heavy Ice Pellets',
    71131: 'Mostly Clear and Heavy Ice Pellets',
    71141: 'Partly Cloudy and Heavy Ice Pellets',
    71161: 'Mostly Cloudy and Heavy Ice Pellets',
    71011: 'Heavy Ice Pellets',
    80011: 'Mostly Clear and Thunderstorm',
    80031: 'Partly Cloudy and Thunderstorm',
    80021: 'Mostly Cloudy and Thunderstorm',
    80001: 'Thunderstorm',
  };

  /// Return English description for a weather code.
  /// [fieldName] lets the caller indicate which mapping to use (FullDay/Day/Night/Default).
  static String getDescription(
    dynamic code, [
    String fieldName = 'weatherCode',
  ]) {
    if (code == null) return 'N/A';
    final int? intCode = int.tryParse(code.toString());
    if (intCode == null) return 'N/A';

    final name = fieldName.toLowerCase();
    if (name.contains('fullday')) {
      return weatherCodeFullDay[intCode] ?? 'Unknown Code ($code)';
    }
    if (name.contains('day') && !name.contains('fullday')) {
      return weatherCodeDay[intCode] ?? 'Unknown Code ($code)';
    }
    if (name.contains('night')) {
      return weatherCodeNight[intCode] ?? 'Unknown Code ($code)';
    }

    return weatherCode[intCode] ?? 'Unknown Code ($code)';
  }
}

// ============================================================================
// SIMPLE APP LATLNG (so both map libs can use same state)
// ============================================================================
class AppLatLng {
  final double latitude;
  final double longitude;
  const AppLatLng(this.latitude, this.longitude);

  osm.LatLng toOsm() => osm.LatLng(latitude, longitude);

  @override
  String toString() => '$latitude, $longitude';
}

// ============================================================================
// DATA MODELS (kept with tiny adjustments)
// ============================================================================
class LocationResult {
  final double lat;
  final double lon;
  final String displayName;

  LocationResult({
    required this.lat,
    required this.lon,
    required this.displayName,
  });

  factory LocationResult.fromNominatim(Map<String, dynamic> json) {
    return LocationResult(
      lat: double.parse(json['lat'].toString()),
      lon: double.parse(json['lon'].toString()),
      displayName: json['display_name'] ?? 'Unknown',
    );
  }
}

class WeatherData {
  final String timestamp;
  final Map<String, dynamic> values;

  WeatherData({required this.timestamp, required this.values});

  String getFormattedTime() {
    try {
      final dt = DateTime.parse(timestamp).toLocal();
      if (timestamp.contains('T')) {
        return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      }
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }

  String formatValue(String key, dynamic value) {
    if (value == null) return 'N/A';
    final numValue = value is num
        ? value
        : (double.tryParse(value.toString()) ?? value);
    if (key.contains('temperature')) {
      if (numValue is num) return '${numValue.toStringAsFixed(1)}°C';
      return '$numValue°C';
    }
    if (key == 'humidity' ||
        key == 'cloudCover' ||
        key == 'thunderstormProbability') {
      return '${(numValue as num).toStringAsFixed(0)}%';
    }
    if (key == 'windSpeed') {
      return '${(numValue as num).toStringAsFixed(1)} m/s';
    }
    if (key == 'windDirection') {
      return '${(numValue as num).toStringAsFixed(0)}°';
    }
    if (key == 'visibility') {
      return '${(numValue as num).toStringAsFixed(1)} km';
    }
    if (key == 'uvIndex') {
      return (numValue as num).toStringAsFixed(1);
    }
    if (key.startsWith('weatherCode')) {
      return WeatherCodeMapper.getDescription(value, key);
    }
    if (key.contains('Time')) {
      if (key == 'sunriseTime' || key == 'sunsetTime') {
        try {
          return DateTime.parse(
            value.toString(),
          ).toLocal().toString().substring(11, 16);
        } catch (_) {
          return value.toString();
        }
      }
    }
    return value.toString();
  }
}

class WeatherReport {
  final LocationResult location;
  final WeatherData? current;
  final List<WeatherData> hourly;
  final List<WeatherData> daily;

  WeatherReport({
    required this.location,
    this.current,
    required this.hourly,
    required this.daily,
  });
}

// ============================================================================
// RIVERPOD PROVIDERS
// ============================================================================
final locationProvider = StateProvider<AppLatLng>(
  (ref) => const AppLatLng(40.7128, -74.0060),
);

final weatherReportProvider = StateProvider<WeatherReport?>((ref) => null);

// ============================================================================
// API CLIENTS (Location API + Weather API)
// ============================================================================
class LocationAPI {
  static Future<List<LocationResult>> searchLocations(String query) async {
    if (query.trim().isEmpty) return [];

    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': query,
      'format': 'json',
      'limit': '10',
      'addressdetails': '1',
      'accept-language': 'en',
    });

    final response = await http
        .get(uri, headers: {'User-Agent': 'WeatherApp/1.0'})
        .timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) {
      throw Exception('Search failed: ${response.statusCode}');
    }

    final List results = jsonDecode(response.body);
    return results.map((json) => LocationResult.fromNominatim(json)).toList();
  }

  static Future<LocationResult> reverseGeocode(double lat, double lon) async {
    final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
      'lat': lat.toString(),
      'lon': lon.toString(),
      'format': 'json',
      'zoom': '18',
      'accept-language': 'en',
    });

    final response = await http
        .get(uri, headers: {'User-Agent': 'WeatherApp/1.0'})
        .timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) {
      throw Exception('Reverse geocoding failed');
    }

    final json = jsonDecode(response.body);
    return LocationResult(
      lat: lat,
      lon: lon,
      displayName: json['display_name'] ?? 'Unknown Location',
    );
  }
}

class WeatherAPI {
  static Future<WeatherReport> fetchWeather(LocationResult location) async {
    final uri = Uri.https('api.tomorrow.io', '/v4/timelines', {
      'location': '${location.lat},${location.lon}',
      'fields': requiredFields.join(','),
      'timesteps': 'current,1h,1d',
      'units': 'metric',
      'apikey': apiKey,
    });

    final response = await http.get(uri).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Weather API failed: HTTP ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return _parseWeatherResponse(json, location);
  }

  static WeatherReport _parseWeatherResponse(
    Map<String, dynamic> json,
    LocationResult location,
  ) {
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
      location: location,
      current: current,
      hourly: hourly,
      daily: daily,
    );
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

// ============================================================================
// MAIN APP
// ============================================================================
void main() {
  runApp(const ProviderScope(child: WeatherApp()));
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather Forecast App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const SplashScreen(),
    );
  }
}

// ============================================================================
// SPLASH SCREEN
// ============================================================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Wait a bit for splash animation then ensure permissions before navigation.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      await _ensureLocationPermissions();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WeatherDisplayScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Simple splash UI, can be customized as needed
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.cloud, size: 80, color: Colors.blue),
            SizedBox(height: 24),
            Text(
              'Weather Forecast App',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Future<void> _ensureLocationPermissions() async {
    try {
      // Check location services
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled && mounted) {
        final open = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Enable Location Services'),
            content: const Text(
              'Location services are disabled. The app needs location to provide local weather. Open location settings?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Open'),
              ),
            ],
          ),
        );
        if (open == true) await Geolocator.openLocationSettings();
      }

      // Check & request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Location Permission Denied'),
            content: const Text(
              'Location permission was denied. You can still use the app but GPS features will be limited.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        final open = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Location Permission Needed'),
            content: const Text(
              'Location permission is permanently denied. Open app settings to allow the permission?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
        if (open == true) await Geolocator.openAppSettings();
        return;
      }
      // permission granted (whenInUse or always) — nothing else to do
    } catch (_) {
      // ignore errors on splash; proceed to app
    }
  }
}

// ============================================================================
// WEATHER DISPLAY SCREEN (Main Hub)
// ============================================================================
class WeatherDisplayScreen extends ConsumerStatefulWidget {
  const WeatherDisplayScreen({super.key});

  @override
  ConsumerState<WeatherDisplayScreen> createState() =>
      _WeatherDisplayScreenState();
}

class _WeatherDisplayScreenState extends ConsumerState<WeatherDisplayScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _fetchWeatherForCurrentLocation() async {
    final currentLocation = ref.read(locationProvider);

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final location = await LocationAPI.reverseGeocode(
        currentLocation.latitude,
        currentLocation.longitude,
      );
      final report = await WeatherAPI.fetchWeather(location);
      ref.read(weatherReportProvider.notifier).state = report;
    } catch (e) {
      setState(() => _errorMessage = 'Failed to fetch weather: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    // Auto-fetch weather on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchWeatherForCurrentLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final weatherReport = ref.watch(weatherReportProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Forecast'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchLocationScreen()),
              );
              _fetchWeatherForCurrentLocation();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(_errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _fetchWeatherForCurrentLocation,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : weatherReport != null
          ? WeatherReportView(report: weatherReport)
          : const Center(child: Text('No weather data available')),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'gps',
            onPressed: () async {
              await _useGPSLocation();
            },
            icon: const Icon(Icons.my_location),
            label: const Text('Use GPS'),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'map',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
              );
              _fetchWeatherForCurrentLocation();
            },
            icon: const Icon(Icons.map),
            label: const Text('Pick on Map'),
          ),
        ],
      ),
    );
  }

  Future<void> _useGPSLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          throw Exception('Location permissions denied');
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      ref.read(locationProvider.notifier).state = AppLatLng(
        position.latitude,
        position.longitude,
      );

      await _fetchWeatherForCurrentLocation();
    } catch (e) {
      setState(() => _errorMessage = 'GPS Error: $e');
      setState(() => _isLoading = false);
    }
  }
}

// ============================================================================
// LOCATION PICKER SCREEN (combined GoogleMap + OSM)
// ============================================================================
class LocationPickerScreen extends ConsumerStatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  ConsumerState<LocationPickerScreen> createState() =>
      _LocationPickerScreenState();
}

class _LocationPickerScreenState extends ConsumerState<LocationPickerScreen> {
  AppLatLng? _selectedPoint;
  // For OSM
  osm.LatLng? _osmSelectedPoint;

  @override
  void initState() {
    super.initState();
    final current = ref.read(locationProvider);
    _selectedPoint = current;
    _osmSelectedPoint = current.toOsm();
    // no Google Maps initialization anymore
  }

  void _confirmAndPop() {
    if (_selectedPoint != null) {
      ref.read(locationProvider.notifier).state = _selectedPoint!;
    } else if (_osmSelectedPoint != null) {
      ref.read(locationProvider.notifier).state = AppLatLng(
        _osmSelectedPoint!.latitude,
        _osmSelectedPoint!.longitude,
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final currentLocation = ref.watch(locationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location on Map'),
        actions: [
          TextButton.icon(
            onPressed: _confirmAndPop,
            icon: const Icon(Icons.check, color: Colors.white),
            label: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Builder(
        builder: (ctx) {
          final init = currentLocation.toOsm();
          return FlutterMap(
            options: MapOptions(
              initialCenter: init,
              initialZoom: 13,
              onTap: (tapPosition, point) {
                setState(() {
                  _osmSelectedPoint = point;
                  // reflect into the shared AppLatLng & _selectedPoint for consistency
                  _selectedPoint = AppLatLng(point.latitude, point.longitude);
                });
                ref.read(locationProvider.notifier).state = AppLatLng(
                  point.latitude,
                  point.longitude,
                );
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ["a", "b", "c"],
                userAgentPackageName: "com.example.yourapp",
              ),
              if (_osmSelectedPoint != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _osmSelectedPoint!,
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
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: _selectedPoint == null
            ? const Text("Tap anywhere on the map to select a location.")
            : Text(
                "Selected: ${_selectedPoint!.latitude.toStringAsFixed(6)}, ${_selectedPoint!.longitude.toStringAsFixed(6)}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}

// ============================================================================
// SEARCH LOCATION SCREEN
// ============================================================================
class SearchLocationScreen extends ConsumerStatefulWidget {
  const SearchLocationScreen({super.key});

  @override
  ConsumerState<SearchLocationScreen> createState() =>
      _SearchLocationScreenState();
}

class _SearchLocationScreenState extends ConsumerState<SearchLocationScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  List<LocationResult> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final results = await LocationAPI.searchLocations(query);
        if (mounted) {
          setState(() {
            _searchResults = results;
            _isSearching = false;
          });
        }
      } catch (e) {
        if (mounted) setState(() => _isSearching = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Location')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for a city...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final location = _searchResults[index];
                return ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.blue),
                  title: Text(location.displayName, maxLines: 2),
                  subtitle: Text(
                    'Lat: ${location.lat.toStringAsFixed(4)}, Lon: ${location.lon.toStringAsFixed(4)}',
                  ),
                  onTap: () {
                    ref.read(locationProvider.notifier).state = AppLatLng(
                      location.lat,
                      location.lon,
                    );
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// WEATHER REPORT VIEW
// ============================================================================
class WeatherReportView extends StatelessWidget {
  final WeatherReport report;

  const WeatherReportView({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: Colors.blue.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        report.location.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (report.current != null) ...[
          const Text(
            'CURRENT',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          WeatherDataCard(data: report.current!, isCurrent: true),
          const SizedBox(height: 24),
        ],
        if (report.hourly.isNotEmpty) ...[
          const Text(
            'HOURLY',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...report.hourly.take(6).map((data) => WeatherDataCard(data: data)),
          const SizedBox(height: 24),
        ],
        if (report.daily.isNotEmpty) ...[
          const Text(
            'DAILY',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...report.daily.map((data) => WeatherDataCard(data: data)),
        ],
      ],
    );
  }
}

class WeatherDataCard extends StatelessWidget {
  final WeatherData data;
  final bool isCurrent;

  const WeatherDataCard({
    super.key,
    required this.data,
    this.isCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    final temp = data.values['temperature'];
    final weatherCode = data.values['weatherCode'];
    final weatherDescription = WeatherCodeMapper.getDescription(weatherCode);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(
          isCurrent ? 'Current Conditions' : data.getFormattedTime(),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Temp: ${data.formatValue("temperature", temp)} | $weatherDescription',
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: Column(
              children: data.values.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 180,
                        child: Text(
                          entry.key,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Expanded(
                        child: Text(data.formatValue(entry.key, entry.value)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
