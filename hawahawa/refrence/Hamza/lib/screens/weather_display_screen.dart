import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hawahawa/constants/colors.dart';
import 'package:hawahawa/models/weather_model.dart';
import 'package:hawahawa/providers/weather_provider.dart';
import 'package:hawahawa/widgets/safe_zone_container.dart';
import 'package:hawahawa/widgets/background_engine.dart';
import 'package:hawahawa/screens/settings_screen.dart';
import 'package:hawahawa/screens/customizer_screen.dart';
import 'package:hawahawa/screens/help_screen.dart';
import 'package:hawahawa/screens/pullup_forecast_menu.dart';
import 'package:hawahawa/screens/profile_screen.dart';
import 'package:hawahawa/screens/user_search_screen.dart';
import 'package:hawahawa/services/firebase_social_service.dart';

class WeatherDisplayScreen extends ConsumerStatefulWidget {
  const WeatherDisplayScreen({super.key});

  @override
  ConsumerState<WeatherDisplayScreen> createState() =>
      _WeatherDisplayScreenState();
}

class _WeatherDisplayScreenState extends ConsumerState<WeatherDisplayScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weatherReport = ref.watch(weatherProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeZoneContainer(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // Background + pixel art live scene (always visible)
              const BackgroundEngine(),

              // Weather data display with location header and controls
              if (weatherReport != null) ...[
                // Main weather display - centered big temp
                Positioned.fill(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildWeatherDisplay(weatherReport),
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

              // Pull-up forecast menu overlay
              const PullUpForecastMenu(),

              // Control buttons (top right - always visible)
              Positioned(
                top: 12,
                right: 12,
                child: Row(
                  children: [
                    _buildIconButton(
                      Icons.search,
                      () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (c) => const UserSearchScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildProfileIconButton(),
                    const SizedBox(width: 8),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherDisplay(WeatherReport report) {
    final current = report.current;
    if (current == null) {
      return const Text('No weather data', style: TextStyle(color: kDarkText));
    }

    final temp = current.values['temperature'] ?? 'N/A';
    final condition = current.values['weatherCode'];
    final humidity = current.values['humidity'];
    final windSpeed = current.values['windSpeed'];

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Large temperature
          Text(
            '${temp is num ? temp.toStringAsFixed(0) : temp}°',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: kDarkText,
              fontSize: 96,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Weather condition
          Text(
            current.formatValue('weatherCode', condition),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: kDarkText.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 32),

          // Additional info row
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

  Widget _buildProfileIconButton() {
    final socialService = ref.watch(firebaseSocialServiceProvider);
    
    return StreamBuilder<int>(
      stream: socialService.getPendingRequestsCount(),
      builder: (context, snapshot) {
        final pendingCount = snapshot.data ?? 0;
        
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                color: kGlassDark,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kDarkAccent.withOpacity(0.3)),
              ),
              child: IconButton(
                icon: const Icon(Icons.person, color: kDarkText),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (c) => const ProfileScreen(),
                  ),
                ),
                iconSize: 24,
              ),
            ),
            if (pendingCount > 0)
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: kDarkPrimary, width: 2),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Center(
                    child: Text(
                      pendingCount > 9 ? '9+' : '$pendingCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
