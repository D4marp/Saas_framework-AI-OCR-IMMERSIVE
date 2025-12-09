# Phase 5 - Real Device Testing Guide

## 📱 Testing Overview

Panduan lengkap untuk menguji implementasi AR di device fisik untuk ketiga platform: Web, Android, dan iOS.

---

## 🔴 Android ARCore Testing

### Prerequisites

1. **Device Requirements**:
   - Android 7.0 (API 24) or higher
   - ARCore support (check: Play Store → Google Play Services for AR)
   - Modern processor (Snapdragon 835 or equivalent)
   - Good camera quality
   - Minimum 2GB RAM

2. **Supported Devices**:
   ```
   Pixel 3, 4, 5, 6, 7
   Samsung Galaxy S9+, S10, S20, S21, S22
   OnePlus 6T, 7, 8, 9
   Google Nexus 5X, 6P
   Huawei P20, P30
   ```

3. **Setup**:
   ```bash
   # Enable USB debugging
   Settings → Developer Options → USB Debugging (ON)
   
   # Install ARCore
   Play Store → Search "Google Play Services for AR"
   
   # Install Flutter
   flutter doctor -v
   ```

### Testing Steps

#### 1. Connect Device & Verify
```bash
# List connected devices
flutter devices

# Expected output:
# SM-G973F (mobile) • 12345678 • android-arm64 • Android 12
```

#### 2. Build & Run
```bash
cd /Users/HCMPublic/Documents/Damar/saas_framework

# Build APK
flutter build apk --release

# Run on connected device
flutter run -d SM-G973F

# Watch mode (for development)
flutter run -d SM-G973F --debug
```

#### 3. Verification Checklist

**Startup**:
- [ ] App launches without crashes
- [ ] Camera access requested
- [ ] "Allow" camera permission
- [ ] ARCore session initializes

**Plane Detection**:
- [ ] Move device slowly around room
- [ ] Look for white plane outlines appearing
- [ ] Horizontal planes (floors, tables) detected
- [ ] Vertical planes (walls) detected (if enabled)
- [ ] Planes appear within 1-2 seconds of detection

**Hit Testing**:
- [ ] Tap on detected plane
- [ ] Object appears at tap location
- [ ] Object is at correct position (not floating)

**Object Placement**:
- [ ] Place multiple objects
- [ ] Objects don't overlap incorrectly
- [ ] Objects stay in same location when moving camera
- [ ] Can place up to 10+ objects

**Tracking**:
- [ ] Move camera around objects
- [ ] Objects maintain position (no drift)
- [ ] Lighting changes tracked
- [ ] No crashes with rapid movement

**Performance**:
- [ ] Frame rate smooth (60 FPS)
- [ ] No stuttering when placing objects
- [ ] Touch response immediate
- [ ] Camera feed responsive

#### 4. Debug Output

**Monitor Logcat**:
```bash
# View real-time logs
flutter logs -d SM-G973F

# Filter ARCore logs
flutter logs -d SM-G973F | grep -i "arcore\|ar\|error"
```

**Expected Log Output**:
```
I/Flutter: [ARCore] Session initialized
I/Flutter: [ARCore] Tracking state: TRACKING
D/ARCore: Planes detected: 3
I/Flutter: [ARCore] Object placed: obj_001
```

#### 5. Test Scenarios

**Scenario 1: Basic Plane Detection**
1. Start app
2. Point camera at floor
3. Move slowly side-to-side
4. ✅ Floor plane should be detected

**Scenario 2: Object Placement**
1. Wait for plane detection
2. Tap center of detected plane
3. ✅ Cube should appear at tap location

**Scenario 3: Multiple Objects**
1. Place first object (tap)
2. Move camera slightly
3. Tap new location
4. Place second object
5. ✅ Both objects visible, correct positions

**Scenario 4: Lighting Changes**
1. Place object in bright area
2. Move to darker area
3. ✅ Object visibility adjusts with lighting

#### 6. Performance Metrics

**Capture**:
```bash
# Use Android Profiler
# Android Studio → Profiler → Memory/CPU/GPU

# OR command line
adb shell dumpsys meminfo com.saas_framework > memory.txt
```

