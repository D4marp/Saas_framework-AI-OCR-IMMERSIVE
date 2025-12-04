import 'package:flutter/material.dart';
import '../providers/face_recognition_provider.dart';

/// Screen untuk management enrolled faces
class EnrolledFacesScreen extends StatefulWidget {
  final FaceRecognitionProvider faceProvider;

  const EnrolledFacesScreen({
    super.key,
    required this.faceProvider,
  });

  @override
  State<EnrolledFacesScreen> createState() => _EnrolledFacesScreenState();
}

class _EnrolledFacesScreenState extends State<EnrolledFacesScreen> {
  @override
  Widget build(BuildContext context) {
    final faces = widget.faceProvider.enrolledFaces;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enrolled Faces'),
        centerTitle: true,
      ),
      body: faces.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.face_retouching_natural,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No enrolled faces yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Enrolled',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            faces.length.toString(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Enrolled People',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: faces.length,
                    itemBuilder: (context, index) {
                      final face = faces[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue[100],
                            child: const Icon(Icons.person),
                          ),
                          title: Text(face.name),
                          subtitle: Text('ID: ${face.userId}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Face'),
                                  content: Text(
                                      'Delete ${face.name}? This action cannot be undone.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        await widget.faceProvider
                                            .removeEnrolledFace(face.id);
                                        if (mounted) {
                                          setState(() {});
                                        }
                                      },
                                      child: const Text('Delete',
                                          style: TextStyle(
                                              color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
