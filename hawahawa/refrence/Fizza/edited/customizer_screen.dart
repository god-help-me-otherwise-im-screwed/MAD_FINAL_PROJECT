import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hawahawa/constants/colors.dart';
import 'package:hawahawa/providers/customizer_provider.dart';
import 'package:hawahawa/providers/theme_provider.dart';
import 'package:hawahawa/widgets/scene_panel.dart';
import 'package:hawahawa/screens/online_presets_screen.dart';

class CustomizerScreen extends ConsumerWidget {
  const CustomizerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preset = ref.watch(customizerProvider);
    final isLightTheme = ref.watch(themeProvider);
    final bgColor = isLightTheme ? kLightPrimary : kDarkPrimary;
    final textColor = isLightTheme ? kLightText : kDarkText;
    final accentColor = isLightTheme ? kLightAccent : kDarkAccent;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('CUSTOMIZER', style: TextStyle(color: textColor)),
        backgroundColor: bgColor,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          IconButton(
            icon: Icon(Icons.restore, color: textColor),
            onPressed: () {
              ref.read(customizerProvider.notifier).resetToDefault();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Reset to default'),
                  backgroundColor: accentColor,
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ScenePanel(
            minWidth: 200,
            minHeight: 80,
            showBorder: true,
            borderWidth: 1,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cloud Density', style: TextStyle(color: textColor)),
                  Slider(
                    value: preset.cloudDensity,
                    onChanged: (v) => ref.read(customizerProvider.notifier).setCloudDensity(v),
                    activeColor: accentColor,
                    label: preset.cloudDensity.toStringAsFixed(2),
                  ),
                  Text(
                    'Value: ${preset.cloudDensity.toStringAsFixed(2)}',
                    style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ScenePanel(
            minWidth: 200,
            minHeight: 80,
            showBorder: true,
            borderWidth: 1,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rain Intensity', style: TextStyle(color: textColor)),
                  Slider(
                    value: preset.rainIntensity,
                    onChanged: (v) => ref.read(customizerProvider.notifier).setRainIntensity(v),
                    activeColor: accentColor,
                    label: preset.rainIntensity.toStringAsFixed(2),
                  ),
                  Text(
                    'Value: ${preset.rainIntensity.toStringAsFixed(2)}',
                    style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ScenePanel(
            minWidth: 200,
            minHeight: 80,
            showBorder: true,
            borderWidth: 1,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Wind Speed Override', style: TextStyle(color: textColor)),
                  Slider(
                    value: preset.windSpeedOverride,
                    min: 0,
                    max: 100,
                    onChanged: (v) => ref.read(customizerProvider.notifier).setWindSpeed(v),
                    activeColor: accentColor,
                    label: preset.windSpeedOverride.toStringAsFixed(0),
                  ),
                  Text(
                    'Value: ${preset.windSpeedOverride.toStringAsFixed(0)} km/h',
                    style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ScenePanel(
            minWidth: 200,
            minHeight: 80,
            showBorder: true,
            borderWidth: 1,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Particle Count', style: TextStyle(color: textColor)),
                  Slider(
                    value: preset.particleCount,
                    min: 0,
                    max: 200,
                    onChanged: (v) => ref.read(customizerProvider.notifier).setParticleCount(v),
                    activeColor: accentColor,
                    label: preset.particleCount.toStringAsFixed(0),
                  ),
                  Text(
                    'Value: ${preset.particleCount.toStringAsFixed(0)}',
                    style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ScenePanel(
            minWidth: 200,
            minHeight: 80,
            showBorder: true,
            borderWidth: 1,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Animation Speed', style: TextStyle(color: textColor)),
                  Slider(
                    value: preset.animationSpeed,
                    min: 0.1,
                    max: 3.0,
                    onChanged: (v) => ref.read(customizerProvider.notifier).setAnimationSpeed(v),
                    activeColor: accentColor,
                    label: preset.animationSpeed.toStringAsFixed(1),
                  ),
                  Text(
                    'Value: ${preset.animationSpeed.toStringAsFixed(1)}x',
                    style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(customizerProvider.notifier).savePreset();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Preset saved locally!'),
                  backgroundColor: accentColor,
                ),
              );
            },
            icon: Icon(Icons.save, color: textColor),
            label: Text('SAVE LOCAL PRESET', style: TextStyle(color: textColor)),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (c) => const OnlinePresetsScreen()),
              );
            },
            icon: Icon(Icons.cloud_download, color: accentColor),
            label: Text('VIEW ONLINE PRESETS', style: TextStyle(color: accentColor)),
            style: OutlinedButton.styleFrom(
              foregroundColor: accentColor,
              side: BorderSide(color: accentColor),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}