import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hawahawa/constants/colors.dart';
import 'package:hawahawa/screens/splash_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ProviderScope(child: PixelWeatherApp()));
}

class PixelWeatherApp extends ConsumerWidget {
  const PixelWeatherApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusNode = FocusNode();

    return Focus(
      autofocus: true,
      focusNode: focusNode,
      onKeyEvent: (FocusNode node, KeyEvent event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.escape) {
            if (navigatorKey.currentState != null) {
              navigatorKey.currentState!.pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (c) => const SplashScreen(reset: true),
                ),
                (Route<dynamic> route) => false,
              );
            }
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: MaterialApp(
        title: 'Pixel Weather Sim',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        theme: _appTheme,
        navigatorKey: navigatorKey,
        home: const SplashScreen(reset: false),
      ),
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
    bodyLarge: TextStyle(color: kDarkText, fontSize: 18.0,fontFamily: 'BoldPixels'),
    bodyMedium: TextStyle(color: kDarkText, fontSize: 16.0,fontFamily: 'BoldPixels'),
    headlineLarge: TextStyle(color: kDarkText, fontSize: 28.0, fontFamily: 'BoldPixels'),
    headlineMedium: TextStyle(color: kDarkText, fontSize: 22.0, fontFamily: 'BoldPixels'),
    headlineSmall: TextStyle(color: kDarkText, fontSize: 20.0, fontFamily: 'BoldPixels'),
    labelLarge: TextStyle(color: kDarkText, fontSize: 16.0, fontFamily: 'BoldPixels'),
  ),
  colorScheme: ColorScheme.dark(primary: kDarkPrimary, secondary: kDarkAccent),
);
