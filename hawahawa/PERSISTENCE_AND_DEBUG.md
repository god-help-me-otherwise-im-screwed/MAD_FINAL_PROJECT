# Persistent State Management & Global Debug Reset Feature

## Overview

This document explains the implementation of persistent state management and a global debug reset feature for the Hawahawa weather app using Riverpod and shared_preferences.

## What Was Implemented

### 1. **Persistent Location Storage** (`lib/providers/location_provider.dart`)

#### New Methods Added:

**`saveLocation(LocationResult location)`**
- Persists the user's selected location to local storage
- Stores as JSON with lat, lon, and displayName fields
- Called automatically when location is set via `setLocation()`, `requestGpsLocation()`, or `searchLocation()`

**`loadSavedLocation()`**
- Loads previously saved location from storage on app startup
- Returns `LocationResult?` - null if no saved location exists
- Used during splash screen to determine initial route

**`resetDebugData()`**
- Clears all persisted location data from storage
- Resets state to null
- Called when user presses **Ctrl+Delete** debug key combo

---

### 2. **Persistent Authentication Storage** (`lib/providers/auth_provider.dart`)

#### New Methods Added:

**`saveAuthStatus(bool isAuthenticated)`**
- Persists authentication status to local storage
- Stores simple boolean (true = authenticated, false = not)
- Called automatically when `login()`, `logout()`, or `signup()` is invoked

**`loadAuthStatus()`**
- Loads authentication status from storage on app startup
- Returns boolean - defaults to false if no data found
- Used during splash screen to determine initial route

**`resetDebugData()`**
- Clears persisted authentication status from storage
- Resets state to false
- Called when user presses **Ctrl+Delete** debug key combo

---

### 3. **Persistent Settings Storage** (`lib/providers/settings_provider.dart`)

#### New Methods Added:

**`loadFromStorage()`**
- Loads user preferences from local storage on app startup
- Retrieves: tempUnit, timeFormat, backgroundMode (all as integers)
- Returns nothing, updates state directly via `state = AppSettings(...)`
- Defaults to 0 for all fields if no saved data exists (0=Celsius, 0=24h, 0=realtime)
- Called automatically by SplashScreen during initialization

**`saveToStorage()`**
- Persists current settings state to local storage
- Automatically called after every state change (in setTempUnit, setTimeFormat, setBackgroundMode)
- Ensures settings persist across app restarts
- No manual save needed - happens automatically

**`resetDebugData()`**
- Clears all persisted settings from storage
- Resets state to `const AppSettings()` (all defaults)
- Called when user presses **Ctrl+Delete** debug key combo

#### Updated Methods:

**`setTempUnit(int unit)`**
- Now calls `saveToStorage()` automatically after state change
- No manual save needed

**`setTimeFormat(int format)`**
- Now calls `saveToStorage()` automatically after state change
- No manual save needed

**`setBackgroundMode(int mode)` [NEW]**
- Added method to update background display mode
- Automatically saves to storage

---

### 4. **Smart Initial Routing** (`lib/screens/splash_screen.dart`)

#### Updated to ConsumerStatefulWidget

The SplashScreen now extends `ConsumerStatefulWidget` instead of `StatefulWidget` to access Riverpod providers.

#### New Routing Logic (`_startApp()` method):

**Before** (Old Behavior):
```
Always → StartupScreen
```

**After** (New Behavior):
```
1. Check widget.reset flag
   ├─ YES → Show splash for 700ms → StartupScreen
   └─ NO → Load saved location & auth status
      ├─ Show splash for 2200ms
      ├─ Check conditions:
      │  ├─ (Saved Location EXISTS) AND (isAuthenticated == true)
      │  │  └─ → WeatherDisplayScreen (skip onboarding)
      │  └─ (No Location) OR (NOT authenticated)
      │     └─ → StartupScreen (show onboarding)
      └─ Navigate with fade transition
```

#### New Helper Methods:

**`_navigateToStartup()`**
- Navigates to StartupScreen with fade animation

**`_navigateToWeather()`**
- Navigates to WeatherDisplayScreen (if location is saved)
- Includes fallback safety check

**`_getWeatherScreenDynamic()`**
- Dynamic widget loader to avoid circular imports
- Returns appropriate widget based on saved location state

---

### 4. **Global Debug Reset Feature** (`lib/main.dart`)

#### Keyboard Listener Setup

**`_setupKeyboardListener()`**
- Initializes the keyboard event handler
- Called in initState
- Uses `ServicesBinding.instance.keyboard.addHandler()`

#### Key Press Handler

**`_handleKeyPress(KeyEvent event)`** [in `_globalKeyHandler()`]
- Monitors all key presses on desktop and mobile platforms
- Detects: **Ctrl+Delete** or **Ctrl+Backspace** combo
- Returns true when combo is detected (event consumed)
- Prints debug message: `[DEBUG] Global reset triggered: Ctrl+Delete`

