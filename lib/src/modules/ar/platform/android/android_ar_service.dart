/// Android AR Service - ARCore Implementation
///
/// Implementasi AR untuk Android menggunakan Google ARCore

import 'dart:async';
import 'dart:typed_data';
import '../../models/exports.dart';
import '../ar_platform_service.dart';

/// Android AR Service menggunakan ARCore
class AndroidARService extends ARPlatformService {
  late ARSession _session;
  final List<ARPlane> _planes = [];
  final List<ARObject> _objects = [];
  final _planesController = StreamController<List<ARPlane>>.broadcast();
  final _objectsController = StreamController<List<ARObject>>.broadcast();
  bool _initialized = false;

  AndroidARService() {
    _session = ARSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      state: ARSessionState.notStarted,
      startedAt: DateTime.now(),
      detectedPlanes: [],
      placedObjects: [],
    );
  }

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    print('[AndroidAR] Initializing ARCore session...');

    try {
      // ARCore initialization happens through the AR view widget
      _initialized = true;
      print('[AndroidAR] ARCore initialized successfully');
    } catch (e) {
      print('[AndroidAR] Initialization error: \$e');
      rethrow;
    }
  }

  @override
  Future<void> startSession() async {
    print('[AndroidAR] Starting AR session...');
    _session = _session.copyWith(
      state: ARSessionState.running,
    );
  }

  @override
  Future<void> pauseSession() async {
    print('[AndroidAR] Pausing AR session...');
    _session = _session.copyWith(
      state: ARSessionState.paused,
    );
  }

  @override
  Future<void> resumeSession() async {
    print('[AndroidAR] Resuming AR session...');
    _session = _session.copyWith(
      state: ARSessionState.running,
    );
  }

  @override
  Future<void> stopSession() async {
    print('[AndroidAR] Stopping AR session...');
    _session = _session.copyWith(
      state: ARSessionState.stopped,
    );
  }

  @override
  ARSession getSession() => _session;

  @override
  List<ARPlane> getPlanes() => _planes;

  @override
  Future<ARHitTestResult?> hitTest(double screenX, double screenY) async {
    print('[AndroidAR] Hit test at (\$screenX, \$screenY)');

    try {
      // In a real implementation, use ARCore's hit test
      // For now, return a mock result
      if (_planes.isNotEmpty) {
        final plane = _planes.first;
        return ARHitTestResult(
          planeId: plane.id,
          hitPoint: plane.center,
          estimatedRotation: Quaternion.identity(),
          distance: 0,
          timestamp: DateTime.now(),
        );
      }
    } catch (e) {
      print('[AndroidAR] Hit test error: \$e');
    }

    return null;
  }

  @override
  Future<ARObject> placeObject(
    ARHitTestResult hitResult, {
    required String modelPath,
    required String name,
    required ARObjectType type,
  }) async {
    final object = ARObject(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      modelPath: modelPath,
      position: hitResult.hitPoint,
      rotation: hitResult.estimatedRotation,
      scale: Vector3(x: 1, y: 1, z: 1),
      type: type,
      placedAt: DateTime.now(),
    );

    _objects.add(object);
    _objectsController.add(_objects);

    print('[AndroidAR] Object placed: \${object.name}');
    return object;
  }

  @override
  Future<void> updateObjectTransform(
    String objectId, {
    Vector3? position,
    Quaternion? rotation,
    Vector3? scale,
  }) async {
    final index = _objects.indexWhere((o) => o.id == objectId);
    if (index != -1) {
      _objects[index] = _objects[index].copyWith(
        position: position,
        rotation: rotation,
        scale: scale,
      );
      _objectsController.add(_objects);
      print('[AndroidAR] Object transform updated');
    }
  }

  @override
  Future<void> removeObject(String objectId) async {
    _objects.removeWhere((o) => o.id == objectId);
    _objectsController.add(_objects);
    print('[AndroidAR] Object removed');
  }

  @override
  List<ARObject> getObjects() => _objects;

  @override
  Stream<List<ARPlane>> get planesStream => _planesController.stream;

  @override
  Stream<List<ARObject>> get objectsStream => _objectsController.stream;

  @override
  Future<Uint8List?> captureScreenshot() async {
    // ARCore screenshot capture
    return null;
  }

  @override
  Future<void> loadModel(String modelPath) async {
    print('[AndroidAR] Loading model: \$modelPath');
  }

  @override
  Future<void> dispose() async {
    await _planesController.close();
    await _objectsController.close();
    print('[AndroidAR] Disposed');
  }

  @override
  bool isSupported() => true;

  @override
  String getPlatformName() => 'Android AR (ARCore)';

  /// Add detected plane
  void addPlane(ARPlane plane) {
    final index = _planes.indexWhere((p) => p.id == plane.id);
    if (index != -1) {
      _planes[index] = plane;
    } else {
      _planes.add(plane);
    }
    _planesController.add(_planes);
  }

  /// Remove plane
  void removePlane(String planeId) {
    _planes.removeWhere((p) => p.id == planeId);
    _planesController.add(_planes);
  }
}
