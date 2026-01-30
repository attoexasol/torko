# Building Torko on Low-Memory Machines

Gradle JVM OOM has been addressed via `android/gradle.properties` (reduced heap, Serial GC, 256m metaspace, optional daemon off). If you see **`java.lang.OutOfMemoryError: Metaspace`** and "daemon disappeared", `MaxMetaspaceSize` was too low — it’s now 256m. If **Flutter/Dart** hits "Out of memory" during `flutter run` (e.g. in `zone.cc` or "AllocateRegisters"), the Dart VM is running out of memory during debug JIT compilation.

## 1. Try Release Build (often uses less memory than debug)

```bash
flutter build apk
```

Install the APK on the device manually (e.g. copy from `build/app/outputs/flutter-apk/app-release.apk`). Release uses AOT compilation and typically has lower peak memory than `flutter run` (debug JIT).

## 2. Free Memory Before Building

- Close browsers, Android Studio, and other heavy apps.
- Run only terminal + IDE (or just terminal) when running `flutter run` or `flutter build apk`.

## 3. Increase Windows Paging File

1. **System Properties** → **Advanced** → **Performance** → **Settings** → **Advanced** → **Virtual memory** → **Change**.
2. Uncheck "Automatically manage paging file."
3. Select the drive where your project lives → **Custom size**:
   - **Initial**: 4096 MB  
   - **Maximum**: 8192 MB (or higher if you have disk space)
4. **Set** → **OK** → restart Windows.

## 4. If `flutter run` Still OOMs

- Use **`flutter build apk`** for regular development; install the APK and test on device. Use **hot reload** only when you have a machine with more RAM.
- Or build on another PC / CI with more RAM, then copy the APK to your machine.

## 5. Gradle Settings (reference)

Current `android/gradle.properties` uses low JVM limits. If you have 8GB+ RAM and builds are slow, you can increase them again (e.g. `-Xmx2G`, `-XX:MaxMetaspaceSize=512m`) and re-enable the daemon.
