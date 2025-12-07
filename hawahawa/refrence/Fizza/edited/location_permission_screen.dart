import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hawahawa/providers/location_provider.dart';
import 'package:hawahawa/providers/theme_provider.dart';
import 'package:hawahawa/constants/colors.dart';
import 'package:hawahawa/screens/notification_permission_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationPermissionScreen extends ConsumerStatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  ConsumerState<LocationPermissionScreen> createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState
    extends ConsumerState<LocationPermissionScreen> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isLightTheme = ref.watch(themeProvider);
    final bgColor = isLightTheme ? kLightPrimary : kDarkPrimary;
    final textColor = isLightTheme ? kLightText : kDarkText;
    final accentColor = isLightTheme ? kLightAccent : kDarkAccent;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on,
                size: 100,
                color: accentColor,
              ),
              const SizedBox(height: 40),
              Text(
                'ENABLE LOCATION',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: textColor,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'We need your location to show you accurate local weather forecasts',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: textColor.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : requestLocationPermission,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: textColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isLoading
                      ? CircularProgressIndicator(color: textColor)
                      : Text(
                    'ALLOW LOCATION',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: textColor,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: isLoading ? null : skipLocation,
                child: Text(
                  'SKIP FOR NOW',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: textColor.withOpacity(0.7),
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void requestLocationPermission() async {
    setState(() {
      isLoading = true;
    });

    try {
      await ref.read(locationProvider.notifier).requestGpsLocation();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('location_permission_requested', true);

      final location = ref.read(locationProvider);

      if (mounted) {
        final isLightTheme = ref.read(themeProvider);
        final accentColor = isLightTheme ? kLightAccent : kDarkAccent;

        if (location != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Location access granted!',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              backgroundColor: accentColor,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Could not get location',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              backgroundColor: accentColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final isLightTheme = ref.read(themeProvider);
        final accentColor = isLightTheme ? kLightAccent : kDarkAccent;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString()}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            backgroundColor: accentColor,
          ),
        );
      }
    }

    setState(() {
      isLoading = false;
    });

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const NotificationPermissionScreen(),
        ),
      );
    }
  }

  void skipLocation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('location_permission_requested', true);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const NotificationPermissionScreen(),
        ),
      );
    }
  }
}