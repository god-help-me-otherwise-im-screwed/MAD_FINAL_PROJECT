# HAWAHAWA Weather App - Complete Architecture & Module Guide

## Overview

Your app is a **pixel-art weather application** with a dark/purple theme. It follows a **clean architecture pattern** with clear separation of concerns:
- **UI Layer** (Screens & Widgets)
- **State Management** (Riverpod Providers)
- **Data Models** (Models)
- **Business Logic** (API Services)
- **Configuration** (Constants)

This structure ensures that **changes to one module rarely affect others** if you follow the patterns correctly.

---

## 1. APP INITIALIZATION FLOW

### Entry Point: `lib/main.dart`

```
main()
  ↓
ProviderScope (enables Riverpod state management across entire app)
  ↓
PixelWeatherApp (root widget)
  ↓
MaterialApp configuration (theme, navigation, orientation lock)
  ↓
SplashScreen (initial screen)
```

**Key Config:**
- **Portrait-only mode** (landscape disabled)
- **Dark theme with BoldPixels font family**
- **Global navigator key** for ESC key handling (reset to splash)
- **Color scheme**: Deep purple (#1A0B2E) + Blue violet accents (#8A2BE2)

**Files to Modify for Global Changes:**
- `main.dart` - Theme, font, global styles
- `constants/colors.dart` - Color palette

---

## 2. NAVIGATION FLOW (Screen Hierarchy)

```
SplashScreen (loading/authentication check)
├─ YES: authenticated → StartupScreen → LoginScreen (if needed)
│
└─ NO: unauthenticated → WeatherDisplayScreen (main hub)
    ├─ Settings Button → SettingsScreen
    ├─ Palette Button → CustomizerScreen
    ├─ Help Button → HelpScreen
    ├─ Pull-up Menu → PullUpForecastMenu (forecast overlay)
    └─ (Swipe) → Search Location → SearchLocationScreen
        └─ Select location → Back to WeatherDisplayScreen
```

---

## 3. CORE MODULES BREAKDOWN

### A. STATE MANAGEMENT LAYER (Riverpod Providers)
Location: `lib/providers/`

These are the **single source of truth** for all app data. Any screen that needs data listens to these providers.

#### 1. `weather_provider.dart` - Weather Data
```dart
final weatherProvider = StateNotifierProvider<WeatherNotifier, WeatherReport?>
```
**Controls:** Current weather, hourly forecast, daily forecast  
**State:** `WeatherReport` object containing:
- `locationName` (String)
- `current` (WeatherData - temperature, condition, humidity, wind)
- `hourly` (List<WeatherData> - 12 entries)
- `daily` (List<WeatherData> - 7 days)

**Who Uses It:**
- `weather_display_screen.dart` - displays main temp
- `pullup_forecast_menu.dart` - shows hourly/daily forecast
- Any screen that needs weather data

**Update Method:** `fetchWeather(LocationResult location)`

---

#### 2. `settings_provider.dart` - User Preferences
```dart
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>
```
**Controls:** Temperature unit, time format, background mode  
**State:** `AppSettings` object with:
- `tempUnit` (0=Celsius, 1=Fahrenheit)
- `timeFormat` (0=24h, 1=12h)
- `backgroundMode` (0=realtime, 1=custom, 2=static)

**Who Uses It:**
- `pullup_forecast_menu.dart` - formats temps/times
- Any screen needing user preferences

**Update Methods:**
- `setTempUnit(int unit)`
- `setTimeFormat(int format)`

---

#### 3. `location_provider.dart` - Current Location
```dart
final locationProvider = StateNotifierProvider<LocationNotifier, LocationResult?>
```
**Controls:** Current selected location (lat/lon/name)  
**State:** `LocationResult` object

**Who Uses It:**
- `weather_provider.dart` (as parameter for weather fetch)
- `search_location_screen.dart` (to update current location)

**Update Method:** `setLocation(LocationResult location)`

---

#### 4. `customizer_provider.dart` - Theme Customization
```dart
final customizerProvider = StateNotifierProvider<CustomizerNotifier, CustomizerModel>
```
**Controls:** Background colors, accent colors, theme settings  
**State:** `CustomizerModel` object

**Who Uses It:**
- `background_engine.dart` (applies dynamic colors)
- `customizer_screen.dart` (UI to change colors)

---

#### 5. `auth_provider.dart` - Authentication
```dart
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>
```
**Controls:** Login/logout, user authentication  
**State:** `AuthState` object

**Who Uses It:**
- `splash_screen.dart` (checks if user is logged in)
- `login_screen.dart` (handles login logic)

---

### B. DATA MODELS LAYER
Location: `lib/models/`

These are **immutable data containers** that define the structure of app data.

#### 1. `weather_model.dart`
```dart
class WeatherReport {
  final String? locationName;
  final WeatherData? current;
  final List<WeatherData> hourly;
  final List<WeatherData> daily;
}

class WeatherData {
  final String timestamp;
  final Map<String, dynamic> values; // 16 fields
  
  String getFormattedTime();
  String formatValue(String key, dynamic value);
}
```

**Used By:**
- Weather display screens
- Pull-up forecast menu

---

#### 2. `settings_model.dart`
```dart
class AppSettings {
  final int tempUnit;
  final int timeFormat;
  final int backgroundMode;
}
```

**Used By:**
- Settings provider & screen
- Any screen showing formatted temps/times

---

#### 3. `location_model.dart`
```dart
class LocationResult {
  final double lat;
  final double lon;
  final String displayName;
}
```

**Used By:**
- Location provider
- Search location screen
- Weather API calls

---

#### 4. `customizer_model.dart`
```dart
class CustomizerModel {
  final Color backgroundColor;
  final Color accentColor;
  // ... other theme properties
}
```

**Used By:**
- Customizer provider & screen
- Background engine

---

### C. API/SERVICE LAYER
Location: `lib/api/`

**Single File:** `api_service.dart`

This file handles **all external API calls**. It's isolated so API changes don't break UI code.

```dart
class LocationAPI {
  static Future<LocationResult> getLocationFromGps()
  static Future<LocationResult> reverseGeocode(lat, lon)
  static Future<LocationResult> searchLocationByName(query)
  static Future<List<LocationResult>> searchLocations(query)
}

class WeatherAPI {
  static Future<WeatherReport> fetchWeather(LocationResult location)
}
```

**Used By:**
- Providers (weather_provider, location_provider)
- Search location screen

**External APIs:**
- **Nominatim** (OpenStreetMap) - Location search/reverse geocoding
- **Tomorrow.io** - Weather data (16 fields)

---

### D. UI LAYER

#### Screens (Location: `lib/screens/`)

Each screen is typically a **ConsumerStatefulWidget** or **ConsumerWidget** that listens to providers.

| Screen | Purpose | Providers Used | Features |
|--------|---------|-----------------|----------|
| `splash_screen.dart` | Entry point, auth check | authProvider | Loading animation, navigation routing |
| `startup_screen.dart` | Initial setup/onboarding | none | Brand intro, next button |
| `login_screen.dart` | User authentication | authProvider | Login form, form validation |
| `weather_display_screen.dart` | **MAIN SCREEN** - Shows current weather | weatherProvider, settingsProvider, customizerProvider | Large temp display, control buttons, pull-up menu trigger |
| `pullup_forecast_menu.dart` | Draggable forecast overlay | weatherProvider, settingsProvider | Hourly scroll, daily list, draggable sheet |
| `search_location_screen.dart` | Location search/autocomplete | locationProvider, weatherProvider | TextField with autocomplete, location list, API calls |
| `settings_screen.dart` | User preferences | settingsProvider | Temp unit toggle, time format toggle, background mode select |
| `customizer_screen.dart` | Theme customization | customizerProvider | Color picker, theme preview |
| `help_screen.dart` | Help/about info | none | FAQ, controls info, about app |
| `map_picker_screen.dart` | Visual location picker | locationProvider | Map view, marker placement |
| `online_presets_screen.dart` | Theme presets from server | customizerProvider | Preset gallery, apply button |

---

#### Widgets/Components (Location: `lib/widgets/`)

Reusable UI components that support the screens.

| Widget | Purpose | Used In |
|--------|---------|---------|
| `background_engine.dart` | Animated pixel-art background | weather_display_screen (BackgroundEngine widget) |
| `safe_zone_container.dart` | Notch/safe area handler | All screens (wraps main content) |
| `scene_panel.dart` | Reusable panel component | Various screens |
| `weather_overlay.dart` | Weather info overlay | weather_display_screen (optional) |
| `weather_report_view.dart` | Weather card display | (legacy - currently unused) |

---

### E. CONSTANTS LAYER
Location: `lib/constants/`

**Centralized configuration** - Change these, affects entire app.

| File | Contents | Affects |
|------|----------|---------|
| `colors.dart` | Color palette (kDarkPrimary, kDarkAccent, etc.) | All screens, theme |
| `app_constants.dart` | API keys, endpoints, timeouts | API calls |
| `weather_codes.dart` | Weather code → description mapping | Weather display, forecast menu |

---

## 4. DETAILED EXAMPLE: IMPLEMENTING SETTINGS

### Current State:
- **Model:** `lib/models/settings_model.dart` ✅
- **Provider:** `lib/providers/settings_provider.dart` ✅
- **Screen:** `lib/screens/settings_screen.dart` (placeholder)

### To Implement Full Settings Feature:

**Files to Modify (ONLY these):**

#### Step 1: Expand Settings Model ❌ Don't modify
- Already has required fields
- No changes needed

#### Step 2: Update Settings Provider (`lib/providers/settings_provider.dart`)
```dart
// ADD: New setter methods if needed
class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings());

  void setTempUnit(int unit) {
    state = state.copyWith(tempUnit: unit);
  }

  void setTimeFormat(int format) {
    state = state.copyWith(timeFormat: format);
  }
  
  // NEW: Add if you want persistence
  Future<void> saveToStorage() async {
    // Save state to SharedPreferences/Hive
  }
  
  Future<void> loadFromStorage() async {
    // Load state from storage on app start
  }
}
```

**Why:** Provider is the **control center** for settings state. All changes funnel through here.

---

#### Step 3: Build Settings Screen UI (`lib/screens/settings_screen.dart`)
```dart
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // WATCH the provider (auto-rebuild when settings change)
    final settings = ref.watch(settingsProvider);
    
    // READ the provider (call methods without rebuild)
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Temperature Unit Toggle
          ListTile(
            title: const Text('Temperature Unit'),
            subtitle: Text(settings.tempUnit == 0 ? 'Celsius' : 'Fahrenheit'),
            onTap: () {
              final newUnit = settings.tempUnit == 0 ? 1 : 0;
              settingsNotifier.setTempUnit(newUnit);
            },
          ),
          
          // Time Format Toggle
          ListTile(
            title: const Text('Time Format'),
            subtitle: Text(settings.timeFormat == 0 ? '24 Hour' : '12 Hour'),
            onTap: () {
              final newFormat = settings.timeFormat == 0 ? 1 : 0;
              settingsNotifier.setTimeFormat(newFormat);
            },
          ),
          
          // Background Mode
          ListTile(
            title: const Text('Background Mode'),
            subtitle: _getBackgroundModeLabel(settings.backgroundMode),
            onTap: () => _showBackgroundModeDialog(context, ref, settings),
          ),
        ],
      ),
    );
  }
}
```

**Why:** Screen is the **view** - it doesn't contain business logic. It only:
1. **Watches** providers to get current state
2. **Reads** providers to call update methods
3. **Updates** via provider methods only

---

#### Step 4: Use Settings in Other Screens (NO CHANGES NEEDED)

**In `pullup_forecast_menu.dart`:**
```dart
final settings = ref.watch(settingsProvider);

// When displaying temperature:
final tempFormatted = settings.tempUnit == 0
    ? temp
    : (temp * 9 / 5) + 32;
final unit = settings.tempUnit == 0 ? '°C' : '°F';
```

The pull-up menu **automatically** respects settings because it watches the provider.

**In `weather_display_screen.dart`:**
Similarly, just watch the provider - no direct modifications needed.

---

### Key Points for Settings Implementation:

✅ **ONLY modify:**
1. `settings_provider.dart` - Add new setter methods
2. `settings_screen.dart` - Build the UI

❌ **DON'T modify:**
- `main.dart` (affects everything)
- `colors.dart` (affects everything)
- `weather_display_screen.dart` (has its own logic)
- Any other provider or screen

✅ **Why this works:**
- Settings provider is **independent** of other providers
- Other screens **watch** the provider, so they auto-update
- No circular dependencies
- Changes are **isolated**

---

## 5. FEATURE ADDITION PATTERNS

### Adding a New Setting:

1. **Update Model** (`lib/models/settings_model.dart`):
   ```dart
   final bool enableNotifications;  // NEW
   ```

2. **Update Provider** (`lib/providers/settings_provider.dart`):
   ```dart
   void setNotifications(bool enabled) {
     state = state.copyWith(enableNotifications: enabled);
   }
   ```

3. **Update Screen** (`lib/screens/settings_screen.dart`):
   ```dart
   SwitchListTile(
     title: const Text('Enable Notifications'),
     value: settings.enableNotifications,
     onChanged: (val) => settingsNotifier.setNotifications(val),
   )
   ```

4. **Use in Other Screens** (as needed):
   ```dart
   final settings = ref.watch(settingsProvider);
   if (settings.enableNotifications) {
     // Show notification
   }
   ```

**Impact Analysis:**
- ✅ No other files affected
- ✅ Automatic in all screens that watch settingsProvider
- ✅ Can be developed independently

---

### Adding a New API Call:

1. **Add Method to `api_service.dart`**:
   ```dart
   class WeatherAPI {
     static Future<AlertData> fetchWeatherAlerts(LocationResult location) async {
       // API call
     }
   }
   ```

2. **Create New Provider** (`lib/providers/alerts_provider.dart`):
   ```dart
   final alertsProvider = StateNotifierProvider<AlertsNotifier, AlertData?>(...);
   ```

3. **Use in Screens**:
   ```dart
   final alerts = ref.watch(alertsProvider);
   ```

**Impact Analysis:**
- ✅ api_service.dart only handles network calls
- ✅ New provider is isolated
- ✅ Can add to any screen without modifying others

---

### Adding a New Color Theme:

1. **Decide:** Add to `customizer_model.dart` or `colors.dart`?
   - **`colors.dart`** = Global app color (affects everything, use with caution)
   - **`customizer_model.dart`** = User-selectable theme (isolated to customizer)

2. **If adding to `customizer_model.dart`**:
   ```dart
   class CustomizerModel {
     final Color tertiaryColor;  // NEW
   }
   ```

3. **Update `customizer_screen.dart`** with color picker

4. **Use in screens that import customizer**:
   ```dart
   final customizer = ref.watch(customizerProvider);
   Container(color: customizer.tertiaryColor)
   ```

**Impact Analysis:**
- ✅ Only affects customizer and screens that watch it
- ✅ Doesn't break main app colors

---

## 6. DEPENDENCY MAP (What Depends on What)

```
constants/colors.dart
    ↓
    └─→ All screens + widgets (theme)

constants/app_constants.dart
    ↓
    └─→ api/api_service.dart (API keys, endpoints)

api/api_service.dart
    ↓
    ├─→ weather_provider.dart (fetches weather)
    └─→ location_provider.dart (searches locations)

models/ (weather_model, settings_model, location_model, customizer_model)
    ↓
    ├─→ All providers (state structure)
    └─→ All screens (data display)

providers/ (auth, weather, settings, location, customizer)
    ↓
    └─→ All screens (data source)

screens/ → Each screen is independent
    └─→ Can use any provider it needs
    └─→ No screen should depend on another screen

widgets/
    ├─→ background_engine.dart (uses customizer_provider)
    ├─→ safe_zone_container.dart (no dependencies - pure UI)
    └─→ weather_report_view.dart (uses weather_provider)

main.dart
    ↓
    └─→ ProviderScope wraps everything
```

---

## 7. SAFE MODIFICATION ZONES

### GREEN LIGHT (Safe to Modify):
- ✅ **`lib/screens/settings_screen.dart`** - UI only, settings logic
- ✅ **`lib/providers/settings_provider.dart`** - New settings methods
- ✅ **`lib/models/settings_model.dart`** - New setting fields
- ✅ **`lib/screens/customizer_screen.dart`** - Theme customization UI
- ✅ **`lib/screens/search_location_screen.dart`** - Search functionality
- ✅ **`lib/screens/help_screen.dart`** - Static content
- ✅ **`lib/widgets/background_engine.dart`** - Animation logic
- ✅ **`lib/api/api_service.dart`** - API endpoints/methods

### YELLOW LIGHT (Careful Modifications):
- ⚠️ **`lib/providers/weather_provider.dart`** - Core weather data (test after changes)
- ⚠️ **`lib/providers/location_provider.dart`** - Location data (used by weather)
- ⚠️ **`lib/screens/weather_display_screen.dart`** - Main screen (many dependencies)
- ⚠️ **`lib/constants/colors.dart`** - Global colors (affects everything)

### RED LIGHT (Don't Modify Without Understanding):
- 🔴 **`lib/main.dart`** - App initialization
- 🔴 **`lib/screens/splash_screen.dart`** - Auth flow routing
- 🔴 **`lib/providers/auth_provider.dart`** - App-wide authentication

---

## 8. COMMUNICATION PATTERNS

### Screen-to-Screen Communication:
```
SearchLocationScreen
    ↓ (calls method)
locationProvider.setLocation(location)
    ↓ (state updated)
weatherProvider.fetchWeather(location)  // Can watch locationProvider
    ↓ (state updated)
WeatherDisplayScreen
    ↓ (watches weatherProvider)
[Auto-rebuilds with new weather]
```

**No direct screen-to-screen calls** ✅

---

### Theme Changes:
```
CustomizerScreen
    ↓ (calls method)
customizerProvider.setBackgroundColor(newColor)
    ↓ (state updated)
BackgroundEngine (watches customizerProvider)
    ↓ (auto-rebuilds)
[Background color changes everywhere]
```

**All screens automatically react** ✅

---

## 9. TESTING & DEBUGGING SETUP

### To verify dependencies:
```bash
# Run in terminal
cd hawahawa
flutter analyze  # Shows unused imports, errors
flutter pub deps # Shows package dependency tree
```

### To add debug output:
```dart
// In any provider
print('Settings changed: $state');

// In any screen
print('Watching weather provider: $weatherReport');
```

---

## 10. TEAM COLLABORATION GUIDELINES

### Feature Assignment Example:

**Feature: "Implement push notifications for weather alerts"**

**Assign to Developer A:**
- [ ] Create `alert_model.dart` (NEW FILE)
- [ ] Create `alerts_provider.dart` (NEW FILE)
- [ ] Create/modify `api_service.dart` (add fetchAlerts method)
- [ ] Create `alerts_screen.dart` (NEW FILE)

**Assign to Developer B (after A finishes):**
- [ ] Modify `weather_display_screen.dart` (add alert icon button)
- [ ] Modify `main.dart` (add route for alerts screen)

**No Conflicts Because:**
- A only touches new files + API service
- B only touches UI files
- Both use the new alerts_provider independently

---

## 11. QUICK REFERENCE: "Which file controls X?"

| Feature | Primary File | Secondary Files |
|---------|--------------|-----------------|
| Temperature unit display | `pullup_forecast_menu.dart` | `settings_provider.dart` |
| Weather forecast data | `weather_provider.dart` | `api_service.dart` |
| Location search | `search_location_screen.dart` | `api_service.dart`, `location_provider.dart` |
| Theme colors | `background_engine.dart` | `customizer_provider.dart`, `colors.dart` |
| Settings UI | `settings_screen.dart` | `settings_provider.dart` |
| App routing/navigation | `main.dart`, `splash_screen.dart` | N/A |
| Pull-up menu appearance | `pullup_forecast_menu.dart` | `weather_provider.dart`, `settings_provider.dart` |

---

## SUMMARY

Your app uses **clean architecture with Riverpod state management**. This means:

1. **Each feature has its own provider** - Isolated state management
2. **Screens don't talk to each other** - They communicate via providers
3. **Models define data structure** - All components follow the same shape
4. **API layer is separate** - Easy to swap out APIs without changing UI
5. **Constants are centralized** - Change colors/values in one place

### To safely add features:
- Create new providers for new state
- Create new screens/widgets for new UI
- Extend existing models if needed
- Modify `api_service.dart` for new API calls
- Everything else auto-connects via Riverpod

**Your team can work in parallel on different features without conflicts as long as they follow these patterns!** 🎉
