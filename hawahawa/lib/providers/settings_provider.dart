import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hawahawa/models/settings_model.dart';

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings());

  void setTempUnit(int unit) {
    state = state.copyWith(tempUnit: unit);
  }

  void setTimeFormat(int format) {
    state = state.copyWith(timeFormat: format);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((
  ref,
) {
  return SettingsNotifier();
});
