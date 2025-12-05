// Platform-Specific AR Implementation Examples
// File: lib/examples/ar_platform_examples.dart

// ============================================================================
// ANDROID AR EXAMPLE - Using ARCore
// ============================================================================

class AndroidARExample {
  /// Real ARCore implementation example
  /// 
  /// This shows how to implement actual plane detection using ARCore
  /// in the Android platform service.
  
  static const String description = '''
  // Android AR Implementation Flow:
  
  1. REQUEST PERMISSIONS
     - Ask user for camera permission
     - Handle permission denied state
  
  2. INITIALIZE ARCORE
     - Check ARCore availability
     - Create ARSession
     - Start frame listener
  
  3. DETECT PLANES
     - ARCore automatically detects planes
     - Filter planes by confidence (> 0.5)
     - Emit via planesStream
  
  4. HIT TEST
     - User taps on screen
     - Get screen coordinates
     - ARCore computes intersection with planes
     - Return ARHitTestResult
  
  5. PLACE OBJECT
     - Create 3D object at hit point
     - Set initial rotation (snap to plane normal)
     - Store in objects list
     - Emit via objectsStream
  
  6. TRANSFORM OBJECT
     - User gestures to move/rotate/scale
     - Update object pose
     - ARCore transforms based on current camera
     - Re-render
  
  7. DISPOSE
     - Stop frame listener
     - Close ARSession
     - Release resources
  ''';
  
  // Implementation pseudocode:
  static String implementationTemplate = '''
import 'package:ar_flutter_plugin_engine/ar_flutter_plugin_engine.dart';
import 'dart:typed_data';

class AndroidARServiceImpl extends ARPlatformService {
  late ArFlutterPlugin _arPlugin;
  late ArSession _arSession;
  late ArFrame _arFrame;
  
  final List<ARPlane> _detectedPlanes = [];
  final List<ARObject> _placedObjects = [];
  
  @override
  Future<void> initialize() async {
    _arPlugin = ArFlutterPlugin();
    
    // Check ARCore availability
    final available = await _arPlugin.checkArAvailability();
    if (!available) {
      throw ARException(
        'ARCore not available on this device',
        code: 'ARCORE_NOT_AVAILABLE',
      );
    }
    
    print('[Android AR] ARCore available');
  }
  
  @override
  Future<void> startSession() async {
    // Create AR session with plane detection
    _arSession = await _arPlugin.createArSession(
      config: ArSessionConfig(
        enablePlaneDetection: true,
        enableLightEstimation: true,
        enableSemanticMode: true,
      ),
    );
    
    // Start frame listener
    _arSession.frameStream.listen(_onArFrame);
    
    print('[Android AR] Session started');
  }
  
  void _onArFrame(ArFrame frame) {
    _arFrame = frame;
    
    // Update detected planes
    _detectedPlanes.clear();
    final planes = frame.getUpdatedPlanes();
    
    for (final plane in planes) {
      if (plane.trackingState == TrackingState.tracking &&
          plane.getSubsumedBy() == null) {  // Ignore subsumed planes
        
        _detectedPlanes.add(ARPlane(
          id: plane.id,
          center: Vector3(
            x: plane.centerPose.tx,
            y: plane.centerPose.ty,
            z: plane.centerPose.tz,
          ),
          normal: Vector3(
            x: plane.normal.x,
            y: plane.normal.y,
            z: plane.normal.z,
          ),
          extent: Vector3(
            x: plane.extentX,
            y: plane.extentZ,
            z: 0,
          ),
          polygon: plane.polygon,  // 2D polygon in plane coordinates
          confidence: plane.trackingConfidence,
          timestamp: DateTime.now(),
        ));
      }
    }
    
    // Emit planes stream
    planesStreamController.add(_detectedPlanes);
    
    // Update light estimation
    final lightEstimate = frame.lightEstimate;
    if (lightEstimate != null) {
      // Update lighting for 3D rendering
    }
  }
  
  @override
  Future<ARHitTestResult?> hitTest(double screenX, double screenY) async {
    if (_arFrame == null) return null;
    
    try {
      // Create hit test query
      final hitTestResults = _arFrame.hitTest(
        x: screenX,
        y: screenY,
        types: HitTestType.plane | HitTestType.estimatedPlane,
      );
      
      if (hitTestResults.isNotEmpty) {
        final hitResult = hitTestResults.first;
        
        // Get intersection point and rotation
        final pose = hitResult.hitPose;
        
        return ARHitTestResult(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          hitPoint: Vector3(
            x: pose.tx,
            y: pose.ty,
            z: pose.tz,
          ),
          estimatedRotation: Quaternion(
            x: pose.qx,
            y: pose.qy,
            z: pose.qz,
            w: pose.qw,
          ),
          distance: _calculateDistance(pose),
          planeId: hitResult.trackable.id,
        );
      }
    } catch (e) {
      print('[Android AR] Hit test error: \$e');
    }
    
    return null;
  }
  
  @override
  Future<void> placeObject(ARObject object) async {
    _placedObjects.add(object);
    objectsStreamController.add(_placedObjects);
    print('[Android AR] Object placed: \${object.id}');
  }
  
  @override
  Future<void> updateObjectTransform(
    String objectId,
    Vector3 position,
    Quaternion rotation,
    Vector3 scale,
  ) async {
    final index = _placedObjects.indexWhere((o) => o.id == objectId);
    if (index >= 0) {
      _placedObjects[index] = _placedObjects[index].copyWith(
        position: position,
        rotation: rotation,
        scale: scale,
      );
      objectsStreamController.add(_placedObjects);
    }
  }
  
  @override
  Future<void> removeObject(String objectId) async {
    _placedObjects.removeWhere((o) => o.id == objectId);
    objectsStreamController.add(_placedObjects);
  }
  
  @override
  Future<void> dispose() async {
    await _arSession.pause();
    await _arSession.close();
    print('[Android AR] Session disposed');
  }
  
  double _calculateDistance(Pose pose) {
    // Calculate distance from camera origin
    return (pose.tx * pose.tx + 
            pose.ty * pose.ty + 
            pose.tz * pose.tz)
        .sqrt();
  }
}
  ''';
}

