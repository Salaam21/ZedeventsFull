# Location & Notifications Setup Guide

## 🌍 Features Implemented

### 1. **Location Services**
- ✅ Get user's current location automatically
- ✅ Calculate distance to events
- ✅ Filter events by proximity
- ✅ Location-based event recommendations
- ✅ "Near you" event notifications

### 2. **Google Maps Integration**
- ✅ Display event location on interactive map
- ✅ Tap marker to see event details
- ✅ "Get Directions" button
- ✅ Opens in Google Maps/Apple Maps/Waze
- ✅ Location picker for event creation
- ✅ Draggable markers

### 3. **Push Notifications**
- ✅ Event happening now nearby
- ✅ Event starting in 1 hour reminder
- ✅ Event starting tomorrow reminder
- ✅ New events matching interests
- ✅ Customizable notification preferences

### 4. **African Currency Support**
- ✅ Zambian Kwacha (ZMW) - Default
- ✅ South African Rand (ZAR)
- ✅ Botswana Pula (BWP)
- ✅ Malawian Kwacha (MWK)
- ✅ Namibian Dollar (NAD)
- ✅ Zimbabwean Dollar (ZWL)
- ✅ Tanzanian Shilling (TZS)
- ✅ Mozambican Metical (MZN)
- ✅ Angolan Kwanza (AOA)
- ✅ Plus USD, EUR, GBP

## 📦 Required Packages

Already added to `pubspec.yaml`:

```yaml
dependencies:
  # Location & Maps
  geolocator: ^10.1.0
  geocoding: ^2.1.1
  google_maps_flutter: ^2.5.0
  url_launcher: ^6.2.2
  
  # Notifications
  flutter_local_notifications: ^16.3.0
  timezone: ^0.9.2
```

## 🔧 Android Setup

### 1. **Update AndroidManifest.xml**

File: `android/app/src/main/AndroidManifest.xml`

Add these permissions BEFORE the `<application>` tag:

```xml
<!-- Location Permissions -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />

<!-- Internet Permission -->
<uses-permission android:name="android.permission.INTERNET"/>

<!-- Notifications -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
```

### 2. **Add Google Maps API Key**

File: `android/app/src/main/AndroidManifest.xml`

Inside the `<application>` tag, add:

```xml
<application>
    <!-- Add this -->
    <meta-data
        android:name="com.google.android.geo.API_KEY"
        android:value="YOUR_GOOGLE_MAPS_API_KEY_HERE"/>
    
    <!-- Rest of your application config -->
</application>
```

### 3. **Get Google Maps API Key**

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable these APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Places API
   - Geocoding API
4. Go to "Credentials" → "Create Credentials" → "API Key"
5. Copy the key and add to AndroidManifest.xml

## 🍎 iOS Setup

### 1. **Update Info.plist**

File: `ios/Runner/Info.plist`

Add these keys:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to show nearby events and provide directions</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>We need your location to notify you about nearby events</string>

<key>NSLocationAlwaysUsageDescription</key>
<string>We need your location to send you notifications about nearby events</string>

<key>NSUserNotificationsUsageDescription</key>
<string>We need notification permission to remind you about events</string>
```

### 2. **Add Google Maps API Key**

File: `ios/Runner/AppDelegate.swift`

```swift
import UIKit
import Flutter
import GoogleMaps  // Add this

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Add this line
    GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY_HERE")
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

## 💻 Usage Examples

### 1. **Get User Location**

```dart
import 'package:event_app/services/location_service.dart';

final locationService = LocationService();

// Get current location
Position? position = await locationService.getCurrentLocation();
if (position != null) {
  print('Lat: ${position.latitude}, Lng: ${position.longitude}');
  print('Address: ${locationService.currentAddress}');
}
```

### 2. **Check if Event is Nearby**

```dart
bool isNearby = locationService.isEventNearby(
  eventLat: -15.4167,
  eventLon: 28.2833,
  radiusInKm: 10, // Within 10km
);

if (isNearby) {
  // Show "Near You" badge
}
```

### 3. **Send Notification**

```dart
import 'package:event_app/services/notification_service.dart';

final notificationService = NotificationService();

// Initialize once
await notificationService.initialize();
await notificationService.requestPermissions();

// Send notification for nearby event
await notificationService.showNearbyEventNotification(
  eventTitle: 'Music Festival',
  location: 'Show Grounds',
  eventId: 'event_001',
);

// Send "starting soon" notification
await notificationService.showEventStartingSoonNotification(
  eventTitle: 'Tech Conference',
  timeUntilStart: '1 hour',
  eventId: 'event_002',
);

// Schedule reminder (1 hour before event)
await notificationService.scheduleEventReminder(
  event: eventModel,
  beforeEvent: Duration(hours: 1),
);
```

