/// AR Platform Service - Abstract interface untuk AR implementations
///
/// File ini mendefinisikan interface untuk berbagai platform AR
/// (Android ARCore, iOS ARKit, Web WebXR)

import 'dart:async';
import 'dart:typed_data';
import '../models/exports.dart';

/// Abstract platform service untuk AR
abstract class ARPlatformService {
  /// Initialize AR session
  Future<void> initialize();

  /// Start AR session
  Future<void> startSession();

  /// Pause AR session
  Future<void> pauseSession();

  /// Resume AR session
  Future<void> resumeSession();

  /// Stop AR session
  Future<void> stopSession();

  /// Get current AR session info
  ARSession getSession();

  /// Get detected planes
  List<ARPlane> getPlanes();

  /// Perform hit test pada screen coordinates
  Future<ARHitTestResult?> hitTest(double screenX, double screenY);

  /// Place AR object pada hit test result
  Future<ARObject> placeObject(
    ARHitTestResult hitResult, {
    required String modelPath,
    required String name,
    required ARObjectType type,
  });

  /// Update object transform
  Future<void> updateObjectTransform(
    String objectId, {
    Vector3? position,
    Quaternion? rotation,
    Vector3? scale,
  });

  /// Remove object from scene
  Future<void> removeObject(String objectId);

  /// Get all placed objects
  List<ARObject> getObjects();

  /// Stream untuk plane updates
  Stream<List<ARPlane>> get planesStream;

  /// Stream untuk object updates
  Stream<List<ARObject>> get objectsStream;

  /// Capture AR screenshot
  Future<Uint8List?> captureScreenshot();

  /// Load 3D model dari path
  Future<void> loadModel(String modelPath);

  /// Release resources
  Future<void> dispose();

  /// Check if platform is supported
  bool isSupported();

  /// Get platform name
  String getPlatformName();
}