// ============================================================================
// iOS AR EXAMPLE - Using ARKit
// ============================================================================

class IOSARExample {
  /// Real ARKit implementation example
  
  static const String description = '''
  // iOS AR Implementation Flow (Same as Android, using ARKit):
  
  1. REQUEST PERMISSIONS
     - Ask user for camera permission
     - Handle permission denied state
  
  2. INITIALIZE ARKIT
     - Check ARKit availability (iOS 14.3+, A9+ chip)
     - Create ARSession
     - Configure with plane detection
  
  3. DETECT PLANES
     - ARKit detects horizontal and vertical planes
     - Filter by tracking state and confidence
     - Convert to ARPlane model
     - Emit via planesStream
  
  4. HIT TEST
     - User taps on screen
     - Convert screen to ARKit coordinates
     - Test intersection with planes
     - Return ARHitTestResult
  
  5. PLACE OBJECT
     - Create node in AR scene
     - Position at hit point
     - Orient to plane normal
     - Emit via objectsStream
  
  6. TRANSFORM OBJECT
     - User gestures (pinch, rotate, drag)
     - Update node transform
     - ARKit handles camera-relative positioning
     - Re-render via Scene Kit
  
  7. DISPOSE
     - Pause AR session
     - Release scene
     - Cleanup resources
  ''';
  