**Targets**:
- Memory: 50-150 MB
- CPU: <30% average
- FPS: 60 FPS (or >50 FPS)
- Temperature: <45°C

---

## 🍎 iOS ARKit Testing

### Prerequisites

1. **Device Requirements**:
   - iPhone XS or newer (ARKit 3+)
   - iOS 12.0 or later
   - Good camera quality
   - Minimum 2GB free storage

2. **Supported Devices**:
   ```
   iPhone XS, XS Max, XR
   iPhone 11, 12, 13, 14, 15
   iPad Pro (3rd gen or later)
   ```

3. **Setup**:
   ```bash
   # Xcode Command Line Tools
   xcode-select --install
   
   # Verify CocoaPods
   sudo gem install cocoapods
   pod setup
   
   # Verify Flutter
   flutter doctor -v
   ```

### Testing Steps

#### 1. Connect Device & Verify

```bash
# Enable Developer Mode (iOS 16+)
Settings → Privacy & Security → Developer Mode (ON)

# Trust Developer Certificate
Settings → General → VPN & Device Management → Trust Certificate

# List devices
flutter devices

# Expected output:
# iPhone 14 (mobile) • ABC123DEF456 • ios • iOS 16.5
```

#### 2. Build & Run

```bash
cd /Users/HCMPublic/Documents/Damar/saas_framework

# Build iOS app
flutter build ios

# Run on device
flutter run -d ABC123DEF456

# Watch mode
flutter run -d ABC123DEF456 --debug
```

#### 3. Verification Checklist

**Startup**:
- [ ] App launches
- [ ] Camera permission requested
- [ ] "Allow" camera access
- [ ] ARKit session initializes
- [ ] No permission dialogs

**Plane Detection**:
- [ ] Look at floor/table surface
- [ ] Move device to different angles
- [ ] Horizontal planes detected (white boxes)
- [ ] Vertical planes detected (walls)
- [ ] Plane detection responsive (<1s latency)

**Hit Testing**:
- [ ] Tap on detected plane
- [ ] Object appears
- [ ] Position matches tap location
- [ ] No floating objects

**Advanced Features**:
- [ ] Person segmentation working (if enabled)
- [ ] Lighting changes reflected
- [ ] Environment texturing applied
- [ ] Smooth rendering

**Performance**:
- [ ] 60 FPS smooth motion
- [ ] No crashes
- [ ] Responsive touch
- [ ] Battery drain reasonable

#### 4. Debug Output

**View Console**:
```bash
# Real-time logs
flutter logs -d ABC123DEF456

# Filter ARKit logs
flutter logs -d ABC123DEF456 | grep -i "arkit\|ar\|error"
```

**Xcode Console**:
```
Open Xcode → Window → Device and Simulators
Select device → View Device Console
Filter by "ARKit"
```

**Expected Output**:
```
[ARKit] Session started
[ARKit] Planes detected: 2
[ARKit] Object placed: obj_001
[ARKit] Lighting intensity: 0.8
```

#### 5. Test Scenarios

**Scenario 1: Horizontal Plane Detection**
1. Point at floor/table
2. Move slightly
3. ✅ White plane outline appears

**Scenario 2: Vertical Plane Detection**
1. Point at wall
2. Move slightly
3. ✅ Vertical plane detected

**Scenario 3: Object Placement**
1. Tap on plane
2. ✅ Object appears
3. ✅ Object stays in place

**Scenario 4: Person Segmentation** (iOS 13+)
1. Stand in front of camera
2. Your silhouette visible
3. Place object behind you
4. ✅ Segmentation works

#### 6. Performance Metrics

**Using Xcode**:
```
Xcode → Product → Profile → System Trace
Analyze CPU, Memory, GPU usage
```

**Targets**:
- Memory: 50-150 MB
- CPU: <30%
- FPS: 60 FPS
- Temperature: <40°C

---

## 🌐 Web Browser Testing

### Prerequisites

1. **Browser Requirements**:
   - Chrome 79+
   - Firefox 55+
   - Safari 15+ (macOS 12+)
   - Edge 79+

