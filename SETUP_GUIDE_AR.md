# Setup Guide - AR untuk Android, iOS, dan Web

## 🚀 Persiapan Awal

```bash
# 1. Update dependencies
cd /path/to/saas_framework
flutter pub get

# 2. Clean build
flutter clean

# 3. Verify analysis
flutter analyze
```

---

## 📱 Android Setup (ARCore)

### Prerequisites
- ✅ Android SDK 21+ (API Level 21)
- ✅ Device dengan dukungan ARCore
- ✅ Google Play Services

### Step 1: Edit `android/app/build.gradle`

```gradle
android {
    compileSdk 34
    
    defaultConfig {
        minSdkVersion 21  // ARCore requirement
        targetSdkVersion 34
    }
}

dependencies {
    // ARCore integration (via ar_flutter_plugin_engine)
    implementation 'com.google.ar:core:1.42.0'
}
```

### Step 2: Edit `android/app/src/main/AndroidManifest.xml`

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.saas_framework">

    <!-- Camera Permission -->
    <uses-permission android:name="android.permission.CAMERA" />
    
    <!-- ARCore Feature -->
    <uses-feature android:name="android.hardware.camera.ar" />
    
    <!-- Location (optional for some AR features) -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    
    <!-- Internet -->
    <uses-permission android:name="android.permission.INTERNET" />

    <application>
        <activity
            android:name=".MainActivity"
            android:hardwareAccelerated="true">
            <!-- AR Intent Filter -->
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
```

### Step 3: Runtime Permissions (Dart)

```dart
import 'package:permission_handler/permission_handler.dart';

Future<void> requestCameraPermission() async {
  final status = await Permission.camera.request();
  
  if (status.isDenied) {
    print('Camera permission denied');
  } else if (status.isGranted) {
    print('Camera permission granted');
    // Initialize AR
  } else if (status.isPermanentlyDenied) {
    openAppSettings();
  }
}
```

### Step 4: Run on Android

```bash
# List connected devices
flutter devices

# Run on specific device
flutter run -d <device_id>

# Or use emulator (ARCore emulator support)
flutter run -d emulator
```

### Test Checklist
- [ ] App opens without crash
- [ ] Camera view appears
- [ ] Planes detected after 1-3 seconds
- [ ] Tap places object correctly
- [ ] Object transform editable

---

## 🍎 iOS Setup (ARKit)

### Prerequisites
- ✅ iOS 14.3+ (ARKit 4+)
- ✅ Device dengan A9+ chip
- ✅ Xcode 13+

### Step 1: Edit `ios/Podfile`

```ruby
# Add this in post_install hook
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_CAMERA=1',
        'PERMISSION_PHOTOS=1',
        'PERMISSION_LOCATION=1',
        'PERMISSION_SENSORS=1',
      ]
    end
  end
end
```

### Step 2: Edit `ios/Runner/Info.plist`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Camera Usage -->
    <key>NSCameraUsageDescription</key>
    <string>We need camera access to enable AR features</string>
    
    <!-- Location Usage (optional) -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>Location helps improve AR accuracy</string>
    
    <!-- Motion Usage (optional) -->
    <key>NSMotionUsageDescription</key>
    <string>Motion data enhances AR experience</string>
    
    <!-- App Transport Security -->
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
    
    <!-- Supported Orientations for AR -->
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
    
    <!-- Build Version -->
    <key>CFBundleVersion</key>
    <string>1</string>
    
</dict>
</plist>
```

### Step 3: Update iOS Build Settings

```bash
cd ios
pod install --repo-update
cd ..
```

### Step 4: Run on iOS

```bash
# List connected devices
flutter devices

# Run on physical device
flutter run -d <device_id>

# Or use simulator (note: Simulator AR is limited)
# Simulator hanya support WebXR-like mode, bukan full ARKit
```

### Test Checklist
- [ ] App opens without crash
- [ ] Requests camera permission
- [ ] ARKit session initializes
- [ ] Planes detected
- [ ] Objects placed and visible
- [ ] Lighting estimation works

---

## 🌐 Web Setup (WebXR + Babylon.js)

### Prerequisites
- ✅ Modern browser dengan WebXR support (Chrome 79+, Firefox 55+)
- ✅ HTTPS required (WebXR security requirement)
- ✅ WebXR-compatible AR device (untuk full experience)

### Step 1: Edit `web/index.html`

