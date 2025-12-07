import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hawahawa/constants/colors.dart';
import 'package:hawahawa/providers/location_provider.dart';
import 'package:hawahawa/providers/weather_provider.dart';
import 'package:hawahawa/models/location_model.dart';
import 'package:hawahawa/screens/weather_display_screen.dart';

class MapPickerScreen extends ConsumerWidget {
  const MapPickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: kDarkPrimary,
      appBar: AppBar(
        title: const Text('Select on Map'),
        backgroundColor: kDarkPrimary,
      ),
      body: Stack(
        children: [
          Container(
            color: kDarkPrimary.withOpacity(0.5),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 64, color: kDarkText.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text(
                    'MAP PICKER',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: kDarkText.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'flutter_map integration goes here',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: kDarkText.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: ElevatedButton(
              onPressed: () async {
                const demoLocation = LocationResult(
                  name: 'Selected Location',
                  coords: AppLatLng(31.5204, 74.3587),
                );
                ref.read(locationProvider.notifier).setLocation(demoLocation);
                await ref.read(weatherProvider.notifier).fetchWeather(demoLocation.coords);
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (c) => const WeatherDisplayScreen()),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kDarkAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('CONFIRM LOCATION'),
            ),
          ),
        ],
      ),
    );
  }
}