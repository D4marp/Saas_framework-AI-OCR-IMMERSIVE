import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/exports.dart';
import '../platform/exports.dart';

/// Main Face Recognition Service
class FaceRecognitionService {
  static final FaceRecognitionService _instance =
      FaceRecognitionService._internal();

  late FaceRecognitionPlatformService _platformService;
  bool _initialized = false;
  final List<EnrolledFace> _enrolledFaces = [];
  final double _matchThreshold = 0.6;

  FaceRecognitionService._internal();

  factory FaceRecognitionService() {
    return _instance;
  }

  /// Initialize face recognition service
  Future<void> initialize() async {
    if (_initialized) return;

    _platformService = _getPlatformService();

    if (!_platformService.isSupported()) {
      throw Exception('Face recognition not supported on this platform');
    }

    await _platformService.initialize();
    _initialized = true;
  }

  /// Get platform-specific service
  FaceRecognitionPlatformService _getPlatformService() {
    if (kIsWeb) {
      return WebFaceRecognitionService();
    } else if (Platform.isAndroid || Platform.isIOS) {
      return MobileFaceRecognitionService();
    } else {
      throw Exception('Unsupported platform');
    }
  }

  /// Detect faces dalam image
  Future<List<FaceDetectionResult>> detectFaces(Uint8List imageData) async {
    if (!_initialized) throw Exception('Service not initialized');
    return await _platformService.detectFaces(imageData);
  }

  /// Enroll new face
  Future<EnrolledFace> enrollFace(
    Uint8List faceImageData, {
    required String userId,
    required String name,
    String? imageUrl,
  }) async {
    if (!_initialized) throw Exception('Service not initialized');

    final embedding = await _platformService.extractEmbedding(faceImageData);

    final enrolledFace = EnrolledFace(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      name: name,
      embedding: embedding,
      enrolledAt: DateTime.now(),
      imageUrl: imageUrl,
    );

    _enrolledFaces.add(enrolledFace);
    return enrolledFace;
  }

  /// Recognize face dari image
  Future<FaceMatchResult> recognizeFace(
    Uint8List imageData, {
    double? threshold,
  }) async {
    if (!_initialized) throw Exception('Service not initialized');
    if (_enrolledFaces.isEmpty) {
      throw Exception('No enrolled faces available');
    }

    final faces = await _platformService.detectFaces(imageData);
    if (faces.isEmpty) {
      throw Exception('No faces detected in image');
    }

    // Gunakan face pertama yang terdeteksi
    final mainFace = faces.first;
    final embedding =
        await _platformService.extractEmbedding(imageData);

    return await _platformService.matchFace(
      embedding,
      _enrolledFaces,
      threshold: threshold ?? _matchThreshold,
    );
  }

  /// Get all enrolled faces
  List<EnrolledFace> getEnrolledFaces() {
    return List.unmodifiable(_enrolledFaces);
  }

  /// Remove enrolled face
  Future<void> removeEnrolledFace(String faceId) async {
    _enrolledFaces.removeWhere((face) => face.id == faceId);
  }

  /// Calculate similarity between two images
  Future<double> calculateImageSimilarity(
    Uint8List imageData1,
    Uint8List imageData2,
  ) async {
    if (!_initialized) throw Exception('Service not initialized');

    final embedding1 = await _platformService.extractEmbedding(imageData1);
    final embedding2 = await _platformService.extractEmbedding(imageData2);

    return _platformService.calculateSimilarity(embedding1, embedding2);
  }

  /// Clear all enrolled faces
  Future<void> clearAllFaces() async {
    _enrolledFaces.clear();
  }

  /// Dispose service
  Future<void> dispose() async {
    if (_initialized) {
      await _platformService.dispose();
      _initialized = false;
    }
  }

  /// Check if service is initialized
  bool get isInitialized => _initialized;

  /// Get number of enrolled faces
  int get enrolledFaceCount => _enrolledFaces.length;
}