2. **Hardware Requirements**:
   - Webcam/camera
   - Good processor
   - Minimum 2GB RAM
   - WebGL 2.0 support

3. **Setup**:
   ```bash
   # Check WebXR support
   # Chrome: chrome://flags → Search "WebXR"
   # Enable: "WebXR Device API"
   
   # Check Babylon.js
   # Should be loaded in console: babylon (v5.0+)
   ```

### Testing Steps

#### 1. Build & Serve

```bash
cd /Users/HCMPublic/Documents/Damar/saas_framework

# Build web
flutter build web

# Serve locally
python3 -m http.server 8000 --directory build/web

# OR using live server
flutter run -d chrome
```

#### 2. Open in Browser

```
Chrome: http://localhost:8000
Firefox: http://localhost:8000
Safari: http://localhost:8000
```

#### 3. Verification Checklist

**Startup**:
- [ ] App loads
- [ ] Camera permission requested
- [ ] Grant permission
- [ ] Camera stream visible

**Plane Detection**:
- [ ] Planes rendered as white boxes
- [ ] Planes appear as camera moves
- [ ] Smooth plane detection

**Hit Testing**:
- [ ] Click on canvas
- [ ] Object appears at click location
- [ ] Position correct

**Rendering**:
- [ ] WebXR scene visible
- [ ] Lighting applied
- [ ] 60 FPS smooth

**Controls**:
- [ ] Click to place objects
- [ ] Drag to rotate view
- [ ] Scroll to zoom

#### 4. Browser Console Debug

```javascript
// Open Console (F12)

// Check Babylon.js
console.log(BABYLON.Engine.LastCreatedEngine);

// Check WebXR support
navigator.xr.isSessionSupported('immersive-ar')
  .then(supported => console.log('AR supported:', supported));

// Monitor frame rate
console.log('FPS:', engine.getFps());
```

#### 5. Test Scenarios

**Scenario 1: Canvas Setup**
1. Open in browser
2. ✅ Camera feed visible
3. ✅ Canvas renders

**Scenario 2: 2D Plane Rendering**
1. Move around
2. ✅ Planes rendered as white boxes
3. ✅ Planes update with movement

**Scenario 3: Object Placement**
1. Click on canvas
2. ✅ Cube appears
3. ✅ Cube at correct position
4. ✅ Lighting applied

**Scenario 4: Multiple Objects**
1. Click multiple locations
2. ✅ Multiple objects visible
3. ✅ Each object correct position

#### 6. Performance Analysis

**Using Chrome DevTools**:
```
F12 → Performance → Record
Interact with AR scene
Stop recording
Analyze: CPU, Memory, FPS
```

**Targets**:
- Memory: 100-200 MB
- FPS: 55-60 FPS
- GPU: <80% utilization
- CPU: <50% (single core)

---

## 📊 Comparative Testing Matrix

### Feature Parity

| Feature | Web | Android | iOS |
|---------|-----|---------|-----|
| Plane detection | ✅ | ✅ | ✅ |
| Hit testing | ✅ | ✅ | ✅ |
| Object placement | ✅ | ✅ | ✅ |
| Object tracking | ✅ | ✅ | ✅ |
| Light estimation | ✅ | ✅ | ✅ |
| Person segmentation | ❌ | ❌ | ✅ |
| Environment texturing | ❌ | ❌ | ✅ |
| 60 FPS | ✅ | ✅ | ✅ |

### Performance Comparison

| Metric | Web | Android | iOS |
|--------|-----|---------|-----|
| Startup time | 2-3s | 1-2s | 0.5-1s |
| Plane detection latency | 200ms | 100ms | 100ms |
| Object placement latency | 50ms | 30ms | 30ms |
| Memory (base) | 100MB | 80MB | 80MB |
| Memory (10 objects) | 150MB | 130MB | 130MB |
| FPS (smooth) | 60 | 60 | 60 |

---

## 🐛 Troubleshooting

### Android Issues

**Issue**: "ARCore not available"
```
Solution: Install Google Play Services for AR
Play Store → Search "Google Play Services for AR"
```

**Issue**: Planes not detected
```
Solutions:
1. Improve lighting (not backlit)
2. Look at textured surfaces (not plain walls)
3. Move device slowly
4. Check camera not blocked
```

