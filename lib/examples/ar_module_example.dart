/// AR Module Example - Furniture AR Placement Demo
///
/// Mendemonstrasikan penggunaan AR module untuk virtual furniture placement

import 'package:flutter/material.dart';
import 'package:saas_framework/src/modules/ar/exports.dart';

void main() {
  runApp(const ARExampleApp());
}

class ARExampleApp extends StatelessWidget {
  const ARExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AR Furniture Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ARExampleScreen(),
    );
  }
}

/// Main AR example screen
class ARExampleScreen extends StatefulWidget {
  const ARExampleScreen({Key? key}) : super(key: key);

  @override
  State<ARExampleScreen> createState() => _ARExampleScreenState();
}

class _ARExampleScreenState extends State<ARExampleScreen> {
  late ARService _arService;
  List<ARObject> _placedObjects = [];
  ARObject? _selectedObject;
  bool _debugMode = false;

  @override
  void initState() {
    super.initState();
    _arService = ARService();
  }

  void _handleHitTest(ARHitTestResult hitResult) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ObjectPlacementPanel(
        arService: _arService,
        hitResult: hitResult,
        onObjectPlaced: (object) {
          setState(() {
            _placedObjects.add(object);
          });
        },
      ),
    );
  }

  void _selectObject(ARObject object) {
    setState(() => _selectedObject = object);

    showModalBottomSheet(
      context: context,
      builder: (context) => ObjectTransformEditor(
        object: object,
        onTransformChanged: (position, rotation, scale) async {
          try {
            await _arService.updateObjectTransform(
              object.id,
              position: position,
              rotation: rotation,
              scale: scale,
            );

            final index = _placedObjects.indexWhere((o) => o.id == object.id);
            if (index != -1) {
              setState(() {
                _placedObjects[index] = object.copyWith(
                  position: position,
                  rotation: rotation,
                  scale: scale,
                );
              });
            }
          } catch (e) {
            print('Error updating transform: $e');
          }
        },
      ),
    );
  }

  Future<void> _deleteObject(ARObject object) async {
    try {
      await _arService.removeObject(object.id);
      setState(() {
        _placedObjects.removeWhere((o) => o.id == object.id);
        if (_selectedObject?.id == object.id) {
          _selectedObject = null;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${object.name} removed')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove object: $e')),
      );
    }
  }

  void _toggleDebugMode() {
    setState(() => _debugMode = !_debugMode);
  }

  void _clearAllObjects() async {
    try {
      for (final object in _placedObjects) {
        await _arService.removeObject(object.id);
      }
      setState(() {
        _placedObjects.clear();
        _selectedObject = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All objects cleared')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error clearing objects: $e')),
      );
    }
  }

  @override
  void dispose() {
    _arService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AR Furniture Placement'),
        actions: [
          IconButton(
            icon: Icon(_debugMode ? Icons.bug_report : Icons.visibility),
            onPressed: _toggleDebugMode,
            tooltip: 'Toggle Debug Mode',
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Clear All'),
                onTap: _clearAllObjects,
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main AR View
          ARView(
            arService: _arService,
            debugMode: _debugMode,
            onHitTest: _handleHitTest,
            onPlanesDetected: (planes) {
              print('Planes detected: ${planes.length}');
            },
            onObjectPlaced: (object) {
              print('Object placed: ${object.name}');
            },
          ),

          // Placed Objects List
          if (_placedObjects.isNotEmpty)
            Positioned(
              bottom: 20,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                constraints: const BoxConstraints(maxWidth: 250),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Objects (${_placedObjects.length})',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _placedObjects.length.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _placedObjects.length,
                        itemBuilder: (context, index) {
                          final object = _placedObjects[index];
                          final isSelected = _selectedObject?.id == object.id;

                          return GestureDetector(
                            onTap: () => _selectObject(object),
                            onLongPress: () => _deleteObject(object),
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.blue.withOpacity(0.2)
                                    : Colors.grey[100],
                                border: isSelected
                                    ? Border.all(color: Colors.blue, width: 2)
                                    : null,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    object.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    _getObjectTypeLabel(object.type),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Instructions
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Instructions:',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '• Tap on a plane to place object',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    '• Tap object to edit transform',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    '• Long press to delete object',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getObjectTypeLabel(ARObjectType type) {
    switch (type) {
      case ARObjectType.model3d:
        return '3D Model';
      case ARObjectType.furniture:
        return 'Furniture';
      case ARObjectType.decoration:
        return 'Decoration';
      case ARObjectType.product:
        return 'Product';
      case ARObjectType.annotation:
        return 'Annotation';
      case ARObjectType.custom:
        return 'Custom';
    }
  }
}
