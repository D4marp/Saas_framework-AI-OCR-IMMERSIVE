/// AR View Widget - Main AR visualization component
///
/// Menampilkan live AR view dengan platform-specific implementations

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/exports.dart';
import '../models/exports.dart';

/// Main AR view widget
class ARView extends StatefulWidget {
  /// AR Service instance
  final ARService arService;

  /// Callback ketika AR view tap detected
  final Function(ARHitTestResult)? onHitTest;

  /// Callback untuk plane detection
  final Function(List<ARPlane>)? onPlanesDetected;

  /// Callback untuk object placement
  final Function(ARObject)? onObjectPlaced;

  /// Initial AR mode
  final ARSessionState initialState;

  /// Enable debug visualization
  final bool debugMode;

  const ARView({
    Key? key,
    required this.arService,
    this.onHitTest,
    this.onPlanesDetected,
    this.onObjectPlaced,
    this.initialState = ARSessionState.initializing,
    this.debugMode = false,
  }) : super(key: key);

  @override
  State<ARView> createState() => _ARViewState();
}

class _ARViewState extends State<ARView> {
  late ARService _arService;
  List<ARPlane> _planes = [];
  List<ARObject> _objects = [];
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _arService = widget.arService;
    _initializeAR();
  }

  Future<void> _initializeAR() async {
    try {
      await _arService.initialize();
      await _arService.startSession();
      _listenToPlanes();
      _listenToObjects();

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('[ARView] Error initializing AR: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize AR: $e')),
        );
      }
    }
  }

  void _listenToPlanes() {
    _arService.planesStream.listen((planes) {
      setState(() {
        _planes = planes;
      });
      widget.onPlanesDetected?.call(planes);
    }).onError((e) {
      print('[ARView] Plane stream error: $e');
    });
  }

  void _listenToObjects() {
    _arService.objectsStream.listen((objects) {
      setState(() {
        _objects = objects;
      });
    }).onError((e) {
      print('[ARView] Object stream error: $e');
    });
  }

  Future<void> _handleTap(TapDownDetails details) async {
    if (!_isInitialized) return;

    try {
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      final local = details.localPosition;

      final hitResult = await _arService.hitTest(local.dx, local.dy);

      if (hitResult != null) {
        widget.onHitTest?.call(hitResult);
      }
    } catch (e) {
      print('[ARView] Hit test error: $e');
    }
  }

  @override
  void dispose() {
    _arService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTap,
      child: Stack(
        children: [
          Container(
            color: Colors.black,
            child: _isInitialized
                ? _buildARView()
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Initializing AR...'),
                      ],
                    ),
                  ),
          ),
          if (widget.debugMode) _buildDebugInfo(),
          if (widget.debugMode && _planes.isNotEmpty) _buildPlaneVisualization(),
        ],
      ),
    );
  }

  Widget _buildARView() {
    if (kIsWeb) {
      return Container(
        color: Colors.grey[900],
        child: const Center(
          child: Text(
            'Web AR View\nTap to place objects',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    } else {
      return Container(
        color: Colors.grey[900],
        child: const Center(
          child: Text(
            'Native AR View\nTap to place objects',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  Widget _buildDebugInfo() {
    return Positioned(
      top: 16,
      left: 16,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'AR Debug Info',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Platform: ${_arService.getPlatformServiceName()}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            Text(
              'Planes: ${_planes.length}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            Text(
              'Objects: ${_objects.length}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            Text(
              'Session: ${_arService.currentSession.state.name}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaneVisualization() {
    return Positioned(
      bottom: 16,
      left: 16,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Detected Planes:',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            ..._planes.map((plane) {
              return Text(
                '• Plane (confidence: ${(plane.confidence * 100).toStringAsFixed(0)}%)',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
