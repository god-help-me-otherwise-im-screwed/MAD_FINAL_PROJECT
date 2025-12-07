import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hawahawa/constants/colors.dart';
import 'package:hawahawa/providers/theme_provider.dart';
import 'package:hawahawa/providers/settings_provider.dart';
import 'package:hawahawa/providers/weather_provider.dart';
import 'package:hawahawa/services/notification_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String theme = 'Dark';
  bool notifications = false;
  bool hideUI = false;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  void loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      theme = prefs.getString('theme') ?? 'Dark';
      notifications = prefs.getBool('notifications_enabled') ?? false;
      hideUI = prefs.getBool('hide_ui') ?? false;
    });

    // Initialize notification service with saved setting
    NotificationService.init(notifications);
  }

  void _showManualLocationDialog(BuildContext context, Color textColor, Color accentColor) {
    final settings = ref.read(settingsProvider);
    final controller = TextEditingController(text: settings.manualLocation);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ref.watch(themeProvider) ? kLightPrimary : kDarkPrimary,
          title: Text(
            'Enter Location',
            style: TextStyle(
              color: textColor,
              fontFamily: 'BoldPixels',
            ),
          ),
          content: TextField(
            controller: controller,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              hintText: 'e.g., New York, London, Tokyo',
              hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: accentColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: textColor.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: accentColor),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: accentColor,
                  fontFamily: 'BoldPixels',
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                if (controller.text.trim().isNotEmpty) {
                  await ref.read(settingsProvider.notifier).setManualLocation(controller.text.trim());
                  Navigator.pop(context);

                  // Trigger weather refresh with new location
                  ref.read(weatherProvider.notifier).fetchWeather();

                  // Show confirmation
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Location set to: ${controller.text.trim()}'),
                        backgroundColor: accentColor,
                      ),
                    );
                  }
                }
              },
              child: Text(
                'Save',
                style: TextStyle(
                  color: accentColor,
                  fontFamily: 'BoldPixels',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLightTheme = ref.watch(themeProvider);
    final settings = ref.watch(settingsProvider);
    final bgColor = isLightTheme ? kLightPrimary : kDarkPrimary;
    final textColor = isLightTheme ? kLightText : kDarkText;
    final accentColor = isLightTheme ? kLightAccent : kDarkAccent;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'SETTINGS',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: textColor,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          buildSettingTile(
            title: 'THEME',
            value: theme,
            icon: theme == 'Light' ? Icons.wb_sunny : Icons.nightlight_round,
            options: ['Light', 'Dark'],
            bgColor: bgColor,
            textColor: textColor,
            accentColor: accentColor,
            onChanged: (value) async {
              setState(() {
                theme = value;
              });
              await ref.read(themeProvider.notifier).setTheme(value == 'Light');
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('theme', value);
            },
          ),
          buildDivider(textColor),
          buildSettingTile(
            title: 'UNIT',
            value: settings.tempUnit == 0 ? 'C°' : 'F°',
            icon: Icons.thermostat,
            options: ['Celsius', 'Fahrenheit'],
            bgColor: bgColor,
            textColor: textColor,
            accentColor: accentColor,
            onChanged: (value) async {
              int unit = value == 'Celsius' ? 0 : 1;
              await ref.read(settingsProvider.notifier).setTempUnit(unit);
            },
          ),
          buildDivider(textColor),
          buildSettingTile(
            title: 'LOCATION',
            value: settings.locationMode,
            icon: Icons.location_on,
            options: ['Auto', 'Manual'],
            bgColor: bgColor,
            textColor: textColor,
            accentColor: accentColor,
            onChanged: (value) async {
              await ref.read(settingsProvider.notifier).setLocationMode(value);

              // If Manual is selected, show dialog to enter location
              if (value == 'Manual') {
                _showManualLocationDialog(context, textColor, accentColor);
              } else {
                // If Auto is selected, refresh weather with auto location
                ref.read(weatherProvider.notifier).fetchWeather();
              }
            },
          ),
          buildDivider(textColor),
          buildSwitchTile(
            title: 'NOTIFICATIONS',
            value: notifications,
            textColor: textColor,
            accentColor: accentColor,
            onChanged: (value) async {
              setState(() {
                notifications = value;
              });
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('notifications_enabled', value);

              // Update notification service
              NotificationService.setEnabled(value);

              // Show confirmation
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value ? 'Notifications enabled' : 'Notifications disabled',
                      style: const TextStyle(fontFamily: 'BoldPixels'),
                    ),
                    backgroundColor: accentColor,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
          buildDivider(textColor),
          buildSwitchTile(
            title: 'HIDE UI',
            value: hideUI,
            textColor: textColor,
            accentColor: accentColor,
            onChanged: (value) async {
              setState(() {
                hideUI = value;
              });
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('hide_ui', value);

              // Show confirmation
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value ? 'UI Hidden (Double tap screen to show)' : 'UI Visible',
                      style: const TextStyle(fontFamily: 'BoldPixels'),
                    ),
                    backgroundColor: accentColor,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
          buildDivider(textColor),
          buildSettingTile(
            title: 'BACKGROUND',
            value: settings.backgroundMode == 0 ? 'Real-time' :
            settings.backgroundMode == 1 ? 'Custom' : 'Static',
            icon: Icons.wallpaper,
            options: ['Real-time', 'Custom', 'Static'],
            bgColor: bgColor,
            textColor: textColor,
            accentColor: accentColor,
            onChanged: (value) async {
              int mode = 0;
              if (value == 'Custom') mode = 1;
              if (value == 'Static') mode = 2;

              await ref.read(settingsProvider.notifier).setBackgroundMode(mode);

              // Show confirmation
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Background mode set to: $value',
                      style: const TextStyle(fontFamily: 'BoldPixels'),
                    ),
                    backgroundColor: accentColor,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
          buildDivider(textColor),
          buildSettingTile(
            title: 'AIR PRESSURE UNIT',
            value: settings.getPressureUnitString(),
            icon: Icons.compress,
            options: ['mbar', 'hPa', 'inHg', 'mmHg'],
            bgColor: bgColor,
            textColor: textColor,
            accentColor: accentColor,
            onChanged: (value) async {
              int unit = 0;
              if (value == 'hPa') unit = 1;
              if (value == 'inHg') unit = 2;
              if (value == 'mmHg') unit = 3;
              await ref.read(settingsProvider.notifier).setPressureUnit(unit);

              // Show confirmation
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Pressure unit set to: $value',
                      style: const TextStyle(fontFamily: 'BoldPixels'),
                    ),
                    backgroundColor: accentColor,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
          buildDivider(textColor),
        ],
      ),
    );
  }

  Widget buildSettingTile({
    required String title,
    required String value,
    IconData? icon,
    required List<String> options,
    required Color bgColor,
    required Color textColor,
    required Color accentColor,
    required Function(String) onChanged,
  }) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      backgroundColor: bgColor,
      collapsedBackgroundColor: bgColor,
      iconColor: textColor,
      collapsedIconColor: textColor,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'BoldPixels',
              color: textColor,
              letterSpacing: 1,
            ),
          ),
          Row(
            children: [
              if (icon != null) Icon(icon, size: 20, color: accentColor),
              if (icon != null) const SizedBox(width: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'BoldPixels',
                  color: accentColor,
                ),
              ),
            ],
          ),
        ],
      ),
      children: options.map((option) {
        bool isSelected = value == option ||
            (title == 'UNIT' &&
                ((option == 'Celsius' && value == 'C°') ||
                    (option == 'Fahrenheit' && value == 'F°'))) ||
            (title == 'BACKGROUND' &&
                ((option == 'Real-time' && value == 'Real-time') ||
                    (option == 'Custom' && value == 'Custom') ||
                    (option == 'Static' && value == 'Static')));

        return ListTile(
          title: Text(
            option,
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'BoldPixels',
              color: textColor,
            ),
          ),
          trailing: isSelected ? Icon(Icons.check, color: accentColor) : null,
          onTap: () {
            onChanged(option);
          },
        );
      }).toList(),
    );
  }

  Widget buildSwitchTile({
    required String title,
    required bool value,
    required Color textColor,
    required Color accentColor,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'BoldPixels',
              color: textColor,
              letterSpacing: 1,
            ),
          ),
          Row(
            children: [
              Text(
                value ? 'ON' : 'OFF',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'BoldPixels',
                  color: accentColor,
                ),
              ),
              const SizedBox(width: 10),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: accentColor,
                activeTrackColor: accentColor.withOpacity(0.5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildDivider(Color textColor) {
    return Divider(
      color: textColor.withOpacity(0.2),
      thickness: 1,
      height: 1,
    );
  }
}