**Key Detection Logic:**
```dart
isCtrlPressed = HardwareKeyboard.isControlPressed 
                OR HardwareKeyboard.isMetaPressed
isDeletKey = LogicalKeyboardKey.delete 
             OR LogicalKeyboardKey.backspace

if (isCtrlPressed && isDeletKey) {
  _performGlobalDebugReset()
}
```

#### Global Debug Reset Function

**`_performGlobalDebugReset()`**
- Executed when debug key combo detected (from main.dart)
- Performs 4 actions:
  1. Clears location data from SharedPreferences
  2. Clears auth data from SharedPreferences
  3. Clears settings data from SharedPreferences
  4. Navigates to SplashScreen with `reset: true` flag
- Prints debug messages for verification
- Useful for testing first-time user experience without clearing app manually

---

## Data Storage Details

### Storage Engine
- **Library**: `shared_preferences: ^2.2.2` (already in pubspec.yaml)
- **Platform**: Works on iOS, Android, Windows, Web
- **Storage Type**: Key-value persistent local storage

### Stored Keys

**Location Data:**
```
Key: "saved_location"
Value: JSON string
Example: {"lat": 31.5204, "lon": 74.3587, "displayName": "Lahore, Pakistan"}
```

**Authentication Status:**
```
Key: "is_authenticated"
Value: Boolean
Example: true
```

**Settings Data:**
```
Key: "tempUnit"
Value: Integer (0=Celsius, 1=Fahrenheit)
Example: 0

Key: "timeFormat"
Value: Integer (0=24h, 1=12h)
Example: 0

Key: "backgroundMode"
Value: Integer (0=realtime, 1=custom, 2=static)
Example: 0
```

---

## File Changes Summary

### Modified Files:

| File | Changes | Impact |
|------|---------|--------|
| `lib/providers/location_provider.dart` | Added `saveLocation()`, `loadSavedLocation()`, `resetDebugData()` | Automatic persistence + reset capability |
| `lib/providers/auth_provider.dart` | Added `saveAuthStatus()`, `loadAuthStatus()`, `resetDebugData()` | Automatic persistence + reset capability |
| `lib/providers/settings_provider.dart` | Added `loadFromStorage()`, `saveToStorage()`, `resetDebugData()` | Automatic persistence + reset capability |
| `lib/screens/splash_screen.dart` | Changed to ConsumerStatefulWidget, added routing logic, keyboard handler, debug reset | Smart routing based on saved data |
| `lib/main.dart` | Added imports, updated `_performGlobalDebugReset()` to clear settings keys | Global reset clears all persisted data |
| `pubspec.yaml` | No changes needed | shared_preferences already included |

### No Files Created
- ✅ Used existing provider structure
- ✅ No new imports needed (shared_preferences already in pubspec)
- ✅ No new routes or files created

---

## Usage Examples

### Example 1: User First Login Flow

```
1. User opens app (first time, no saved location)
   ↓
2. Splash screen loads saved location (returns null)
   ↓
3. Splash determines: No location → StartupScreen
   ↓
4. User signs up & searches for location
   ↓
5. Location selected via setLocation()
   ↓
6. saveLocation() automatically called
   ↓
7. User logs in
   ↓
8. saveAuthStatus(true) automatically called
   ↓
9. Navigation to WeatherDisplayScreen
```

### Example 2: User Returns After Closing App

```
1. User opens app (has saved location from before)
   ↓
2. Splash screen loads saved location (returns location object)
   ↓
3. loadAuthStatus() returns true (user was authenticated before)
   ↓
4. Splash determines: Location EXISTS + Authenticated
   ↓
5. Auto-navigate to WeatherDisplayScreen
   ↓
6. User sees current weather immediately (no onboarding)
```

### Example 3: Developer Testing with Debug Reset

```
1. User at any screen
   ↓
2. Press: Ctrl + Delete (on desktop)
   ↓
3. Both providers' resetDebugData() called
   ↓
4. shared_preferences keys removed
   ↓
5. State reset to null/false
   ↓
6. Auto-navigate to StartupScreen
   ↓
7. Fresh first-time-user experience
   ↓
(Useful for testing onboarding flow without data wipes)
```

---

## Key Features

### ✅ Automatic Persistence
- No manual "Save" button needed
- Data persists across app restarts
- Survives force-close and phone reboots

### ✅ Smart Routing
- Skips onboarding if user has saved location + auth
- Shows onboarding if any data is missing
- Respects `widget.reset` flag for forced startup

### ✅ Debug-Friendly Reset
- Quick test of first-time-user flow
- Keyboard shortcut (Ctrl+Delete) on desktop
- Console logging for verification
- Useful for QA and testing

