import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(false) {
    loadTheme();
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString('theme') ?? 'Dark';
    state = theme == 'Light';
  }

  Future<void> setTheme(bool isLight) async {
    state = isLight;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', isLight ? 'Light' : 'Dark');
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier();
});