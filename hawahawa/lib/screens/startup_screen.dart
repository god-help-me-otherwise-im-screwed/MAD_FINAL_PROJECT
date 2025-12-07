import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hawahawa/constants/colors.dart';
import 'package:hawahawa/models/location_model.dart'; // Make sure this path is correct for your LocationResult model
import 'package:hawahawa/providers/location_provider.dart';
import 'package:hawahawa/providers/weather_provider.dart';
import 'package:hawahawa/screens/weather_display_screen.dart';
import 'package:hawahawa/screens/map_picker_screen.dart';
import 'package:hawahawa/screens/search_location_screen.dart';
import 'package:hawahawa/screens/login_screen.dart';

class StartupScreen extends ConsumerStatefulWidget {
  const StartupScreen({super.key});

  @override
  ConsumerState<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends ConsumerState<StartupScreen> {
  // 1. STATE TRACKING
  bool _isGpsLoading = false;
  LocationResult? _detectedLocation;

  // Function to handle GPS button press
  Future<void> _handleGpsLocation() async {
    setState(() {
      _isGpsLoading = true;
      _detectedLocation = null;
    });

    // Request GPS location and wait for the result
    final LocationResult? location =
        await ref.read(locationProvider.notifier).requestGpsLocation();

    if (mounted) {
      setState(() {
        _isGpsLoading = false;
        _detectedLocation = location;
      });
    }
  }

  // Function to handle proceeding to weather screen
  Future<void> _proceedToWeather(LocationResult location) async {
    if (!mounted) return;

    // Save the location to the provider (important for persistence)
    ref.read(locationProvider.notifier).setLocation(location);

    // Fetch weather using the confirmed location
    await ref.read(weatherProvider.notifier).fetchWeather(location);

    if (!mounted) return;

    // Navigate away
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (c) => const WeatherDisplayScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 3),
              Text(
                'Hawa Hawa',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: kDarkText,
                      fontSize: 75,
                      letterSpacing: 3,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Choose Your Location',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: kDarkText.withOpacity(0.7),
                      fontSize: 25,
                    ),
              ),
              const Spacer(flex: 5),

              // 2. LOCATION STATUS DISPLAY (No explicit loading spinner here)
              if (_detectedLocation != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    children: [
                      Text(
                        'Detected Location:',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: kDarkText.withOpacity(0.8),
                              fontWeight: FontWeight.normal,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _detectedLocation!
                            .displayName, // Display the full displayName
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: kDarkText,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              // CONDITIONAL PROCEED BUTTON is shown *only* when a location is detected
              if (_detectedLocation != null)
                _buildButton(
                  context,
                  icon: Icons.cloud,
                  label: 'PROCEED TO WEATHER',
                  onPressed: () => _proceedToWeather(_detectedLocation!),
                ),

              // GPS Button is shown *only* when no location is detected
              if (_detectedLocation == null)
                _buildButton(
                  context,
                  icon: Icons.my_location,
                  // Text changes to show loading state
                  label: _isGpsLoading ? 'LOADING GPS...' : 'USE GPS LOCATION',
                  // Button is disabled while loading
                  onPressed: _isGpsLoading ? () {} : _handleGpsLocation,
                ),

              const SizedBox(height: 20),

              // Other location methods
              _buildButton(
                context,
                icon: Icons.map,
                label: 'SELECT ON MAP',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (c) => const MapPickerScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildButton(
                context,
                icon: Icons.search,
                label: 'SEARCH BY NAME',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (c) => const SearchLocationScreen()),
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
        elevation: secondary ? 0 : 8,
        shadowColor: kDarkAccent.withOpacity(0.5),
        padding: const EdgeInsets.symmetric(vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: secondary
                ? kDarkAccent.withOpacity(0.5)
                : Colors.transparent,
            width: 2,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}