**Issue**: Low FPS / Stuttering
```
Solutions:
1. Close other apps
2. Reduce plane detection frequency
3. Update device firmware
4. Check device temperature
```

### iOS Issues

**Issue**: "App not installed"
```
Solution: Trust developer certificate
Settings → General → VPN & Device Management → Trust
```

**Issue**: "Camera permission denied"
```
Solution: Grant permission
Settings → Privacy → Camera → Allow app
```

**Issue**: ARKit not working
```
Solutions:
1. Check device support (XS+)
2. Check iOS version (12.0+)
3. Restart app and device
4. Check ARKit availability in code
```

### Web Issues

**Issue**: "WebXR not supported"
```
Solution: Use Chrome with flag enabled
chrome://flags → WebXR Device API → Enabled
```

**Issue**: Camera not working
```
Solutions:
1. Grant camera permission
2. Check HTTPS (required for WebXR)
3. Check camera not in use by other app
4. Refresh page
```

**Issue**: Low FPS / Laggy
```
Solutions:
1. Close other browser tabs
2. Reduce canvas resolution
3. Reduce object count
4. Update GPU drivers
```

---

## 📝 Testing Report Template

```markdown
# AR System Testing Report

## Device Info
- Device: [Model]
- OS: [OS Name] [Version]
- Camera: [Quality]
- RAM: [GB]

## Test Date
- Date: [YYYY-MM-DD]
- Tester: [Name]
- Duration: [Minutes]

## Features Tested

### Plane Detection
- [ ] Horizontal planes: PASS/FAIL
- [ ] Vertical planes: PASS/FAIL
- [ ] Plane confidence: PASS/FAIL
- [ ] Update latency: [ms]

### Hit Testing
- [ ] Tap detection: PASS/FAIL
- [ ] Position accuracy: ±[cm]
- [ ] Rotation accuracy: ±[°]

### Object Management
- [ ] Object placement: PASS/FAIL
- [ ] Object tracking: PASS/FAIL
- [ ] Position stability: PASS/FAIL
- [ ] Removal: PASS/FAIL

### Performance
- [ ] FPS: [Average]
- [ ] Memory: [MB]
- [ ] CPU: [%]
- [ ] Temperature: [°C]

### Stability
- [ ] Crashes: [Count]
- [ ] Session duration: [Minutes]
- [ ] Permission handling: PASS/FAIL

## Issues Found
1. [Description]
   - Severity: Critical/Major/Minor
   - Reproducibility: Always/Sometimes/Rarely

## Overall Assessment
- PASS/FAIL
- Ready for production: YES/NO
- Notes: [Any additional notes]
```

---

## 🚀 Test Execution Timeline

### Week 1: Android Testing
- Day 1-2: Setup and verification
- Day 3-4: Feature testing
- Day 5: Performance optimization
- Day 6-7: Bug fixes and re-testing

### Week 2: iOS Testing
- Day 1-2: Setup and verification
- Day 3-4: Feature testing
- Day 5: Performance optimization
- Day 6-7: Bug fixes and re-testing

### Week 3: Web Testing
- Day 1-2: Setup and verification
- Day 3-4: Feature testing
- Day 5: Performance optimization
- Day 6-7: Bug fixes and re-testing

### Week 4: Cross-platform Verification
- Day 1-3: Compare performance across platforms
- Day 4-5: Fix inconsistencies
- Day 6-7: Final approval

---

## ✅ Sign-Off Criteria

- [ ] All tests PASS on all platforms
- [ ] Performance targets met (60 FPS)
- [ ] No critical bugs
- [ ] Documentation complete
- [ ] Ready for production

---

## 📞 Support & Resources

- GitHub: https://github.com/D4marp/Saas_framework-AI-OCR-IMMERSIVE
- Docs: See iOS_ARKit_INTEGRATION.md, REAL_PLATFORM_INTEGRATION.md
- Flutter: https://flutter.dev
- ARCore: https://developers.google.com/ar
- ARKit: https://developer.apple.com/arkit/
- WebXR: https://www.w3.org/TR/webxr/

