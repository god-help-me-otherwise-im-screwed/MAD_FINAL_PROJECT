import 'package:hawahawa/constants/weather_codes.dart';

class WeatherData {
  final String timestamp;
  final Map<String, dynamic> values;

  WeatherData({required this.timestamp, required this.values});

  /// Format time respecting timezone offset and user preferences
  /// Parameters:
  ///   - timezoneOffset: hours offset from UTC (e.g., 5 for UTC+5)
  ///   - is24HourFormat: true for 24-hour, false for 12-hour
  String getFormattedTime({
    double timezoneOffset = 0,
    bool is24HourFormat = true,
  }) {
    try {
      final dt = DateTime.parse(timestamp).toUtc();
      final offsetDuration = Duration(
        hours: timezoneOffset.toInt(),
        minutes: ((timezoneOffset % 1) * 60).toInt(),
      );
      final localDt = dt.add(offsetDuration);

      if (timestamp.contains('T')) {
        // Time format
        if (is24HourFormat) {
          return '${localDt.hour.toString().padLeft(2, '0')}:${localDt.minute.toString().padLeft(2, '0')}';
        } else {
          // 12-hour format with AM/PM
          final hour = localDt.hour % 12 == 0 ? 12 : localDt.hour % 12;
          final ampm = localDt.hour < 12 ? 'AM' : 'PM';
          return '${hour.toString().padLeft(2, '0')}:${localDt.minute.toString().padLeft(2, '0')} $ampm';
        }
      }
      // Date format
      return '${localDt.day.toString().padLeft(2, '0')}/${localDt.month.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }

  String formatValue(
    String key,
    dynamic value, {
    double timezoneOffset = 0,
    bool is24HourFormat = true,
  }) {
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
          final dt = DateTime.parse(value.toString()).toUtc();
          final offsetDuration = Duration(
            hours: timezoneOffset.toInt(),
            minutes: ((timezoneOffset % 1) * 60).toInt(),
          );
          final localDt = dt.add(offsetDuration);
          return '${localDt.hour.toString().padLeft(2, '0')}:${localDt.minute.toString().padLeft(2, '0')}';
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
  final double timezoneOffset; // Hours offset from UTC (e.g., 5.0 for UTC+5)

  WeatherReport({
    this.locationName,
    this.current,
    required this.hourly,
    required this.daily,
    this.timezoneOffset = 0,
  });

  factory WeatherReport.placeholder({double timezoneOffset = 0}) {
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
    return WeatherReport(
      current: sample,
      hourly: [sample],
      daily: [sample],
      timezoneOffset: timezoneOffset,
    );
  }
}
