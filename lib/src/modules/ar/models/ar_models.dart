/// AR Models - Data structures untuk Augmented Reality
///
/// File ini mendefinisikan semua model data yang digunakan dalam AR module

import 'dart:math' as math;
import 'dart:typed_data';

/// Representasi 3D vector untuk posisi dan rotasi
class Vector3 {
  final double x;
  final double y;
  final double z;

  Vector3({
    required this.x,
    required this.y,
    required this.z,
  });

  /// Euclidean distance antara dua vectors
  double distanceTo(Vector3 other) {
    final dx = x - other.x;
    final dy = y - other.y;
    final dz = z - other.z;
    return math.sqrt(dx * dx + dy * dy + dz * dz);
  }

  /// Normalize vector
  Vector3 normalized() {
    final length = math.sqrt(x * x + y * y + z * z);
    if (length == 0) return Vector3(x: 0, y: 0, z: 0);
    return Vector3(
      x: x / length,
      y: y / length,
      z: z / length,
    );
  }

  /// Cross product
  Vector3 cross(Vector3 other) {
    return Vector3(
      x: y * other.z - z * other.y,
      y: z * other.x - x * other.z,
      z: x * other.y - y * other.x,
    );
  }

  /// Dot product
  double dot(Vector3 other) => x * other.x + y * other.y + z * other.z;

  /// Magnitude (length) of vector
  double get magnitude => math.sqrt(x * x + y * y + z * z);

  /// Add two vectors
  Vector3 operator +(Vector3 other) {
    return Vector3(
      x: x + other.x,
      y: y + other.y,
      z: z + other.z,
    );
  }

  /// Subtract two vectors
  Vector3 operator -(Vector3 other) {
    return Vector3(
      x: x - other.x,
      y: y - other.y,
      z: z - other.z,
    );
  }

  /// Scalar multiplication
  Vector3 operator *(double scalar) {
    return Vector3(
      x: x * scalar,
      y: y * scalar,
      z: z * scalar,
    );
  }

  @override
  String toString() => 'Vector3($x, $y, $z)';

