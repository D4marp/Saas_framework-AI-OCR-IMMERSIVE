package com.saas_framework.ar

import android.Manifest
import android.content.pm.PackageManager
import android.graphics.Color
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.google.ar.core.*
import com.google.ar.core.exceptions.CameraNotAvailableException
import com.google.ar.core.exceptions.UnavailableApkTooOldException
import com.google.ar.core.exceptions.UnavailableDeviceNotCompatibleException
import com.google.ar.core.exceptions.UnavailableSdkTooOldException
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import java.util.*
import kotlin.collections.ArrayList

/**
 * ARCore Handler untuk Android AR implementation
 *
 * Mengelola ARCore session, plane detection, dan object placement
 */
class ARCoreHandler(private val flutterEngine: FlutterEngine) {
    companion object {
        const val CHANNEL_NAME = "com.saas_framework.ar/arcore"
        const val PERMISSION_REQUEST_CODE = 100
        
        // ARCore configuration constants
        const val MAX_PLANES = 100
        const val PLANE_UPDATE_INTERVAL = 33L // ~30 FPS
    }

    private val methodChannel: MethodChannel
    private var arSession: Session? = null
    private val detectedPlanes = mutableMapOf<String, Plane>()
    private val trackedObjects = mutableMapOf<String, ObjectAnchor>()
    private var isSessionRunning = false

    // Configuration
    private var lightEstimationEnabled = true
    private var cloudAnchorEnabled = false
    private var instantPlacementMode = InstantPlacementMode.DISABLED
    private var depthMode = Config.DepthMode.AUTOMATIC

