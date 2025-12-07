import 'dart:ui'; // Needed for BackdropFilter
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Assuming these imports correctly point to your project files:
import 'package:hawahawa/constants/colors.dart';
import 'package:hawahawa/providers/weather_provider.dart';
import 'package:hawahawa/providers/settings_provider.dart';
import 'package:hawahawa/constants/weather_codes.dart';

class PullUpForecastMenu extends ConsumerWidget {
  const PullUpForecastMenu({super.key});

  // Helper method for temperature conversion and formatting
  String _formatTemp(num? temp, int tempUnit) {
    if (temp == null) return 'N/A';
    // Settings: 0=Celsius, 1=Fahrenheit
    num formattedTemp = tempUnit == 0 ? temp : (temp * 9 / 5) + 32;
    final unit = tempUnit == 0 ? '°C' : '°F';
    return '${formattedTemp.toStringAsFixed(0)}$unit';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weather = ref.watch(weatherProvider);
    final settings = ref.watch(settingsProvider);

    // Define a local helper function for the header with improved styling
    Widget buildHeader(String title) {
      return Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: kDarkText.withOpacity(0.9),
              fontWeight: FontWeight.normal, 
              letterSpacing: 2.0,
              fontSize: 16,
            ),
      );
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.025, // Updated to 0.025
      minChildSize: 0.025,    // Updated to 0.025
      maxChildSize: 0.75,
      snap: true,
      snapSizes: const [0.025, 0.5, 0.75], // Updated smallest snap size to 0.025
      builder: (context, scrollController) {
        if (weather == null) {
          return Container(
            decoration: BoxDecoration(
              color: kGlassDark.withOpacity(0.9),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: kGlassDark.withOpacity(0.9),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                border: Border.all(color: kDarkAccent.withOpacity(0.4)),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8), 
                children: [
                  // --- Custom Handle ---
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 15), 
                      decoration: BoxDecoration(
                        color: kDarkText.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                  
                  // --- Hourly Forecast Section Header ---
                  buildHeader('HOURLY TREND'),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 130,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: weather.hourly?.length.clamp(0, 12) ?? 0,
                      itemBuilder: (context, index) {
                        final hour = weather.hourly![index];
                        final temp = hour.values['temperature'] as num?;
                        final is24HourFormat = settings.timeFormat == 0;
                        
                        final timeStr = hour.getFormattedTime(
                          timezoneOffset: weather.timezoneOffset,
                          is24HourFormat: is24HourFormat,
                        );
                        
                        final iconData = WeatherCodeMapper.getIcon(hour.values['weatherCode']);
                        
                        return Container(
                          width: 90,
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: kDarkAccent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(15), 
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                timeStr,
                                style: TextStyle(
                                  color: kDarkText.withOpacity(0.7),
                                  fontSize: 14,
                                  letterSpacing: 0.5, 
                                ),
                              ),
                              Icon(
                                iconData,
                                color: kDarkAccent.withOpacity(0.9),
                                size: 32,
                              ),
                              Text(
                                _formatTemp(temp, settings.tempUnit),
                                style: TextStyle(
                                  color: kDarkText,
                                  fontSize: 22, 
                                  fontWeight: FontWeight.normal, 
                                  letterSpacing: 0.5, 
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 30),
                  const Divider(color: kDarkAccent, thickness: 0.5),
                  const SizedBox(height: 20),

                  // --- Daily Forecast Section Header ---
                  buildHeader('DAILY OUTLOOK'),
                  const SizedBox(height: 15),
                  
                  ...weather.daily?.map((day) {
                    final temp = day.values['temperature'] as num?;
                    final is24HourFormat = settings.timeFormat == 0;
                    
                    final dayName = day.getFormattedTime(
                      timezoneOffset: weather.timezoneOffset,
                      is24HourFormat: is24HourFormat,
                    );
                    final description = WeatherCodeMapper.getDescription(day.values['weatherCode']);
                    
                    final iconData = WeatherCodeMapper.getIcon(day.values['weatherCode']);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 1. Day Name (Left)
                          SizedBox(
                            width: 100,
                            child: Text(
                              dayName,
                              style: TextStyle(
                                color: kDarkText,
                                fontSize: 22, 
                                fontWeight: FontWeight.normal, 
                                letterSpacing: 0.5, 
                              ),
                            ),
                          ),

                          // 2. Weather Icon & Description (Center)
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  iconData,
                                  color: kDarkAccent.withOpacity(0.8),
                                  size: 24, 
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  description,
                                  style: TextStyle(
                                    color: kDarkText.withOpacity(0.8),
                                    fontSize: 20, 
                                    fontWeight: FontWeight.w300, 
                                    letterSpacing: 0.5, 
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 3. Temperature (Right, Prominent)
                          Text(
                            _formatTemp(temp, settings.tempUnit),
                            style: TextStyle(
                              color: kDarkText,
                              fontWeight: FontWeight.w300, 
                              fontSize: 25, 
                              letterSpacing: 0.5, 
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList() ?? [],
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}