import 'package:flutter/material.dart';
import 'face_recognition_service.dart';

void main() {
  runApp(const FaceRecognitionExample());
}

class FaceRecognitionExample extends StatelessWidget {
  const FaceRecognitionExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Face Recognition Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const FaceRecognitionPage(),
    );
  }
}

class FaceRecognitionPage extends StatefulWidget {
  const FaceRecognitionPage({super.key});

  @override
  State<FaceRecognitionPage> createState() => _FaceRecognitionPageState();
}

class _FaceRecognitionPageState extends State<FaceRecognitionPage> {
  late FaceRecognitionService _faceService;
  bool _isInitialized = false;
  String _status = 'Initializing...';
  int _enrolledCount = 0;
  List<String> _log = [];

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    try {
      _faceService = FaceRecognitionService();
      await _faceService.initialize();
      
      setState(() {
        _isInitialized = true;
        _status = 'Ready';
        _enrolledCount = _faceService.enrolledFaceCount;
      });
      
      _addLog('Service initialized successfully');
    } catch (e) {
      setState(() {
        _status = 'Error: ${e.toString()}';
      });
      _addLog('Error: ${e.toString()}');
    }
  }

  void _addLog(String message) {
    setState(() {
      _log.insert(0, '[${DateTime.now().toIso8601String()}] $message');
      if (_log.length > 10) {
        _log.removeLast();
      }
    });
  }

  @override
  void dispose() {
    _faceService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Face Recognition Module'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Service Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Status: $_status'),
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isInitialized ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Enrolled Faces: $_enrolledCount'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Info Card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Module Features',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      _FeatureItem(
                        title: 'Face Detection',
                        description: 'Detect multiple faces in an image',
                      ),
                      SizedBox(height: 8),
                      _FeatureItem(
                        title: 'Face Enrollment',
                        description: 'Enroll and store face embeddings',
                      ),
                      SizedBox(height: 8),
                      _FeatureItem(
                        title: 'Face Recognition',
                        description: 'Match faces against enrolled database',
                      ),
                      SizedBox(height: 8),
                      _FeatureItem(
                        title: 'Multi-Platform',
                        description: 'Support Android, iOS, and Web',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Platform Support
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Platform Support',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      _PlatformItem(
                        name: 'Android',
                        framework: 'TensorFlow Lite',
                        status: 'Configured',
                      ),
                      SizedBox(height: 8),
                      _PlatformItem(
                        name: 'iOS',
                        framework: 'TensorFlow Lite',
                        status: 'Configured',
                      ),
                      SizedBox(height: 8),
                      _PlatformItem(
                        name: 'Web',
                        framework: 'TensorFlow.js + face-api.js',
                        status: 'Configured',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Log Section
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Activity Log',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        color: Colors.grey[100],
                        padding: const EdgeInsets.all(12.0),
                        height: 150,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _log.isEmpty
                                ? [
                                    const Text(
                                      'No activity yet',
                                      style: TextStyle(color: Colors.grey),
                                    )
                                  ]
                                : _log
                                    .map((log) => Text(
                                          log,
                                          style: const TextStyle(fontSize: 12),
                                        ))
                                    .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Quick Start
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quick Start Code',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        color: Colors.grey[900],
                        padding: const EdgeInsets.all(12.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(
                            '''final faceService = FaceRecognitionService();
await faceService.initialize();

// Enroll
final face = await faceService.enrollFace(
  imageData,
  userId: 'user123',
  name: 'John',
);

// Recognize
final result = await faceService.recognizeFace(imageData);
if (result.isMatch) {
  print('Matched!');
}''',
                            style: const TextStyle(
                              fontFamily: 'Courier',
                              color: Colors.green,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String title;
  final String description;

  const _FeatureItem({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                description,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlatformItem extends StatelessWidget {
  final String name;
  final String framework;
  final String status;

  const _PlatformItem({
    required this.name,
    required this.framework,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                framework,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue[900],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
