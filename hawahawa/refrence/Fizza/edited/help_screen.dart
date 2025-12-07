import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hawahawa/constants/colors.dart';
import 'package:hawahawa/providers/theme_provider.dart';
import 'package:hawahawa/widgets/scene_panel.dart';

class HelpScreen extends ConsumerWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLightTheme = ref.watch(themeProvider);
    final bgColor = isLightTheme ? kLightPrimary : kDarkPrimary;
    final textColor = isLightTheme ? kLightText : kDarkText;
    final accentColor = isLightTheme ? kLightAccent : kDarkAccent;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('HELP', style: TextStyle(color: textColor)),
        backgroundColor: bgColor,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ScenePanel(
            minWidth: 200,
            minHeight: 160,
            showBorder: true,
            borderWidth: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gesture Controls',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• Swipe RIGHT: Hide UI overlay (background only)',
                    style: TextStyle(color: textColor, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Swipe LEFT or TAP: Show UI overlay',
                    style: TextStyle(color: textColor, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Pull UP: View detailed forecast',
                    style: TextStyle(color: textColor, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ScenePanel(
            minWidth: 200,
            minHeight: 180,
            showBorder: true,
            borderWidth: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Buttons',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildHelpItem(
                    Icons.settings,
                    'Settings',
                    'Adjust temperature units, time format, and background mode',
                    textColor,
                    accentColor,
                  ),
                  const SizedBox(height: 8),
                  _buildHelpItem(
                    Icons.palette,
                    'Customizer',
                    'Customize weather effects and colors',
                    textColor,
                    accentColor,
                  ),
                  const SizedBox(height: 8),
                  _buildHelpItem(
                    Icons.help_outline,
                    'Help',
                    'View this help screen',
                    textColor,
                    accentColor,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ScenePanel(
            minWidth: 200,
            minHeight: 120,
            showBorder: true,
            borderWidth: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Keyboard Shortcuts',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• Press P: Return to startup screen',
                    style: TextStyle(color: textColor, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(
      IconData icon,
      String title,
      String description,
      Color textColor,
      Color accentColor,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: accentColor, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  color: textColor.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}