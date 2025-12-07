import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hawahawa/constants/colors.dart';
import 'package:hawahawa/providers/settings_provider.dart';
import 'package:hawahawa/providers/location_provider.dart';
import 'package:hawahawa/providers/auth_provider.dart';
import 'package:hawahawa/screens/splash_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set up global keyboard listener for debug reset (Ctrl+Delete)
  ServicesBinding.instance.keyboard.addHandler(_globalKeyHandler);

  runApp(const ProviderScope(child: PixelWeatherApp()));
}

/// Global keyboard handler for debug reset (Ctrl+Delete)
bool _globalKeyHandler(KeyEvent event) {
  if (event is KeyDownEvent) {
    final isCtrlPressed =
        HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed;
    final isDeletKey =
        event.logicalKey == LogicalKeyboardKey.delete ||
        event.logicalKey == LogicalKeyboardKey.backspace;

    if (isCtrlPressed && isDeletKey) {
      print('[DEBUG] Global reset triggered: Ctrl+Delete');
      _performGlobalDebugReset();
      return true;
    }
  }
  return false;
}

/// Global debug reset that clears all persisted data
Future<void> _performGlobalDebugReset() async {
  print('[DEBUG] Performing global debug reset...');

  try {
    // Clear SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_location');
    await prefs.remove('is_authenticated');
    await prefs.remove('tempUnit');
    await prefs.remove('timeFormat');
    await prefs.remove('backgroundMode');
    await prefs.remove('cached_weather');
    await prefs.remove('weather_is_fresh');
    await prefs.remove('location_permission_checked');
    print('[DEBUG] SharedPreferences cleared successfully');

    // Navigate back to splash with reset flag
    final navigator = navigatorKey.currentState;
    if (navigator != null) {
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const SplashScreen(reset: true),
        ),
        (route) => false,
      );
      print('[DEBUG] Navigated to SplashScreen with reset flag');
    }
  } catch (e) {
    print('[DEBUG] Error during global reset: $e');
  }
}

class PixelWeatherApp extends ConsumerWidget {
  const PixelWeatherApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'HawaHawa',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: _appTheme,
      navigatorKey: navigatorKey,
      home: const SplashScreen(reset: false),
    );
  }
}

final ThemeData _appTheme = ThemeData(
  brightness: Brightness.dark,
  fontFamily: 'BoldPixels',
  primaryColor: kDarkPrimary,
  scaffoldBackgroundColor: kDarkPrimary,
  appBarTheme: const AppBarTheme(backgroundColor: kDarkPrimary, elevation: 0),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(
      color: kDarkText,
      fontSize: 18.0,
      fontFamily: 'BoldPixels',
    ),
    bodyMedium: TextStyle(
      color: kDarkText,
      fontSize: 16.0,
      fontFamily: 'BoldPixels',
    ),
    headlineLarge: TextStyle(
      color: kDarkText,
      fontSize: 28.0,
      fontFamily: 'BoldPixels',
    ),
    headlineMedium: TextStyle(
      color: kDarkText,
      fontSize: 22.0,
      fontFamily: 'BoldPixels',
    ),
    headlineSmall: TextStyle(
      color: kDarkText,
      fontSize: 20.0,
      fontFamily: 'BoldPixels',
    ),
    labelLarge: TextStyle(
      color: kDarkText,
      fontSize: 16.0,
      fontFamily: 'BoldPixels',
    ),
  ),
  colorScheme: ColorScheme.dark(primary: kDarkPrimary, secondary: kDarkAccent),
);