  // Implementation pseudocode:
  static String implementationTemplate = '''
import 'package:arkit_flutter_plugin/arkit_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class IOSARServiceImpl extends ARPlatformService {
  late ARKitController _arkitController;
  final List<ARPlane> _detectedPlanes = [];
  final List<ARObject> _placedObjects = [];
  
  @override
  Future<void> initialize() async {
    // Check ARKit availability
    final available = await ARKitPlugin.checkIsARKitAvailable();
    if (!available) {
      throw ARException(
        'ARKit not available on this device',
        code: 'ARKIT_NOT_AVAILABLE',
      );
    }
    
    print('[iOS AR] ARKit available');
  }
  
  @override
  Future<void> startSession() async {
    // ARKitController setup via widget is required
    // This shows the implementation logic
    
    // Initialize with plane detection
    final config = ARKitConfiguration(
      planeDetection: [
        ARPlaneDetection.horizontal,
        ARPlaneDetection.vertical,
      ],
      lightEstimationEnabled: true,
      worldAlignment: ARWorldAlignment.gravity,
    );
    
    // Update planes when detected
    _arkitController.onArSessionDidUpdate = (ARKitSessionUpdate update) {
      _updateDetectedPlanes(update.addedAnchors);
      _updateDetectedPlanes(update.updatedAnchors);
    };
    
    print('[iOS AR] Session started');
  }
  
  void _updateDetectedPlanes(List<ARKitAnchor> anchors) {
    _detectedPlanes.clear();
    
    for (final anchor in anchors) {
      if (anchor is ARPlaneAnchor) {
        _detectedPlanes.add(ARPlane(
          id: anchor.identifier,
          center: Vector3(
            x: anchor.center.x,
            y: anchor.center.y,
            z: anchor.center.z,
          ),
          normal: Vector3(
            x: anchor.extent.x,  // Extent used for size
            y: anchor.extent.y,
            z: anchor.extent.z,
          ),
          extent: Vector3(
            x: anchor.extent.x,
            y: anchor.extent.y,
            z: anchor.extent.z,
          ),
          confidence: 1.0,  // ARKit doesn't provide confidence
          timestamp: DateTime.now(),
        ));
      }
    }
    
    planesStreamController.add(_detectedPlanes);
  }
  
  @override
  Future<ARHitTestResult?> hitTest(double screenX, double screenY) async {
    try {
      // Perform hit test against planes
      final hitResults = await _arkitController.hitTest(
        ARPoint(x: screenX, y: screenY),
        types: [ARHitTestResultType.existingPlane],
      );
      
      if (hitResults.isNotEmpty) {
        final hitResult = hitResults.first;
        
        // Convert ARKit result to our model
        final position = hitResult.worldTransform.translation;
        
        return ARHitTestResult(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          hitPoint: Vector3(
            x: position.x,
            y: position.y,
            z: position.z,
          ),
          estimatedRotation: Quaternion.identity(),  // TODO: Extract from transform
          distance: _calculateDistance(position),
          planeId: hitResult.anchor?.identifier,
        );
      }
    } catch (e) {
      print('[iOS AR] Hit test error: \$e');
    }
    
    return null;
  }
  
  @override
  Future<void> placeObject(ARObject object) async {
    // Create 3D node in ARKit
    final node = ARKitNode(
      name: object.id,
      geometry: ARKitSphere(radius: 0.1),  // Example: sphere
      position: ARKitVector3(
        x: object.position.x,
        y: object.position.y,
        z: object.position.z,
      ),
    );
    
    // Add to scene
    await _arkitController.addNode(node);
    
    _placedObjects.add(object);
    objectsStreamController.add(_placedObjects);
    
    print('[iOS AR] Object placed: \${object.id}');
  }
  
  @override
  Future<void> updateObjectTransform(
    String objectId,
    Vector3 position,
    Quaternion rotation,
    Vector3 scale,
  ) async {
    // Update node position in ARKit
    await _arkitController.updateNode(
      objectId,
      geometry: null,
      position: ARKitVector3(
        x: position.x,
        y: position.y,
        z: position.z,
      ),
      scale: ARKitVector3(
        x: scale.x,
        y: scale.y,
        z: scale.z,
      ),
    );
    
    final index = _placedObjects.indexWhere((o) => o.id == objectId);
    if (index >= 0) {
      _placedObjects[index] = _placedObjects[index].copyWith(
        position: position,
        rotation: rotation,
        scale: scale,
      );
      objectsStreamController.add(_placedObjects);
    }
  }
  
  @override
  Future<void> removeObject(String objectId) async {
    await _arkitController.removeNode(objectId);
    _placedObjects.removeWhere((o) => o.id == objectId);
    objectsStreamController.add(_placedObjects);
  }
  
  @override
  Future<void> dispose() async {
    await _arkitController.dispose();
    print('[iOS AR] Session disposed');
  }
  
  double _calculateDistance(vm.Vector3 position) {
    return position.length;  // Vector math library provides length
  }
}
  ''';
}

