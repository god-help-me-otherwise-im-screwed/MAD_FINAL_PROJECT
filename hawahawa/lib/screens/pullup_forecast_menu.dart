import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hawahawa/constants/colors.dart';
import 'package:hawahawa/providers/weather_provider.dart';
import 'package:hawahawa/providers/settings_provider.dart';
import 'package:hawahawa/constants/weather_codes.dart';

class PullUpForecastMenu extends ConsumerWidget {
  const PullUpForecastMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weather = ref.watch(weatherProvider);
    final settings = ref.watch(settingsProvider);

    return DraggableScrollableSheet(
      // Collapse down to a very small top indicator so only the handle
      // is visible initially. Users can drag up to expand the forecast.
      initialChildSize: 0.04,
      minChildSize: 0.04,
      maxChildSize: 0.6,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: kGlassDark,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(color: kDarkAccent.withOpacity(0.3)),
          ),
          child: weather == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 6,
                        decoration: BoxDecoration(
                          color: kDarkText.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'FORECAST',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: kDarkText,
                            fontSize: 18,
                            letterSpacing: 2,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Hourly',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: kDarkText.withOpacity(0.7),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: weather.hourly.length.clamp(0, 12),
                        itemBuilder: (context, index) {
                          final hour = weather.hourly[index];
                          final temp = settings.tempUnit == 0
                              ? hour.temp
                              : (hour.temp * 9 / 5) + 32;
                          final unit = settings.tempUnit == 0 ? '°C' : '°F';
                          final time = settings.timeFormat == 0
                              ? '${hour.timestamp.hour}:00'
                              : _format12Hour(hour.timestamp.hour);

                          return Container(
                            width: 70,
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: kGlassLight.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: kDarkAccent.withOpacity(0.2),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  time,
                                  style: const TextStyle(
                                    color: kDarkText,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${temp.toStringAsFixed(0)}$unit',
                                  style: const TextStyle(
                                    color: kDarkText,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  WeatherCodeMapper.getDescription(
                                    hour.conditionCode,
                                  ).split(' ').first,
                                  style: TextStyle(
                                    color: kDarkText.withOpacity(0.6),
                                    fontSize: 10,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Daily',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: kDarkText.withOpacity(0.7),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...weather.daily.map((day) {
                      final temp = settings.tempUnit == 0
                          ? day.temp
                          : (day.temp * 9 / 5) + 32;
                      final unit = settings.tempUnit == 0 ? '°C' : '°F';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: kGlassLight.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: kDarkAccent.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDate(day.timestamp),
                              style: const TextStyle(color: kDarkText),
                            ),
                            Text(
                              WeatherCodeMapper.getDescription(
                                day.conditionCode,
                              ),
                              style: TextStyle(
                                color: kDarkText.withOpacity(0.7),
                              ),
                            ),
                            Text(
                              '${temp.toStringAsFixed(0)}$unit',
                              style: const TextStyle(
                                color: kDarkText,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
        );
      },
    );
  }

  String _format12Hour(int hour) {
    if (hour == 0) return '12 AM';
    if (hour < 12) return '$hour AM';
    if (hour == 12) return '12 PM';
    return '${hour - 12} PM';
  }

  String _formatDate(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[(date.weekday - 1) % 7]} ${date.day}';
  }
}
