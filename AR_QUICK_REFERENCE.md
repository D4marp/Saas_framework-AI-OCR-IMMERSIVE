# Quick Reference - AR Setup Checklist

## 🚀 Pre-Launch Checklist

### General Setup
- [ ] Run `flutter pub get`
- [ ] Run `flutter clean`
- [ ] Run `flutter analyze` → 0 errors
- [ ] Run `flutter test` → all pass
- [ ] Check pubspec.yaml versions:
  - ar_flutter_plugin_engine: ^1.0.1 ✅
  - permission_handler: ^10.4.5 ✅
  - flutter: ^3.9.0 ✅

---

## 📱 Android Checklist

### Native Setup
- [ ] Edit `android/app/build.gradle`
  - [ ] `compileSdk 34`
  - [ ] `minSdkVersion 21`
  - [ ] Add ARCore dependency

- [ ] Edit `android/app/src/main/AndroidManifest.xml`
  - [ ] Add `<uses-permission android:name="android.permission.CAMERA" />`
  - [ ] Add `<uses-feature android:name="android.hardware.camera.ar" />`
  - [ ] Add location permissions (if needed)

### Permission Runtime
- [ ] Call `requestCameraPermission()` before AR init
- [ ] Verify `permission_handler: ^10.4.5` in pubspec.yaml
- [ ] Handle permission denied gracefully

### Build & Test
```bash
flutter pub get
flutter analyze
flutter run -d <android-device>
```

### Runtime Testing
- [ ] App opens without crash
- [ ] Permissions dialog appears
- [ ] Camera preview shows
- [ ] Planes detected within 3 sec
- [ ] Can tap to place objects
- [ ] Objects transform correctly

---

## 🍎 iOS Checklist

### Native Setup
- [ ] Edit `ios/Podfile`
  - [ ] Add post_install hook with GCC_PREPROCESSOR_DEFINITIONS
  - [ ] Include PERMISSION_CAMERA=1, etc.

- [ ] Edit `ios/Runner/Info.plist`
  - [ ] Add NSCameraUsageDescription
  - [ ] Add NSLocationWhenInUseUsageDescription (if needed)
  - [ ] Add NSMotionUsageDescription
  - [ ] Verify App Transport Security

### Pod Install
```bash
cd ios
pod install --repo-update
cd ..
```

### Build & Test
```bash
flutter pub get
flutter analyze
flutter run -d <ios-device>
```

### Runtime Testing
- [ ] App opens without crash
- [ ] Permissions dialog appears
- [ ] ARKit session initializes
- [ ] Planes detected
- [ ] Objects placed correctly
- [ ] Lighting estimation works

---

## 🌐 Web Checklist

### Setup
- [ ] Edit `web/index.html`
  - [ ] Add Babylon.js CDN
  - [ ] Add WebXR Polyfill CDN
  - [ ] Add canvas element with ID="canvas"
  - [ ] Add status divs for debugging

### Browser Support
- [ ] Chrome 79+ ✅
- [ ] Firefox 55+ ✅
- [ ] Edge 79+ ✅
- [ ] Safari (experimental)

### Build & Test
```bash
flutter run -d chrome --web-renderer=canvaskit
# atau
flutter build web --release
```

### Runtime Testing
- [ ] Page loads without errors
- [ ] Console: "WebXR available"
- [ ] Can start AR session
- [ ] Hit testing works
- [ ] 3D objects render
- [ ] Performance: 60 FPS

### HTTPS Requirement
- [ ] Use HTTPS for production
- [ ] Localhost OK for development
- [ ] If needed: `npx http-server -p 8000 --ssl`

---

## 🔧 Debugging Commands

### Android
```bash
# View logs
adb logcat | grep flutter

# List devices
adb devices

# Check ARCore support
adb shell getprop ro.build.product

# Install Google Play Services
adb install google-play-services-ar.apk

# Check permissions
adb shell pm list permissions | grep -i camera
```

### iOS
```bash
# View logs
log stream --predicate 'process == "Runner"'

# List devices
xcrun xctrace list devices

# Check permissions in Settings → Privacy

# Force rebuild
rm -rf ~/Library/Developer/Xcode/DerivedData/Runner
flutter clean
flutter run
```