// ============================================================================
// WEB AR EXAMPLE - Using WebXR + Babylon.js
// ============================================================================

class WebARExample {
  /// Real WebXR + Babylon.js implementation example
  
  static const String description = '''
  // Web AR Implementation Flow:
  
  1. CHECK WEBXR SUPPORT
     - Verify navigator.xr available
     - Check browser compatibility
  
  2. REQUEST XR SESSION
     - Request 'immersive-ar' session
     - Handle user permission
     - Configure WebXR features
  
  3. INITIALIZE BABYLON SCENE
     - Create 3D scene
     - Setup camera and lights
     - Enable shadow rendering
  
  4. DETECT "PLANES" (Mock)
     - For development, use mock plane data
     - In production, use XR hit-test API
     - Emit via planesStream
  
  5. HIT TEST
     - User taps on screen
     - Use XR hit-test API
     - Returns intersection with virtual planes
  
  6. PLACE OBJECT
     - Create Babylon.js mesh
     - Position at hit point
     - Add to scene
     - Emit via objectsStream
  
  7. TRANSFORM OBJECT
     - Update mesh position/rotation/scale
     - Babylon.js handles rendering
     - WebXR updates camera transform
     - Browser renders final image
  
  8. RENDER LOOP
     - XR frame loop: beforeRender → render → afterRender
     - WebXR camera tracks device orientation
     - Browser composites virtual + camera feed
  ''';
  
