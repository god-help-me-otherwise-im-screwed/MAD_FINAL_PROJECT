import 'package:flutter/material.dart';

class NotificationService {
  static bool _notificationsEnabled = false;

  static void init(bool enabled) {
    _notificationsEnabled = enabled;
  }

  static void setEnabled(bool enabled) {
    _notificationsEnabled = enabled;
    if (enabled) {
      print('Notifications enabled');
      // In a real app, you would initialize flutter_local_notifications here
    } else {
      print('Notifications disabled');
      // Cancel all notifications
    }
  }

  static bool get isEnabled => _notificationsEnabled;

  // Show a simple weather alert (using SnackBar for now)
  static void showWeatherAlert(BuildContext context, String message) {
    if (!_notificationsEnabled) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.notifications_active, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Show weather update notification
  static void showWeatherUpdate(BuildContext context, String location, String temp, String condition) {
    if (!_notificationsEnabled) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weather Update',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('$location: $temp - $condition'),
          ],
        ),
        backgroundColor: Colors.blueGrey,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}