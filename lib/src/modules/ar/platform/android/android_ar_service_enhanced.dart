/// Android AR Service - Real ARCore Implementation
///
/// Implementasi AR untuk Android menggunakan ARCore dengan ar_flutter_plugin_engine
/// Mendukung plane detection, object placement, dan hit testing real-time

import 'dart:async';
import 'dart:typed_data';
import 'package:ar_flutter_plugin_engine/ar_flutter_plugin_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../models/exports.dart';
import '../ar_platform_service.dart';

/// Android AR Service menggunakan ARCore
class AndroidARService extends ARPlatformService {
  static const platform = MethodChannel('com.saas_framework.ar/arcore');

  late ARSession _session;
  final List<ARPlane> _planes = [];
  final List<ARObject> _objects = [];
  final _planesController = StreamController<List<ARPlane>>.broadcast();
  final _objectsController = StreamController<List<ARObject>>.broadcast();

  bool _initialized = false;
  dynamic _arCoreSession;
  Timer? _updateTimer;

  // ARCore features
  final List<Map<String, dynamic>> _detectedPlanes = [];
  final Map<String, Map<String, dynamic>> _trackedObjects = {};

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

    try {
      print('[ARCore] Initializing ARCore session...');

      // Request AR permissions
      await _requestARPermissions();

      // Initialize ARCore using the plugin
      final result = await platform.invokeMethod('initializeARCore');
      print('[ARCore] Initialize result: $result');

      _initialized = true;
      print('[ARCore] ARCore initialized successfully');
    } catch (e) {
      print('[ARCore] Initialization error: $e');
      _session = _session.copyWith(
        state: ARSessionState.error,
        error: 'Failed to initialize ARCore: $e',
      );
      rethrow;
    }
  }

  @override
  Future<void> startSession() async {
    try {
      print('[ARCore] Starting ARCore session...');

      // Create AR session configuration
      final config = {
        'lightEstimation': true,
        'cloudAnchor': false,
        'instantPlacementMode': 'DISABLED',
        'depthMode': 'AUTOMATIC',
      };

      final result = await platform.invokeMethod('startARSession', config);
      print('[ARCore] Session start result: $result');

      _session = _session.copyWith(state: ARSessionState.running);

      // Start update loop for plane detection and tracking
      _startUpdateLoop();

      print('[ARCore] ARCore session started');
    } catch (e) {
      print('[ARCore] Session start error: $e');
      _session = _session.copyWith(
        state: ARSessionState.error,
        error: e.toString(),
      );
    }
  }

  @override
  Future<void> pauseSession() async {
    try {
      print('[ARCore] Pausing ARCore session...');
      _updateTimer?.cancel();

      final result = await platform.invokeMethod('pauseARSession');
      print('[ARCore] Session pause result: $result');

      _session = _session.copyWith(state: ARSessionState.paused);
    } catch (e) {
      print('[ARCore] Session pause error: $e');
    }
  }

  @override
  Future<void> resumeSession() async {
    try {
      print('[ARCore] Resuming ARCore session...');

      final result = await platform.invokeMethod('resumeARSession');
      print('[ARCore] Session resume result: $result');

      _session = _session.copyWith(state: ARSessionState.running);
      _startUpdateLoop();
    } catch (e) {
      print('[ARCore] Session resume error: $e');
    }
  }

  @override
  Future<void> stopSession() async {
    try {
      print('[ARCore] Stopping ARCore session...');
      _updateTimer?.cancel();

      final result = await platform.invokeMethod('stopARSession');
      print('[ARCore] Session stop result: $result');

      _session = _session.copyWith(state: ARSessionState.stopped);
      _planes.clear();
      _objects.clear();
      _planesController.add([]);
      _objectsController.add([]);
    } catch (e) {
      print('[ARCore] Session stop error: $e');
    }
  }

  @override
  ARSession getSession() => _session;

  @override
  List<ARPlane> getPlanes() => _planes;

  @override
  Stream<List<ARPlane>> get planesStream => _planesController.stream;

  @override
  Stream<List<ARObject>> get objectsStream => _objectsController.stream;

  @override
  Future<ARHitTestResult?> hitTest(double screenX, double screenY) async {
    try {
      print('[ARCore] Hit test at ($screenX, $screenY)');

      // Perform hit test using ARCore
      final result = await platform.invokeMethod('performHitTest', {
        'x': screenX.toInt(),
        'y': screenY.toInt(),
      });

      if (result != null) {
        return ARHitTestResult(
          planeId: result['planeId'] as String? ?? 'unknown',
          hitPoint: Vector3(
            x: (result['hitX'] as num).toDouble(),
            y: (result['hitY'] as num).toDouble(),
            z: (result['hitZ'] as num).toDouble(),
          ),
          estimatedRotation: Quaternion(
            x: (result['rotX'] as num?)?.toDouble() ?? 0.0,
            y: (result['rotY'] as num?)?.toDouble() ?? 0.0,
            z: (result['rotZ'] as num?)?.toDouble() ?? 0.0,
            w: (result['rotW'] as num?)?.toDouble() ?? 1.0,
          ),
          distance: (result['distance'] as num).toDouble(),
          timestamp: DateTime.now(),
        );
      }

      return null;
    } catch (e) {
      print('[ARCore] Hit test error: $e');
      return null;
    }
  }

  @override
  Future<void> placeObject(ARObject object) async {
    try {
      print('[ARCore] Placing object: ${object.name}');

      // Add object to tracking
      _trackedObjects[object.id] = {
        'object': object,
        'arAnchor': null, // Will be set by platform
      };

      _objects.add(object);
      _session = _session.copyWith(placedObjects: _objects);

      // Notify platform to place object
      await platform.invokeMethod('placeObject', {
        'objectId': object.id,
        'name': object.name,
        'modelPath': object.modelPath,
        'positionX': object.position.x,
        'positionY': object.position.y,
        'positionZ': object.position.z,
        'scaleX': object.scale.x,
        'scaleY': object.scale.y,
        'scaleZ': object.scale.z,
      });

      _objectsController.add(_objects);
      print('[ARCore] Object placed: ${object.id}');
    } catch (e) {
      print('[ARCore] Place object error: $e');
    }
  }

  @override
  Future<void> updateObject(ARObject object) async {
    try {
      final index = _objects.indexWhere((o) => o.id == object.id);
      if (index != -1) {
        _objects[index] = object;

        // Update object on platform
        await platform.invokeMethod('updateObject', {
          'objectId': object.id,
          'positionX': object.position.x,
          'positionY': object.position.y,
          'positionZ': object.position.z,
          'rotationX': object.rotation.x,
          'rotationY': object.rotation.y,
          'rotationZ': object.rotation.z,
          'rotationW': object.rotation.w,
          'scaleX': object.scale.x,
          'scaleY': object.scale.y,
          'scaleZ': object.scale.z,
        });

        _session = _session.copyWith(placedObjects: _objects);
        _objectsController.add(_objects);
      }
    } catch (e) {
      print('[ARCore] Update object error: $e');
    }
  }

  @override
  Future<void> removeObject(String objectId) async {
    try {
      _objects.removeWhere((o) => o.id == objectId);
      _trackedObjects.remove(objectId);

      // Remove object on platform
      await platform.invokeMethod('removeObject', {
        'objectId': objectId,
      });

      _session = _session.copyWith(placedObjects: _objects);
      _objectsController.add(_objects);
    } catch (e) {
      print('[ARCore] Remove object error: $e');
    }
  }

  // ============ Private Methods ============

  /// Request AR permissions (camera, location, etc.)
  Future<void> _requestARPermissions() async {
    try {
      final result = await platform.invokeMethod('requestPermissions');
      print('[ARCore] Permission request result: $result');
    } catch (e) {
      print('[ARCore] Permission request error: $e');
    }
  }

  /// Start update loop untuk plane detection dan object tracking
  void _startUpdateLoop() {
    _updateTimer = Timer.periodic(Duration(milliseconds: 33), (_) async {
      try {
        // Get updated planes
        await _updatePlanes();

        // Get light estimation
        await _updateLighting();

        // Update object positions
        await _updateTrackedObjects();
      } catch (e) {
        print('[ARCore] Update loop error: $e');
      }
    });
  }

  /// Update detected planes dari ARCore
  Future<void> _updatePlanes() async {
    try {
      final planesData = await platform.invokeMethod('getDetectedPlanes');

      if (planesData != null) {
        _planes.clear();

        final List<dynamic> planesJson = planesData as List<dynamic>;
        for (final planeData in planesJson) {
          final plane = _createPlaneFromData(planeData as Map<dynamic, dynamic>);
          _planes.add(plane);
        }

        _session = _session.copyWith(detectedPlanes: _planes);
        _planesController.add(_planes);
      }
    } catch (e) {
      print('[ARCore] Update planes error: $e');
    }
  }

  /// Update lighting estimation
  Future<void> _updateLighting() async {
    try {
      final lightingData = await platform.invokeMethod('getLightingEstimation');
      if (lightingData != null) {
        print('[ARCore] Light intensity: ${lightingData['intensity']}');
      }
    } catch (e) {
      print('[ARCore] Update lighting error: $e');
    }
  }

  /// Update tracked objects positions
  Future<void> _updateTrackedObjects() async {
    try {
      for (final objectId in _trackedObjects.keys) {
        final posData = await platform.invokeMethod('getObjectPosition', {
          'objectId': objectId,
        });

        if (posData != null) {
          final index = _objects.indexWhere((o) => o.id == objectId);
          if (index != -1) {
            _objects[index] = _objects[index].copyWith(
              position: Vector3(
                x: (posData['x'] as num).toDouble(),
                y: (posData['y'] as num).toDouble(),
                z: (posData['z'] as num).toDouble(),
              ),
            );
          }
        }
      }

      if (_objects.isNotEmpty) {
        _session = _session.copyWith(placedObjects: _objects);
        _objectsController.add(_objects);
      }
    } catch (e) {
      // Silently ignore errors in continuous tracking
    }
  }

  /// Create ARPlane dari platform data
  ARPlane _createPlaneFromData(Map<dynamic, dynamic> data) {
    final planeId = data['id'] as String? ?? 'plane_${DateTime.now().millisecondsSinceEpoch}';

    final List<dynamic>? polygonData = data['polygon'] as List<dynamic>?;
    final polygon = polygonData?.map((p) {
      final point = p as Map<dynamic, dynamic>;
      return Vector3(
        x: (point['x'] as num).toDouble(),
        y: (point['y'] as num).toDouble(),
        z: (point['z'] as num).toDouble(),
      );
    }).toList() ?? [];

    return ARPlane(
      id: planeId,
      center: Vector3(
        x: (data['centerX'] as num?)?.toDouble() ?? 0.0,
        y: (data['centerY'] as num?)?.toDouble() ?? 0.0,
        z: (data['centerZ'] as num?)?.toDouble() ?? 0.0,
      ),
      normal: Vector3(
        x: (data['normalX'] as num?)?.toDouble() ?? 0.0,
        y: (data['normalY'] as num?)?.toDouble() ?? 1.0,
        z: (data['normalZ'] as num?)?.toDouble() ?? 0.0,
      ),
      extent: Vector3(
        x: (data['extentX'] as num?)?.toDouble() ?? 1.0,
        y: 0.0,
        z: (data['extentZ'] as num?)?.toDouble() ?? 1.0,
      ),
      polygon: polygon,
      detectedAt: DateTime.now(),
      isHorizontal: (data['isHorizontal'] as bool?) ?? true,
      confidence: (data['confidence'] as num?)?.toDouble() ?? 0.5,
    );
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _planesController.close();
    _objectsController.close();
  }
}
