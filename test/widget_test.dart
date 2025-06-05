// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ayni/main.dart';
import 'package:ayni/core/di/service_locator.dart';

void main() {
  testWidgets('App starts with splash screen', (WidgetTester tester) async {
    // Initialize shared preferences for testing
    SharedPreferences.setMockInitialValues({});
    
    // Initialize dependencies
    await initDependencies();
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    
    // Wait for the splash screen to load and process initial animations
    await tester.pump();
    
    // Fast-forward time to let all timers complete
    await tester.pump(const Duration(seconds: 5));

    // Verify that our app shows some content (the splash screen should be visible)
    // We look for any widget that contains our app structure
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
