import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../providers/face_recognition_provider.dart';

/// Screen untuk pengenalan wajah
class RecognitionScreen extends StatefulWidget {
  final FaceRecognitionProvider faceProvider;

  const RecognitionScreen({
    super.key,
    required this.faceProvider,
  });

  @override
  State<RecognitionScreen> createState() => _RecognitionScreenState();
}

class _RecognitionScreenState extends State<RecognitionScreen> {
  Uint8List? _selectedImageData;
  bool _isProcessing = false;
  String? _errorMessage;

  Future<void> _recognizeFace() async {
    if (_selectedImageData == null) {
      setState(() => _errorMessage = 'Please select an image');
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      await widget.faceProvider.recognizeFace(_selectedImageData!);
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Recognition error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lastMatch = widget.faceProvider.lastMatchResult;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Recognition'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_errorMessage != null)
              Card(
                color: Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(child: Text(_errorMessage!)),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () =>
                            setState(() => _errorMessage = null),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              child: Column(
                children: [
                  Container(
                    height: 250,
                    width: double.infinity,
                    color: Colors.grey[100],
                    child: _selectedImageData != null
                        ? Image.memory(
                            _selectedImageData!,
                            fit: BoxFit.cover,
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No image selected',
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                            ],
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isProcessing ? null : () {},
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Select Image'),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _isProcessing || _selectedImageData == null
                              ? null
                              : _recognizeFace,
                          icon: _isProcessing
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.search),
                          label: Text(_isProcessing
                              ? 'Recognizing...'
                              : 'Recognize Face'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (lastMatch != null)
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lastMatch.isMatch ? '✓ Match Found' : '✗ No Match',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: lastMatch.isMatch
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Similarity:'),
                          Text(
                            '${(lastMatch.similarityScore * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
