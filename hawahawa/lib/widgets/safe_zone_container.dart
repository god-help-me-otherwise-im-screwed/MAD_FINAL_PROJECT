import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hawahawa/config/ui_settings.dart';

// These aspect ratios are expressed as width / height (W / H).
// The app is portrait-first, so valid width/height ratios are < 1.
// Keep the scene between a narrow tall phone (9:16 -> 0.5625)
// and a slightly wider portrait (3:4 -> 0.75).
const double kMinWidthHeightAspect = 9.0 / 16.0; // 0.5625
const double kMaxWidthHeightAspect = 3.0 / 4.0; // 0.75

class SafeZoneContainer extends ConsumerWidget {
  final Widget child;

  const SafeZoneContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use the UI settings backgroundColor when available
    final ui = ref.watch(uiSettingsProvider);
    final backgroundColor = ui.backgroundColor;

    return Container(
      // This container fills the entire screen and provides the background color
      color: backgroundColor,
      child: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double availableWidth = constraints.maxWidth;
            final double availableHeight = constraints.maxHeight;

            // Defensive: if unconstrained, just return the child on the background
            if (availableWidth.isInfinite || availableHeight.isInfinite) {
              return child;
            }

            final double currentAspect =
                availableWidth / availableHeight; // W / H

            double sceneWidth = availableWidth;
            double sceneHeight = availableHeight;

            if (currentAspect < kMinWidthHeightAspect) {
              // Too narrow: expand width so height limits the scene (letterbox horizontally)
              sceneWidth = availableHeight * kMinWidthHeightAspect;
              sceneHeight = availableHeight;
            } else if (currentAspect > kMaxWidthHeightAspect) {
              // Too wide: constrain width according to max aspect (pillarbox)
              sceneWidth = availableHeight * kMaxWidthHeightAspect;
              sceneHeight = availableHeight;
            } else {
              // Aspect inside allowed range -> use full available area
              sceneWidth = availableWidth;
              sceneHeight = availableHeight;
            }

            // Center a fixed-size box for the scene and clip any overflow.
            return Center(
              child: SizedBox(
                width: sceneWidth,
                height: sceneHeight,
                child: ClipRect(
                  child: Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: sceneWidth,
                      height: sceneHeight,
                      child: child,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
