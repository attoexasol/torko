# Firebase iOS setup – production checklist

Use these steps to get the app building and running without Firebase errors.

---

## 1. Verify Firebase iOS setup

- **GoogleService-Info.plist** is in `ios/Runner/` and is included in the **Runner** target’s **Copy Bundle Resources** (already done in this project).
- **Bundle ID** in Xcode must match the **BUNDLE_ID** in `GoogleService-Info.plist`.  
  Current value: **com.attoexasolutions.torko**.

---

## 2. GoogleService-Info.plist in Runner target

Already configured:

- File reference and “Copy Bundle Resources” build phase include `GoogleService-Info.plist`.
- If you replace the file (e.g. after adding a new iOS app in Firebase), keep the same filename and location: `ios/Runner/GoogleService-Info.plist`.

---

## 3. Firebase initialization in main.dart

Already done:

- `lib/main.dart` calls `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`.
- `lib/firebase_options.dart` provides platform-specific options (iOS and Android).

---

## 4. FlutterFire CLI configuration

To regenerate `lib/firebase_options.dart` from your Firebase project:

```bash
# From project root
dart run flutterfire_cli:flutterfire configure
```

Requirements:

- Firebase CLI: `npm install -g firebase-tools` then `firebase login`
- Select the same Firebase project (e.g. **torko-ad923**) and ensure the iOS app bundle ID is **com.attoexasolutions.torko**.

After running, replace or merge the generated `lib/firebase_options.dart` if you need to keep any manual edits.

---

## 5. Pod installation (iOS)

From the **project root**:

```bash
flutter pub get
cd ios
pod install
cd ..
```

If `pod install` fails:

```bash
sudo gem install cocoapods
pod repo update
cd /path/to/torko/ios
pod install
cd ..
```

The Podfile already has `platform :ios, '15.0'` (required for Firebase/cloud_firestore).

---

## 6. Bundle identifier and Firebase Console

- **Xcode Runner target:** `PRODUCT_BUNDLE_IDENTIFIER = com.attoexasolutions.torko`
- **GoogleService-Info.plist:** `BUNDLE_ID` = **com.attoexasolutions.torko**
- **Firebase Console:** In [Firebase Console](https://console.firebase.google.com/) → Project **torko-ad923** → Project settings → Your apps, the iOS app must use bundle ID **com.attoexasolutions.torko**. If you had **com.example.torko**, add a new iOS app with **com.attoexasolutions.torko** and download the new **GoogleService-Info.plist** into `ios/Runner/`.

---

## 7. Push Notifications capability (Xcode)

Already configured in the project:

- **Runner.entitlements** exists at `ios/Runner/Runner.entitlements` with `aps-environment` = `development`.
- The Runner target’s **Code Signing Entitlements** is set to **Runner/Runner.entitlements** for Debug, Profile, and Release.

In Xcode you should still add the capability so the UI matches:

1. Open `ios/Runner.xcworkspace` in Xcode.
2. Select the **Runner** target.
3. **Signing & Capabilities** → **+ Capability** → **Push Notifications**.
4. Optionally add **Background Modes** and enable **Remote notifications**.

---

## 8. Build and run (no Firebase errors)

From the **project root**:

```bash
# Clean and get deps
flutter clean
flutter pub get

# iOS pods
cd ios
pod install
cd ..

# Run on iOS device or simulator
flutter run -d ios
```

Or run on a specific device:

```bash
flutter devices
flutter run -d <device_id>
```

To open in Xcode and run from there:

```bash
open ios/Runner.xcworkspace
```

---

## Quick verification

After `flutter run -d ios`:

- No “Could not locate configuration file: 'GoogleService-Info.plist'”.
- No “[core/not-initialized] Firebase has not been correctly initialized”.
- Push: “no valid aps-environment entitlement” should be resolved; if you still see it, confirm in Xcode that the Runner target has the **Push Notifications** capability and that **Runner.entitlements** is used (Signing & Capabilities or Build Settings → Code Signing Entitlements).

---

## Summary of file changes made

| Item | Change |
|------|--------|
| **ios/Runner/GoogleService-Info.plist** | BUNDLE_ID set to **com.attoexasolutions.torko** (was com.example.torko). |
| **ios/Runner.xcodeproj** | GoogleService-Info.plist added to Runner group and Copy Bundle Resources. |
| **ios/Runner/Runner.entitlements** | New file with **aps-environment** = development. |
| **ios/Runner.xcodeproj** | CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements for Debug/Profile/Release. |
| **lib/firebase_options.dart** | New file with iOS/Android FirebaseOptions. |
| **lib/main.dart** | Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform) and _initializeFirebase(). |
| **pubspec.yaml** | dev_dependency **flutterfire_cli** added. |
