# Show the map in ZedEvents

The Map tab stays blank until you add a **Google Maps API key**.

## Steps

1. Open [Google Cloud Console](https://console.cloud.google.com/).
2. Create or select a project.
3. Enable **Maps SDK for Android** (and **Maps SDK for iOS** if you build for iOS):  
   APIs & Services → Library → search “Maps SDK for Android” → Enable.
4. Create an API key:  
   APIs & Services → Credentials → Create credentials → API key.
5. Add the key to your project:
   - Open **`android/local.properties`** (create it if needed).
   - Add this line (use your real key instead of `YOUR_KEY_HERE`):
   ```properties
   maps.api.key=YOUR_KEY_HERE
   ```
6. Rebuild and run the app:  
   `flutter run`

After this, the Map tab should show the map and event pins.
