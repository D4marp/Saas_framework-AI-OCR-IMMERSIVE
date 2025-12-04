/// Object Placer Widget - For placing AR objects
///
/// UI component untuk memudahkan placement of AR objects

import 'package:flutter/material.dart';
import '../models/exports.dart';
import '../services/exports.dart';

/// Object type selector
class ObjectTypePicker extends StatelessWidget {
  final Function(ARObjectType) onSelected;
  final ARObjectType? selectedType;

  const ObjectTypePicker({
    Key? key,
    required this.onSelected,
    this.selectedType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ARObjectType.values.map((type) {
          final isSelected = selectedType == type;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: FilterChip(
              label: Text(_getTypeName(type)),
              selected: isSelected,
              onSelected: (_) => onSelected(type),
              backgroundColor: Colors.grey[300],
              selectedColor: Colors.blue,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getTypeName(ARObjectType type) {
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

/// Object transform editor
class ObjectTransformEditor extends StatefulWidget {
  final ARObject object;
  final Function(Vector3?, Quaternion?, Vector3?) onTransformChanged;

  const ObjectTransformEditor({
    Key? key,
    required this.object,
    required this.onTransformChanged,
  }) : super(key: key);

  @override
  State<ObjectTransformEditor> createState() => _ObjectTransformEditorState();
}

class _ObjectTransformEditorState extends State<ObjectTransformEditor> {
  late TextEditingController _xController;
  late TextEditingController _yController;
  late TextEditingController _zController;
  late TextEditingController _scaleController;

  @override
  void initState() {
    super.initState();
    _xController = TextEditingController(
      text: widget.object.position.x.toStringAsFixed(2),
    );
    _yController = TextEditingController(
      text: widget.object.position.y.toStringAsFixed(2),
    );
    _zController = TextEditingController(
      text: widget.object.position.z.toStringAsFixed(2),
    );
    _scaleController = TextEditingController(
      text: widget.object.scale.x.toStringAsFixed(2),
    );
  }

  void _applyTransform() {
    try {
      final x = double.parse(_xController.text);
      final y = double.parse(_yController.text);
      final z = double.parse(_zController.text);
      final scale = double.parse(_scaleController.text);

      final newPosition = Vector3(x: x, y: y, z: z);
      final newScale = Vector3(x: scale, y: scale, z: scale);

      widget.onTransformChanged(newPosition, null, newScale);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transform applied')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid input: $e')),
      );
    }
  }

  @override
  void dispose() {
    _xController.dispose();
    _yController.dispose();
    _zController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Object Transform',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildPositionFields(),
            const SizedBox(height: 16),
            _buildScaleField(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyTransform,
                child: const Text('Apply Transform'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Position'),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _xController,
                decoration: const InputDecoration(labelText: 'X'),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _yController,
                decoration: const InputDecoration(labelText: 'Y'),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _zController,
                decoration: const InputDecoration(labelText: 'Z'),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScaleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Scale'),
        TextField(
          controller: _scaleController,
          decoration: const InputDecoration(labelText: 'Scale (uniform)'),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }
}

/// Object placement panel
class ObjectPlacementPanel extends StatefulWidget {
  final ARService arService;
  final ARHitTestResult hitResult;
  final Function(ARObject) onObjectPlaced;

  const ObjectPlacementPanel({
    Key? key,
    required this.arService,
    required this.hitResult,
    required this.onObjectPlaced,
  }) : super(key: key);

  @override
  State<ObjectPlacementPanel> createState() => _ObjectPlacementPanelState();
}

class _ObjectPlacementPanelState extends State<ObjectPlacementPanel> {
  ARObjectType? _selectedType;
  late TextEditingController _nameController;
  bool _isPlacing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Object');
  }

  Future<void> _placeObject() async {
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an object type')),
      );
      return;
    }

    setState(() => _isPlacing = true);

    try {
      final selectedType = _selectedType;
      if (selectedType == null) return;

      final object = await widget.arService.placeObject(
        widget.hitResult,
        modelPath: 'models/${selectedType.name}.gltf',
        name: _nameController.text,
        type: selectedType,
      );

      widget.onObjectPlaced(object);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_nameController.text} placed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to place object: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPlacing = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Place Object',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Object Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          ObjectTypePicker(
            selectedType: _selectedType,
            onSelected: (type) {
              setState(() => _selectedType = type);
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isPlacing ? null : _placeObject,
              icon: _isPlacing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add),
              label: Text(_isPlacing ? 'Placing...' : 'Place Object'),
            ),
          ),
        ],
      ),
    );
  }
}
