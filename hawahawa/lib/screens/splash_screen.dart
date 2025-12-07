import 'package:flutter/material.dart';
import 'package:hawahawa/screens/startup_screen.dart';

class SplashScreen extends StatefulWidget {
  final bool reset;
  const SplashScreen({super.key, required this.reset});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
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
      duration: const Duration(seconds: 15),
    );
    _gradientAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _gradientController, curve: Curves.linear),
    );

    _gradientController.repeat(reverse: true);

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _logoScaleAnimation = Tween<double>(begin: 0.8, end: 1.0)
      .animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOut));
    _logoController.forward();

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _textScaleAnimation = Tween<double>(begin: 0.0, end: 1.0)
      .animate(CurvedAnimation(parent: _textController, curve: Curves.bounceOut));
    
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
    final duration = widget.reset
        ? const Duration(milliseconds: 700) 
        : const Duration(milliseconds: 2200); 

    await Future.delayed(duration);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (context, animation, secondaryAnimation) => const StartupScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = theme.scaffoldBackgroundColor;
    
    // --- CUSTOM COLOR DEFINITION HERE ---
    final customTeal = const Color.fromARGB(255, 13, 54, 41); 
    final highlightColor = customTeal.withAlpha(128); 
    // ------------------------------------

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
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [baseColor, highlightColor, baseColor],
                    stops: [
                      -0.5 + _gradientAnimation.value * 0.5,
                      0.5 + _gradientAnimation.value * 0.5,
                      1.5 + _gradientAnimation.value * 0.5,
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