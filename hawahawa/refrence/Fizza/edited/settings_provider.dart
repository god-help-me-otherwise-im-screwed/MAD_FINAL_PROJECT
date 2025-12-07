import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hawahawa/models/settings_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = AppSettings(
      tempUnit: prefs.getInt('temp_unit') ?? 0,
      timeFormat: prefs.getInt('time_format') ?? 0,
      backgroundMode: prefs.getInt('background_mode') ?? 0,
      pressureUnit: prefs.getInt('pressure_unit') ?? 0,
      locationMode: prefs.getString('location_mode') ?? 'Auto',
      manualLocation: prefs.getString('manual_location') ?? '',
    );
  }

  Future<void> setTempUnit(int unit) async {
    state = state.copyWith(tempUnit: unit);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('temp_unit', unit);
  }

  Future<void> setTimeFormat(int format) async {
    state = state.copyWith(timeFormat: format);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('time_format', format);
  }

  Future<void> setBackgroundMode(int mode) async {
    state = state.copyWith(backgroundMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('background_mode', mode);
  }

  Future<void> setPressureUnit(int unit) async {
    state = state.copyWith(pressureUnit: unit);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('pressure_unit', unit);
  }

  Future<void> setLocationMode(String mode) async {
    state = state.copyWith(locationMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('location_mode', mode);
  }

  Future<void> setManualLocation(String location) async {
    state = state.copyWith(manualLocation: location);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('manual_location', location);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>(
      (ref) {
    return SettingsNotifier();
  },
);