### Web
```bash
# Open DevTools
F12 or Cmd+Option+I

# Check console for errors
# Check Network tab for CDN loads
# Check Application → Local Storage for state

# Test WebXR availability
console.log(navigator.xr)
```

---

## 🎯 Performance Targets

| Metric | Target | Status |
|--------|--------|--------|
| Compile Time | < 30s | - |
| First Frame | < 2s | - |
| Plane Detection | < 3s | - |
| Object Placement | Instant | - |
| Frame Rate | 30+ FPS | - |
| Memory Usage | < 50MB | - |
| Battery Impact | < 10% per hour | - |

---

## 🚨 Common Issues & Quick Fixes

| Issue | Android | iOS | Web |
|-------|---------|-----|-----|
| Camera not working | Check permissions | Check Info.plist | Check browser support |
| Planes not detected | Wait 3sec, check light | Ensure ARKit support | Mock data |
| Objects invisible | Check z-position | Check lighting | Check Babylon scene |
| App crash on init | Check ARCore | Check iOS version | Check polyfill |
| Permission denied | Settings → App → Permissions | Settings → Privacy | Browser permission |

---

## 📋 File Locations

```
saas_framework/
├── pubspec.yaml ← Check versions
├── lib/
│   └── src/modules/ar/
│       ├── platform/
│       │   ├── android/
│       │   │   └── android_ar_service.dart ← ARCore integration
│       │   ├── ios/
│       │   │   └── ios_ar_service.dart ← ARKit integration
│       │   └── web/
│       │       └── web_ar_service.dart ← WebXR integration
│       └── services/
│           └── ar_service.dart ← Platform routing
├── android/
│   ├── app/build.gradle ← ARCore dependency
│   └── app/src/main/AndroidManifest.xml ← Permissions
├── ios/
│   ├── Podfile ← Pod setup
│   └── Runner/Info.plist ← Info.plist
└── web/
    └── index.html ← Babylon.js, WebXR
```

---

## 🔗 Next Steps

### Phase 2A: ARCore Full Implementation
- [ ] Replace mock with real ARCore method channels
- [ ] Implement plane detection via ARCore
- [ ] Implement object placement
- [ ] Test on real Android device
- File: `lib/src/modules/ar/platform/android/android_ar_service.dart`

### Phase 2B: ARKit Full Implementation
- [ ] Replace mock with real ARKit method channels
- [ ] Implement plane detection via ARKit
- [ ] Implement object placement
- [ ] Test on real iOS device
- File: `lib/src/modules/ar/platform/ios/ios_ar_service.dart`

### Phase 2C: WebXR Full Implementation
- [ ] Replace mock with real WebXR API
- [ ] Integrate Babylon.js rendering
- [ ] Test on Chrome/Firefox
- File: `lib/src/modules/ar/platform/web/web_ar_service.dart`

### Phase 3: Advanced Features
- [ ] 3D model loading (GLTF, FBX, OBJ)
- [ ] Gesture controls (rotate, scale, move)
- [ ] Physics simulation
- [ ] Custom shaders and materials

### Phase 4: Deployment
- [ ] Final testing on all platforms
- [ ] Performance optimization
- [ ] Build APK/IPA/Web release
- [ ] Push to GitHub
- [ ] Deploy to stores (Google Play, App Store)

---

## 📞 Support References

**For Errors:**
1. Check console logs (print statements)
2. Run `flutter analyze` for type errors
3. Check native logs (adb logcat / xcrun)
4. Visit documentation links below

**Documentation:**
- [ARCore Docs](https://developers.google.com/ar/develop)
- [ARKit Docs](https://developer.apple.com/arkit/)
- [WebXR Spec](https://www.w3.org/TR/webxr/)
- [Babylon.js Docs](https://doc.babylonjs.com/)
- [Flutter Docs](https://flutter.dev/docs)

**Plugin Docs:**
- [ar_flutter_plugin_engine](https://pub.dev/packages/ar_flutter_plugin_engine)
- [permission_handler](https://pub.dev/packages/permission_handler)

---

**Last Updated:** December 5, 2025
**Version:** 1.0
**Status:** Ready for Phase 2 Implementation
