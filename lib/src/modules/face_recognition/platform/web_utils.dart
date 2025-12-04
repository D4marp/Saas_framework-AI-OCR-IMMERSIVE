/// JavaScript interop setup untuk face-api.js dan TensorFlow.js
/// 
/// File ini menyediakan utilities untuk komunikasi dengan JavaScript
/// di sisi browser.

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

/// Result dari face detection di web
class WebFaceDetection {
  final int faceId;
  final double x;
  final double y;
  final double width;
  final double height;
  final double confidence;
  final List<double> descriptor;

  WebFaceDetection({
    required this.faceId,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.confidence,
    required this.descriptor,
  });

  factory WebFaceDetection.fromJson(Map<String, dynamic> json) {
    return WebFaceDetection(
      faceId: json['id'] ?? 0,
      x: (json['box']['x'] as num).toDouble(),
      y: (json['box']['y'] as num).toDouble(),
      width: (json['box']['width'] as num).toDouble(),
      height: (json['box']['height'] as num).toDouble(),
      confidence: (json['score'] as num).toDouble(),
      descriptor: List<double>.from(
        (json['descriptor'] as List).map((e) => (e as num).toDouble()),
      ),
    );
  }
}

/// Helper untuk convert canvas image to data URL
String uint8ListToDataUrl(Uint8List imageData, String mimeType) {
  // Konversi Uint8List ke base64
  final base64String = _bytesToBase64(imageData);
  return 'data:$mimeType;base64,$base64String';
}

/// Convert Uint8List to base64 string
String _bytesToBase64(Uint8List bytes) {
  // Implementasi manual jika dart:convert tidak available
  const String _base64Characters =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

  final StringBuffer result = StringBuffer();
  int index = 0;

  while (index < bytes.length) {
    final int b1 = bytes[index];
    int b2 = 0;
    int b3 = 0;
    final bool isThirdByteExist = index + 2 < bytes.length;
    final bool isSecondByteExist = index + 1 < bytes.length;

    if (isSecondByteExist) {
      b2 = bytes[index + 1];
    }
    if (isThirdByteExist) {
      b3 = bytes[index + 2];
    }

    final int byte1 = (b1) >> 2;
    final int byte2 = ((b1 & 0x03) << 4) | (b2 >> 4);
    int byte3 = ((b2 & 0x0f) << 2) | (b3 >> 6);
    int byte4 = b3 & 0x3f;

    if (index + 1 >= bytes.length) {
      byte3 = 64;
    }
    if (index + 2 >= bytes.length) {
      byte4 = 64;
    }

    result.write(_base64Characters[byte1]);
    result.write(_base64Characters[byte2]);
    result.write(byte3 == 64 ? '=' : _base64Characters[byte3]);
    result.write(byte4 == 64 ? '=' : _base64Characters[byte4]);

    index += 3;
  }

  return result.toString();
}

/// Manager untuk canvas operations di web
class CanvasImageProcessor {
  /// Convert image bytes to canvas element
  /// dan return element reference untuk face detection
  static Future<dynamic> createCanvasFromImageBytes(
    Uint8List imageData,
    int width,
    int height,
  ) async {
    // Implementasi tergantung dari js_interop setup
    // Untuk sekarang, throw UnimplementedError
    throw UnimplementedError(
      'CanvasImageProcessor.createCanvasFromImageBytes requires JS interop setup',
    );
  }

  /// Extract image data dari canvas element
  static Future<Uint8List> extractCanvasImageData(dynamic canvasElement) async {
    throw UnimplementedError(
      'CanvasImageProcessor.extractCanvasImageData requires JS interop setup',
    );
  }
}

/// Configuration untuk TensorFlow.js loading
class TFJSConfig {
  /// URL untuk CDN hosting model files
  final String modelBaseUrl;

  /// Enable/disable logging
  final bool debug;

  /// Timeout untuk model loading (milliseconds)
  final Duration modelLoadTimeout;

  TFJSConfig({
    this.modelBaseUrl = 'https://cdn.jsdelivr.net/npm/@vladmandic/face-api/model/',
    this.debug = false,
    this.modelLoadTimeout = const Duration(seconds: 30),
  });
}

/// Global TensorFlow.js configuration
TFJSConfig _tfJSConfig = TFJSConfig();

/// Get current TensorFlow.js config
TFJSConfig getTFJSConfig() => _tfJSConfig;

/// Set TensorFlow.js config
void setTFJSConfig(TFJSConfig config) {
  _tfJSConfig = config;
}

/// Check apakah code berjalan di web
bool isWebPlatform() => kIsWeb;

/// Console log untuk web debugging
void webLog(String message) {
  if (kIsWeb && _tfJSConfig.debug) {
    print('[WebFaceRecognition] $message');
  }
}
