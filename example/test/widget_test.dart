import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/main.dart';

void main() {
  testWidgets('Face Recognition app loads successfully',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FaceRecognitionApp());

    // Verify that the app is loaded
    expect(find.text('Face Recognition System'), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });
}
