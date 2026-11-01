# EV-M+REW Connector

Flutter app: pick a location -> see nearby EV chargers (closest first) -> check port availability -> get directions.

## 1. Install
1. Install Flutter (https://docs.flutter.dev/get-started/install) and run `flutter doctor`.
2. Install VS Code with the "Flutter" and "Dart" extensions.

## 2. Create platform folders (one time)
This project contains `lib/` and `pubspec.yaml`. From the project folder run:

    flutter create --project-name ev_mrew_connector --org com.example .
    flutter pub get

`flutter create .` keeps your existing `lib/` and `pubspec.yaml`; if it asks about overwriting, say no.

## 3. Permissions
Android: `android/app/src/main/AndroidManifest.xml`, inside `<manifest>` and above `<application>`:

    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    <queries>
      <intent><action android:name="android.intent.action.VIEW"/><data android:scheme="https"/></intent>
    </queries>

iOS: `ios/Runner/Info.plist`, inside `<dict>`:

    <key>NSLocationWhenInUseUsageDescription</key>
    <string>We use your location to find nearby EV charging stations.</string>
    <key>LSApplicationQueriesSchemes</key>
    <array><string>https</string></array>

## 4. Maps (OpenStreetMap, no key needed)
The map uses `flutter_map` with OpenStreetMap tiles. Change `userAgentPackageName` in `location_screen.dart` to your app id. OSM's public tile server is for light use; use a dedicated tile provider for production.

## 5. Real charging station data (Open Charge Map)
1. Create a free account at https://openchargemap.org and request an API key (My Profile -> My Apps).
2. Run with the key:

       flutter run --dart-define=OCM_API_KEY=YOUR_KEY

Without a key the app shows clearly labelled SAMPLE stations.

## 6. Run in VS Code
1. File -> Open Folder, choose this project.
2. Pick a device in the bottom-right (Android emulator, iOS simulator, or a connected phone).
3. Press F5 or run `flutter run`. To pass the key from VS Code, add
   `"args": ["--dart-define=OCM_API_KEY=YOUR_KEY"]` to your configuration in `.vscode/launch.json`.

GPS and address lookup work on Android/iOS. On web/desktop, use map tap instead.

## About availability data
Open Charge Map does not provide live occupancy, so the app shows:
- Out of service: real, from the listing.
- Available / Occupied: an ESTIMATE (stable pseudo-random), labelled on screen.
- Sample mode: everything is demo data, labelled on screen.
Real-time data needs an operator/network API or your own Firestore data.

## Firebase (optional, not wired in yet)
Create a Firebase project, run `dart pub global activate flutterfire_cli` then `flutterfire configure`, add `firebase_core` and `cloud_firestore`, and read a `stations` collection in `StationService.fetch` as another data source (mark those ports as live).
