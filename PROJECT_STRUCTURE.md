# SaaS Framework - Project Structure

## Directory Layout

```
saas_framework/
├── lib/                                    # Main library code
│   ├── saas_framework.dart                # Main export file
│   ├── examples/                          # Examples directory (NEW)
│   │   └── face_recognition/              # Face Recognition examples
│   │       ├── face_recognition_example.dart           # Simple example
│   │       ├── face_recognition_complete_example.dart  # Complete example
│   │       └── README.md                               # Documentation
│   │
│   └── src/                               # Source code
│       ├── constants/                     # Application constants
│       │   ├── exports.dart
│       │   └── app_constants.dart
│       ├── core/                          # Core utilities
│       │   ├── exports.dart
│       │   └── app_config.dart
│       ├── models/                        # Data models
│       │   ├── exports.dart
│       │   └── [model files]
│       ├── modules/                       # Feature modules
│       │   └── face_recognition/          # Face Recognition Module
│       │       ├── exports.dart
│       │       ├── models/
│       │       │   ├── exports.dart
│       │       │   └── face_models.dart
│       │       ├── services/
│       │       │   ├── exports.dart
│       │       │   └── face_recognition_service.dart
│       │       ├── platform/
│       │       │   ├── exports.dart
│       │       │   └── [platform implementations]
│       │       └── widgets/
│       │           ├── components/
│       │           ├── providers/
│       │           │   └── face_recognition_provider.dart
│       │           └── screens/
│       │               ├── enrollment_screen.dart
│       │               ├── recognition_screen.dart
│       │               └── enrolled_faces_screen.dart
│       ├── services/                      # Global services
│       │   ├── exports.dart
│       │   └── [service files]
│       ├── utils/                         # Utility functions
│       │   ├── exports.dart
│       │   └── [utility files]
│       └── widgets/                       # Global widgets
│           ├── exports.dart
│           └── [widget files]
│
├── example/                               # Example application
│   ├── lib/
│   │   ├── main.dart                      # Entry point (imports from lib)
│   │   ├── face_models.dart               # Export shim
│   │   ├── face_recognition_service.dart  # Export shim
│   │   ├── face_recognition_provider.dart # Export shim
│   │   ├── enrollment_screen.dart         # Export shim
│   │   ├── recognition_screen.dart        # Export shim
│   │   └── enrolled_faces_screen.dart     # Export shim
│   ├── test/
│   │   └── widget_test.dart               # Widget tests
│   └── pubspec.yaml
│
├── test/                                  # Unit tests
├── android/                               # Android-specific code
├── ios/                                   # iOS-specific code
├── web/                                   # Web-specific code
├── macos/                                 # macOS-specific code
├── linux/                                 # Linux-specific code
├── windows/                               # Windows-specific code
│
├── pubspec.yaml                           # Project dependencies
├── pubspec.lock                           # Locked dependencies
├── analysis_options.yaml                  # Dart analysis configuration
├── ARCHITECTURE.md                        # Architecture documentation
└── README.md                              # Project README
```

## Module Organization

### Face Recognition Module
Located in `lib/src/modules/face_recognition/`

**Structure:**
```
face_recognition/
├── models/              # Data models (FaceDetectionResult, EnrolledFace, etc.)
├── services/            # Core service logic (FaceRecognitionService)
├── platform/            # Platform-specific implementations (Mobile, Web)
├── widgets/
│   ├── components/      # Reusable UI components
│   ├── providers/       # State management (FaceRecognitionProvider)
│   └── screens/         # Complete screens (Enrollment, Recognition, etc.)
└── exports.dart         # Module exports
```

**Key Classes:**
- `FaceRecognitionService` - Core service (singleton)
- `FaceRecognitionProvider` - State management (ChangeNotifier)
- Screen widgets - UI implementation
- Data models - Serializable data structures

### Examples Structure
Located in `lib/examples/face_recognition/`

**Files:**
1. `face_recognition_example.dart` - Simple service demonstration
2. `face_recognition_complete_example.dart` - Full app with 3 screens
3. `README.md` - Documentation for examples

**Usage:**
- Run from `example/lib/main.dart` 
- Or directly via: `flutter run lib/examples/face_recognition/face_recognition_complete_example.dart`

## Export Shims in example/lib

Files like `face_models.dart`, `face_recognition_service.dart` in `example/lib/` are **export shims** that re-export from the main module:

```dart
// example/lib/face_models.dart
export 'package:saas_framework/src/modules/face_recognition/models/face_models.dart';
```

**Purpose:**
- Maintain backward compatibility
- Easy migration path for existing code
- Clear separation between module and example

## Dependencies Flow

```
Application (example/lib)
    ↓
SaaS Framework (lib)
    ├── Face Recognition Module
    │   ├── Services
    │   ├── Models
    │   └── Widgets
    ├── Core Utilities
    ├── Constants
    └── Other Modules
```

## Best Practices

1. **Module Independence**: Face Recognition module can be used independently
2. **Export Everything**: Use `exports.dart` files for clean imports
3. **Separation of Concerns**: Keep UI, logic, and data separate
4. **Platform Abstraction**: Abstract platform services behind interfaces
5. **State Management**: Use Provider/ChangeNotifier for UI state
6. **Example-Driven**: Examples serve as documentation

## Running Examples

```bash
# Run the complete face recognition example
flutter run lib/examples/face_recognition/face_recognition_complete_example.dart

# Run the simple face recognition example
flutter run lib/examples/face_recognition/face_recognition_example.dart

# Run tests
flutter test
```

## Importing from the Module

```dart
// Import specific models
import 'package:saas_framework/src/modules/face_recognition/models/face_models.dart';

// Import service
import 'package:saas_framework/src/modules/face_recognition/services/face_recognition_service.dart';

// Import provider
import 'package:saas_framework/src/modules/face_recognition/widgets/providers/face_recognition_provider.dart';

// Import screens
import 'package:saas_framework/src/modules/face_recognition/widgets/screens/enrollment_screen.dart';
```

## Adding New Modules

When adding a new module:

1. Create `lib/src/modules/[module_name]/` directory
2. Structure with: `models/`, `services/`, `widgets/`, `platform/`
3. Create `exports.dart` with all public exports
4. Add examples in `lib/examples/[module_name]/`
5. Update main `saas_framework.dart` with module exports

---

**Last Updated**: December 4, 2025
**Version**: 0.1.0-beta
