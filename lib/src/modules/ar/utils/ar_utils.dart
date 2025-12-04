/// AR Utility Functions
///
/// Helper functions untuk AR operations dan conversions

import 'dart:math' as math;
import '../models/exports.dart';

/// Convert degrees to radians
double degreesToRadians(double degrees) => degrees * math.pi / 180.0;

/// Convert radians to degrees
double radiansToDegrees(double radians) => radians * 180.0 / math.pi;

/// Clamp value between min and max
double clamp(double value, double min, double max) {
  if (value < min) return min;
  if (value > max) return max;
  return value;
}

/// Interpolate between two vectors
Vector3 lerpVector3(Vector3 a, Vector3 b, double t) {
  t = clamp(t, 0, 1);
  return Vector3(
    x: a.x + (b.x - a.x) * t,
    y: a.y + (b.y - a.y) * t,
    z: a.z + (b.z - a.z) * t,
  );
}

/// Interpolate between two quaternions (SLERP)
Quaternion slerpQuaternion(Quaternion a, Quaternion b, double t) {
  t = clamp(t, 0, 1);
  
  // Calculate dot product
  var dot = a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w;
  
  var b2 = Quaternion(x: b.x, y: b.y, z: b.z, w: b.w);
  
  // If dot product negative, negate one quaternion
  if (dot < 0) {
    b2 = Quaternion(x: -b.x, y: -b.y, z: -b.z, w: -b.w);
    dot = -dot;
  }
  
  // Clamp dot product
  dot = clamp(dot, -1, 1);
  
  // Calculate angle
  final theta = math.acos(dot);
  final sinTheta = math.sin(theta);
  
  if (sinTheta.abs() < 0.001) {
    // Linear interpolation if angle is very small
    return Quaternion(
      x: a.x + (b2.x - a.x) * t,
      y: a.y + (b2.y - a.y) * t,
      z: a.z + (b2.z - a.z) * t,
      w: a.w + (b2.w - a.w) * t,
    );
  }
  
  final w1 = math.sin((1 - t) * theta) / sinTheta;
  final w2 = math.sin(t * theta) / sinTheta;
  
  return Quaternion(
    x: a.x * w1 + b2.x * w2,
    y: a.y * w1 + b2.y * w2,
    z: a.z * w1 + b2.z * w2,
    w: a.w * w1 + b2.w * w2,
  );
}

/// Calculate angle between two vectors
double angleBetweenVectors(Vector3 a, Vector3 b) {
  final dotProduct = a.dot(b);
  final magnitudes = a.magnitude * b.magnitude;
  
  if (magnitudes == 0) return 0;
  
  return math.acos(clamp(dotProduct / magnitudes, -1, 1));
}

/// Project vector onto plane
Vector3 projectVectorOntoPlane(Vector3 vector, Vector3 planeNormal) {
  final normalized = planeNormal.normalized();
  final dot = vector.dot(normalized);
  return vector - (normalized * dot);
}

/// Rotate vector by quaternion
Vector3 rotateVectorByQuaternion(Vector3 vector, Quaternion q) {
  // Convert vector to quaternion: (0, x, y, z)
  final vq = Quaternion(x: vector.x, y: vector.y, z: vector.z, w: 0);
  
  // Get quaternion inverse (conjugate for unit quaternions)
  final qInverse = Quaternion(
    x: -q.x,
    y: -q.y,
    z: -q.z,
    w: q.w,
  );
  
  // q * v * q^-1
  final result = quaternionMultiply(q, quaternionMultiply(vq, qInverse));
  
  return Vector3(x: result.x, y: result.y, z: result.z);
}

/// Multiply two quaternions
Quaternion quaternionMultiply(Quaternion a, Quaternion b) {
  return Quaternion(
    x: a.w * b.x + a.x * b.w + a.y * b.z - a.z * b.y,
    y: a.w * b.y - a.x * b.z + a.y * b.w + a.z * b.x,
    z: a.w * b.z + a.x * b.y - a.y * b.x + a.z * b.w,
    w: a.w * b.w - a.x * b.x - a.y * b.y - a.z * b.z,
  );
}

/// Format Vector3 untuk debugging
String formatVector3(Vector3 v, {int decimals = 2}) {
  return 'Vector3(${v.x.toStringAsFixed(decimals)}, ${v.y.toStringAsFixed(decimals)}, ${v.z.toStringAsFixed(decimals)})';
}

/// Format Quaternion untuk debugging
String formatQuaternion(Quaternion q, {int decimals = 2}) {
  return 'Quaternion(${q.x.toStringAsFixed(decimals)}, ${q.y.toStringAsFixed(decimals)}, ${q.z.toStringAsFixed(decimals)}, ${q.w.toStringAsFixed(decimals)})';
}

/// Calculate bounding box dari list of vectors
({Vector3 min, Vector3 max}) calculateBoundingBox(List<Vector3> points) {
  if (points.isEmpty) {
    return (min: Vector3(x: 0, y: 0, z: 0), max: Vector3(x: 0, y: 0, z: 0));
  }
  
  var minX = points[0].x;
  var minY = points[0].y;
  var minZ = points[0].z;
  var maxX = points[0].x;
  var maxY = points[0].y;
  var maxZ = points[0].z;
  
  for (final point in points) {
    if (point.x < minX) minX = point.x;
    if (point.y < minY) minY = point.y;
    if (point.z < minZ) minZ = point.z;
    if (point.x > maxX) maxX = point.x;
    if (point.y > maxY) maxY = point.y;
    if (point.z > maxZ) maxZ = point.z;
  }
  
  return (
    min: Vector3(x: minX, y: minY, z: minZ),
    max: Vector3(x: maxX, y: maxY, z: maxZ),
  );
}

/// Calculate center dari list of vectors
Vector3 calculateCenter(List<Vector3> points) {
  if (points.isEmpty) return Vector3(x: 0, y: 0, z: 0);
  
  var sumX = 0.0;
  var sumY = 0.0;
  var sumZ = 0.0;
  
  for (final point in points) {
    sumX += point.x;
    sumY += point.y;
    sumZ += point.z;
  }
  
  final count = points.length.toDouble();
  return Vector3(
    x: sumX / count,
    y: sumY / count,
    z: sumZ / count,
  );
}

/// Check if two vectors are approximately equal
bool vectorsApproximatelyEqual(Vector3 a, Vector3 b, {double tolerance = 0.0001}) {
  return (a.x - b.x).abs() <= tolerance &&
      (a.y - b.y).abs() <= tolerance &&
      (a.z - b.z).abs() <= tolerance;
}

/// Check if two quaternions are approximately equal
bool quaternionsApproximatelyEqual(Quaternion a, Quaternion b, {double tolerance = 0.0001}) {
  return (a.x - b.x).abs() <= tolerance &&
      (a.y - b.y).abs() <= tolerance &&
      (a.z - b.z).abs() <= tolerance &&
      (a.w - b.w).abs() <= tolerance;
}
