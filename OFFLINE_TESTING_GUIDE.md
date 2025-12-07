# Quick Start: Testing Offline Weather

## 🚀 One-Minute Setup

### 1. Install the Package
```bash
cd hawahawa
flutter pub get
```

### 2. Run the App
```bash
flutter run
```

---

## 📱 Test 1: Normal Operation (Online)

### Steps:
1. Make sure internet is ON
2. Open app
3. Select a location (e.g., "Lahore")
4. View weather for 5 seconds
5. Note the current temperature

### Expected:
- ✅ Weather displays immediately
- ✅ NO orange badge at top
- ✅ Console shows: `[WEATHER] Data fetched and cached`

---

## 📴 Test 2: View Cached Data (Offline)

### Steps:
1. App running with weather loaded
2. Turn OFF WiFi/Internet
3. Close app completely
4. Reopen app
5. Weather should display

### Expected:
- ✅ Weather displays (same as before)
- ✅ Orange badge at top: "☁️ No Connection • Data Cached"
- ✅ Console shows: `[WEATHER] Offline - attempting to load from cache`
- ✅ Console shows: `[WEATHER] Loaded from cache (offline)`

---

## 🔄 Test 3: Switch Between Online/Offline

### Steps:
1. Open app (online) → Weather loads fresh
2. Note: NO orange badge
3. Turn OFF WiFi
4. Close and reopen app
5. Orange badge appears
6. Turn ON WiFi
7. Close and reopen app
8. Orange badge disappears
9. Fresh weather displays

### Expected:
- ✅ Badge appears/disappears correctly
- ✅ Data persists across offline periods
- ✅ Fresh data refetches when online

---

## 🧹 Test 4: First-Time Offline (No Cache)

### Steps:
1. Clear app data from Settings:
   - Android: Settings > Apps > Hawahawa > Clear Cache & Clear Data
   - iOS: Settings > General > iPhone Storage > Hawahawa > Offload/Delete
2. Turn OFF WiFi
3. Open app
4. Select location (won't work - offline)
5. App should show default weather

### Expected:
- ✅ Default weather displays (20°C, clear sky)
- ✅ Orange badge shows
- ✅ Console shows: `[WEATHER] Using default weather (offline, no cache)`

### Then:
1. Turn ON WiFi
2. Try selecting location again
3. Weather should load and cache

---

## 🐛 Test 5: Debug Reset

### Steps:
1. App running at any screen
2. Press **Ctrl+Delete** (or Ctrl+Backspace)
3. App navigates to Splash → Startup
4. Close and reopen

### Expected:
- ✅ Console shows: `[DEBUG] Performing global debug reset...`
- ✅ Navigates to Startup screen
- ✅ All cached data cleared
- ✅ Settings reset to defaults
- ✅ Location cleared

---

## 📊 Console Output Reference

### Online Success:
```
[WEATHER] Online - fetching from API
[WEATHER CACHE] Weather report cached successfully
[WEATHER] Data fetched and cached
[WEATHER] Loaded from storage: tempUnit=0, timeFormat=0, backgroundMode=0
```

### Offline:
```
[WEATHER] Offline - attempting to load from cache
[WEATHER CACHE] Cached weather loaded successfully
[WEATHER] Loaded from cache (offline)
```

### Offline (No Cache):
```
[WEATHER] Offline - attempting to load from cache
[WEATHER CACHE] No cached weather found
[WEATHER] Using default weather (offline, no cache)
```

### API Error:
```
[WEATHER] Online - fetching from API
[WEATHER ERROR] API call failed: SocketException: Failed host lookup
[WEATHER CACHE] Cached weather loaded successfully
[WEATHER] Loaded from cache due to API error
```

---

## 🎯 What to Verify

- [ ] Online mode shows weather (no badge)
- [ ] Offline mode shows cached weather + badge
- [ ] Badge appears when offline
- [ ] Badge disappears when reconnected
- [ ] Default weather shows on first offline use
- [ ] Switching locations still works online
- [ ] Settings persist across offline
- [ ] Debug reset (Ctrl+Delete) works
- [ ] App never crashes (always has fallback)
- [ ] Console logs make sense

---

## 🚨 Troubleshooting

**Weather not showing offline?**
- Make sure you loaded weather online first
- Check: Settings > Apps > Hawahawa > Permissions > Storage (Android)
- Clear app cache and try again with WiFi first

**Orange badge always showing?**
- Turn WiFi on, close/reopen app
- If still there, might be API down (check network)
- Badge should disappear after 1-2 restarts when online

**Debug reset not working?**
- Try: Ctrl+Delete or Ctrl+Backspace
- Make sure you're NOT in a text field
- Try from any screen (splash, weather, settings)

**Default weather never shows?**
- First-time offline requires clearing cache
- Or: Use airplane mode when opening for first time
- Then turn WiFi on to load real weather

---

## ✨ Success Criteria

Your offline implementation is working if:

1. ✅ App works online (fresh weather, no badge)
2. ✅ App works offline (cached weather, orange badge)
3. ✅ App works offline first-time (default weather, orange badge)
4. ✅ Badge shows/hides appropriately
5. ✅ No crashes under any condition
6. ✅ Location persists through offline periods
7. ✅ Debug reset clears everything
8. ✅ Settings persist through offline

You're done! 🎉
