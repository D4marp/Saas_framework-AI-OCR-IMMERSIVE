/// Face detection result model
class FaceDetectionResult {
  final double confidence;
  final Rect boundingBox;
  final List<double> embedding;
  final int id;
  final DateTime detectedAt;

  FaceDetectionResult({
    required this.confidence,
    required this.boundingBox,
    required this.embedding,
    required this.id,
    required this.detectedAt,
  });

  factory FaceDetectionResult.fromJson(Map<String, dynamic> json) {
    return FaceDetectionResult(
      confidence: (json['confidence'] as num).toDouble(),
      boundingBox: Rect.fromJson(json['boundingBox'] as Map<String, dynamic>),
      embedding: List<double>.from(json['embedding'] as List),
      id: json['id'] as int,
      detectedAt: DateTime.parse(json['detectedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'confidence': confidence,
      'boundingBox': boundingBox.toJson(),
      'embedding': embedding,
      'id': id,
      'detectedAt': detectedAt.toIso8601String(),
    };
  }

  @override
  String toString() =>
      'FaceDetectionResult(confidence: $confidence, id: $id, detectedAt: $detectedAt)';
}

/// Bounding box for detected face
class Rect {
  final double left;
  final double top;
  final double right;
  final double bottom;

  Rect({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  double get width => right - left;
  double get height => bottom - top;
  double get centerX => (left + right) / 2;
  double get centerY => (top + bottom) / 2;

  factory Rect.fromJson(Map<String, dynamic> json) {
    return Rect(
      left: (json['left'] as num).toDouble(),
      top: (json['top'] as num).toDouble(),
      right: (json['right'] as num).toDouble(),
      bottom: (json['bottom'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'left': left,
      'top': top,
      'right': right,
      'bottom': bottom,
    };
  }
}

/// Face recognition match result
class FaceMatchResult {
  final String enrolledFaceId;
  final double similarityScore;
  final bool isMatch;
  final DateTime matchedAt;

  FaceMatchResult({
    required this.enrolledFaceId,
    required this.similarityScore,
    required this.isMatch,
    required this.matchedAt,
  });

  @override
  String toString() =>
      'FaceMatchResult(enrolledFaceId: $enrolledFaceId, similarity: $similarityScore, isMatch: $isMatch)';
}

/// Enrolled face model
class EnrolledFace {
  final String id;
  final String userId;
  final String name;
  final List<double> embedding;
  final DateTime enrolledAt;
  final String? imageUrl;

  EnrolledFace({
    required this.id,
    required this.userId,
    required this.name,
    required this.embedding,
    required this.enrolledAt,
    this.imageUrl,
  });

  factory EnrolledFace.fromJson(Map<String, dynamic> json) {
    return EnrolledFace(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      embedding: List<double>.from(json['embedding'] as List),
      enrolledAt: DateTime.parse(json['enrolledAt'] as String),
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'embedding': embedding,
      'enrolledAt': enrolledAt.toIso8601String(),
      'imageUrl': imageUrl,
    };
  }
}
