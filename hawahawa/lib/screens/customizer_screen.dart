import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hawahawa/constants/colors.dart';
import 'package:hawahawa/providers/customizer_provider.dart';
import 'package:hawahawa/widgets/scene_panel.dart';
import 'package:hawahawa/screens/online_presets_screen.dart';

class CustomizerScreen extends ConsumerWidget {
  const CustomizerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preset = ref.watch(customizerProvider);

    return Scaffold(
      backgroundColor: kDarkPrimary,
      appBar: AppBar(
        title: const Text('CUSTOMIZER'),
        backgroundColor: kDarkPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: () {
              ref.read(customizerProvider.notifier).resetToDefault();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reset to default')),
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
                  const Text('Cloud Density', style: TextStyle(color: kDarkText)),
                  Slider(
                    value: preset.cloudDensity,
                    onChanged: (v) => ref.read(customizerProvider.notifier).setCloudDensity(v),
                    activeColor: kDarkAccent,
                    label: preset.cloudDensity.toStringAsFixed(2),
                  ),
                  Text(
                    'Value: ${preset.cloudDensity.toStringAsFixed(2)}',
                    style: TextStyle(color: kDarkText.withOpacity(0.6), fontSize: 12),
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
                  const Text('Rain Intensity', style: TextStyle(color: kDarkText)),
                  Slider(
                    value: preset.rainIntensity,
                    onChanged: (v) => ref.read(customizerProvider.notifier).setRainIntensity(v),
                    activeColor: kDarkAccent,
                    label: preset.rainIntensity.toStringAsFixed(2),
                  ),
                  Text(
                    'Value: ${preset.rainIntensity.toStringAsFixed(2)}',
                    style: TextStyle(color: kDarkText.withOpacity(0.6), fontSize: 12),
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
                  const Text('Wind Speed Override', style: TextStyle(color: kDarkText)),
                  Slider(
                    value: preset.windSpeedOverride,
                    min: 0,
                    max: 100,
                    onChanged: (v) => ref.read(customizerProvider.notifier).setWindSpeed(v),
                    activeColor: kDarkAccent,
                    label: preset.windSpeedOverride.toStringAsFixed(0),
                  ),
                  Text(
                    'Value: ${preset.windSpeedOverride.toStringAsFixed(0)} km/h',
                    style: TextStyle(color: kDarkText.withOpacity(0.6), fontSize: 12),
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
                  const Text('Particle Count', style: TextStyle(color: kDarkText)),
                  Slider(
                    value: preset.particleCount,
                    min: 0,
                    max: 200,
                    onChanged: (v) => ref.read(customizerProvider.notifier).setParticleCount(v),
                    activeColor: kDarkAccent,
                    label: preset.particleCount.toStringAsFixed(0),
                  ),
                  Text(
                    'Value: ${preset.particleCount.toStringAsFixed(0)}',
                    style: TextStyle(color: kDarkText.withOpacity(0.6), fontSize: 12),
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
                  const Text('Animation Speed', style: TextStyle(color: kDarkText)),
                  Slider(
                    value: preset.animationSpeed,
                    min: 0.1,
                    max: 3.0,
                    onChanged: (v) => ref.read(customizerProvider.notifier).setAnimationSpeed(v),
                    activeColor: kDarkAccent,
                    label: preset.animationSpeed.toStringAsFixed(1),
                  ),
                  Text(
                    'Value: ${preset.animationSpeed.toStringAsFixed(1)}x',
                    style: TextStyle(color: kDarkText.withOpacity(0.6), fontSize: 12),
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
                const SnackBar(content: Text('Preset saved locally!')),
              );
            },
            icon: const Icon(Icons.save),
            label: const Text('SAVE LOCAL PRESET'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kDarkAccent,
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
            icon: const Icon(Icons.cloud_download),
            label: const Text('VIEW ONLINE PRESETS'),
            style: OutlinedButton.styleFrom(
              foregroundColor: kDarkAccent,
              side: const BorderSide(color: kDarkAccent),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}