/// JavaScript interop bridge untuk TensorFlow.js dan face-api.js
/// 
/// File ini memberikan akses ke TensorFlow.js dan face-api.js dari Dart
/// untuk implementasi face recognition di web.

import 'dart:async';
import 'dart:js_interop';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';

/// Global instance untuk JS context
late final TFJSBridge _tfJsBridge;

/// Initialize JS bridge (harus dipanggil sebelum menggunakan TF.js)
Future<void> initializeTFJSBridge() async {
  _tfJsBridge = TFJSBridge();
  await _tfJsBridge.initialize();
}

/// Get TF.js bridge instance
TFJSBridge getTFJSBridge() => _tfJsBridge;

/// Bridge untuk berinteraksi dengan TensorFlow.js dan face-api.js dari Dart
@JS()
class TFJSBridge {
  external int get tf;

  /// Initialize TensorFlow.js dan load face detection models
  @JS('window.initTensorFlow')
  external Future<void> initialize();

  /// Detect faces dalam image (menggunakan face-api.js)
  /// Returns array of detected faces dengan label (detected face positions)
  @JS('window.detectFacesWeb')
  external Future<JSArray> detectFacesWeb(JSObject imageElement);

  /// Get face descriptor (embedding) dari detected face
  @JS('window.getFaceDescriptorWeb')
  external Future<JSArray> getFaceDescriptorWeb(JSObject detection);

  /// Compute face distance antara dua descriptors
  @JS('window.computeFaceDistanceWeb')
  external double computeFaceDistanceWeb(JSArray descriptor1, JSArray descriptor2);
}

/// JavaScript functions untuk face recognition
/// Akan diinjected ke window object
const String tfJsCode = '''
window.initTensorFlow = async function() {
  console.log('Initializing TensorFlow.js...');
  if (typeof tf === 'undefined') {
    console.error('TensorFlow.js not loaded!');
    return;
  }
  
  // Load face-detection model (default model)
  const net = await faceapi.nets.tinyFaceDetector.load(document.location.origin + '/assets/');
  console.log('Face Detection model loaded');
  
  // Load face landmarks model
  await faceapi.nets.faceLandmark68Net.load(document.location.origin + '/assets/');
  console.log('Face Landmarks model loaded');
  
  // Load face recognition model
  await faceapi.nets.faceRecognitionNet.load(document.location.origin + '/assets/');
  console.log('Face Recognition model loaded');
  
  // Load face expression model
  await faceapi.nets.faceExpressionNet.load(document.location.origin + '/assets/');
  console.log('Face Expression model loaded');
};

window.detectFacesWeb = async function(imageElement) {
  console.log('Detecting faces...');
  try {
    const detections = await faceapi
      .detectAllFaces(imageElement, new faceapi.TinyFaceDetectorOptions())
      .withFaceLandmarks()
      .withFaceDescriptors()
      .withFaceExpressions();
    
    console.log('Detected ' + detections.length + ' faces');
    
    // Convert detections to simple format
    const results = detections.map((detection, index) => ({
      id: index,
      score: detection.detection.score,
      box: {
        x: detection.detection.box.x,
        y: detection.detection.box.y,
        width: detection.detection.box.width,
        height: detection.detection.box.height
      },
      descriptor: Array.from(detection.descriptor),
      landmarks: detection.landmarks.positions.map(p => ({x: p.x, y: p.y})),
      expressions: detection.expressions
    }));
    
    return results;
  } catch (error) {
    console.error('Face detection error:', error);
    return [];
  }
};

window.getFaceDescriptorWeb = async function(detection) {
  // Detection object dari faceapi sudah memiliki descriptor
  // Hanya return descriptor array
  if (detection.descriptor && Array.isArray(detection.descriptor)) {
    return detection.descriptor;
  }
  return [];
};

window.computeFaceDistanceWeb = function(descriptor1, descriptor2) {
  // Compute Euclidean distance
  if (!Array.isArray(descriptor1) || !Array.isArray(descriptor2)) {
    return 1.0; // Max distance if invalid
  }
  
  if (descriptor1.length !== descriptor2.length) {
    return 1.0;
  }
  
  let sum = 0;
  for (let i = 0; i < descriptor1.length; i++) {
    const diff = descriptor1[i] - descriptor2[i];
    sum += diff * diff;
  }
  
  const distance = Math.sqrt(sum);
  // Convert distance to similarity (0-1 range)
  // distance ~0-0.6 for same person, >0.6 for different person
  return Math.max(0, Math.min(1, 1 - (distance / 1.5)));
};
''';

/// Inject TF.js code ke halaman
void injectTFJSCode() {
  if (kIsWeb) {
    // Code akan diinjected via flutter web bootstrap
    // atau bisa manual jika diperlukan
  }
}

/// Convert image bytes ke canvas element (untuk face detection)
@JS()
@anonymous
class CanvasElement {
  external dynamic getContext(String contextType);
}

/// Helper untuk convert Uint8List ke image data
Future<JSObject> uint8ListToImageData(Uint8List imageBytes, int width, int height) async {
  // Implementation tergantung dari bagaimana image bytes diterima
  // Bisa dari canvas atau dari <img> element
  // TODO: Implement conversion logic
  throw UnimplementedError('uint8ListToImageData not implemented');
}