```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AR SaaS Framework</title>
    
    <!-- Babylon.js for 3D rendering -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/babylonjs/5.53.0/babylon.min.js"></script>
    
    <!-- Babylon.js Inspector (development) -->
    <script src="https://cdn.babylonjs.com/inspector/babylon.inspector.bundle.js"></script>
    
    <!-- Babylon.js Materials Library -->
    <script src="https://www.babylonjs-playground.com/babylon.materials.js"></script>
    
    <!-- WebXR Polyfill (untuk browser yang belum support) -->
    <script src="https://cdn.jsdelivr.net/npm/webxr-polyfill@latest/build/webxr-polyfill.js"></script>
    
    <style>
        body {
            margin: 0;
            overflow: hidden;
            background-color: #000;
        }
        
        #canvas {
            width: 100%;
            height: 100vh;
            display: block;
        }
        
        #info {
            position: absolute;
            top: 10px;
            left: 10px;
            color: white;
            font-family: Arial;
            font-size: 14px;
            background: rgba(0,0,0,0.5);
            padding: 10px;
            border-radius: 5px;
        }
        
        #status {
            position: absolute;
            bottom: 20px;
            left: 20px;
            color: white;
            font-family: Arial;
            background: rgba(0,0,0,0.7);
            padding: 10px 15px;
            border-radius: 5px;
        }
    </style>
</head>
<body>
    <canvas id="canvas"></canvas>
    <div id="info">
        <p>AR Session Status: <span id="status-text">Not Started</span></p>
        <p>Planes: <span id="planes-count">0</span></p>
        <p>Objects: <span id="objects-count">0</span></p>
    </div>
    
    <!-- Flutter App -->
    <script src="flutter.js"></script>
    <script>
        _flutter.loader.loadEntrypoint({
            onEntrypointLoaded: async function(engineInitializer) {
                let appRunner = await engineInitializer.initializeEngine();
                await appRunner.runApp();
            }
        });
    </script>
</body>
</html>
```

### Step 2: Konfigurasi WebXR di Dart

```dart
// lib/src/modules/ar/platform/web/web_ar_service.dart

import 'dart:js' as js;

class WebARService extends ARPlatformService {
  late js.JsObject _babylonScene;
  late js.JsObject _xrSession;
  
  @override
  Future<void> initialize() async {
    // Check WebXR support
    final hasXR = js.context['navigator']['xr'] != null;
    if (!hasXR) {
      throw Exception('WebXR not supported in this browser');
    }
    
    // Initialize Babylon.js scene
    _initializeBabylonScene();
    print('[WebAR] WebXR initialized');
  }
  
  void _initializeBabylonScene() {
    // Get canvas
    final canvas = js.context['document'].callMethod('getElementById', ['canvas']);
    
    // Create Babylon engine
    final engine = js.JsObject(
      js.context['BABYLON']['Engine'],
      [canvas]
    );
    
    // Create scene
    _babylonScene = js.JsObject(
      js.context['BABYLON']['Scene'],
      [engine]
    );
  }
  
  @override
  Future<void> startSession() async {
    try {
      // Request XR session
      final requestedFeatures = ['hit-test', 'dom-overlay'];
      
      _xrSession = await js.context['navigator']['xr']
          .callMethod('requestSession', ['immersive-ar', requestedFeatures]);
      
      print('[WebAR] XR Session started');
    } catch (e) {
      print('[WebAR] Error starting XR session: $e');
      rethrow;
    }
  }
  
  @override
  Future<ARHitTestResult?> hitTest(double screenX, double screenY) async {
    // Perform hit test via WebXR
    try {
      final pose = await _xrSession.callMethod('hitTest', [screenX, screenY]);
      if (pose != null) {
        return ARHitTestResult(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          hitPoint: Vector3(x: pose['x'], y: pose['y'], z: pose['z']),
          estimatedRotation: Quaternion.identity(),
          distance: pose['distance'] ?? 0,
          planeId: pose['planeId'],
        );
      }
    } catch (e) {
      print('[WebAR] Hit test error: $e');
    }
    return null;
  }
}
```

### Step 3: Run Web Build

```bash
# Development
flutter run -d chrome --web-renderer=html

# Or canvaskit for better performance
flutter run -d chrome --web-renderer=canvaskit

# Build for production
flutter build web --release

# Serve locally with HTTPS (required for WebXR)
python3 -m http.server 8000 --cgi  # Simple HTTP
# atau gunakan
npx http-server -p 8000 --ssl      # Dengan SSL
```

### Step 4: Test on Different Browsers

| Browser | WebXR | Status |
|---------|-------|--------|
| Chrome 79+ | ✅ | Full support |
| Firefox 55+ | ✅ | Full support |
| Safari | ⏳ | Experimental |
| Edge | ✅ | Full support |

