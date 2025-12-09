import ARKit
import RealityKit
import Flutter

/**
 * ARKit Handler untuk iOS AR implementation
 *
 * Mengelola ARKit session, plane detection, dan object placement
 */
class ARKitHandler: NSObject, ARSessionDelegate {
    static let channelName = "com.saas_framework.ar/arkit"
    
    var methodChannel: FlutterMethodChannel?
    var arSession: ARSession?
    var arView: ARView?
    
    // Configuration
    var lightEstimationEnabled = true
    var personSegmentationEnabled = true
    var environmentTexturingEnabled = true
    var targetFramerate = 60
    
    // State tracking
    private var isSessionRunning = false
    private var detectedPlanes: [UUID: ARPlaneAnchor] = [:]
    private var trackedObjects: [String: AnchorEntity] = [:]
    
    // Initialize ARKit
    func initialize() -> Bool {
        // Check ARKit availability
        guard ARWorldTrackingConfiguration.isSupported else {
            return false
        }
        
        // Create AR session
        arSession = ARSession()
        arSession?.delegate = self
        
        return true
    }
    
    /**
     * Start ARKit session
     */
    func startARSession(config: [String: Any]?) -> [String: Any] {
        guard let session = arSession else {
            return ["status": "error", "message": "Session not initialized"]
        }
        
        // Parse configuration
        let planeDetection = config?["planeDetection"] as? String ?? "all"
        lightEstimationEnabled = config?["lightEstimation"] as? Bool ?? true
        personSegmentationEnabled = config?["frameSemantics"] as? String == "personSegmentationWithDepth"
        environmentTexturingEnabled = config?["environmentTexturing"] as? Bool ?? true
        targetFramerate = config?["targetFramerate"] as? Int ?? 60
        
        // Create configuration
        let arConfig = ARWorldTrackingConfiguration()
        
        // Set plane detection
        var planeDetectionOptions: ARWorldTrackingConfiguration.PlaneDetection = []
        switch planeDetection {
        case "horizontal":
            planeDetectionOptions = .horizontal
        case "vertical":
            planeDetectionOptions = .vertical
        case "all":
            planeDetectionOptions = [.horizontal, .vertical]
        default:
            planeDetectionOptions = [.horizontal, .vertical]
        }
        arConfig.planeDetection = planeDetectionOptions
        
        // Set light estimation
        if lightEstimationEnabled {
            arConfig.lightEstimationMode = .environmentTexture
        }
        
        // Set frame semantics
        if #available(iOS 13.0, *) {
            if personSegmentationEnabled {
                arConfig.frameSemantics.insert(.personSegmentationWithDepth)
            }
        }
        
