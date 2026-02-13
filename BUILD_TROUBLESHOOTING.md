# Build & Run Troubleshooting Guide

## ✅ **Fixed Issues**

### 1. ~~Gradle Plugin Error~~ - **FIXED** ✅
**Error:** "only buildscript {}, pluginManagement {} ... are allowed before plugins {} blocks"

**Fix Applied:** Moved `plugins {}` block to the top of `android/app/build.gradle`

**Status:** ✅ Ready to build

---

## 🚀 **How to Run the App**

### **Option 1: Run on Chrome (Web) - Fastest**
```bash
flutter run -d chrome
```
✅ No setup needed
✅ Works immediately
⚠️ Limited features (no location/maps on web)

### **Option 2: Run on Android Emulator**
```bash
flutter run
# Select your Android emulator
```
✅ Full features available
⚠️ Requires emulator running

### **Option 3: Run on Physical Device**
```bash
flutter run
# Select your connected device
```
✅ Best for testing location/maps
✅ Real GPS data

---

## 📱 **Current Status**

### ✅ **Working:**
- Gradle configuration fixed
- All packages installed
- App compiles successfully
- Ready to run on all platforms

### ⚠️ **Requires Setup (Optional):**
- Google Maps API key (for maps features)
- Location permissions (Android/iOS)
- Notification setup (for push notifications)

---

## 🗺️ **Google Maps Setup (Optional)**

Maps features will work without API key in development, but for production:

### **Get API Key:**
1. Visit: https://console.cloud.google.com/
2. Create project
3. Enable "Maps SDK for Android" and "Maps SDK for iOS"
4. Create API key

### **Add to Android:**
File: `android/app/src/main/AndroidManifest.xml`

Add inside `<application>` tag:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE"/>
```

### **Add Permissions:**
Add before `<application>` tag:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

---

## 🔔 **Notification Setup (Optional)**

For push notifications to work:

### **Android:**
File: `android/app/src/main/AndroidManifest.xml`

Add permissions:
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.VIBRATE" />
```

---

## 🐛 **Common Issues & Fixes**

### **Issue 1: Gradle Build Failed**
```
Solution:
flutter clean
flutter pub get
flutter run
```

### **Issue 2: Maps Not Showing**
```
Cause: Missing API key or permissions
Solution: Add API key to AndroidManifest.xml
```

### **Issue 3: Location Not Working**
```
Cause: Missing permissions or emulator GPS
Solution 1: Add location permissions to AndroidManifest.xml
Solution 2: Set emulator GPS location in extended controls
```

### **Issue 4: "SDK not found" errors**
```
Solution:
1. Check flutter doctor
2. Ensure Android SDK installed
3. Run: flutter doctor --android-licenses
```

### **Issue 5: Package conflicts**
```
Solution:
flutter pub cache clean
flutter pub get
```

---

## 🧪 **Testing Without Full Setup**

### **Test on Chrome (Web):**
✅ All UI works
✅ Navigation works
✅ Data displays
⚠️ Maps show placeholder
⚠️ Location features disabled

### **Test on Android Emulator:**
✅ Full app functionality
✅ Can simulate GPS
✅ Test notifications
⚠️ Need to set GPS in emulator

### **Test on Real Device:**
✅ Real GPS data
✅ Real notifications
✅ Best user experience
✅ Test in Lusaka, Zambia!

---

## 📋 **Quick Commands**

```bash
# Check everything is OK
flutter doctor

# Clean and rebuild
flutter clean && flutter pub get && flutter run

# Run on specific device
flutter devices  # List devices
flutter run -d chrome  # Run on Chrome
flutter run -d <device-id>  # Run on specific device

# Build release
flutter build apk  # Android
flutter build ios  # iOS

# Check for issues
flutter analyze

# See installed packages
flutter pub deps
```

---

## 🎯 **What Works Right Now**

Even without Google Maps API key:

✅ **All Pages:**
- Home with events
- Search functionality
- Event details
- Create event
- Profile & Settings
- Login/Signup

✅ **All Features:**
- Event browsing
- Category filtering
- Interest selection
- Event creation
- Profile management
- Settings (including currency)
- Navigation between pages

⏳ **Needs API Key:**
- Interactive Google Maps
- "Get Directions" button
- Location picker with map

⏳ **Needs Real Device:**
- GPS location
- Push notifications
- Camera (for profile picture)

---

## 💡 **Pro Tips**

### **For Fast Development:**
1. Use **Chrome** for UI testing (instant hot reload)
2. Use **Android Emulator** for feature testing
3. Use **Real Device** for final testing

### **For Debugging:**
```bash
# Verbose output
flutter run -v

# Check what's wrong
flutter doctor -v

# See all logs
flutter logs
```

### **For Clean Builds:**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

---

## 🇿🇲 **Testing in Zambia**

### **Set Emulator Location to Lusaka:**
1. Open Android Emulator
2. Click "..." (More) → Location
3. Set coordinates:
   - Latitude: -15.4167
   - Longitude: 28.2833
4. Click "Send"

### **Test Venues:**
- Show Grounds: -15.4253, 28.3092
- Levy Mall: -15.3875, 28.3228
- Garden City: -15.3947, 28.3075

---

## 🎉 **Summary**

### **Current Status:**
✅ App builds successfully
✅ All packages installed
✅ Gradle configuration fixed
✅ Ready to run on all platforms

### **To Test Full App:**
1. Run on Chrome for quick UI test
2. Add Google Maps API key (optional)
3. Run on Android/iOS for full features
4. Test on real device in Zambia

### **Everything Works Without Setup:**
- Event browsing ✅
- Search & filter ✅
- Event creation ✅
- Profile & settings ✅
- Navigation ✅
- Currency (ZMW) ✅

**Your app is ready to run!** 🚀

---

## 📞 **Need Help?**

Check these files:
- `QUICK_START.md` - Basic running instructions
- `LOCATION_NOTIFICATIONS_SETUP.md` - Maps & notifications
- `FINAL_FEATURES_SUMMARY.md` - All features
- `README_MARKETPLACE.md` - Complete documentation

**Just run:** `flutter run` and start testing! 🎊

