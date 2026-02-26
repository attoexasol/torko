# iOS setup checklist (Torko)

## 1. Navigate to iOS folder

```bash
cd ios
```

## 2. Install CocoaPods

```bash
pod install
```

If `pod` fails:

```bash
sudo gem install cocoapods
pod repo update
pod install
```

## 3. iOS platform (already set)

The Podfile uses **platform :ios, '15.0'** (required for Firebase/cloud_firestore).  
If you ever change it, ensure **≥ 12.0**. Then run:

```bash
pod install
```

## 4. Open Xcode workspace

Always open the **workspace**, not the `.xcodeproj`:

```bash
open Runner.xcworkspace
```

## 5. Enable Capabilities (Xcode)

- Select the **Runner** target.
- Open **Signing & Capabilities**.
- **+ Capability** and add:
  - **Push Notifications**
  - **Background Modes**  
    - Check **Remote notifications**  
    - Check **Background fetch** (if needed)

## 6. Bundle identifier & Firebase

- **Bundle ID in this project:** `com.attoexasolutions.torko`
- It must match:
  - The **iOS app** in [Firebase Console](https://console.firebase.google.com/) (project: **torko-ad923**).
  - The **BUNDLE_ID** inside **GoogleService-Info.plist**.

Put **GoogleService-Info.plist** in `ios/Runner/` (downloaded from Firebase → Project settings → Your apps → iOS app).  
The Xcode project is already set to include it in the app.

## 7. Firebase init in Flutter

Already done in `lib/main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // ...
}
```

## 8. Network (HTTP)

**NSAppTransportSecurity** is already added in `ios/Runner/Info.plist` so non-HTTPS APIs can be used if needed.

## 9. Clean and run

From the **project root** (not `ios/`):

```bash
flutter clean
flutter pub get
cd ios
pod install
cd ..
flutter run -d ios
```

To pick a specific device/simulator:

```bash
flutter devices
flutter run -d <device_id>
```

## 10. Verify Auth & Firestore

In Flutter you can confirm the current user:

```dart
print(FirebaseAuth.instance.currentUser?.uid);
```

Ensure it is not `null` when you expect a signed-in user.