        // Set environment texturing
        if #available(iOS 12.0, *) {
            if environmentTexturingEnabled {
                arConfig.environmentTexturingMode = .automatic
            }
        }
        
        // Run configuration
        session.run(arConfig)
        isSessionRunning = true
        
        return ["status": "started"]
    }
    
    /**
     * Pause ARKit session
     */
    func pauseARSession() -> [String: Any] {
        arSession?.pause()
        isSessionRunning = false
        return ["status": "paused"]
    }
    
    /**
     * Resume ARKit session
     */
    func resumeARSession() -> [String: Any] {
        guard let session = arSession else {
            return ["status": "error"]
        }
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        session.run(config)
        isSessionRunning = true
        
        return ["status": "resumed"]
    }
    
    /**
     * Stop ARKit session
     */
    func stopARSession() -> [String: Any] {
        arSession?.pause()
        isSessionRunning = false
        detectedPlanes.removeAll()
        trackedObjects.removeAll()
        return ["status": "stopped"]
    }
    
    /**
     * Check ARKit availability
     */
    func checkARKitAvailable() -> Bool {
        return ARWorldTrackingConfiguration.isSupported
    }
    
    /**
     * Request camera permission
     */
    func requestCameraPermission() -> [String: Any] {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            // Permission handled by Flutter
        }
        return ["status": "requested"]
    }
    
    /**
     * Perform hit test
     */
    func performHitTest(x: Int, y: Int) -> [String: Any]? {
        guard let frame = arSession?.currentFrame else {
            return nil
        }
        
        let query = frame.raycastQuery(
            from: CGPoint(x: CGFloat(x), y: CGFloat(y)),
            allowing: .estimatedPlane,
            alignment: .any
        )
        
        guard let query = query else { return nil }
        
        let results = arSession?.raycast(query)
        guard let result = results?.first else { return nil }
        
        let transform = result.worldTransform
        
        return [
            "hitX": transform.translation.x,
            "hitY": transform.translation.y,
            "hitZ": transform.translation.z,
            "rotX": 0.0,
            "rotY": 0.0,
            "rotZ": 0.0,
            "rotW": 1.0,
            "distance": simd_length(transform.translation),
            "planeId": "plane_hit_test"
        ]
    }
    
    /**
     * Get detected planes
     */
    func getDetectedPlanes() -> [[String: Any]] {
        guard let frame = arSession?.currentFrame else {
            return []
        }
        
        var planes: [[String: Any]] = []
        
        for anchor in frame.anchors {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                // Update detected planes
                detectedPlanes[anchor.identifier] = planeAnchor
                
                // Get plane geometry
                var polygonPoints: [[String: Float]] = []
                
                if #available(iOS 14.0, *) {
                    let geometry = planeAnchor.geometry
                    for vertex in geometry.vertices {
                        polygonPoints.append([
                            "x": vertex.x,
                            "y": 0,
                            "z": vertex.z
                        ])
                    }
                }
                
                let planeData: [String: Any] = [
                    "id": planeAnchor.identifier.uuidString,
                    "centerX": planeAnchor.center.x,
                    "centerY": planeAnchor.center.y,
                    "centerZ": planeAnchor.center.z,
                    "normalX": planeAnchor.normal.x,
                    "normalY": planeAnchor.normal.y,
                    "normalZ": planeAnchor.normal.z,
                    "extentX": planeAnchor.extent.x,
                    "extentZ": planeAnchor.extent.z,
                    "isHorizontal": planeAnchor.alignment == .horizontal,
                    "confidence": 0.95,
                    "polygon": polygonPoints
                ]
                
                planes.append(planeData)
                
                // Notify Dart about plane detection
                methodChannel?.invokeMethod("onPlanesDetected", arguments: planes)
            }
        }
        
        return planes
    }
    
    /**
     * Place object di AR scene
     */
    func placeObject(objectId: String, name: String, modelPath: String, 
                     positionX: Float, positionY: Float, positionZ: Float,
                     scaleX: Float, scaleY: Float, scaleZ: Float) -> [String: Any] {
        guard let frame = arSession?.currentFrame else {
            return ["status": "error", "message": "No frame available"]
        }
        
        // Create anchor at position
        var transform = float4x4()
        transform.translation = [positionX, positionY, positionZ]
        
        let anchor = AnchorEntity(world: transform)
        anchor.name = name
        
        // Scale anchor
        anchor.scale = [scaleX, scaleY, scaleZ]
        
        // Store anchor
        trackedObjects[objectId] = anchor
        
        // Notify about object placement
        let objectData: [String: Any] = [
            "objectId": objectId,
            "name": name,
            "status": "placed"
        ]
        methodChannel?.invokeMethod("onObjectPlaced", arguments: objectData)
        
        return ["status": "placed", "objectId": objectId]
    }
    
    /**
     * Update object position
     */
    func updateObject(objectId: String, positionX: Float, positionY: Float, positionZ: Float,
                      rotationX: Float, rotationY: Float, rotationZ: Float, rotationW: Float,
                      scaleX: Float, scaleY: Float, scaleZ: Float) -> [String: Any] {
        guard let anchor = trackedObjects[objectId] else {
            return ["status": "error", "message": "Object not found"]
        }
        
        // Update transform
        var transform = float4x4()
        transform.translation = [positionX, positionY, positionZ]
        
        // Apply rotation
        let quaternion = simd_quatf(ix: rotationX, iy: rotationY, iz: rotationZ, r: rotationW)
        transform = float4x4(translation: transform.translation) * 
                   float4x4(quaternion)
        
        anchor.move(to: transform, relativeTo: nil, duration: 0.1, timingFunction: .linear)
        
        // Update scale
        anchor.scale = [scaleX, scaleY, scaleZ]
        
        return ["status": "updated"]
    }
    
    /**
     * Remove object
     */
    func removeObject(objectId: String) -> [String: Any] {
        guard let anchor = trackedObjects.removeValue(forKey: objectId) else {
            return ["status": "error", "message": "Object not found"]
        }
        
        anchor.removeFromParent()
        
        return ["status": "removed"]
    }
    
    /**
     * Get lighting estimation
     */
    func getLightingEstimation() -> [String: Any]? {
        guard let frame = arSession?.currentFrame else {
            return nil
        }
        
        guard let lightEstimate = frame.lightEstimate else {
            return nil
        }
        
        return [
            "intensity": lightEstimate.ambientIntensity,
            "colorTemperature": lightEstimate.ambientColorTemperature,
            "primaryLightDirection": [0.0, 1.0, 0.0] // Normalized
        ]
    }
    
    // MARK: - ARSessionDelegate
    
    func session(_ session: ARSession, didUpdate anchors: [AnchorProtocol]) {
        for anchor in anchors {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                // Update plane
                detectedPlanes[planeAnchor.identifier] = planeAnchor
                
                // Notify Dart
                let planeData: [String: Any] = [
                    "id": planeAnchor.identifier.uuidString,
                    "centerX": planeAnchor.center.x,
                    "centerY": planeAnchor.center.y,
                    "centerZ": planeAnchor.center.z
                ]
                methodChannel?.invokeMethod("onPlaneUpdated", arguments: planeData)
            }
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        print("[ARKit] Session error: \(error.localizedDescription)")
        
        methodChannel?.invokeMethod("onSessionError", arguments: [
            "error": error.localizedDescription
        ])
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        print("[ARKit] Session interrupted")
        isSessionRunning = false
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        print("[ARKit] Session interruption ended")
        // Resume session
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        session.run(config)
        isSessionRunning = true
    }
}

