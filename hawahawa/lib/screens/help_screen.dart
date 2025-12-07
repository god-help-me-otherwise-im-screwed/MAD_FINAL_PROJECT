import 'package:flutter/material.dart';
import 'package:hawahawa/constants/colors.dart';
import 'package:hawahawa/widgets/scene_panel.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkPrimary,
      appBar: AppBar(title: const Text('HELP'), backgroundColor: kDarkPrimary),
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
                      color: kDarkText,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• Swipe RIGHT: Hide UI overlay (background only)',
                    style: TextStyle(color: kDarkText, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Swipe LEFT or TAP: Show UI overlay',
                    style: TextStyle(color: kDarkText, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Pull UP: View detailed forecast',
                    style: TextStyle(color: kDarkText, fontSize: 14),
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
                  const Text(
                    'Buttons',
                    style: TextStyle(
                      color: kDarkText,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildHelpItem(
                    Icons.settings,
                    'Settings',
                    'Adjust temperature units, time format, and background mode',
                  ),
                  const SizedBox(height: 8),
                  _buildHelpItem(
                    Icons.palette,
                    'Customizer',
                    'Customize weather effects and colors',
                  ),
                  const SizedBox(height: 8),
                  _buildHelpItem(
                    Icons.help_outline,
                    'Help',
                    'View this help screen',
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
                      color: kDarkText,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• Press P: Return to startup screen',
                    style: TextStyle(color: kDarkText, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: kDarkAccent, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: kDarkText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  color: kDarkText.withOpacity(0.7),
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
