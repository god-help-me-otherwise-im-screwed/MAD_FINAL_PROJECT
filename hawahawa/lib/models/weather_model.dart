import 'package:hawahawa/constants/weather_codes.dart';

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
  final String? locationName;
  final WeatherData? current;
  final List<WeatherData> hourly;
  final List<WeatherData> daily;

  WeatherReport({
    this.locationName,
    this.current,
    required this.hourly,
    required this.daily,
  });

  factory WeatherReport.placeholder() {
    final now = DateTime.now();
    final sample = WeatherData(
      timestamp: now.toIso8601String(),
      values: {
        'temperature': 20.0,
        'weatherCode': 1000,
        'humidity': 50.0,
        'windSpeed': 5.0,
        'cloudCover': 10.0,
      },
    );
    return WeatherReport(current: sample, hourly: [sample], daily: [sample]);
  }
}
