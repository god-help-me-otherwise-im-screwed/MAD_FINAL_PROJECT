import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hawahawa/providers/settings_provider.dart';
import 'package:hawahawa/providers/customizer_provider.dart';
import 'package:hawahawa/providers/weather_provider.dart';

class BackgroundEngine extends ConsumerWidget {
  const BackgroundEngine({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final customPreset = ref.watch(customizerProvider);
    final weather = ref.watch(weatherProvider);

    switch (settings.backgroundMode) {
      case 0:
        return RealtimeWeatherBackground(weather: weather);
      case 1:
        return CustomGradientBackground(preset: customPreset);
      case 2:
        return StaticLocationBackground(preset: customPreset);
      default:
        return CustomGradientBackground(preset: customPreset);
    }
  }
}

class RealtimeWeatherBackground extends StatelessWidget {
  final dynamic weather;
  const RealtimeWeatherBackground({super.key, this.weather});

  @override
  Widget build(BuildContext context) {
    // Layered background: a linear sky gradient, a subtle radial vignette,
    // and the pixel-art effects painted on top. This container is intended
    // to be placed inside the `SafeZoneContainer` so it preserves aspect.
    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Core sky gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.6, 1.0],
                colors: [
                  Color(0xFF0B1020), // deep twilight top
                  Color(0xFF2B1A44), // mid-sky
                  Color(0xFF071028), // near-horizon
                ],
              ),
            ),
          ),

          // Soft radial vignette to add depth near edges
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.0, -0.2),
                radius: 1.0,
                colors: [Colors.transparent, Colors.black.withOpacity(0.25)],
                stops: const [0.7, 1.0],
              ),
            ),
          ),

          // Pixel-art weather effects painted above the gradients
          CustomPaint(
            painter: WeatherEffectsPainter(weather: weather),
            child: Container(),
          ),
        ],
      ),
    );
  }
}

class CustomGradientBackground extends StatelessWidget {
  final dynamic preset;
  const CustomGradientBackground({super.key, required this.preset});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [preset.skyGradientTop, preset.skyGradientBottom],
        ),
      ),
    );
  }
}

class StaticLocationBackground extends StatelessWidget {
  final dynamic preset;
  const StaticLocationBackground({super.key, required this.preset});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [preset.skyGradientTop, preset.skyGradientBottom],
        ),
      ),
    );
  }
}

class WeatherEffectsPainter extends CustomPainter {
  final dynamic weather;
  WeatherEffectsPainter({this.weather});

  @override
  void paint(Canvas canvas, Size size) {
    // Dots removed: intentionally do not paint floating particles here.
    // Previously this painted many small white dots; per request we leave
    // the canvas clean so the pixel art scene isn't cluttered.
    return;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
