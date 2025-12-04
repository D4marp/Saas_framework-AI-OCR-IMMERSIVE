import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import '../../models/exports.dart';
import '../../services/exports.dart';

/// State provider untuk Face Recognition Service
class FaceRecognitionProvider extends ChangeNotifier {
  final FaceRecognitionService _service = FaceRecognitionService();
  
  bool _isInitialized = false;
  bool _isProcessing = false;
  String? _errorMessage;
  List<EnrolledFace> _enrolledFaces = [];
  FaceMatchResult? _lastMatchResult;
  List<String> _operationLog = [];

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;
  List<EnrolledFace> get enrolledFaces => List.unmodifiable(_enrolledFaces);
  FaceMatchResult? get lastMatchResult => _lastMatchResult;
  List<String> get operationLog => List.unmodifiable(_operationLog);
  int get enrolledFaceCount => _enrolledFaces.length;

  /// Initialize service
  Future<void> initialize() async {
    try {
      _setProcessing(true);
      _clearError();
      
      await _service.initialize();
      _isInitialized = true;
      _addLog('Service initialized successfully');
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to initialize: $e');
      _addLog('Error: Failed to initialize - $e');
    } finally {
      _setProcessing(false);
    }
  }

  /// Enroll new face
  Future<EnrolledFace?> enrollFace(
    List<int> imageData, {
    required String userId,
    required String name,
    String? imageUrl,
  }) async {
    if (!_isInitialized) {
      _setError('Service not initialized');
      return null;
    }

    try {
      _setProcessing(true);
      _clearError();
      
      final face = await _service.enrollFace(
        imageData as Uint8List,
        userId: userId,
        name: name,
        imageUrl: imageUrl,
      );
      
      _enrolledFaces = _service.getEnrolledFaces();
      _addLog('Face enrolled: $name (ID: ${face.id})');
      
      notifyListeners();
      return face;
    } catch (e) {
      _setError('Failed to enroll face: $e');
      _addLog('Error: Failed to enroll - $e');
      return null;
    } finally {
      _setProcessing(false);
    }
  }

  /// Recognize face from image
  Future<FaceMatchResult?> recognizeFace(List<int> imageData) async {
    if (!_isInitialized) {
      _setError('Service not initialized');
      return null;
    }

    if (_enrolledFaces.isEmpty) {
      _setError('No enrolled faces available');
      return null;
    }

    try {
      _setProcessing(true);
      _clearError();
      
      final result = await _service.recognizeFace(imageData as Uint8List);
      _lastMatchResult = result;
      _addLog('Recognition: ${result.isMatch ? 'Match' : 'No Match'} (${(result.similarityScore * 100).toStringAsFixed(1)}%)');
      
      notifyListeners();
      return result;
    } catch (e) {
      _setError('Recognition error: $e');
      _addLog('Error: Recognition failed - $e');
      return null;
    } finally {
      _setProcessing(false);
    }
  }

  /// Get all enrolled faces
  List<EnrolledFace> getEnrolledFaces() {
    return _service.getEnrolledFaces();
  }

  /// Remove enrolled face
  Future<bool> removeEnrolledFace(String faceId) async {
    try {
      await _service.removeEnrolledFace(faceId);
      _enrolledFaces = _service.getEnrolledFaces();
      _addLog('Face removed: $faceId');
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to remove face: $e');
      return false;
    }
  }

  /// Clear all enrolled faces
  Future<bool> clearAllFaces() async {
    try {
      await _service.clearAllFaces();
      _enrolledFaces = [];
      _addLog('All faces cleared');
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to clear faces: $e');
      return false;
    }
  }

  // Private helpers
  void _setError(String message) {
    _errorMessage = message;
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _setProcessing(bool value) {
    _isProcessing = value;
  }

  void _addLog(String message) {
    _operationLog.insert(0, '[${DateTime.now().toIso8601String()}] $message');
    if (_operationLog.length > 20) {
      _operationLog.removeLast();
    }
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