  factory Vector3.fromJson(Map<String, dynamic> json) {
    return Vector3(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      z: (json['z'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {'x': x, 'y': y, 'z': z};
}

/// Quaternion untuk rotasi 3D
class Quaternion {
  final double x;
  final double y;
  final double z;
  final double w;

  Quaternion({
    required this.x,
    required this.y,
    required this.z,
    required this.w,
  });

  /// Identity quaternion (no rotation)
  factory Quaternion.identity() {
    return Quaternion(x: 0, y: 0, z: 0, w: 1);
  }

  /// Quaternion from Euler angles (in radians)
  factory Quaternion.fromEuler(double roll, double pitch, double yaw) {
    final cy = math.cos(yaw * 0.5);
    final sy = math.sin(yaw * 0.5);
    final cp = math.cos(pitch * 0.5);
    final sp = math.sin(pitch * 0.5);
    final cr = math.cos(roll * 0.5);
    final sr = math.sin(roll * 0.5);

    return Quaternion(
      x: sr * cp * cy - cr * sp * sy,
      y: cr * sp * cy + sr * cp * sy,
      z: cr * cp * sy - sr * sp * cy,
      w: cr * cp * cy + sr * sp * sy,
    );
  }

  /// Normalize quaternion
  Quaternion normalized() {
    final length = math.sqrt(x * x + y * y + z * z + w * w);
    if (length == 0) return Quaternion.identity();
    return Quaternion(
      x: x / length,
      y: y / length,
      z: z / length,
      w: w / length,
    );
  }

  factory Quaternion.fromJson(Map<String, dynamic> json) {
    return Quaternion(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      z: (json['z'] as num).toDouble(),
      w: (json['w'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {'x': x, 'y': y, 'z': z, 'w': w};
}

/// Plane detection hasil dari AR platform
class ARPlane {
  final String id;
  final Vector3 center;
  final Vector3 normal;
  final Vector3 extent;
  final List<Vector3> polygon;
  final DateTime detectedAt;
  final bool isHorizontal;
  final double confidence;

  ARPlane({
    required this.id,
    required this.center,
    required this.normal,
    required this.extent,
    required this.polygon,
    required this.detectedAt,
    required this.isHorizontal,
    required this.confidence,
  });

  factory ARPlane.fromJson(Map<String, dynamic> json) {
    return ARPlane(
      id: json['id'] as String,
      center: Vector3.fromJson(json['center'] as Map<String, dynamic>),
      normal: Vector3.fromJson(json['normal'] as Map<String, dynamic>),
      extent: Vector3.fromJson(json['extent'] as Map<String, dynamic>),
      polygon: (json['polygon'] as List)
          .map((e) => Vector3.fromJson(e as Map<String, dynamic>))
          .toList(),
      detectedAt: DateTime.parse(json['detectedAt'] as String),
      isHorizontal: json['isHorizontal'] as bool,
      confidence: (json['confidence'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'center': center.toJson(),
        'normal': normal.toJson(),
        'extent': extent.toJson(),
        'polygon': polygon.map((e) => e.toJson()).toList(),
        'detectedAt': detectedAt.toIso8601String(),
        'isHorizontal': isHorizontal,
        'confidence': confidence,
      };
}

/// AR Object yang ditempatkan di AR scene
class ARObject {
  final String id;
  final String name;
  final String modelPath;
  final Vector3 position;
  final Quaternion rotation;
  final Vector3 scale;
  final ARObjectType type;
  final DateTime placedAt;
  final Map<String, dynamic>? metadata;

  ARObject({
    required this.id,
    required this.name,
    required this.modelPath,
    required this.position,
    required this.rotation,
    required this.scale,
    required this.type,
    required this.placedAt,
    this.metadata,
  });

  factory ARObject.fromJson(Map<String, dynamic> json) {
    return ARObject(
      id: json['id'] as String,
      name: json['name'] as String,
      modelPath: json['modelPath'] as String,
      position: Vector3.fromJson(json['position'] as Map<String, dynamic>),
      rotation: Quaternion.fromJson(json['rotation'] as Map<String, dynamic>),
      scale: Vector3.fromJson(json['scale'] as Map<String, dynamic>),
      type: ARObjectType.values.byName(json['type'] as String),
      placedAt: DateTime.parse(json['placedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'modelPath': modelPath,
        'position': position.toJson(),
        'rotation': rotation.toJson(),
        'scale': scale.toJson(),
        'type': type.name,
        'placedAt': placedAt.toIso8601String(),
        'metadata': metadata,
      };

  /// Create copy with updated fields
  ARObject copyWith({
    Vector3? position,
    Quaternion? rotation,
    Vector3? scale,
    Map<String, dynamic>? metadata,
  }) {
    return ARObject(
      id: id,
      name: name,
      modelPath: modelPath,
      position: position ?? this.position,
      rotation: rotation ?? this.rotation,
      scale: scale ?? this.scale,
      type: type,
      placedAt: placedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Tipe-tipe AR Object
enum ARObjectType {
  model3d,
  furniture,
  decoration,
  product,
  annotation,
  custom,
}

/// Hit test result untuk mendeteksi tap pada plane
class ARHitTestResult {
  final String planeId;
  final Vector3 hitPoint;
  final Quaternion estimatedRotation;
  final double distance;
  final DateTime timestamp;

  ARHitTestResult({
    required this.planeId,
    required this.hitPoint,
    required this.estimatedRotation,
    required this.distance,
    required this.timestamp,
  });

  factory ARHitTestResult.fromJson(Map<String, dynamic> json) {
    return ARHitTestResult(
      planeId: json['planeId'] as String,
      hitPoint: Vector3.fromJson(json['hitPoint'] as Map<String, dynamic>),
      estimatedRotation:
          Quaternion.fromJson(json['estimatedRotation'] as Map<String, dynamic>),
      distance: (json['distance'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'planeId': planeId,
        'hitPoint': hitPoint.toJson(),
        'estimatedRotation': estimatedRotation.toJson(),
        'distance': distance,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// AR Session state
enum ARSessionState {
  notStarted,
  initializing,
  running,
  paused,
  stopped,
  error,
}

/// AR Session info
class ARSession {
  final String id;
  final ARSessionState state;
  final DateTime startedAt;
  final DateTime? updatedAt;
  final List<ARPlane> detectedPlanes;
  final List<ARObject> placedObjects;
  final String? error;

  ARSession({
    required this.id,
    required this.state,
    required this.startedAt,
    this.updatedAt,
    required this.detectedPlanes,
    required this.placedObjects,
    this.error,
  });

  factory ARSession.fromJson(Map<String, dynamic> json) {
    return ARSession(
      id: json['id'] as String,
      state: ARSessionState.values.byName(json['state'] as String),
      startedAt: DateTime.parse(json['startedAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      detectedPlanes: (json['detectedPlanes'] as List)
          .map((e) => ARPlane.fromJson(e as Map<String, dynamic>))
          .toList(),
      placedObjects: (json['placedObjects'] as List)
          .map((e) => ARObject.fromJson(e as Map<String, dynamic>))
          .toList(),
      error: json['error'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'state': state.name,
        'startedAt': startedAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'detectedPlanes': detectedPlanes.map((e) => e.toJson()).toList(),
        'placedObjects': placedObjects.map((e) => e.toJson()).toList(),
        'error': error,
      };
}

/// AR Camera info
class ARCamera {
  final Vector3 position;
  final Quaternion rotation;
  final double fov;
  final double nearClip;
  final double farClip;

  ARCamera({
    required this.position,
    required this.rotation,
    required this.fov,
    required this.nearClip,
    required this.farClip,
  });

  factory ARCamera.fromJson(Map<String, dynamic> json) {
    return ARCamera(
      position: Vector3.fromJson(json['position'] as Map<String, dynamic>),
      rotation: Quaternion.fromJson(json['rotation'] as Map<String, dynamic>),
      fov: (json['fov'] as num).toDouble(),
      nearClip: (json['nearClip'] as num).toDouble(),
      farClip: (json['farClip'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'position': position.toJson(),
        'rotation': rotation.toJson(),
        'fov': fov,
        'nearClip': nearClip,
        'farClip': farClip,
      };
}
