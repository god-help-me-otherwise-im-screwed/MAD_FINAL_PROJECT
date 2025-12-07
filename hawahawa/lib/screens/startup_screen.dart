import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hawahawa/constants/colors.dart';
import 'package:hawahawa/models/location_model.dart';
import 'package:hawahawa/providers/location_provider.dart';
import 'package:hawahawa/providers/weather_provider.dart';
import 'package:hawahawa/screens/weather_display_screen.dart';
import 'package:hawahawa/screens/map_picker_screen.dart';
import 'package:hawahawa/screens/search_location_screen.dart';

class StartupScreen extends ConsumerStatefulWidget {
  const StartupScreen({super.key});

  @override
  ConsumerState<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends ConsumerState<StartupScreen>
    with TickerProviderStateMixin {
  // 1. STATE TRACKING
  bool _isGpsLoading = false;
  LocationResult? _detectedLocation;

  // 2. ANIMATION CONTROLLERS
  // Controller for the three interactive location selection buttons
  late final AnimationController _selectionButtonController = AnimationController(
    duration: const Duration(milliseconds: 150),
    vsync: this,
  );

  // Controller for the PROCEED button (used for both press animation and disabled pulse)
  late final AnimationController _proceedButtonController = AnimationController(
    duration: const Duration(milliseconds: 1000),
    vsync: this,
  );

  // Animation for the pulsing effect when the PROCEED button is disabled
  late final Animation<double> _disabledPulseAnimation = Tween<double>(
    begin: 0.8,
    end: 1.0,
  ).animate(CurvedAnimation(
    parent: _proceedButtonController,
    curve: Curves.easeInOut,
  ));

  @override
  void initState() {
    super.initState();
    // Start the pulsing animation loop immediately
    _proceedButtonController.repeat(reverse: true);
  }

  // Function to handle GPS button press
  Future<void> _handleGpsLocation() async {
    setState(() {
      _isGpsLoading = true;
    });

    final LocationResult? location =
        await ref.read(locationProvider.notifier).requestGpsLocation();

    if (mounted) {
      setState(() {
        _isGpsLoading = false;
        if (location != null) {
          _detectedLocation = location;
        }
      });
    }
  }

  // Function to handle map selection
  Future<void> _handleMapSelection() async {
    final LocationResult? location = await Navigator.of(context)
        .push<LocationResult?>(
          MaterialPageRoute(builder: (c) => const MapPickerScreen()),
        );

    if (location != null && mounted) {
      setState(() {
        _detectedLocation = location;
      });
    }
  }

  // Function to handle search location
  Future<void> _handleSearchLocation() async {
    final LocationResult? location = await Navigator.of(context)
        .push<LocationResult?>(
          MaterialPageRoute(builder: (c) => const SearchLocationScreen()),
        );

    if (location != null && mounted) {
      setState(() {
        _detectedLocation = location;
      });
    }
  }

  // Function to handle proceeding to weather screen
  Future<void> _proceedToWeather(LocationResult location) async {
    if (!mounted) return;

    ref.read(locationProvider.notifier).setLocation(location);
    await ref.read(weatherProvider.notifier).fetchWeather(location);

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (c) => const WeatherDisplayScreen()),
    );
  }

  @override
  void dispose() {
    _selectionButtonController.dispose();
    _proceedButtonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isProceedEnabled = _detectedLocation != null;

    return Scaffold(
      backgroundColor: kDarkPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 3),
              Text(
                'Hawa Hawa',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: kDarkText,
                      fontSize: 75,
                      letterSpacing: 3,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Choose Your Location',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: kDarkText.withOpacity(0.7),
                      fontSize: 25,
                    ),
              ),
              const Spacer(flex: 5),

              // LOCATION STATUS DISPLAY (Always visible if a location is selected)
              if (_detectedLocation != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    children: [
                      Text(
                        'Selected Location:',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: kDarkText.withOpacity(0.8),
                              fontWeight: FontWeight.normal,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _detectedLocation!.displayName,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: kDarkText,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              
              // GPS Button (Always visible)
              _buildButton(
                context,
                icon: Icons.my_location,
                label: _isGpsLoading ? 'LOADING GPS...' : 'USE GPS LOCATION',
                onPressed: _isGpsLoading ? null : _handleGpsLocation,
                isInteractive: true,
                animationController: _selectionButtonController,
              ),

              // Map Selection Button (Always visible)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: _buildButton(
                  context,
                  icon: Icons.map,
                  label: 'SELECT ON MAP',
                  onPressed: _handleMapSelection,
                  isInteractive: true,
                  animationController: _selectionButtonController,
                ),
              ),

              // Search Location Button (Always visible)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: _buildButton(
                  context,
                  icon: Icons.search,
                  label: 'SEARCH BY NAME',
                  onPressed: _handleSearchLocation,
                  isInteractive: true,
                  animationController: _selectionButtonController,
                ),
              ),

              const Spacer(flex: 2),

              // PROCEED TO WEATHER Button (Now has its own animation logic)
              _buildButton(
                context,
                icon: isProceedEnabled ? Icons.cloud : Icons.lock,
                label: 'PROCEED TO WEATHER',
                onPressed: isProceedEnabled
                    ? () => _proceedToWeather(_detectedLocation!)
                    : null,
                disabled: !isProceedEnabled,
                isInteractive: true, // Mark as interactive for press animation
                animationController: _proceedButtonController,
                disabledPulse: isProceedEnabled ? null : _disabledPulseAnimation, // Pass pulse animation when disabled
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required AnimationController animationController,
    Animation<double>? disabledPulse,
    bool secondary = false,
    bool disabled = false,
    bool isInteractive = false,
  }) {
    // Common styles
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: disabled
          ? kDarkAccent.withOpacity(0.3)
          : (secondary ? kDarkPrimary : kDarkAccent),
      foregroundColor: disabled ? kDarkText.withOpacity(0.5) : kDarkText,
      elevation: disabled ? 0 : (secondary ? 0 : 8),
      shadowColor: kDarkAccent.withOpacity(0.5),
      padding: const EdgeInsets.symmetric(vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: disabled
              ? kDarkAccent.withOpacity(0.2)
              : (secondary ? kDarkAccent.withOpacity(0.5) : Colors.transparent),
          width: 2,
        ),
      ),
    );

    // Common child widget
    final buttonChild = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 32),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: disabled ? kDarkText.withOpacity(0.5) : kDarkText,
            ),
          ),
        ),
      ],
    );

    // Create the button widget
    final button = ElevatedButton(
      onPressed: onPressed,
      style: buttonStyle,
      child: buttonChild,
    );

    // 1. Disabled Pulse Animation for PROCEED button
    if (disabled && disabledPulse != null) {
      return AnimatedBuilder(
        animation: disabledPulse,
        builder: (context, child) {
          // Wrap the disabled button in an Opacity widget controlled by the pulse animation
          return Opacity(
            opacity: disabledPulse.value,
            child: button,
          );
        },
      );
    }
    
    // 2. Press-Down Scale Animation for Enabled buttons (Selection and PROCEED)
    if (isInteractive && !disabled) {
      return GestureDetector(
        onTapDown: (_) => animationController.forward(),
        onTapUp: (_) => animationController.reverse(),
        onTapCancel: () => animationController.reverse(),
        onTap: onPressed,
        child: ScaleTransition(
          scale: Tween<double>(begin: 1.0, end: 0.95).animate(animationController),
          child: button,
        ),
      );
    }

    // 3. Fallback for non-interactive disabled buttons
    return button;
  }
}