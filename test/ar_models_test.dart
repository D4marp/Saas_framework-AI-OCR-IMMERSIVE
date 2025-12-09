import 'package:flutter_test/flutter_test.dart';
import 'package:saas_framework/src/modules/ar/models/ar_models.dart';

void main() {
  group('Vector3 Tests', () {
    test('Vector3 creation and properties', () {
      final v = Vector3(x: 1.0, y: 2.0, z: 3.0);
      expect(v.x, 1.0);
      expect(v.y, 2.0);
      expect(v.z, 3.0);
    });

    test('Vector3 distance calculation', () {
      final v1 = Vector3(x: 0.0, y: 0.0, z: 0.0);
      final v2 = Vector3(x: 3.0, y: 4.0, z: 0.0);
      final distance = v1.distanceTo(v2);
      expect(distance, closeTo(5.0, 0.0001));
    });

    test('Vector3 normalization', () {
      final v = Vector3(x: 3.0, y: 4.0, z: 0.0);
      final normalized = v.normalized();
      final magnitude = normalized.magnitude;
      expect(magnitude, closeTo(1.0, 0.0001));
    });

    test('Vector3 magnitude', () {
      final v = Vector3(x: 1.0, y: 1.0, z: 1.0);
      expect(v.magnitude, closeTo(1.732, 0.001));
    });

    test('Vector3 addition', () {
      final v1 = Vector3(x: 1.0, y: 2.0, z: 3.0);
      final v2 = Vector3(x: 4.0, y: 5.0, z: 6.0);
      final result = v1 + v2;
      expect(result.x, 5.0);
      expect(result.y, 7.0);
      expect(result.z, 9.0);
    });

    test('Vector3 subtraction', () {
      final v1 = Vector3(x: 5.0, y: 6.0, z: 7.0);
      final v2 = Vector3(x: 1.0, y: 2.0, z: 3.0);
      final result = v1 - v2;
      expect(result.x, 4.0);
      expect(result.y, 4.0);
      expect(result.z, 4.0);
    });

    test('Vector3 dot product', () {
      final v1 = Vector3(x: 1.0, y: 0.0, z: 0.0);
      final v2 = Vector3(x: 1.0, y: 0.0, z: 0.0);
      expect(v1.dot(v2), 1.0);
    });

    test('Vector3 cross product', () {
      final v1 = Vector3(x: 1.0, y: 0.0, z: 0.0);
      final v2 = Vector3(x: 0.0, y: 1.0, z: 0.0);
      final result = v1.cross(v2);
      expect(result.x, closeTo(0.0, 0.0001));
      expect(result.y, closeTo(0.0, 0.0001));
      expect(result.z, closeTo(1.0, 0.0001));
    });

    test('Vector3 JSON serialization', () {
      final v = Vector3(x: 1.0, y: 2.0, z: 3.0);
      final json = v.toJson();
      expect(json['x'], 1.0);
      expect(json['y'], 2.0);
      expect(json['z'], 3.0);
      
      final fromJson = Vector3.fromJson(json);
      expect(fromJson.x, 1.0);
      expect(fromJson.y, 2.0);
      expect(fromJson.z, 3.0);
    });
  });

  group('Quaternion Tests', () {
    test('Quaternion creation', () {
      final q = Quaternion(x: 0.0, y: 0.0, z: 0.0, w: 1.0);
      expect(q.w, 1.0);
      expect(q.x, 0.0);
      expect(q.y, 0.0);
      expect(q.z, 0.0);
    });

    test('Quaternion normalization', () {
      final q = Quaternion(x: 0.0, y: 0.0, z: 0.0, w: 2.0);
      final normalized = q.normalized();
      expect(normalized.w, closeTo(1.0, 0.0001));
    });

    test('Quaternion identity', () {
      final q = Quaternion.identity();
      expect(q.w, 1.0);
      expect(q.x, 0.0);
      expect(q.y, 0.0);
      expect(q.z, 0.0);
    });

    test('Quaternion from Euler angles', () {
      final q = Quaternion.fromEuler(0, 0, 0);
      expect(q.w, closeTo(1.0, 0.0001));
    });

    test('Quaternion JSON serialization', () {
      final q = Quaternion(x: 0.0, y: 0.0, z: 0.0, w: 1.0);
      final json = q.toJson();
      expect(json['w'], 1.0);
      
      final fromJson = Quaternion.fromJson(json);
      expect(fromJson.w, 1.0);
    });
  });

  group('ARPlane Tests', () {
    test('ARPlane creation and properties', () {
      final center = Vector3(x: 0.0, y: 0.0, z: 0.0);
      final normal = Vector3(x: 0.0, y: 1.0, z: 0.0);
      final polygon = [
        Vector3(x: -1.0, y: 0.0, z: -1.0),
        Vector3(x: 1.0, y: 0.0, z: -1.0),
        Vector3(x: 1.0, y: 0.0, z: 1.0),
        Vector3(x: -1.0, y: 0.0, z: 1.0),
      ];
      final plane = ARPlane(
        id: 'plane1',
        center: center,
        normal: normal,
        extent: Vector3(x: 2.0, y: 0.0, z: 2.0),
        polygon: polygon,
        detectedAt: DateTime.now(),
        isHorizontal: true,
        confidence: 0.95,
      );

      expect(plane.id, 'plane1');
      expect(plane.confidence, 0.95);
      expect(plane.isHorizontal, true);
    });

    test('ARPlane JSON serialization', () {
      final now = DateTime.now();
      final plane = ARPlane(
        id: 'plane1',
        center: Vector3(x: 0.0, y: 0.0, z: 0.0),
        normal: Vector3(x: 0.0, y: 1.0, z: 0.0),
        extent: Vector3(x: 2.0, y: 0.0, z: 2.0),
        polygon: [Vector3(x: 0.0, y: 0.0, z: 0.0)],
        detectedAt: now,
        isHorizontal: true,
        confidence: 0.95,
      );

      final json = plane.toJson();
      final fromJson = ARPlane.fromJson(json);
      
      expect(fromJson.id, 'plane1');
      expect(fromJson.confidence, 0.95);
    });
  });

  group('ARObject Tests', () {
    test('ARObject creation', () {
      final obj = ARObject(
        id: 'obj1',
        name: 'Test Object',
        modelPath: 'assets/models/test.gltf',
        position: Vector3(x: 0.0, y: 0.0, z: 0.0),
        rotation: Quaternion.identity(),
        scale: Vector3(x: 1.0, y: 1.0, z: 1.0),
        type: ARObjectType.furniture,
        placedAt: DateTime.now(),
      );

      expect(obj.id, 'obj1');
      expect(obj.type, ARObjectType.furniture);
    });

    test('ARObject copyWith', () {
      final now = DateTime.now();
      final obj1 = ARObject(
        id: 'obj1',
        name: 'Test Object',
        modelPath: 'assets/models/test.gltf',
        position: Vector3(x: 0.0, y: 0.0, z: 0.0),
        rotation: Quaternion.identity(),
        scale: Vector3(x: 1.0, y: 1.0, z: 1.0),
        type: ARObjectType.furniture,
        placedAt: now,
      );

      final obj2 = obj1.copyWith(
        position: Vector3(x: 1.0, y: 1.0, z: 1.0),
      );

      expect(obj2.position.x, 1.0);
      expect(obj2.position.y, 1.0);
      expect(obj2.position.z, 1.0);
    });

    test('ARObject JSON serialization', () {
      final now = DateTime.now();
      final obj = ARObject(
        id: 'obj1',
        name: 'Test Object',
        modelPath: 'assets/models/test.gltf',
        position: Vector3(x: 1.0, y: 2.0, z: 3.0),
        rotation: Quaternion.identity(),
        scale: Vector3(x: 2.0, y: 2.0, z: 2.0),
        type: ARObjectType.furniture,
        placedAt: now,
      );

      final json = obj.toJson();
      final fromJson = ARObject.fromJson(json);

      expect(fromJson.id, 'obj1');
      expect(fromJson.position.x, 1.0);
    });
  });

  group('ARSession Tests', () {
    test('ARSession creation', () {
      final session = ARSession(
        id: 'session1',
        state: ARSessionState.running,
        startedAt: DateTime.now(),
        detectedPlanes: [],
        placedObjects: [],
      );

      expect(session.id, 'session1');
      expect(session.state, ARSessionState.running);
    });

    test('ARSession JSON serialization', () {
      final now = DateTime.now();
      final session = ARSession(
        id: 'session1',
        state: ARSessionState.running,
        startedAt: now,
        detectedPlanes: [],
        placedObjects: [],
      );

      final json = session.toJson();
      final fromJson = ARSession.fromJson(json);

      expect(fromJson.id, 'session1');
      expect(fromJson.state, ARSessionState.running);
    });
  });
}