### ✅ Error Handling
- Try-catch blocks around all storage operations
- Graceful fallbacks (returns null/false on error)
- Console error logs for debugging

### ✅ Type Safety
- Uses LocationResult model for location data
- JSON serialization/deserialization
- Riverpod's type-safe providers

---

## Testing the Feature

### Test 1: First Run Persistence

```
1. Run app → go through startup/login flow
2. Search and select a location → login
3. Close app completely
4. Reopen app
5. VERIFY: Should skip startup screen and show weather directly
6. Console should show: [ROUTING] Saved location found + authenticated → WeatherDisplayScreen
```

### Test 2: Debug Reset

```
1. App running, on any screen
2. Press: Ctrl + Delete (or Ctrl + Backspace)
3. Console should show:
   - [DEBUG] Reset key combo detected: Ctrl+Delete
   - [DEBUG] Performing full debug reset...
   - [DEBUG] Debug reset completed - navigating to StartupScreen
4. Should navigate to StartupScreen
5. Close and reopen app
6. VERIFY: Shows startup screen again (data was cleared)
```

### Test 3: Selective Login/Logout

```
1. Run app → complete login/location selection
2. Note: Weather screen is shown on next restart
3. From anywhere, logout (if implemented in SettingsScreen)
4. This calls authProvider.logout() → saveAuthStatus(false)
5. Close/reopen app
6. Should show StartupScreen (auth false, even with location)
```

---

## Future Enhancements

### Could Add:
1. **Encryption**: Use `flutter_secure_storage` for sensitive auth tokens
2. **Cloud Sync**: Sync saved location/prefs to user account
3. **Version Migration**: Handle schema changes across app versions
4. **Auto-Delete**: Clear old data after X days of inactivity
5. **Analytics**: Track user onboarding path decisions
6. **Settings UI**: Add "Clear All Data" button in settings screen

### Implementation Locations:
- Encryption: Import and replace SharedPreferences calls in providers
- Cloud Sync: Add `syncToCloud()` method to both providers
- Version Migration: Check storage version on `loadSavedLocation()`/`loadAuthStatus()`

---

## Architecture Diagram

```
SplashScreen (entry point)
    ├─ _setupKeyboardListener()
    │  └─ Monitors Ctrl+Delete presses
    │
    ├─ _startApp()
    │  ├─ Check widget.reset
    │  │  └─ YES → Show splash → _navigateToStartup()
    │  │
    │  └─ NO → Load saved data
    │     ├─ locationProvider.loadSavedLocation()
    │     ├─ authProvider.loadAuthStatus()
    │     └─ Determine route
    │        ├─ Location + Auth → _navigateToWeather()
    │        └─ Missing data → _navigateToStartup()
    │
    └─ _performDebugReset() [on Ctrl+Delete]
       ├─ locationProvider.resetDebugData()
       ├─ authProvider.resetDebugData()
       └─ _navigateToStartup()

LocationProvider (state management)
    ├─ saveLocation(location) → SharedPreferences
    ├─ loadSavedLocation() ← SharedPreferences
    └─ resetDebugData() → Clear SharedPreferences

AuthProvider (state management)
    ├─ saveAuthStatus(bool) → SharedPreferences
    ├─ loadAuthStatus() ← SharedPreferences
    └─ resetDebugData() → Clear SharedPreferences

SettingsProvider (state management)
    ├─ saveToStorage() → SharedPreferences (tempUnit, timeFormat, backgroundMode)
    ├─ loadFromStorage() ← SharedPreferences
    └─ resetDebugData() → Clear SharedPreferences

SharedPreferences (device storage)
    ├─ "saved_location": LocationResult JSON
    ├─ "is_authenticated": boolean
    ├─ "tempUnit": integer
    ├─ "timeFormat": integer
    └─ "backgroundMode": integer
```

---

## Console Output Reference

### Normal App Start (with saved location):
```
[ROUTING] Saved location found + authenticated → WeatherDisplayScreen
```

### App Start (first time or cleared):
```
[ROUTING] No saved location OR not authenticated → StartupScreen
```

### Debug Reset Triggered:
```
[DEBUG] Global reset triggered: Ctrl+Delete
[DEBUG] Performing global debug reset...
[DEBUG] SharedPreferences cleared successfully
[DEBUG] Navigated to SplashScreen with reset flag
```

### Error During Load:
```
Error loading location: FormatException: ...
Error loading auth status: ...
```

---

## Summary

This feature implements a robust persistent state system with:
- ✅ Automatic data saving to device storage
- ✅ Smart routing that detects saved user data
- ✅ Global debug reset for testing first-time flows
- ✅ Error handling and graceful fallbacks
- ✅ Console logging for verification
- ✅ No new files or major restructuring

The implementation integrates seamlessly into your existing Riverpod architecture and enhances the user experience by skipping onboarding for returning users while maintaining a simple way to test the first-time flow for developers.
