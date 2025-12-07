import 'package:flutter/material.dart';
import 'package:hawahawa/constants/colors.dart';

class WeatherOverlay extends StatelessWidget {
  const WeatherOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    // Use the app text theme (which uses the pixel font) and make the
    // overlay title more prominent for readability.
    final titleStyle = Theme.of(
      context,
    ).textTheme.headlineLarge?.copyWith(color: kDarkText, fontSize: 28);

    return Container(
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text('Weather Overlay', style: titleStyle),
    );
  }
}
