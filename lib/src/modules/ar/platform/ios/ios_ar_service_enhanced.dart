/// iOS AR Service - Real ARKit Implementation
///
/// Implementasi AR untuk iOS menggunakan ARKit dengan ar_flutter_plugin_engine
/// Mendukung plane detection, object placement, dan hit testing real-time

import 'dart:async';
import 'dart:typed_data';
import 'package:ar_flutter_plugin_engine/ar_flutter_plugin_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../models/exports.dart';
import '../ar_platform_service.dart';

/// iOS AR Service menggunakan ARKit
class iOSARService extends ARPlatformService {
  static const platform = MethodChannel('com.saas_framework.ar/arkit');

  late ARSession _session;
  final List<ARPlane> _planes = [];
  final List<ARObject> _objects = [];
  final _planesController = StreamController<List<ARPlane>>.broadcast();
  final _objectsController = StreamController<List<ARObject>>.broadcast();

  bool _initialized = false;
  dynamic _arSession;
  Timer? _updateTimer;

  // ARKit features
  final List<Map<String, dynamic>> _detectedPlanes = [];
  final Map<String, Map<String, dynamic>> _trackedObjects = {};
  double _currentLightIntensity = 1.0;

  iOSARService() {
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
      print('[ARKit] Initializing ARKit session...');

      // Check ARKit availability
      final available = await platform.invokeMethod('checkARKitAvailable');
      if (!available) {
        throw Exception('ARKit not available on this device');
      }

      // Request camera permissions
      await _requestCameraPermissions();

      // Initialize ARKit
      final result = await platform.invokeMethod('initializeARKit');
      print('[ARKit] Initialize result: $result');

      _initialized = true;
      print('[ARKit] ARKit initialized successfully');
    } catch (e) {
      print('[ARKit] Initialization error: $e');
      _session = _session.copyWith(
        state: ARSessionState.error,
        error: 'Failed to initialize ARKit: $e',
      );
      rethrow;
    }
  }

  @override
  Future<void> startSession() async {
    try {
      print('[ARKit] Starting ARKit session...');

      // Create AR session configuration
      final config = {
        'planeDetection': 'all', // 'horizontal', 'vertical', 'all'
        'lightEstimation': true,
        'frameSemantics': 'personSegmentationWithDepth',
        'environmentTexturing': true,
        'targetFramerate': 60,
      };

      final result = await platform.invokeMethod('startARSession', config);
      print('[ARKit] Session start result: $result');

      _session = _session.copyWith(state: ARSessionState.running);

      // Start update loop
      _startUpdateLoop();

      // Setup event listeners
      _setupEventListeners();

      print('[ARKit] ARKit session started');
    } catch (e) {
      print('[ARKit] Session start error: $e');
      _session = _session.copyWith(
        state: ARSessionState.error,
        error: e.toString(),
      );
    }
  }

  @override
  Future<void> pauseSession() async {
    try {
      print('[ARKit] Pausing ARKit session...');
      _updateTimer?.cancel();

      final result = await platform.invokeMethod('pauseARSession');
      print('[ARKit] Session pause result: $result');

      _session = _session.copyWith(state: ARSessionState.paused);
    } catch (e) {
      print('[ARKit] Session pause error: $e');
    }
  }

  @override
  Future<void> resumeSession() async {
    try {
      print('[ARKit] Resuming ARKit session...');

      final result = await platform.invokeMethod('resumeARSession');
      print('[ARKit] Session resume result: $result');

      _session = _session.copyWith(state: ARSessionState.running);
      _startUpdateLoop();
    } catch (e) {
      print('[ARKit] Session resume error: $e');
    }
  }

  @override
  Future<void> stopSession() async {
    try {
      print('[ARKit] Stopping ARKit session...');
      _updateTimer?.cancel();

      final result = await platform.invokeMethod('stopARSession');
      print('[ARKit] Session stop result: $result');

      _session = _session.copyWith(state: ARSessionState.stopped);
      _planes.clear();
      _objects.clear();
      _planesController.add([]);
      _objectsController.add([]);
    } catch (e) {
      print('[ARKit] Session stop error: $e');
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
      print('[ARKit] Hit test at ($screenX, $screenY)');

      // Perform hit test using ARKit
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
      print('[ARKit] Hit test error: $e');
      return null;
    }
  }

  @override
  Future<void> placeObject(ARObject object) async {
    try {
      print('[ARKit] Placing object: ${object.name}');

      _trackedObjects[object.id] = {
        'object': object,
        'arAnchor': null,
      };

      _objects.add(object);
      _session = _session.copyWith(placedObjects: _objects);

      // Place object using ARKit
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
      print('[ARKit] Object placed: ${object.id}');
    } catch (e) {
      print('[ARKit] Place object error: $e');
    }
  }

  @override
  Future<void> updateObject(ARObject object) async {
    try {
      final index = _objects.indexWhere((o) => o.id == object.id);
      if (index != -1) {
        _objects[index] = object;

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
      print('[ARKit] Update object error: $e');
    }
  }

  @override
  Future<void> removeObject(String objectId) async {
    try {
      _objects.removeWhere((o) => o.id == objectId);
      _trackedObjects.remove(objectId);

      await platform.invokeMethod('removeObject', {
        'objectId': objectId,
      });

      _session = _session.copyWith(placedObjects: _objects);
      _objectsController.add(_objects);
    } catch (e) {
      print('[ARKit] Remove object error: $e');
    }
  }

  // ============ Private Methods ============

  /// Request camera permissions
  Future<void> _requestCameraPermissions() async {
    try {
      final result = await platform.invokeMethod('requestCameraPermission');
      print('[ARKit] Camera permission result: $result');
    } catch (e) {
      print('[ARKit] Camera permission error: $e');
    }
  }

  /// Setup event listeners untuk AR updates
  void _setupEventListeners() {
    platform.setMethodCallHandler((call) async {
      print('[ARKit] Received event: ${call.method}');

      try {
        switch (call.method) {
          case 'onPlanesDetected':
            final planes = call.arguments as List<dynamic>;
            await _handlePlanesDetected(planes);
            break;

          case 'onObjectTracked':
            final data = call.arguments as Map<dynamic, dynamic>;
            await _handleObjectTracked(data);
            break;

          case 'onLightingEstimation':
            final data = call.arguments as Map<dynamic, dynamic>;
            _currentLightIntensity = (data['intensity'] as num).toDouble();
            break;

          case 'onSessionError':
            final error = call.arguments as String?;
            _session = _session.copyWith(
              state: ARSessionState.error,
              error: error ?? 'Unknown error',
            );
            break;
        }
      } catch (e) {
        print('[ARKit] Event handling error: $e');
      }
    });
  }

  /// Handle planes detected event
  Future<void> _handlePlanesDetected(List<dynamic> planesData) async {
    _planes.clear();

    for (final planeData in planesData) {
      final plane = _createPlaneFromData(planeData as Map<dynamic, dynamic>);
      _planes.add(plane);
    }

    _session = _session.copyWith(detectedPlanes: _planes);
    _planesController.add(_planes);
    print('[ARKit] ${_planes.length} planes detected');
  }

  /// Handle object tracked event
  Future<void> _handleObjectTracked(Map<dynamic, dynamic> data) async {
    final objectId = data['objectId'] as String?;
    if (objectId != null) {
      final index = _objects.indexWhere((o) => o.id == objectId);
      if (index != -1) {
        _objects[index] = _objects[index].copyWith(
          position: Vector3(
            x: (data['x'] as num?)?.toDouble() ?? 0.0,
            y: (data['y'] as num?)?.toDouble() ?? 0.0,
            z: (data['z'] as num?)?.toDouble() ?? 0.0,
          ),
        );

        _session = _session.copyWith(placedObjects: _objects);
        _objectsController.add(_objects);
      }
    }
  }

  /// Start update loop
  void _startUpdateLoop() {
    _updateTimer = Timer.periodic(Duration(milliseconds: 33), (_) async {
      try {
        // The updates are handled by event listeners
        // This timer just ensures periodic checks
        if (_session.state != ARSessionState.running) {
          _updateTimer?.cancel();
        }
      } catch (e) {
        print('[ARKit] Update loop error: $e');
      }
    });
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
