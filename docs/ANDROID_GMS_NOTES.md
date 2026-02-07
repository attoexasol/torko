# Android GMS / Google Play Services Notes

## Known Emulator/Device Warnings

The following logs may appear in Android debug output. They are **not app bugs** and typically do not affect functionality:

| Log / Error | Cause | Mitigation |
|-------------|-------|------------|
| `GoogleApiManager` / `FlagRegistrar` | Play Services internal initialization | Ignore; no code fix available |
| `DEVELOPER_ERROR` (12501 etc.) | Emulator often lacks valid Play Services config; or SHA-1 not registered in Firebase Console | Use physical device for full testing; ensure SHA-1/SHA-256 from `keytool` are added in Firebase project settings |
| `Google Play services out of date` | Emulator image or device has outdated GMS | Update emulator system image or device Play Services |

## App Safeguards

- **No hardcoded SHA-1/SHA-256** in code.
- **applicationId** is read from `build.gradle.kts` (not hardcoded).
- If Play Services is missing/outdated, Firebase Auth and Firestore may fail; the app handles these as network/permission errors and shows user-safe messages.

## Recommendation

For production: test on physical devices with up-to-date Google Play Services. Emulator warnings can be filtered in logcat if they pollute debug flow.
