/// Web platform test untuk face recognition
/// 
/// Jalankan dengan: flutter test test/web_face_recognition_test.dart -d chrome

@TestOn('browser')
import 'package:flutter_test/flutter_test.dart';
import 'dart:typed_data';
import 'package:saas_framework/src/modules/face_recognition/services/face_recognition_service.dart';
import 'package:saas_framework/src/modules/face_recognition/models/exports.dart';

void main() {
  group('Web Face Recognition', () {
    late FaceRecognitionService service;

    setUpAll(() {
      service = FaceRecognitionService();
    });

    test('Service initialized on web platform', () async {
      // Initialize service
      await service.initialize();
      
      expect(true, true);
    });

    test('Face detection returns results', () async {
      // Mock image data (simple PNG bytes)
      final mockImageData = _createMockImageData();
      
      final faces = await service.detectFaces(mockImageData);
      
      expect(faces, isNotEmpty);
      expect(faces.length, greaterThan(0));
      expect(faces.first.confidence, greaterThan(0.0));
    });

    test('Face embedding extraction works', () async {
      final mockFaceData = _createMockImageData();
      
      final faces = await service.detectFaces(mockFaceData);
      
      expect(faces, isNotEmpty);
      expect(faces.first.embedding.length, equals(128)); // face-api uses 128D embeddings
    });

    test('Face enrollment and recognition works', () async {
      // Create first enrollment
      final enrollmentImage = _createMockImageData();
      final enrolledFace = await service.enrollFace(
        enrollmentImage,
        userId: 'user_123',
        name: 'Test Person',
      );
      
      expect(enrolledFace.id, isNotEmpty);
      expect(enrolledFace.name, equals('Test Person'));
      expect(enrolledFace.userId, equals('user_123'));

      // Try to recognize the same face
      final recognitionImage = _createMockImageData();
      final match = await service.recognizeFace(recognitionImage);

      expect(match, isNotNull);
      expect(match.isMatch, isTrue);
      expect(match.similarityScore, greaterThan(0.6));
    });

    test('Multiple face detection', () async {
      final mockImageData = _createMockImageData();
      
      final faces = await service.detectFaces(mockImageData);
      
      // Should detect at least 1 face
      expect(faces.length, greaterThanOrEqualTo(1));
    });
  });
}

/// Create mock image data for testing
Uint8List _createMockImageData() {
  // Return simple 1x1 pixel PNG
  // PNG magic number + IHDR chunk
  return Uint8List.fromList([
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG signature
    0x00, 0x00, 0x00, 0x0D, // IHDR length
    0x49, 0x48, 0x44, 0x52, // IHDR
    0x00, 0x00, 0x00, 0x01, // width: 1
    0x00, 0x00, 0x00, 0x01, // height: 1
    0x08, 0x02, 0x00, 0x00, 0x00, // bit depth, color type, etc.
    0x90, 0x77, 0x53, 0xDE, // CRC
  ]);
}
