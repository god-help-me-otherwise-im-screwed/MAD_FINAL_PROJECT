import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hawahawa/screens/startup_screen.dart';
import 'package:hawahawa/screens/location_permission_screen.dart';

class SplashScreen extends StatefulWidget {
  final bool reset;
  const SplashScreen({super.key, required this.reset});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startApp();
  }

  void _startApp() async {
    final duration = widget.reset
        ? const Duration(milliseconds: 500)
        : const Duration(seconds: 3);

    await Future.delayed(duration);

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunchComplete = prefs.getBool('first_launch_complete') ?? false;

    if (isFirstLaunchComplete) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) {
          return const StartupScreen();
        }),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) {
          return const LocationPermissionScreen();
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Flexible(flex: 3, child: SizedBox.shrink()),
              Flexible(
                flex: 5,
                child: FractionallySizedBox(
                  widthFactor: 0.5,
                  child: Image.asset(
                    'assets/logo/splash_logo.png',
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.none,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.cloud,
                        size: 100,
                        color: theme.colorScheme.secondary,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'PIXEL WEATHER SIM',
                style: theme.textTheme.headlineSmall?.copyWith(
                  letterSpacing: 2,
                ),
              ),
              const Flexible(flex: 4, child: SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }
}