    init {
        methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_NAME
        )
        setupMethodCallHandler()
    }

    /**
     * Setup method call handler untuk komunikasi dengan Dart
     */
    private fun setupMethodCallHandler() {
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "initializeARCore" -> initializeARCore(result)
                "startARSession" -> {
                    val args = call.arguments as? Map<*, *>
                    startARSession(args, result)
                }
                "pauseARSession" -> pauseARSession(result)
                "resumeARSession" -> resumeARSession(result)
                "stopARSession" -> stopARSession(result)
                "requestPermissions" -> requestPermissions(result)
                "performHitTest" -> {
                    val args = call.arguments as? Map<*, *>
                    performHitTest(args, result)
                }
                "getDetectedPlanes" -> getDetectedPlanes(result)
                "placeObject" -> {
                    val args = call.arguments as? Map<*, *>
                    placeObject(args, result)
                }
                "updateObject" -> {
                    val args = call.arguments as? Map<*, *>
                    updateObject(args, result)
                }
                "removeObject" -> {
                    val args = call.arguments as? Map<*, *>
                    removeObject(args, result)
                }
                "getObjectPosition" -> {
                    val args = call.arguments as? Map<*, *>
                    getObjectPosition(args, result)
                }
                "getLightingEstimation" -> getLightingEstimation(result)
                else -> result.notImplemented()
            }
        }
    }

    /**
     * Initialize ARCore session
     */
    private fun initializeARCore(result: MethodChannel.Result) {
        try {
            // Check ARCore availability
            when (ArCoreApk.getInstance().checkAvailability(getActivity())) {
                ArCoreApk.Availability.SUPPORTED_INSTALLED -> {
                    // Continue
                }
                ArCoreApk.Availability.SUPPORTED_APK_TOO_OLD -> {
                    result.error("ARCore_OLD", "ARCore APK is too old", null)
                    return
                }
                ArCoreApk.Availability.UNSUPPORTED_DEVICE_NOT_CAPABLE -> {
                    result.error("ARCore_UNSUPPORTED", "Device not capable of AR", null)
                    return
                }
                ArCoreApk.Availability.UNKNOWN_CHECKING -> {
                    result.success(mapOf("status" to "checking"))
                    return
                }
                ArCoreApk.Availability.UNKNOWN_ERROR -> {
                    result.error("ARCore_ERROR", "Unknown ARCore error", null)
                    return
                }
                else -> {
                    result.error("ARCore_ERROR", "Unknown error", null)
                    return
                }
            }

            // Create ARCore session
            arSession = Session(getActivity())
            result.success(mapOf("status" to "initialized"))
        } catch (e: CameraNotAvailableException) {
            result.error("CAMERA_NOT_AVAILABLE", e.message, null)
        } catch (e: UnavailableApkTooOldException) {
            result.error("ARCore_OLD", e.message, null)
        } catch (e: UnavailableSdkTooOldException) {
            result.error("SDK_OLD", e.message, null)
        } catch (e: UnavailableDeviceNotCompatibleException) {
            result.error("DEVICE_NOT_COMPATIBLE", e.message, null)
        } catch (e: Exception) {
            result.error("ERROR", e.message, null)
        }
    }

    /**
     * Start AR session dengan configuration
     */
    private fun startARSession(args: Map<*, *>?, result: MethodChannel.Result) {
        try {
            val session = arSession ?: throw Exception("ARCore session not initialized")

            // Parse configuration
            lightEstimationEnabled = (args?.get("lightEstimation") as? Boolean) ?: true
            cloudAnchorEnabled = (args?.get("cloudAnchor") as? Boolean) ?: false
            val depthModeStr = (args?.get("depthMode") as? String) ?: "AUTOMATIC"
            
            // Parse instant placement mode
            val instantPlacementStr = (args?.get("instantPlacementMode") as? String) ?: "DISABLED"
            instantPlacementMode = when (instantPlacementStr) {
                "LOCAL_ONLY" -> InstantPlacementMode.LOCAL_ONLY
                "GLOBAL" -> InstantPlacementMode.GLOBAL
                else -> InstantPlacementMode.DISABLED
            }

            // Create and configure session
            val config = Config(session)

            // Set plane detection mode
            config.planeFindingMode = Config.PlaneFindingMode.HORIZONTAL_AND_VERTICAL

            // Set light estimation
            if (lightEstimationEnabled) {
                config.lightEstimationMode = Config.LightEstimationMode.ENVIRONMENTAL_HDR
            }

            // Set depth mode
            config.depthMode = when (depthModeStr) {
                "RAW_DEPTH_ONLY" -> Config.DepthMode.RAW_DEPTH_ONLY
                "AUTOMATIC" -> Config.DepthMode.AUTOMATIC
                else -> Config.DepthMode.AUTOMATIC
            }

            // Configure instant placement
            config.instantPlacementMode = instantPlacementMode

            // Apply configuration
            session.configure(config)
            isSessionRunning = true

            result.success(mapOf("status" to "started"))
        } catch (e: Exception) {
            result.error("ERROR", e.message, null)
        }
    }

    /**
     * Pause AR session
     */
    private fun pauseARSession(result: MethodChannel.Result) {
        try {
            arSession?.pause()
            isSessionRunning = false
            result.success(mapOf("status" to "paused"))
        } catch (e: Exception) {
            result.error("ERROR", e.message, null)
        }
    }

    /**
     * Resume AR session
     */
    private fun resumeARSession(result: MethodChannel.Result) {
        try {
            arSession?.resume()
            isSessionRunning = true
            result.success(mapOf("status" to "resumed"))
        } catch (e: Exception) {
            result.error("ERROR", e.message, null)
        }
    }

    /**
     * Stop AR session
     */
    private fun stopARSession(result: MethodChannel.Result) {
        try {
            arSession?.close()
            isSessionRunning = false
            detectedPlanes.clear()
            trackedObjects.clear()
            result.success(mapOf("status" to "stopped"))
        } catch (e: Exception) {
            result.error("ERROR", e.message, null)
        }
    }

    /**
     * Request AR-related permissions
     */
    private fun requestPermissions(result: MethodChannel.Result) {
        val activity = getActivity()
        val permissions = arrayOf(
            Manifest.permission.CAMERA,
            Manifest.permission.ACCESS_FINE_LOCATION
        )

        val permissionsNeeded = permissions.filter {
            ContextCompat.checkSelfPermission(activity, it) != PackageManager.PERMISSION_GRANTED
        }

        if (permissionsNeeded.isNotEmpty()) {
            ActivityCompat.requestPermissions(
                activity,
                permissionsNeeded.toTypedArray(),
                PERMISSION_REQUEST_CODE
            )
        }

        result.success(mapOf(
            "status" to "permissions_requested",
            "requested" to permissionsNeeded.size
        ))
    }

    /**
     * Perform hit test pada screen coordinates
     */
    private fun performHitTest(args: Map<*, *>?, result: MethodChannel.Result) {
        try {
            val session = arSession ?: throw Exception("Session not initialized")
            val frame = session.update() ?: throw Exception("Failed to update frame")

            val x = (args?.get("x") as? Number)?.toInt() ?: 0
            val y = (args?.get("y") as? Number)?.toInt() ?: 0

            // Perform hit test
            val hitTestResults = frame.hitTest(x.toFloat(), y.toFloat())

            if (hitTestResults.isNotEmpty()) {
                val hit = hitTestResults[0]
                val hitPose = hit.hitPose

                result.success(mapOf(
                    "hitX" to hitPose.tx(),
                    "hitY" to hitPose.ty(),
                    "hitZ" to hitPose.tz(),
                    "rotX" to 0.0,
                    "rotY" to 0.0,
                    "rotZ" to 0.0,
                    "rotW" to 1.0,
                    "distance" to hit.distance,
                    "planeId" to (hit.trackable as? Plane)?.index?.toString()
                ))
            } else {
                result.success(null)
            }
        } catch (e: Exception) {
            result.error("ERROR", e.message, null)
        }
    }

    /**
     * Get detected planes
     */
    private fun getDetectedPlanes(result: MethodChannel.Result) {
        try {
            val session = arSession ?: throw Exception("Session not initialized")
            val frame = session.update() ?: throw Exception("Failed to update frame")

            val planes = mutableListOf<Map<String, Any>>()

            // Get all detected planes
            val allPlanes = frame.getUpdatedTrackables(Plane::class.java)
            
            for (plane in allPlanes) {
                if (plane.trackingState == TrackingState.TRACKING) {
                    detectedPlanes[plane.hashCode().toString()] = plane

                    // Get plane polygon
                    val polygon = mutableListOf<Map<String, Float>>()
                    val polygon2D = FloatArray(2 * 6)
                    plane.getPolygon(polygon2D)

                    for (i in 0 until polygon2D.size step 2) {
                        polygon.add(mapOf(
                            "x" to polygon2D[i],
                            "y" to 0f,
                            "z" to polygon2D[i + 1]
                        ))
                    }

                    val planeData = mapOf(
                        "id" to plane.hashCode().toString(),
                        "centerX" to plane.centerPose.tx(),
                        "centerY" to plane.centerPose.ty(),
                        "centerZ" to plane.centerPose.tz(),
                        "normalX" to plane.normal.x,
                        "normalY" to plane.normal.y,
                        "normalZ" to plane.normal.z,
                        "extentX" to plane.extentX,
                        "extentZ" to plane.extentZ,
                        "isHorizontal" to (plane.type == Plane.Type.HORIZONTAL_UPWARD_FACING),
                        "confidence" to 0.95f,
                        "polygon" to polygon
                    )
                    planes.add(planeData)
                }
            }

            result.success(planes)
        } catch (e: Exception) {
            result.error("ERROR", e.message, null)
        }
    }

    /**
     * Place object di AR scene
     */
    private fun placeObject(args: Map<*, *>?, result: MethodChannel.Result) {
        try {
            val session = arSession ?: throw Exception("Session not initialized")
            val frame = session.update() ?: throw Exception("Failed to update frame")

            val objectId = args?.get("objectId") as? String ?: return
            val x = (args?.get("positionX") as? Number)?.toFloat() ?: 0f
            val y = (args?.get("positionY") as? Number)?.toFloat() ?: 0f
            val z = (args?.get("positionZ") as? Number)?.toFloat() ?: 0f

            // Create anchor at position
            val pose = Pose(floatArrayOf(x, y, z), floatArrayOf(0f, 0f, 0f, 1f))
            val anchor = session.createAnchor(pose)

            trackedObjects[objectId] = ObjectAnchor(
                id = objectId,
                anchor = anchor,
                position = floatArrayOf(x, y, z)
            )

            result.success(mapOf("status" to "placed", "objectId" to objectId))
        } catch (e: Exception) {
            result.error("ERROR", e.message, null)
        }
    }

    /**
     * Update object position
     */
    private fun updateObject(args: Map<*, *>?, result: MethodChannel.Result) {
        try {
            val objectId = args?.get("objectId") as? String ?: return
            val anchor = trackedObjects[objectId]?.anchor ?: return

            val x = (args?.get("positionX") as? Number)?.toFloat() ?: 0f
            val y = (args?.get("positionY") as? Number)?.toFloat() ?: 0f
            val z = (args?.get("positionZ") as? Number)?.toFloat() ?: 0f

            // Update position
            trackedObjects[objectId]?.position = floatArrayOf(x, y, z)

            result.success(mapOf("status" to "updated"))
        } catch (e: Exception) {
            result.error("ERROR", e.message, null)
        }
    }

    /**
     * Remove object dari scene
     */
    private fun removeObject(args: Map<*, *>?, result: MethodChannel.Result) {
        try {
            val objectId = args?.get("objectId") as? String ?: return
            val objectAnchor = trackedObjects.remove(objectId) ?: return
            
            objectAnchor.anchor?.detach()

            result.success(mapOf("status" to "removed"))
        } catch (e: Exception) {
            result.error("ERROR", e.message, null)
        }
    }

    /**
     * Get object position
     */
    private fun getObjectPosition(args: Map<*, *>?, result: MethodChannel.Result) {
        try {
            val objectId = args?.get("objectId") as? String ?: return
            val objectAnchor = trackedObjects[objectId] ?: return

            result.success(mapOf(
                "x" to objectAnchor.position[0],
                "y" to objectAnchor.position[1],
                "z" to objectAnchor.position[2]
            ))
        } catch (e: Exception) {
            result.error("ERROR", e.message, null)
        }
    }

    /**
     * Get lighting estimation
     */
    private fun getLightingEstimation(result: MethodChannel.Result) {
        try {
            val session = arSession ?: throw Exception("Session not initialized")
            val frame = session.update() ?: throw Exception("Failed to update frame")

            val lightEstimate = frame.lightEstimate

            result.success(mapOf(
                "intensity" to lightEstimate.pixelIntensity,
                "colorCorrectionRgba" to lightEstimate.colorCorrectionRgba.toList()
            ))
        } catch (e: Exception) {
            result.error("ERROR", e.message, null)
        }
    }

    /**
     * Helper function untuk mendapatkan activity
     */
    private fun getActivity() = (flutterEngine.dartExecutor as? DartExecutor)?.let {
        // Return the activity context
        // This should be implemented in MainActivity
        null
    } ?: throw Exception("Activity not available")

    /**
     * Data class untuk tracked objects
     */
    data class ObjectAnchor(
        val id: String,
        val anchor: Anchor?,
        var position: FloatArray
    ) {
        override fun equals(other: Any?): Boolean {
            if (this === other) return true
            if (javaClass != other?.javaClass) return false

            other as ObjectAnchor

            if (id != other.id) return false
            if (!position.contentEquals(other.position)) return false

            return true
        }

        override fun hashCode(): Int {
            var result = id.hashCode()
            result = 31 * result + position.contentHashCode()
            return result
        }
    }
}
