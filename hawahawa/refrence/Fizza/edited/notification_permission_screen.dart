import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hawahawa/constants/colors.dart';
import 'package:hawahawa/providers/theme_provider.dart';
import 'package:hawahawa/screens/startup_screen.dart';

class NotificationPermissionScreen extends ConsumerStatefulWidget {
  const NotificationPermissionScreen({super.key});

  @override
  ConsumerState<NotificationPermissionScreen> createState() =>
      _NotificationPermissionScreenState();
}

class _NotificationPermissionScreenState
    extends ConsumerState<NotificationPermissionScreen> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isLightTheme = ref.watch(themeProvider);
    final bgColor = isLightTheme ? kLightPrimary : kDarkPrimary;
    final textColor = isLightTheme ? kLightText : kDarkText;
    final accentColor = isLightTheme ? kLightAccent : kDarkAccent;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_active,
                size: 100,
                color: accentColor,
              ),
              const SizedBox(height: 40),
              Text(
                'STAY UPDATED',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: textColor,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'Get notified about severe weather alerts and daily forecast updates',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: textColor.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : requestNotificationPermission,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: textColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isLoading
                      ? CircularProgressIndicator(color: textColor)
                      : Text(
                    'ENABLE NOTIFICATIONS',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: textColor,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: isLoading ? null : skipNotifications,
                child: Text(
                  'SKIP FOR NOW',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: textColor.withOpacity(0.7),
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void requestNotificationPermission() async {
    setState(() {
      isLoading = true;
    });

    try {
      PermissionStatus status = await Permission.notification.request();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notification_permission_requested', true);
      await prefs.setBool('notifications_enabled', status.isGranted);

      if (mounted) {
        final isLightTheme = ref.read(themeProvider);
        final accentColor = isLightTheme ? kLightAccent : kDarkAccent;

        if (status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Notifications enabled!',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              backgroundColor: accentColor,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Notification permission denied',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              backgroundColor: accentColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final isLightTheme = ref.read(themeProvider);
        final accentColor = isLightTheme ? kLightAccent : kDarkAccent;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString()}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            backgroundColor: accentColor,
          ),
        );
      }
    }

    setState(() {
      isLoading = false;
    });

    finishOnboarding();
  }

  void skipNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_permission_requested', true);
    await prefs.setBool('notifications_enabled', false);

    finishOnboarding();
  }

  void finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_launch_complete', true);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const StartupScreen()),
      );
    }
  }
}