### Test Checklist
- [ ] Page loads without errors
- [ ] Console shows WebXR available
- [ ] Can start AR session
- [ ] Hit testing works
- [ ] Objects visible in 3D scene
- [ ] Performance acceptable (60 FPS)

---

## 🔗 Platform Detection & Routing

```dart
// lib/src/modules/ar/services/ar_service.dart

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

Future<void> initialize() async {
  if (kIsWeb) {
    // WEB
    print('🌐 Initializing Web AR (WebXR)');
    _platformService = WebARService();
  } else if (Platform.isAndroid) {
    // ANDROID
    print('🤖 Initializing Android AR (ARCore)');
    _platformService = AndroidARService();
  } else if (Platform.isIOS) {
    // iOS
    print('🍎 Initializing iOS AR (ARKit)');
    _platformService = iOSARService();
  } else {
    throw UnsupportedError('Platform not supported for AR');
  }
  
  await _platformService.initialize();
}

// Detect platform programmatically
String getPlatformName() {
  if (kIsWeb) return 'Web';
  else if (Platform.isAndroid) return 'Android';
  else if (Platform.isIOS) return 'iOS';
  return 'Unknown';
}
```

---

## 🧪 Testing Across Platforms

### Unit Tests
```bash
flutter test test/ar_module_test.dart
```

### Widget Tests
```bash
flutter test test/ar_widgets_test.dart
```

### Integration Tests
```bash
# Android
flutter drive --target=test_driver/app.dart -d android

# iOS
flutter drive --target=test_driver/app.dart -d ios

# Web
flutter drive --target=test_driver/app.dart -d chrome
```

---

## 📊 Troubleshooting

### Android Issues

**Problem:** ARCore not detected
```
Solution:
1. Check device supports ARCore
2. Install Google Play Services
3. Run: adb install google-play-services-ar.apk
```

**Problem:** Camera permission denied
```
Solution:
1. Go to Settings → App → Permissions
2. Enable Camera
3. Restart app
```

### iOS Issues

**Problem:** "Camera not available" after permission grant
```
Solution:
1. Check Info.plist has NSCameraUsageDescription
2. Update Podfile permissions
3. Run: pod install --repo-update
4. Clean build folder: Cmd+Shift+K
```

**Problem:** ARKit session fails
```
Solution:
1. Check iOS version >= 14.3
2. Check device has A9+ chip
3. Restart device
```

### Web Issues

**Problem:** WebXR not available
```
Solution:
1. Use Chrome 79+ or Firefox 55+
2. Check HTTPS enabled (localhost OK for dev)
3. Enable WebXR in browser settings
4. Try WebXR Polyfill: 
   <script src="https://cdn.jsdelivr.net/npm/webxr-polyfill"></script>
```

**Problem:** Babylon.js not loading
```
Solution:
1. Check CDN link in index.html
2. Open DevTools Console (F12)
3. Check for CORS errors
4. Use local babylon.js if needed
```

---

## 🚀 Deployment Checklist

### Before Release
- [ ] All permissions properly configured
- [ ] AR session handles interruptions gracefully
- [ ] Error handling comprehensive
- [ ] Performance tested (target: 30+ FPS)
- [ ] Battery impact acceptable
- [ ] Memory usage < 50MB
- [ ] Tested on multiple devices per platform
- [ ] Privacy policy updated

### Android Release
```bash
flutter build apk --release
# atau
flutter build app-bundle --release
# Upload ke Google Play
```

### iOS Release
```bash
flutter build ios --release
# Open in Xcode
# Create archive and upload to App Store
```

### Web Release
```bash
flutter build web --release --dart-define=FLUTTER_WEB_USE_SKIA=true
# Deploy to hosting (Firebase, Netlify, etc.)
```

---

## 📚 Useful Links

### Documentation
- [ARCore Documentation](https://developers.google.com/ar/develop)
- [ARKit Documentation](https://developer.apple.com/arkit/)
- [WebXR Standard](https://www.w3.org/TR/webxr/)
- [Babylon.js Docs](https://doc.babylonjs.com/)

### Plugins
- [ar_flutter_plugin_engine](https://pub.dev/packages/ar_flutter_plugin_engine)
- [permission_handler](https://pub.dev/packages/permission_handler)

### Tools
- [ARCore Emulator Setup](https://developers.google.com/ar/develop/getting-started#supported_devices)
- [WebXR Browser Support](https://caniuse.com/webxr)

---

**Last Updated:** December 5, 2025
**Status:** Setup Guide v1.0