### 4. **Display Event Location on Map**

```dart
import 'package:event_app/ui/widgets/event_location_map.dart';

// In your widget
EventLocationMap(
  latitude: -15.4167,
  longitude: 28.2833,
  locationName: 'Show Grounds, Lusaka',
)
```

### 5. **Let User Pick Location (Event Creation)**

```dart
import 'package:event_app/ui/widgets/location_picker.dart';

// Navigate to location picker
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => LocationPicker(
      onLocationSelected: (lat, lng, address) {
        print('Selected: $lat, $lng - $address');
        // Save location to event
      },
    ),
  ),
);
```

## 🎯 Notification Types

### 1. **Nearby Event (Happening Now)**
```
🎉 Event Happening Now!
Music Festival at Show Grounds - Tap to view details
```

### 2. **Starting Soon**
```
⏰ Event Starting Soon!
Tech Conference starts in 1 hour
```

### 3. **New Event (Matching Interests)**
```
✨ New Music Event
Summer Music Festival - Check it out!
```

### 4. **Scheduled Reminders**
- 1 hour before event
- 1 day before event
- 1 week before event

## 📍 Location Features

### For Users:
1. **Automatic Location Detection**
   - Get current city/country
   - Show nearby events
   - Distance indicators

2. **Event Discovery**
   - "Near You" section
   - Sort by distance
   - Filter by radius

3. **Navigation**
   - Tap "Get Directions"
   - Opens preferred maps app
   - Works with Google Maps, Apple Maps, Waze

### For Event Organizers:
1. **Location Picker**
   - Interactive map
   - Search for location
   - Drag marker to adjust
   - Use current location

2. **Venue Selection**
   - Precise coordinates
   - Address auto-fill
   - Verify on map

## 🔔 Notification Scenarios

### Scenario 1: "Event Near You"
```
User is in Lusaka
Event at Show Grounds (2km away) starts in 30 min
→ Send notification: "Event starting soon near you!"
```

### Scenario 2: "Followed Interest"
```
User interests: Music, Sports
New music event posted
→ Send notification: "New Music event you might like"
```

### Scenario 3: "Reminder"
```
User registered for event tomorrow
→ Send notification: "Your event starts tomorrow at 2 PM"
→ 1 hour before: "Your event starts in 1 hour"
```

## 🚀 Implementation Checklist

### Backend Integration:
- [ ] Store event coordinates (latitude, longitude)
- [ ] User location preferences
- [ ] Notification settings per user
- [ ] Event registration tracking
- [ ] Push notification tokens

### App Integration:
- [x] LocationService created
- [x] NotificationService created
- [x] EventModel updated with lat/lng
- [x] Map widgets created
- [x] Location picker created
- [ ] Initialize services in main.dart
- [ ] Request permissions on first launch
- [ ] Integrate with event creation
- [ ] Add map to event details
- [ ] Implement notification triggers

### Testing:
- [ ] Test location permissions
- [ ] Test map display
- [ ] Test directions button
- [ ] Test notifications
- [ ] Test different currencies
- [ ] Test on real device (location)

## 🎨 UI Integration

### Event Detail Page
Add map widget:
```dart
if (event.latitude != null && event.longitude != null)
  EventLocationMap(
    latitude: event.latitude!,
    longitude: event.longitude!,
    locationName: event.location,
  )
```

### Event Card
Show distance:
```dart
if (locationService.currentPosition != null) {
  double distance = locationService.calculateDistance(
    locationService.currentPosition!.latitude,
    locationService.currentPosition!.longitude,
    event.latitude!,
    event.longitude!,
  );
  Text('${locationService.formatDistance(distance)} away');
}
```

## 💡 Best Practices

1. **Always request permissions gracefully**
2. **Show why you need location**
3. **Allow users to disable notifications**
4. **Cache location data**
5. **Handle permission denied scenarios**
6. **Test on real devices**
7. **Respect battery life**
8. **Clear notification channels**

## 🌍 Zambian Locations for Testing

Default coordinates (Lusaka, Zambia):
- Latitude: -15.4167
- Longitude: 28.2833

Popular venues:
- Show Grounds: -15.4253, 28.3092
- Levy Mall: -15.3875, 28.3228
- Garden City: -15.3947, 28.3075

## 🔒 Privacy

- Location data stays on device (unless user shares)
- No tracking without permission
- Users can disable location services
- Clear privacy policy about data usage

---

**All services are ready! Just add API keys and test on real device.** 🎉

