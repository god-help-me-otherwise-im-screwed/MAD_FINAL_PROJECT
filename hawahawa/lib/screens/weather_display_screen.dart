import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:hawahawa/constants/colors.dart';
import 'package:hawahawa/models/weather_model.dart';
import 'package:hawahawa/models/settings_model.dart';
import 'package:hawahawa/providers/weather_provider.dart';
import 'package:hawahawa/providers/settings_provider.dart';
import 'package:hawahawa/providers/location_provider.dart';
import 'package:hawahawa/widgets/safe_zone_container.dart';
import 'package:hawahawa/widgets/background_engine.dart';
import 'package:hawahawa/screens/settings_screen.dart';
import 'package:hawahawa/screens/customizer_screen.dart';
import 'package:hawahawa/screens/help_screen.dart';
import 'package:hawahawa/screens/pullup_forecast_menu.dart';

class WeatherDisplayScreen extends ConsumerStatefulWidget {
  const WeatherDisplayScreen({super.key});

  @override
  ConsumerState<WeatherDisplayScreen> createState() =>
      _WeatherDisplayScreenState();
}

class _WeatherDisplayScreenState extends ConsumerState<WeatherDisplayScreen> {
  late Timer _timer;
  late Timer _minuteTimer;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    // Update UI every second (for live clock)
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {});
    });

    // Fetch weather every minute
    _minuteTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _refreshWeather();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _minuteTimer.cancel();
    super.dispose();
  }

  Future<void> _refreshWeather() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);

    try {
      final currentWeather = ref.read(weatherProvider);
      if (currentWeather?.locationName != null) {
        await Future.delayed(const Duration(milliseconds: 500));
        // Get the saved location from provider
        var savedLocation = ref.read(locationProvider);

        // If location not in provider, try to load from storage
        if (savedLocation == null) {
          savedLocation = await ref
              .read(locationProvider.notifier)
              .loadSavedLocation();
        }

        if (savedLocation != null) {
          // Use saved location with correct coordinates
          final notifier = ref.read(weatherProvider.notifier);
          await notifier.fetchWeather(savedLocation);
        } else {
          print('Error: No saved location found for refresh');
        }
      }
    } catch (e) {
      print('Error refreshing weather: $e');
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  void _navigateTo(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (c) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final weatherReport = ref.watch(weatherProvider);
    final isFresh = ref.watch(weatherIsFreshProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeZoneContainer(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // Background + pixel art live scene (always visible)
              const BackgroundEngine(),

              // Control buttons at top right
              Positioned(
                top: 12,
                right: 12,
                child: Row(
                  children: [
                    _buildIconButton(
                      _isRefreshing ? Icons.hourglass_bottom : Icons.refresh,
                      () => _refreshWeather(),
                      enabled: !_isRefreshing,
                    ),
                    const SizedBox(width: 8),
                    _buildIconButton(
                      Icons.settings,
                      () => _navigateTo(const SettingsScreen()),
                    ),
                    const SizedBox(width: 8),
                    _buildIconButton(
                      Icons.palette,
                      () => _navigateTo(const CustomizerScreen()),
                    ),
                    const SizedBox(width: 8),
                    _buildIconButton(
                      Icons.help_outline,
                      () => _navigateTo(const HelpScreen()),
                    ),
                  ],
                ),
              ),

              // Weather data display with location header and controls
              if (weatherReport != null) ...[
                // Main weather display - centered big temp
                Positioned.fill(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildMainDisplay(weatherReport, settings),
                    ),
                  ),
                ),
              ] else
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: kDarkAccent),
                      const SizedBox(height: 16),
                      Text(
                        'Loading weather data...',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: kDarkText),
                      ),
                    ],
                  ),
                ),

              // Stale data indicator
              isFresh.when(
                data: (fresh) {
                  if (!fresh && weatherReport != null) {
                    return Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade300),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.cloud_off,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'No Connection • Data Cached',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
                loading: () => const SizedBox.shrink(),
                error: (err, st) => const SizedBox.shrink(),
              ),

              // Pull-up forecast menu overlay
              const PullUpForecastMenu(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainDisplay(WeatherReport report, AppSettings settings) {
    final current = report.current;
    if (current == null) {
      return const Text('No weather data', style: TextStyle(color: kDarkText));
    }

    final temp = current.values['temperature'] ?? 'N/A';
    final condition = current.values['weatherCode'];
    final humidity = current.values['humidity'];
    final windSpeed = current.values['windSpeed'];
    final visibility = current.values['visibility'];
    final uvIndex = current.values['uvIndex'];

    // Format time with timezone awareness
    final is24h = settings.timeFormat == 0;
    final timeString = current.getFormattedTime(
      timezoneOffset: report.timezoneOffset,
      is24HourFormat: is24h,
    );

    // Format date
    final dateString = DateFormat('EEEE, MMM d').format(
      DateTime.now().add(Duration(hours: report.timezoneOffset.toInt())),
    );

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Location name
          Text(
            _getShortLocationName(report.locationName),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: kDarkText.withOpacity(0.9),
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),

          // Live time
          Text(
            timeString,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: kDarkText.withOpacity(0.8),
              fontSize: 18,
            ),
          ),

          // Date
          Text(
            dateString,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: kDarkText.withOpacity(0.7),
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 40),

          // Glassmorphism main weather card
          _buildGlassCard(
            child: Column(
              children: [
                // Large temperature
                Text(
                  '${temp is num ? temp.toStringAsFixed(0) : temp}°',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: kDarkText,
                    fontSize: 120,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Weather condition
                Text(
                  current.formatValue('weatherCode', condition),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: kDarkText.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 50), // Increased vertical spacing
          // Info card grid (4 columns) - NOW WITHOUT GLASS CARD
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
            ), // Added horizontal padding for spacing
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoMetric(
                      'Humidity',
                      '${humidity is num ? humidity.toStringAsFixed(0) : humidity}%',
                    ),
                    _buildInfoMetric(
                      'Wind Speed',
                      '${windSpeed is num ? windSpeed.toStringAsFixed(1) : windSpeed} m/s',
                    ),
                  ],
                ),
                const SizedBox(height: 30), // Increased vertical spacing
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoMetric(
                      'Visibility',
                      '${visibility is num ? (visibility / 1000).toStringAsFixed(1) : visibility} km',
                    ),
                    _buildInfoMetric(
                      'UV Index',
                      '${uvIndex is num ? uvIndex.toStringAsFixed(1) : uvIndex}',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Added padding at the bottom to ensure the last glass card is not partially covered
          const SizedBox(height: 150),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: kGlassDark.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 1.0,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildInfoMetric(String label, String value) {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Label (e.g., Humidity, Wind Speed) - Increased size/prominence
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: kDarkText.withOpacity(
                0.9,
              ), // Slightly darker for better contrast
              fontSize: 16, // Increased size
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 6,
          ), // Increased spacing between label and value
          // Value (e.g., 81%, 2.0 m/s) - Increased size/prominence
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: kDarkText,
              fontWeight: FontWeight.w900,
              fontSize: 24, // Increased size
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  String _getShortLocationName(String? fullName) {
    if (fullName == null || fullName.isEmpty) return 'Unknown';

    // Try to extract just the city name (first part before comma)
    final parts = fullName.split(',');
    String shortName = parts[0].trim();

    // If it's too long, just show first part or truncate
    if (shortName.length > 15) {
      final words = shortName.split(' ');
      shortName = words[0];
    }

    return shortName;
  }

  Widget _buildIconButton(
    IconData icon,
    VoidCallback onPressed, {
    bool enabled = true,
  }) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: kGlassDark.withOpacity(0.6),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: enabled
                ? kDarkAccent.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
          ),
        ),
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Icon(
              icon,
              color: enabled ? kDarkText : Colors.grey,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
