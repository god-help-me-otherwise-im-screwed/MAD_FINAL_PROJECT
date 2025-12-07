import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hawahawa/models/settings_model.dart';

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings());

  /// Load settings from persistent storage
  Future<void> loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final tempUnit = prefs.getInt('tempUnit') ?? 0;
      final timeFormat = prefs.getInt('timeFormat') ?? 0;
      final backgroundMode = prefs.getInt('backgroundMode') ?? 0;

      state = AppSettings(
        tempUnit: tempUnit,
        timeFormat: timeFormat,
        backgroundMode: backgroundMode,
      );

      print('[SETTINGS] Loaded from storage: $state');
    } catch (e) {
      print('Error loading settings from storage: $e');
      // State remains default
    }
  }

  /// Save settings to persistent storage
  Future<void> saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setInt('tempUnit', state.tempUnit);
      await prefs.setInt('timeFormat', state.timeFormat);
      await prefs.setInt('backgroundMode', state.backgroundMode);

      print('[SETTINGS] Saved to storage: $state');
    } catch (e) {
      print('Error saving settings to storage: $e');
    }
  }

  /// Clear all settings from storage (debug reset)
  Future<void> resetDebugData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('tempUnit');
      await prefs.remove('timeFormat');
      await prefs.remove('backgroundMode');

      state = const AppSettings();
      print('[SETTINGS] Debug reset completed');
    } catch (e) {
      print('Error resetting settings debug data: $e');
    }
  }

  void setTempUnit(int unit) {
    state = state.copyWith(tempUnit: unit);
    saveToStorage();
  }

  void setTimeFormat(int format) {
    state = state.copyWith(timeFormat: format);
    saveToStorage();
  }

  void setBackgroundMode(int mode) {
    state = state.copyWith(backgroundMode: mode);
    saveToStorage();
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((
  ref,
) {
  return SettingsNotifier();
});
