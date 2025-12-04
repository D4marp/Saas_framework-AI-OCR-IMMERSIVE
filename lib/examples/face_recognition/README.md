# Face Recognition Examples

This directory contains example implementations of the Face Recognition module from the SaaS Framework.

## Files

### 1. `face_recognition_example.dart`
A simple example showcasing:
- Service initialization
- Module features overview
- Platform support information
- Activity logging
- Quick start code snippet

**Run with:**
```bash
flutter run lib/examples/face_recognition/face_recognition_example.dart
```

### 2. `face_recognition_complete_example.dart`
A complete, production-ready example with:
- **Registrasi Screen**: Enrollment of new faces with full form validation
- **Absen Screen**: Face recognition and attendance system
- **Manage Screen**: View and delete enrolled faces
- Bottom navigation between screens
- Error handling and user feedback

**Run with:**
```bash
flutter run lib/examples/face_recognition/face_recognition_complete_example.dart
```

## Features Demonstrated

### Face Recognition Module
- ✓ Face Detection
- ✓ Face Enrollment (Registration)
- ✓ Face Recognition (Matching)
- ✓ Multi-platform support (Android, iOS, Web)
- ✓ State management with ChangeNotifier
- ✓ Error handling and logging

### UI Components
- Status cards with visual indicators
- Image preview with upload functionality
- Form validation
- Loading states with progress indicators
- Success/Error notifications
- Activity logs
- Platform information display

## Integration Points

These examples use the SaaS Framework's Face Recognition module:
- `FaceRecognitionService` - Core service
- `FaceRecognitionProvider` - State management
- Screen components from the main module

## Usage in Your App

To use these examples in your application:

```dart
import 'package:saas_framework/examples/face_recognition/face_recognition_complete_example.dart';

// In your main.dart
void main() {
  runApp(const FaceRecognitionApp());
}
```

## Customization

You can customize these examples by:
1. Modifying colors and themes in `ThemeData`
2. Changing form fields and validation rules
3. Implementing actual image picker functionality
4. Adding camera integration
5. Connecting to your backend database
6. Implementing real-time face detection with camera stream

## Notes

- These are demonstration examples
- Image picker and camera capture are simplified (show SnackBar)
- For production use, integrate `image_picker` and `camera` packages
- Face recognition results depend on model implementation
- Adjust similarity threshold based on your use case

## Architecture

```
Example App
    ↓
FaceRecognitionProvider (State Management)
    ↓
FaceRecognitionService (Core Logic)
    ↓
Platform Services (Android/iOS/Web)
```

For more details, see `../../ARCHITECTURE.md` in the project root.