// MARK: - Extension for float4x4

extension float4x4 {
    var translation: SIMD3<Float> {
        get { columns.3.xyz }
        set {
            var m = self
            m.columns.3 = [newValue.x, newValue.y, newValue.z, 1]
            self = m
        }
    }
    
    init(translation: SIMD3<Float>) {
        self = matrix_identity_float4x4
        self.translation = translation
    }
    
    init(_ quaternion: simd_quatf) {
        let qx = quaternion.vector.x
        let qy = quaternion.vector.y
        let qz = quaternion.vector.z
        let qw = quaternion.vector.w
        
        let x2 = qx + qx
        let y2 = qy + qy
        let z2 = qz + qz
        
        let xx = qx * x2
        let xy = qx * y2
        let xz = qx * z2
        let yy = qy * y2
        let yz = qy * z2
        let zz = qz * z2
        let wx = qw * x2
        let wy = qw * y2
        let wz = qw * z2
        
        var result = matrix_identity_float4x4
        result.columns.0.x = 1 - (yy + zz)
        result.columns.0.y = xy + wz
        result.columns.0.z = xz - wy
        
        result.columns.1.x = xy - wz
        result.columns.1.y = 1 - (xx + zz)
        result.columns.1.z = yz + wx
        
        result.columns.2.x = xz + wy
        result.columns.2.y = yz - wx
        result.columns.2.z = 1 - (xx + yy)
        
        self = result
    }
}

extension SIMD3 {
    var xyz: SIMD3<Scalar> {
        return self
    }
}
