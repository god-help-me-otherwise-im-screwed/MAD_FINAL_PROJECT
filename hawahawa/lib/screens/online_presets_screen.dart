import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hawahawa/constants/colors.dart';
import 'package:hawahawa/providers/auth_provider.dart';
import 'package:hawahawa/widgets/scene_panel.dart';

class OnlinePresetsScreen extends ConsumerWidget {
  const OnlinePresetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: kDarkPrimary,
      appBar: AppBar(
        title: const Text('ONLINE PRESETS'),
        backgroundColor: kDarkPrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: isLoggedIn
              ? _buildPresetsView(context)
              : _buildLoginRequired(context),
        ),
      ),
    );
  }

  Widget _buildLoginRequired(BuildContext context) {
    return ScenePanel(
      minWidth: 200,
      minHeight: 200,
      showBorder: true,
      borderWidth: 1,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock, color: kDarkAccent, size: 64),
            const SizedBox(height: 16),
            const Text(
              'LOGIN REQUIRED',
              style: TextStyle(
                color: kDarkText,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please login to view and upload online presets',
              style: TextStyle(color: kDarkText.withOpacity(0.7)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: kDarkAccent,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
              ),
              child: const Text('GO BACK'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetsView(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ScenePanel(
            minWidth: 200,
            minHeight: 400,
            showBorder: true,
            borderWidth: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'ONLINE PRESETS',
                    style: TextStyle(
                      color: kDarkText,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_off, color: kDarkText.withOpacity(0.3), size: 64),
                          const SizedBox(height: 16),
                          Text(
                            'Firebase integration placeholder',
                            style: TextStyle(
                              color: kDarkText.withOpacity(0.5),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Online presets will be loaded here\nfrom Cloud Firestore',
                            style: TextStyle(
                              color: kDarkText.withOpacity(0.3),
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Firebase upload feature coming soon!')),
            );
          },
          icon: const Icon(Icons.cloud_upload),
          label: const Text('UPLOAD CURRENT PRESET'),
          style: ElevatedButton.styleFrom(
            backgroundColor: kDarkAccent,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),
      ],
    );
  }
}