import ARKit
import Flutter

/**
 * iOS Platform Channel Configuration untuk AR
 * 
 * Menghubungkan Dart layer dengan native ARKit implementation
 */
class ARKitPlatformChannelSetup {
    static let arKitHandler = ARKitHandler()
    
    /**
     * Setup method channel untuk iOS AR
     */
    static func setupARChannel(with controller: FlutterViewController) {
        let methodChannel = FlutterMethodChannel(
            name: ARKitHandler.channelName,
            binaryMessenger: controller.binaryMessenger
        )
        
        arKitHandler.methodChannel = methodChannel
        
        methodChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
            handleARMethodCall(call, result: result)
        }
        
        // Setup event channel untuk real-time updates
        let eventChannel = FlutterEventChannel(
            name: "com.saas_framework.ar/arkit_events",
            binaryMessenger: controller.binaryMessenger
        )
        
        eventChannel.setStreamHandler(AREventStreamHandler(handler: arKitHandler))
    }
    
    /**
     * Handle method calls dari Dart
     */
    private static func handleARMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            let success = arKitHandler.initialize()
            result(success ? ["status": "initialized"] : ["status": "error"])
            
        case "requestCameraPermission":
            result(arKitHandler.requestCameraPermission())
            
        case "checkARKitAvailable":
            result(["available": arKitHandler.checkARKitAvailable()])
            
        case "startARSession":
            let args = call.arguments as? [String: Any]
            result(arKitHandler.startARSession(config: args))
            
        case "pauseARSession":
            result(arKitHandler.pauseARSession())
            
        case "resumeARSession":
            result(arKitHandler.resumeARSession())
            
        case "stopARSession":
            result(arKitHandler.stopARSession())
            
        case "performHitTest":
            let args = call.arguments as? [String: Int]
            let x = args?["x"] ?? 0
            let y = args?["y"] ?? 0
            
            if let hitResult = arKitHandler.performHitTest(x: x, y: y) {
                result(hitResult)
            } else {
                result(nil)
            }
            
        case "getDetectedPlanes":
            result(arKitHandler.getDetectedPlanes())
            
        case "placeObject":
            let args = call.arguments as? [String: Any]
            let objectId = args?["objectId"] as? String ?? ""
            let name = args?["name"] as? String ?? "object"
            let modelPath = args?["modelPath"] as? String ?? ""
            let posX = (args?["positionX"] as? NSNumber)?.floatValue ?? 0
            let posY = (args?["positionY"] as? NSNumber)?.floatValue ?? 0
            let posZ = (args?["positionZ"] as? NSNumber)?.floatValue ?? 0
            let scaleX = (args?["scaleX"] as? NSNumber)?.floatValue ?? 1
            let scaleY = (args?["scaleY"] as? NSNumber)?.floatValue ?? 1
            let scaleZ = (args?["scaleZ"] as? NSNumber)?.floatValue ?? 1
            
            result(arKitHandler.placeObject(
                objectId: objectId,
                name: name,
                modelPath: modelPath,
                positionX: posX,
                positionY: posY,
                positionZ: posZ,
                scaleX: scaleX,
                scaleY: scaleY,
                scaleZ: scaleZ
            ))
            
        case "updateObject":
            let args = call.arguments as? [String: Any]
            let objectId = args?["objectId"] as? String ?? ""
            let posX = (args?["positionX"] as? NSNumber)?.floatValue ?? 0
            let posY = (args?["positionY"] as? NSNumber)?.floatValue ?? 0
            let posZ = (args?["positionZ"] as? NSNumber)?.floatValue ?? 0
            let rotX = (args?["rotationX"] as? NSNumber)?.floatValue ?? 0
            let rotY = (args?["rotationY"] as? NSNumber)?.floatValue ?? 0
            let rotZ = (args?["rotationZ"] as? NSNumber)?.floatValue ?? 0
            let rotW = (args?["rotationW"] as? NSNumber)?.floatValue ?? 1
            let scaleX = (args?["scaleX"] as? NSNumber)?.floatValue ?? 1
            let scaleY = (args?["scaleY"] as? NSNumber)?.floatValue ?? 1
            let scaleZ = (args?["scaleZ"] as? NSNumber)?.floatValue ?? 1
            
            result(arKitHandler.updateObject(
                objectId: objectId,
                positionX: posX,
                positionY: posY,
                positionZ: posZ,
                rotationX: rotX,
                rotationY: rotY,
                rotationZ: rotZ,
                rotationW: rotW,
                scaleX: scaleX,
                scaleY: scaleY,
                scaleZ: scaleZ
            ))
            
        case "removeObject":
            let args = call.arguments as? [String: Any]
            let objectId = args?["objectId"] as? String ?? ""
            result(arKitHandler.removeObject(objectId: objectId))
            
        case "getLightingEstimation":
            result(arKitHandler.getLightingEstimation())
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

/**
 * Event stream handler untuk real-time AR updates
 */
class AREventStreamHandler: NSObject, FlutterStreamHandler {
    let arKitHandler: ARKitHandler
    var eventSink: FlutterEventSink?
    
    init(handler: ARKitHandler) {
        self.arKitHandler = handler
    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
}
