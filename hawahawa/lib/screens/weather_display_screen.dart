import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hawahawa/constants/colors.dart';
import 'package:hawahawa/widgets/safe_zone_container.dart';
import 'package:hawahawa/widgets/background_engine.dart';
import 'package:hawahawa/widgets/weather_overlay.dart';
import 'package:hawahawa/screens/pullup_forecast_menu.dart';
import 'package:hawahawa/screens/settings_screen.dart';
import 'package:hawahawa/screens/customizer_screen.dart';
import 'package:hawahawa/screens/help_screen.dart';

class WeatherDisplayScreen extends ConsumerStatefulWidget {
  const WeatherDisplayScreen({super.key});

  @override
  ConsumerState<WeatherDisplayScreen> createState() =>
      _WeatherDisplayScreenState();
}

class _WeatherDisplayScreenState extends ConsumerState<WeatherDisplayScreen> {
  bool _showOverlay = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeZoneContainer(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // Background + pixel art live scene are now constrained by SafeZoneContainer
              const BackgroundEngine(),

              // Interactive area sits above the background (also constrained)
              GestureDetector(
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity! > 0) {
                    setState(() => _showOverlay = false);
                  } else if (details.primaryVelocity! < 0) {
                    setState(() => _showOverlay = true);
                  }
                },
                onTap: () {
                  if (!_showOverlay) {
                    setState(() => _showOverlay = true);
                  }
                },
                child: Stack(
                  children: [
                    AnimatedOpacity(
                      opacity: _showOverlay ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: const WeatherOverlay(),
                    ),
                    if (_showOverlay)
                      Positioned(
                        top: 16,
                        right: 16,
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
                                MaterialPageRoute(
                                  builder: (c) => const HelpScreen(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // The PullUpForecastMenu should appear visually to originate
              // from the bottom of the constrained scene. Keep it inside
              // the SafeZoneContainer so it aligns correctly.
              if (_showOverlay) const PullUpForecastMenu(),
            ],
          ),
        ),
      ),
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
}
