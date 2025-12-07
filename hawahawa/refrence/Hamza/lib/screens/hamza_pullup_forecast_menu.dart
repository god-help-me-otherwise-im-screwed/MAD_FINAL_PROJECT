import 'dart:ui' as ui;
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
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    kDarkPrimary.withOpacity(0.7),
                    kDarkSecondary.withOpacity(0.6),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                border: Border.all(
                  color: kDarkAccent.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: kDarkAccent.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
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
                              color: kDarkAccent.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(3),
                              boxShadow: [
                                BoxShadow(
                                  color: kDarkAccent.withOpacity(0.3),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'FORECAST',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: kDarkText,
                            fontSize: 18,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Hourly',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: kDarkText.withValues(alpha: 0.7),
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
                          final temp = hour.values['temperature'] as num?;
                          final tempFormatted = settings.tempUnit == 0
                              ? temp
                              : (temp != null ? (temp * 9 / 5) + 32 : 0);
                          final unit = settings.tempUnit == 0 ? '°C' : '°F';
                          final timeStr = hour.getFormattedTime();

                          return Container(
                            width: 70,
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: kGlassLight.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: kDarkAccent.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  timeStr,
                                  style: const TextStyle(
                                    color: kDarkText,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${tempFormatted?.toStringAsFixed(0) ?? 'N/A'}$unit',
                                  style: const TextStyle(
                                    color: kDarkText,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  WeatherCodeMapper.getDescription(
                                    hour.values['weatherCode'],
                                  ).split(' ').first,
                                  style: TextStyle(
                                    color: kDarkText.withValues(alpha: 0.6),
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
                        color: kDarkText.withValues(alpha: 0.7),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...weather.daily.map((day) {
                      final temp = day.values['temperature'] as num?;
                      final tempFormatted = settings.tempUnit == 0
                          ? temp
                          : (temp != null ? (temp * 9 / 5) + 32 : 0);
                      final unit = settings.tempUnit == 0 ? '°C' : '°F';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: kGlassLight.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: kDarkAccent.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              day.getFormattedTime(),
                              style: const TextStyle(color: kDarkText),
                            ),
                            Text(
                              WeatherCodeMapper.getDescription(
                                day.values['weatherCode'],
                              ),
                              style: TextStyle(
                                color: kDarkText.withValues(alpha: 0.7),
                              ),
                            ),
                            Text(
                              '${tempFormatted?.toStringAsFixed(0) ?? 'N/A'}$unit',
                              style: const TextStyle(
                                color: kDarkText,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
            ),
          ),
        );
      },
    );
  }
}
