class WeatherData {
  final double temp;
  final int conditionCode;
  final DateTime timestamp;
  final double? humidity;
  final double? windSpeed;
  final double? cloudCover;
  final double? precipitation;

  WeatherData({
    required this.temp,
    required this.conditionCode,
    required this.timestamp,
    this.humidity,
    this.windSpeed,
    this.cloudCover,
    this.precipitation,
  });
}

class WeatherReport {
  final WeatherData? current;
  final List<WeatherData> hourly;
  final List<WeatherData> daily;

  WeatherReport({
    required this.current,
    required this.hourly,
    required this.daily,
  });

  factory WeatherReport.placeholder() {
    final now = DateTime.now();
    final sample = WeatherData(
      temp: 20.0,
      conditionCode: 1000,
      timestamp: now,
      humidity: 50.0,
      windSpeed: 5.0,
      cloudCover: 10.0,
      precipitation: 0.0,
    );
    return WeatherReport(current: sample, hourly: [sample], daily: [sample]);
  }
}
