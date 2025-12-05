/// AR Service - Singleton service untuk Augmented Reality
///
/// Menyediakan interface unified untuk AR operations di berbagai platform:
/// - Web (WebXR, Babylon.js)
/// - Android (ARCore)
/// - iOS (ARKit)
///
/// Pattern: Same code, automatic platform routing

import 'dart:async';
import 'dart:io' show Platform;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../models/exports.dart';
import '../platform/ar_platform_service.dart';
import '../platform/android/android_ar_service.dart';
import '../platform/ios/ios_ar_service.dart';
import '../platform/web/web_ar_service.dart';

/// Exception untuk AR operations
class ARException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  ARException(
    this.message, {
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'ARException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Main AR Service - Singleton pattern
class ARService {
  static final ARService _instance = ARService._internal();

  factory ARService() => _instance;

  ARService._internal();

  late ARPlatformService _platformService;
  bool _initialized = false;
  late ARSession _currentSession;

  // Getters
  bool get initialized => _initialized;
  ARSession get currentSession => _currentSession;
  ARPlatformService get platformService => _platformService;

  /// Initialize AR service untuk current platform
  Future<void> initialize() async {
    if (_initialized) {
      print('[ARService] Already initialized');
      return;
    }

    try {
      print('[ARService] Initializing for platform: ${_getPlatformName()}');

      // Platform detection dan initialization
      if (kIsWeb) {
        _platformService = WebARService();
        print('[ARService] Using Web AR (WebXR)');
      } else if (Platform.isAndroid) {
        _platformService = AndroidARService();
        print('[ARService] Using Android AR (ARCore)');
      } else if (Platform.isIOS) {
        _platformService = iOSARService();
        print('[ARService] Using iOS AR (ARKit)');
      } else {
        throw ARException('Unsupported platform for AR');
      }

      await _platformService.initialize();
      _initialized = true;
      print('[ARService] Initialization successful');
    } catch (e) {
      throw ARException(
        'Failed to initialize AR service',
        code: 'INIT_FAILED',
        originalError: e,
      );
    }
  }

  /// Start AR session
  Future<void> startSession() async {
    if (!_initialized) {
      throw ARException('AR Service not initialized. Call initialize() first.');
    }

    try {
      await _platformService.startSession();
      _currentSession = _platformService.getSession();
    } catch (e) {
      throw ARException(
        'Failed to start AR session',
        originalError: e,
      );
    }
  }

  /// Pause AR session
  Future<void> pauseSession() async {
    if (!_initialized) throw ARException('AR Service not initialized');

    try {
      await _platformService.pauseSession();
    } catch (e) {
      throw ARException('Failed to pause AR session', originalError: e);
    }
  }

  /// Resume AR session
  Future<void> resumeSession() async {
    if (!_initialized) throw ARException('AR Service not initialized');

    try {
      await _platformService.resumeSession();
    } catch (e) {
      throw ARException('Failed to resume AR session', originalError: e);
    }
  }

  /// Stop AR session
  Future<void> stopSession() async {
    if (!_initialized) throw ARException('AR Service not initialized');

    try {
      await _platformService.stopSession();
    } catch (e) {
      throw ARException('Failed to stop AR session', originalError: e);
    }
  }

  /// Get list of detected planes
  List<ARPlane> getDetectedPlanes() {
    if (!_initialized) throw ARException('AR Service not initialized');
    return _platformService.getPlanes();
  }

  /// Perform hit test on screen
  Future<ARHitTestResult?> hitTest(double screenX, double screenY) async {
    if (!_initialized) throw ARException('AR Service not initialized');

    try {
      return await _platformService.hitTest(screenX, screenY);
    } catch (e) {
      throw ARException(
        'Hit test failed',
        originalError: e,
      );
    }
  }

  /// Place AR object at hit test result
  Future<ARObject> placeObject(
    ARHitTestResult hitResult, {
    required String modelPath,
    required String name,
    required ARObjectType type,
  }) async {
    if (!_initialized) throw ARException('AR Service not initialized');

    try {
      return await _platformService.placeObject(
        hitResult,
        modelPath: modelPath,
        name: name,
        type: type,
      );
    } catch (e) {
      throw ARException(
        'Failed to place object',
        originalError: e,
      );
    }
  }

  /// Update placed object transform
  Future<void> updateObjectTransform(
    String objectId, {
    Vector3? position,
    Quaternion? rotation,
    Vector3? scale,
  }) async {
    if (!_initialized) throw ARException('AR Service not initialized');

    try {
      await _platformService.updateObjectTransform(
        objectId,
        position: position,
        rotation: rotation,
        scale: scale,
      );
    } catch (e) {
      throw ARException(
        'Failed to update object transform',
        originalError: e,
      );
    }
  }

  /// Remove object from AR scene
  Future<void> removeObject(String objectId) async {
    if (!_initialized) throw ARException('AR Service not initialized');

    try {
      await _platformService.removeObject(objectId);
    } catch (e) {
      throw ARException(
        'Failed to remove object',
        originalError: e,
      );
    }
  }

  /// Get all placed objects
  List<ARObject> getPlacedObjects() {
    if (!_initialized) throw ARException('AR Service not initialized');
    return _platformService.getObjects();
  }

  /// Stream untuk plane detection updates
  Stream<List<ARPlane>> get planesStream {
    if (!_initialized) throw ARException('AR Service not initialized');
    return _platformService.planesStream;
  }

  /// Stream untuk object placement updates
  Stream<List<ARObject>> get objectsStream {
    if (!_initialized) throw ARException('AR Service not initialized');
    return _platformService.objectsStream;
  }

  /// Capture AR view screenshot
  Future<Uint8List?> captureScreenshot() async {
    if (!_initialized) throw ARException('AR Service not initialized');

    try {
      return await _platformService.captureScreenshot();
    } catch (e) {
      throw ARException(
        'Failed to capture screenshot',
        originalError: e,
      );
    }
  }

  /// Load 3D model
  Future<void> loadModel(String modelPath) async {
    if (!_initialized) throw ARException('AR Service not initialized');

    try {
      await _platformService.loadModel(modelPath);
    } catch (e) {
      throw ARException(
        'Failed to load model',
        originalError: e,
      );
    }
  }

  /// Cleanup resources
  Future<void> dispose() async {
    if (!_initialized) return;

    try {
      await _platformService.dispose();
      _initialized = false;
      print('[ARService] Disposed successfully');
    } catch (e) {
      print('[ARService] Error during disposal: $e');
    }
  }

  /// Get platform name
  String _getPlatformName() {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isLinux) return 'Linux';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isWindows) return 'Windows';
    return 'Unknown';
  }

  /// Check if AR is supported on this platform
  bool isSupported() {
    try {
      if (!_initialized) return false;
      return _platformService.isSupported();
    } catch (_) {
      return false;
    }
  }

  /// Get current platform service name
  String getPlatformServiceName() {
    if (!_initialized) return 'Not initialized';
    return _platformService.getPlatformName();
  }
}
