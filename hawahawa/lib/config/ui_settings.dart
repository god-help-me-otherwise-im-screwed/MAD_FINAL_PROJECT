import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// UI settings stored in a StateNotifier so they can be changed at runtime
/// and widgets can reactively consume them via Riverpod.
class UISettings {
  final Color backgroundColor;
  final List<Color> gradientColors;

  const UISettings({
    required this.backgroundColor,
    required this.gradientColors,
  });

  UISettings copyWith({Color? backgroundColor, List<Color>? gradientColors}) {
    return UISettings(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      gradientColors: gradientColors ?? this.gradientColors,
    );
  }
}

class UISettingsNotifier extends StateNotifier<UISettings> {
  UISettingsNotifier()
    : super(
        const UISettings(
          backgroundColor: Color(0xFF1A0B2E),
          gradientColors: [Color.fromARGB(255, 67, 23, 78), Color.fromARGB(255, 30, 12, 53)],
        ),
      );

  void setBackgroundColor(Color c) =>
      state = state.copyWith(backgroundColor: c);
  void setGradientColors(List<Color> colors) =>
      state = state.copyWith(gradientColors: colors);
}

final uiSettingsProvider =
    StateNotifierProvider<UISettingsNotifier, UISettings>((ref) {
      return UISettingsNotifier();
    });
