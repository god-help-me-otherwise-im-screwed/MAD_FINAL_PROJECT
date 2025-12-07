import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hawahawa/constants/colors.dart';
import 'package:hawahawa/providers/location_provider.dart';
import 'package:hawahawa/providers/weather_provider.dart';
import 'package:hawahawa/screens/weather_display_screen.dart';
import 'package:hawahawa/screens/map_picker_screen.dart';
import 'package:hawahawa/screens/search_location_screen.dart';
import 'package:hawahawa/screens/login_screen.dart';

class StartupScreen extends ConsumerWidget {
  const StartupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: kDarkPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              Text(
                'PIXEL WEATHER',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: kDarkText,
                  fontSize: 32,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose Your Location',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: kDarkText.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const Spacer(flex: 3),
              _buildButton(
                context,
                icon: Icons.my_location,
                label: 'USE GPS LOCATION',
                onPressed: () async {
                  await ref.read(locationProvider.notifier).requestGpsLocation();
                  final location = ref.read(locationProvider);
                  if (location != null && context.mounted) {
                    await ref.read(weatherProvider.notifier).fetchWeather(location.coords);
                    if (context.mounted) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (c) => const WeatherDisplayScreen()),
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 16),
              _buildButton(
                context,
                icon: Icons.map,
                label: 'SELECT ON MAP',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (c) => const MapPickerScreen()),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildButton(
                context,
                icon: Icons.search,
                label: 'SEARCH BY NAME',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (c) => const SearchLocationScreen()),
                  );
                },
              ),
              const Spacer(flex: 2),
              _buildButton(
                context,
                icon: Icons.person,
                label: 'LOGIN / USER INFO',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (c) => const LoginScreen()),
                  );
                },
                secondary: true,
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool secondary = false,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: secondary ? kDarkPrimary : kDarkAccent,
        foregroundColor: kDarkText,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: secondary ? kDarkAccent : Colors.transparent,
            width: 2,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}