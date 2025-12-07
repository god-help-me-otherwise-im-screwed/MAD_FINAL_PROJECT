import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hawahawa/screens/weather_display_screen.dart';
import 'package:hawahawa/screens/location_permission_screen.dart';
import 'package:hawahawa/screens/startup_screen.dart';
import 'package:hawahawa/providers/location_provider.dart';
import 'package:hawahawa/providers/weather_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  final bool reset;
  const SplashScreen({super.key, required this.reset});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _textController;
  late Animation<double> _textScaleAnimation;
  final String _title = 'Hawa Hawa';

  late AnimationController _logoController;
  late Animation<double> _logoScaleAnimation;

  late AnimationController _gradientController;
  late Animation<double> _gradientAnimation;

  @override
  void initState() {
    super.initState();

    _gradientController = AnimationController(
      vsync: this,
      // Increased duration slightly for a more gentle flow
      duration: const Duration(seconds: 18),
    );
    _gradientAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      // CHANGED: Using a smoother curve for a "breathing" effect
      CurvedAnimation(
        parent: _gradientController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _gradientController.repeat(reverse: true);

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _logoScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOut));
    _logoController.forward();

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _textScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.bounceOut),
    );

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _textController.forward();
      }
    });

    _startApp();
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _textController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  void _startApp() async {
    // If reset flag is set, navigate to location permission immediately
    if (widget.reset) {
      await Future.delayed(const Duration(milliseconds: 700));
      _navigateToLocationPermission();
      return;
    }

    // Check if location permission has been requested before
    final prefs = await SharedPreferences.getInstance();
    final permissionChecked =
        prefs.getBool('location_permission_checked') ?? false;

    // Try to load saved location
    // NOTE: Location persistence is INDEPENDENT of authentication status
    final savedLocation = await ref
        .read(locationProvider.notifier)
        .loadSavedLocation();

    await Future.delayed(const Duration(milliseconds: 2200));

    if (mounted) {
      // Smart routing:
      // 1. If first launch and location permission NOT checked -> Go to LocationPermissionScreen
      // 2. If location is saved -> Go to WeatherDisplayScreen
      // 3. Otherwise -> Go to StartupScreen for manual location selection

      if (!permissionChecked) {
        print(
          '[ROUTING] First launch, permission not checked -> LocationPermissionScreen',
        );
        _navigateToLocationPermission();
      } else if (savedLocation != null) {
        print('[ROUTING] Saved location found -> WeatherDisplayScreen');
        // Fetch weather data before navigating
        await ref.read(weatherProvider.notifier).fetchWeather(savedLocation);
        _navigateToWeather();
      } else {
        print('[ROUTING] No saved location -> StartupScreen');
        _navigateToStartup();
      }
    }
  }

  void _navigateToLocationPermission() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LocationPermissionScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _navigateToStartup() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const StartupScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _navigateToWeather() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const WeatherDisplayScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = theme.scaffoldBackgroundColor;

    // --- CUSTOM COLOR DEFINITION ---
    final customColor1 = const Color.fromARGB(255, 25, 1, 44);
    final highlightColor = customColor1.withAlpha(128);

    final customColor2 = const Color.fromARGB(255, 95, 10, 112);
    final shadowColor = customColor2.withAlpha(64);
    // -------------------------------

    return Scaffold(
      backgroundColor: baseColor,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _gradientAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    // CHANGED: Diagonal movement for a sweeping effect
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,

                    colors: [
                      baseColor,
                      shadowColor,
                      highlightColor,
                      shadowColor,
                      baseColor,
                    ],

                    // Kept the stops as they were adjusted to fit the 5 colors
                    stops: [
                      -0.6 + _gradientAnimation.value * 0.5,
                      -0.3 + _gradientAnimation.value * 0.5,
                      0.5 + _gradientAnimation.value * 0.5,
                      1.3 + _gradientAnimation.value * 0.5,
                      1.6 + _gradientAnimation.value * 0.5,
                    ],
                  ),
                ),
              );
            },
          ),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Flexible(flex: 3, child: SizedBox.shrink()),

                  Flexible(
                    flex: 5,
                    child: FadeTransition(
                      opacity: _logoController,
                      child: ScaleTransition(
                        scale: _logoScaleAnimation,
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
                    ),
                  ),
                  const SizedBox(height: 12),

                  ScaleTransition(
                    scale: _textScaleAnimation,
                    child: Text(
                      _title,
                      style: theme.textTheme.headlineLarge?.copyWith(
                        letterSpacing: 3,
                        fontSize: 32.0,
                      ),
                    ),
                  ),

                  const Flexible(flex: 4, child: SizedBox.shrink()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
