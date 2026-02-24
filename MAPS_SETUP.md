# Map in ZedEvents (free – no API key)

The Map tab uses **OpenStreetMap** via the `flutter_map` package. No API key or billing is required.

## What’s included

- **Events map tab:** Event pins on an OSM map; tap a pin for the event card, directions, and add to calendar.
- **Location picker:** Tap the map to choose a location when creating an event.
- **Event location map:** Small map preview with “Get directions” (opens Google Maps or device maps app).

## Optional: restrict to Wi‑Fi for tiles

If you want to avoid using mobile data for map tiles, you can add logic (e.g. connectivity checks) so that tiles load only on Wi‑Fi. The app does not enforce this by default.

## Optional: switch back to Google Maps

If you later want Google Maps again:

1. Add `google_maps_flutter` to `pubspec.yaml` and remove `flutter_map` and `latlong2`.
2. Create a Google Cloud API key and enable **Maps SDK for Android** (and iOS if needed).
3. Put the key in `android/local.properties` as `maps.api.key=YOUR_KEY`.
4. Revert the map screens and widgets to use `GoogleMap` and the previous setup.

Current setup is **fully free** with no API key.
