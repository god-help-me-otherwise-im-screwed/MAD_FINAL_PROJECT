import 'package:flutter/material.dart';
import 'package:hawahawa/models/weather_model.dart';
import 'package:hawahawa/constants/colors.dart';

class WeatherReportView extends StatelessWidget {
  final WeatherReport report;

  const WeatherReportView({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header with location
        if (report.locationName != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Text(
              report.locationName!,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: kDarkText),
              textAlign: TextAlign.center,
            ),
          ),

        // Current weather
        if (report.current != null) ...[
          Text(
            'Current Weather',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: kDarkText),
          ),
          const SizedBox(height: 12),
          WeatherDataCard(data: report.current!, isCurrent: true),
          const SizedBox(height: 24),
        ],

        // Hourly forecast
        if (report.hourly.isNotEmpty) ...[
          Text(
            'Hourly Forecast',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: kDarkText),
          ),
          const SizedBox(height: 12),
          ...report.hourly
              .take(12)
              .map((data) => WeatherDataCard(data: data, isCurrent: false))
              .toList(),
          const SizedBox(height: 24),
        ],

        // Daily forecast
        if (report.daily.isNotEmpty) ...[
          Text(
            'Daily Forecast',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: kDarkText),
          ),
          const SizedBox(height: 12),
          ...report.daily
              .map((data) => WeatherDataCard(data: data, isCurrent: false))
              .toList(),
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
    final humidity = data.values['humidity'];
    final windSpeed = data.values['windSpeed'];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: kDarkAccent.withOpacity(0.1),
      child: ExpansionTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              data.getFormattedTime(),
              style: const TextStyle(color: kDarkText, fontSize: 16),
            ),
            if (temp != null)
              Text(
                data.formatValue('temperature', temp),
                style: const TextStyle(
                  color: kDarkText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        subtitle: weatherCode != null
            ? Text(
                data.formatValue('weatherCode', weatherCode),
                style: const TextStyle(color: kDarkText, fontSize: 12),
              )
            : null,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(context, 'Temperature', 'temperature', temp),
                _buildDetailRow(
                  context,
                  'Apparent Temp',
                  'temperatureApparent',
                  data.values['temperatureApparent'],
                ),
                _buildDetailRow(context, 'Humidity', 'humidity', humidity),
                _buildDetailRow(context, 'Wind Speed', 'windSpeed', windSpeed),
                _buildDetailRow(
                  context,
                  'Wind Direction',
                  'windDirection',
                  data.values['windDirection'],
                ),
                _buildDetailRow(
                  context,
                  'Cloud Cover',
                  'cloudCover',
                  data.values['cloudCover'],
                ),
                _buildDetailRow(
                  context,
                  'Visibility',
                  'visibility',
                  data.values['visibility'],
                ),
                _buildDetailRow(
                  context,
                  'UV Index',
                  'uvIndex',
                  data.values['uvIndex'],
                ),
                if (data.values['sunriseTime'] != null)
                  _buildDetailRow(
                    context,
                    'Sunrise',
                    'sunriseTime',
                    data.values['sunriseTime'],
                  ),
                if (data.values['sunsetTime'] != null)
                  _buildDetailRow(
                    context,
                    'Sunset',
                    'sunsetTime',
                    data.values['sunsetTime'],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String key,
    dynamic value,
  ) {
    if (value == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: kDarkText, fontSize: 14)),
          Text(
            data.formatValue(key, value),
            style: const TextStyle(
              color: kDarkText,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