  // Implementation pseudocode:
  static String implementationTemplate = '''
import 'dart:js' as js;
import 'dart:html' as html;

class WebARServiceImpl extends ARPlatformService {
  late js.JsObject _xrSession;
  late js.JsObject _babylonScene;
  late js.JsObject _engine;
  
  final List<ARPlane> _detectedPlanes = [];
  final List<ARObject> _placedObjects = [];
  
  @override
  Future<void> initialize() async {
    // Check WebXR support
    if (!_hasWebXRSupport()) {
      throw ARException(
        'WebXR not supported in this browser',
        code: 'WEBXR_NOT_AVAILABLE',
      );
    }
    
    // Initialize Babylon.js
    await _initializeBabylonScene();
    
    print('[Web AR] WebXR and Babylon.js initialized');
  }
  
  bool _hasWebXRSupport() {
    return js.context['navigator']?['xr'] != null;
  }
  
  Future<void> _initializeBabylonScene() async {
    // Get canvas
    final canvas = html.document.getElementById('canvas') as html.CanvasElement?;
    if (canvas == null) {
      throw Exception('Canvas element not found');
    }
    
    // Create Babylon engine
    _engine = js.JsObject(
      js.context['BABYLON']['Engine'],
      [canvas, true],
    );
    
    // Create scene
    _babylonScene = js.JsObject(
      js.context['BABYLON']['Scene'],
      [_engine],
    );
    
    // Setup basic lighting
    _setupLighting();
    
    // Start render loop
    _startRenderLoop();
  }
  
  void _setupLighting() {
    // Create light sources for better visualization
    final hemLight = js.JsObject(
      js.context['BABYLON']['HemisphericLight'],
      ['hemiLight', 
       js.JsObject(js.context['BABYLON']['Vector3'], [0, 1, 0]),
       _babylonScene],
    );
    hemLight['intensity'] = 0.9;
    
    final pointLight = js.JsObject(
      js.context['BABYLON']['PointLight'],
      ['pointLight',
       js.JsObject(js.context['BABYLON']['Vector3'], [5, 5, 5]),
       _babylonScene],
    );
    pointLight['intensity'] = 0.5;
  }
  
  void _startRenderLoop() {
    // Babylon.js render loop
    _engine.callMethod('runRenderLoop', [js.allowInterop(() {
      _babylonScene.callMethod('render');
    })]);
    
    // Handle window resize
    html.window.onResize.listen((_) {
      _engine.callMethod('resize');
    });
  }
  
  @override
  Future<void> startSession() async {
    try {
      // Request XR session with AR features
      _xrSession = await js.context['navigator']['xr']
          .callMethod('requestSession', [
            'immersive-ar',
            js.JsObject.jsify({
              'requiredFeatures': ['hit-test', 'dom-overlay'],
              'domOverlay': {'root': html.document.body},
            }),
          ]) as js.JsObject;
      
      // Get WebXR camera
      await _setupXRCamera();
      
      print('[Web AR] XR Session started');
    } catch (e) {
      print('[Web AR] Error starting XR session: \$e');
      rethrow;
    }
  }
  
  Future<void> _setupXRCamera() async {
    // Get XR reference space (immersive-ar space)
    final refSpace = await _xrSession.callMethod(
      'requestReferenceSpace',
      ['viewer'],
    ) as js.JsObject;
    
    // Connect Babylon.js camera to WebXR
    // This allows camera to follow device orientation
    final camera = js.JsObject(
      js.context['BABYLON']['UniversalCamera'],
      ['xrCamera',
       js.JsObject(js.context['BABYLON']['Vector3'], [0, 1.6, 0]),
       _babylonScene],
    );
    
    // Make camera active
    _babylonScene['activeCamera'] = camera;
    
    // Emit initial plane (mock data for now)
    _emitMockPlanes();
  }
  
  void _emitMockPlanes() {
    // For development, create mock planes
    _detectedPlanes.clear();
    _detectedPlanes.addAll([
      ARPlane(
        id: 'plane_1',
        center: Vector3(x: 0, y: -0.5, z: -2),
        normal: Vector3(x: 0, y: 1, z: 0),  // Floor (horizontal)
        extent: Vector3(x: 5, y: 0, z: 5),
        confidence: 1.0,
        timestamp: DateTime.now(),
      ),
      ARPlane(
        id: 'plane_2',
        center: Vector3(x: 0, y: 1, z: -2),
        normal: Vector3(x: 0, y: 0, z: 1),  // Wall (vertical)
        extent: Vector3(x: 5, y: 3, z: 0),
        confidence: 1.0,
        timestamp: DateTime.now(),
      ),
    ]);
    
    planesStreamController.add(_detectedPlanes);
  }
  
  @override
  Future<ARHitTestResult?> hitTest(double screenX, double screenY) async {
    try {
      // Use mock hit test for now
      // In production, use WebXR hit-test API
      
      // Normalize screen coordinates
      final normalizedX = screenX / html.window.innerWidth!;
      final normalizedY = screenY / html.window.innerHeight!;
      
      // Mock: return hit on floor plane
      return ARHitTestResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        hitPoint: Vector3(
          x: (normalizedX - 0.5) * 4,  // -2 to 2
          y: -0.5,  // Floor level
          z: -(normalizedY * 3 + 1),  // -1 to -4
        ),
        estimatedRotation: Quaternion.identity(),
        distance: 2.0,
        planeId: 'plane_1',
      );
    } catch (e) {
      print('[Web AR] Hit test error: \$e');
      return null;
    }
  }
  
  @override
  Future<void> placeObject(ARObject object) async {
    try {
      // Create 3D mesh in Babylon.js
      final mesh = js.JsObject(
        js.context['BABYLON']['MeshBuilder'].callMethod('CreateBox', [
          object.id,
          js.JsObject.jsify({
            'width': object.scale.x,
            'height': object.scale.y,
            'depth': object.scale.z,
          }),
          _babylonScene,
        ]),
      );
      
      // Set position
      final pos = mesh['position'];
      pos['x'] = object.position.x;
      pos['y'] = object.position.y;
      pos['z'] = object.position.z;
      
      // Create material
      final material = js.JsObject(
        js.context['BABYLON']['StandardMaterial'],
        [object.id + '_mat', _babylonScene],
      );
      material['emissiveColor'] = 
        js.JsObject(js.context['BABYLON']['Color3'], [0.5, 0.5, 1.0]);
      mesh['material'] = material;
      
      _placedObjects.add(object);
      objectsStreamController.add(_placedObjects);
      
      print('[Web AR] Object placed: \${object.id}');
    } catch (e) {
      print('[Web AR] Error placing object: \$e');
    }
  }
  
  @override
  Future<void> updateObjectTransform(
    String objectId,
    Vector3 position,
    Quaternion rotation,
    Vector3 scale,
  ) async {
    try {
      // Find mesh by object ID
      final mesh = _babylonScene.callMethod(
        'getMeshByName',
        [objectId],
      ) as js.JsObject?;
      
      if (mesh != null) {
        // Update position
        mesh['position']['x'] = position.x;
        mesh['position']['y'] = position.y;
        mesh['position']['z'] = position.z;
        
        // Update scale
        mesh['scaling']['x'] = scale.x;
        mesh['scaling']['y'] = scale.y;
        mesh['scaling']['z'] = scale.z;
        
        // Update rotation (from quaternion)
        final euler = _quaternionToEuler(rotation);
        mesh['rotation']['x'] = euler.x;
        mesh['rotation']['y'] = euler.y;
        mesh['rotation']['z'] = euler.z;
        
        // Update local object
        final index = _placedObjects.indexWhere((o) => o.id == objectId);
        if (index >= 0) {
          _placedObjects[index] = _placedObjects[index].copyWith(
            position: position,
            rotation: rotation,
            scale: scale,
          );
          objectsStreamController.add(_placedObjects);
        }
      }
    } catch (e) {
      print('[Web AR] Error updating transform: \$e');
    }
  }
  
  @override
  Future<void> removeObject(String objectId) async {
    try {
      // Find and dispose mesh
      final mesh = _babylonScene.callMethod(
        'getMeshByName',
        [objectId],
      ) as js.JsObject?;
      
      if (mesh != null) {
        mesh.callMethod('dispose');
      }
      
      _placedObjects.removeWhere((o) => o.id == objectId);
      objectsStreamController.add(_placedObjects);
      
      print('[Web AR] Object removed: \$objectId');
    } catch (e) {
      print('[Web AR] Error removing object: \$e');
    }
  }
  
  @override
  Future<void> dispose() async {
    try {
      // Dispose Babylon.js
      _babylonScene.callMethod('dispose');
      _engine.callMethod('dispose');
      
      // End XR session
      await _xrSession.callMethod('end');
      
      print('[Web AR] Session disposed');
    } catch (e) {
      print('[Web AR] Dispose error: \$e');
    }
  }
  
  Vector3 _quaternionToEuler(Quaternion q) {
    // Convert quaternion to Euler angles
    // (Implementation details omitted for brevity)
    return Vector3(x: 0, y: 0, z: 0);
  }
}
  ''';
}

