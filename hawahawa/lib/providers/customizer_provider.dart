import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hawahawa/models/customizer_model.dart';

class CustomizerNotifier extends StateNotifier<CustomPreset> {
  CustomizerNotifier() : super(const CustomPreset());

  void resetToDefault() => state = const CustomPreset();

  void setCloudDensity(double v) => state = state.copyWith(cloudDensity: v);
  void setRainIntensity(double v) => state = state.copyWith(rainIntensity: v);
  void setWindSpeed(double v) => state = state.copyWith(windSpeedOverride: v);
  void setParticleCount(double v) => state = state.copyWith(particleCount: v);
  void setAnimationSpeed(double v) => state = state.copyWith(animationSpeed: v);

  void savePreset() {
    // Minimal local save stub - in real app, persist to storage
  }
}

final customizerProvider =
    StateNotifierProvider<CustomizerNotifier, CustomPreset>((ref) {
      return CustomizerNotifier();
    });
