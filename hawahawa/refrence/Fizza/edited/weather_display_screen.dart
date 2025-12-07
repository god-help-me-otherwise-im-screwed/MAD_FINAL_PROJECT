import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hawahawa/constants/colors.dart';
import 'package:hawahawa/models/weather_model.dart';
import 'package:hawahawa/models/settings_model.dart';
import 'package:hawahawa/providers/weather_provider.dart';
import 'package:hawahawa/providers/settings_provider.dart';
import 'package:hawahawa/widgets/safe_zone_container.dart';
import 'package:hawahawa/widgets/background_engine.dart';
import 'package:hawahawa/screens/settings_screen.dart';
import 'package:hawahawa/screens/customizer_screen.dart';
import 'package:hawahawa/screens/help_screen.dart';
import 'package:hawahawa/screens/pullup_forecast_menu.dart';
import 'package:hawahawa/services/notification_service.dart';

class WeatherDisplayScreen extends ConsumerStatefulWidget {
  const WeatherDisplayScreen({super.key});

  @override
  ConsumerState<WeatherDisplayScreen> createState() =>
      _WeatherDisplayScreenState();
}

class _WeatherDisplayScreenState extends ConsumerState<WeatherDisplayScreen> {
  late PageController _pageController;
  bool _hideUI = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hideUI = prefs.getBool('hide_ui') ?? false;
    });

    // Load notification preference
    final notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
    NotificationService.init(notificationsEnabled);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weatherReport = ref.watch(weatherProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeZoneContainer(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: GestureDetector(
            // Double tap to toggle hide UI
            onDoubleTap: () async {
              setState(() {
                _hideUI = !_hideUI;
              });
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('hide_ui', _hideUI);

              // Show a brief message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _hideUI ? 'UI Hidden (Double tap to show)' : 'UI Visible',
                    style: const TextStyle(fontFamily: 'BoldPixels'),
                  ),
                  duration: const Duration(seconds: 2),
                  backgroundColor: kDarkAccent,
                ),
              );
            },
            child: Stack(
              children: [
                const BackgroundEngine(),

                if (weatherReport != null) ...[
                  Positioned.fill(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _buildWeatherDisplay(weatherReport, settings),
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

                // Only show pull-up menu if UI is not hidden
                if (!_hideUI) const PullUpForecastMenu(),

                // Only show control buttons if UI is not hidden
                if (!_hideUI)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Row(
                      children: [
                        _buildIconButton(
                          Icons.settings,
                              () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (c) => const SettingsScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildIconButton(
                          Icons.palette,
                              () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (c) => const CustomizerScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildIconButton(
                          Icons.help_outline,
                              () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (c) => const HelpScreen()),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Show a small hint if UI is hidden
                if (_hideUI)
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: kDarkPrimary.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: kDarkAccent.withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          'Double tap to show controls',
                          style: TextStyle(
                            color: kDarkText.withOpacity(0.7),
                            fontSize: 12,
                            fontFamily: 'BoldPixels',
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherDisplay(WeatherReport report, AppSettings settings) {
    final current = report.current;
    if (current == null) {
      return const Text('No weather data', style: TextStyle(color: kDarkText));
    }

    final tempValue = current.values['temperature'];
    final condition = current.values['weatherCode'];
    final humidity = current.values['humidity'];
    final windSpeed = current.values['windSpeed'];
    final pressure = current.values['pressure'];

    String displayTemp = 'N/A';
    if (tempValue is num) {
      displayTemp = _formatTemperature(
        tempValue.toDouble(),
        settings.tempUnit,
      );
    }

    String displayPressure = 'N/A';
    if (pressure is num) {
      displayPressure = _formatPressure(
        pressure.toDouble(),
        settings.pressureUnit,
      );
    }

    // Show weather update notification when data loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final tempStr = tempValue is num ? '${tempValue.round()}°' : 'N/A';
        final conditionStr = current.formatValue('weatherCode', condition);
        final location = report.locationName ?? 'Current Location';
        NotificationService.showWeatherUpdate(
          context,
          location,
          tempStr,
          conditionStr,
        );
      }
    });

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            displayTemp,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: kDarkText,
              fontSize: 96,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            current.formatValue('weatherCode', condition),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: kDarkText.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 32),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildInfoCard(
                'Humidity',
                '${humidity is num ? humidity.toStringAsFixed(0) : humidity}%',
              ),
              const SizedBox(width: 24),
              _buildInfoCard(
                'Wind',
                '${windSpeed is num ? windSpeed.toStringAsFixed(1) : windSpeed} m/s',
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (pressure != null) _buildInfoCard('Pressure', displayPressure),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: kDarkText.withOpacity(0.6)),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: kDarkText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: kGlassDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kDarkAccent.withOpacity(0.3)),
      ),
      child: IconButton(
        icon: Icon(icon, color: kDarkText),
        onPressed: onPressed,
        iconSize: 24,
      ),
    );
  }

  // Unit conversion helper methods
  double _celsiusToFahrenheit(double celsius) {
    return (celsius * 9 / 5) + 32;
  }

  String _formatTemperature(double tempInCelsius, int unit) {
    if (unit == 1) {
      double fahrenheit = _celsiusToFahrenheit(tempInCelsius);
      return '${fahrenheit.round()}°F';
    } else {
      return '${tempInCelsius.round()}°C';
    }
  }

  double _convertPressure(double mbar, int targetUnit) {
    switch (targetUnit) {
      case 0:
        return mbar;
      case 1:
        return mbar;
      case 2:
        return mbar * 0.02953;
      case 3:
        return mbar * 0.75006;
      default:
        return mbar;
    }
  }

  String _formatPressure(double pressureInMbar, int unit) {
    double converted = _convertPressure(pressureInMbar, unit);
    String unitString = '';

    switch (unit) {
      case 0:
        unitString = 'mbar';
        break;
      case 1:
        unitString = 'hPa';
        break;
      case 2:
        unitString = 'inHg';
        break;
      case 3:
        unitString = 'mmHg';
        break;
    }

    if (unit == 0 || unit == 1) {
      return '${converted.toStringAsFixed(0)} $unitString';
    } else {
      return '${converted.toStringAsFixed(2)} $unitString';
    }
  }
}