// ============================================================================
// COMPLETE FLOW DIAGRAM
// ============================================================================

const String completeFlowDiagram = '''
┌─────────────────────────────────────────────────────────────────┐
│                    UNIVERSAL AR SERVICE FLOW                    │
└─────────────────────────────────────────────────────────────────┘

[1] INITIALIZATION
    ├─ Check platform (Android/iOS/Web)
    ├─ Route to platform service
    ├─ Request permissions
    └─ Initialize platform-specific AR engine

    ANDROID: ARCore
    iOS: ARKit
    WEB: WebXR + Babylon.js

[2] SESSION START
    ├─ Start camera
    ├─ Enable plane detection
    ├─ Enable light estimation
    └─ Begin frame loop

[3] PLANE DETECTION (Continuous)
    ├─ Platform detects physical planes
    ├─ Filter by confidence and state
    ├─ Convert to ARPlane model
    └─ Emit via planesStream

    ANDROID: ARCore provides plane mesh
    iOS: ARKit provides plane anchor
    WEB: Mock 2 planes (floor + wall)

[4] USER INTERACTION (Tap on screen)
    ├─ Capture screen coordinates
    ├─ Perform hit test
    ├─ Find intersection with planes
    └─ Return ARHitTestResult

[5] PLACE OBJECT
    ├─ Create 3D object
    ├─ Position at hit point
    ├─ Snap to plane normal
    ├─ Add to scene
    └─ Emit via objectsStream

    ANDROID: Add AnchorNode to ArFragment
    iOS: Add SCNNode to ARView
    WEB: Create Babylon.js mesh

[6] TRANSFORM OBJECT (User gestures)
    ├─ Capture gesture (pinch/rotate/drag)
    ├─ Calculate new transform
    ├─ Update object position/rotation/scale
    └─ Re-render

    ANDROID: Update AnchorNode transform
    iOS: Update SCNNode transform
    WEB: Update Babylon.js mesh

[7] CLEANUP
    ├─ Pause session
    ├─ Release resources
    └─ Dispose platform service

    ANDROID: Close ArSession
    iOS: Pause ARSession
    WEB: End XRSession + dispose Babylon

┌─────────────────────────────────────────────────────────────────┐
│                   DATA MODELS & FLOW                            │
└─────────────────────────────────────────────────────────────────┘

User Interaction
      ↓
ARService (Singleton, Platform Detection)
      ↓
┌─────────────────────────────────────┐
│  Platform Service (Android/iOS/Web) │
├─────────────────────────────────────┤
│ · initialize()                      │
│ · startSession()                    │
│ · hitTest(x, y) → ARHitTestResult   │
│ · placeObject(ARObject)             │
│ · updateObjectTransform()           │
│ · removeObject()                    │
│ · dispose()                         │
└─────────────────────────────────────┘
      ↓
Native AR Engine (ARCore/ARKit/WebXR)
      ↓
Streams:
├─ planesStream → [ARPlane, ...]
├─ objectsStream → [ARObject, ...]
└─ errorStream → ARException

Models:
├─ Vector3 (x, y, z)
├─ Quaternion (x, y, z, w)
├─ ARPlane (id, center, normal, extent, ...)
├─ ARObject (id, position, rotation, scale, ...)
├─ ARCamera (fov, aspect, near, far)
├─ ARSession (state, config, ...)
└─ ARHitTestResult (hitPoint, estimatedRotation, ...)

┌─────────────────────────────────────────────────────────────────┐
│                    TESTING STRATEGY                             │
└─────────────────────────────────────────────────────────────────┘

Unit Tests:
├─ Vector3 math operations
├─ Quaternion conversions
├─ ARService platform routing
└─ Stream emissions

Widget Tests:
├─ ARView rendering
├─ Hit test detection
├─ Object placement UI
└─ Error handling

Integration Tests:
├─ Full AR session flow
├─ Multi-object management
├─ Transform operations
└─ Performance benchmarks

Platform Tests:
├─ Android: Real device or emulator with ARCore
├─ iOS: Real device or simulator (limited AR)
└─ Web: Chrome/Firefox with WebXR

Performance Targets:
├─ Frame rate: 30+ FPS
├─ Plane detection: < 3 seconds
├─ Object placement: Instant
├─ Memory usage: < 50MB
└─ Battery drain: < 10% per hour
''';
