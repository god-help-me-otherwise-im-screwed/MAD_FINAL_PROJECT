import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hawahawa/config/ui_settings.dart';

/// A reusable, configurable panel used as the main scene container.
///
/// Provides a subtle gradient, border and shadow and exposes parameters
/// so screens can control contrast and color without duplicating code.
class ScenePanel extends ConsumerWidget {
  final Widget child;
  final double minWidth;
  final double minHeight;
  final Color? borderColor;
  final List<Color>? backgroundGradientColors;
  final double borderWidth;
  final bool showBorder;
  final bool showShadow;

  const ScenePanel({
    super.key,
    required this.child,
    this.minWidth = 240,
    this.minHeight = 240,
    this.borderColor,
    this.backgroundGradientColors,
    this.borderWidth = 0.0,
    this.showBorder = false,
    this.showShadow = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // If no custom gradient is supplied, use the app-wide UI settings
    final UISettings ui = ref.watch(uiSettingsProvider);

    // Prefer provided gradient, fall back to ui settings
    final List<Color> gradientColors =
        backgroundGradientColors ?? ui.gradientColors;

    final Color effectiveBorderColor = borderColor ?? theme.colorScheme.primary;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      constraints: BoxConstraints(minHeight: minHeight),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: showBorder
            ? Border.all(color: effectiveBorderColor, width: borderWidth)
            : null,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.55),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}
