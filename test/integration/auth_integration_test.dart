import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ayni/main.dart';
import 'package:ayni/core/di/service_locator.dart';

void main() {
  group('Authentication Integration Tests', () {
    setUpAll(() async {
      // Initialize dependencies for testing
      await initDependencies();
    });

    testWidgets('should show login page when not authenticated', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Verify that login page is shown
      expect(find.text('Welcome to Ayni'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('should validate email and password inputs', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Find form elements
      final emailField = find.byKey(const Key('loginForm_emailInput_textField'));
      final passwordField = find.byKey(const Key('loginForm_passwordInput_textField'));
      final loginButton = find.byKey(const Key('loginForm_submit_button'));

      // Initially button should be disabled
      expect(tester.widget<ElevatedButton>(loginButton).onPressed, isNull);

      // Enter invalid email
      await tester.enterText(emailField, 'invalid-email');
      await tester.pump();

      // Button should still be disabled
      expect(tester.widget<ElevatedButton>(loginButton).onPressed, isNull);

      // Enter valid email but short password
      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, '123');
      await tester.pump();

      // Button should still be disabled
      expect(tester.widget<ElevatedButton>(loginButton).onPressed, isNull);

      // Enter valid email and password
      await tester.enterText(passwordField, 'password123');
      await tester.pump();

      // Button should now be enabled
      expect(tester.widget<ElevatedButton>(loginButton).onPressed, isNotNull);
    });

    testWidgets('should show loading state when login is submitted', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Find form elements
      final emailField = find.byKey(const Key('loginForm_emailInput_textField'));
      final passwordField = find.byKey(const Key('loginForm_passwordInput_textField'));
      final loginButton = find.byKey(const Key('loginForm_submit_button'));

      // Enter valid credentials
      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');
      await tester.pump();

      // Tap login button
      await tester.tap(loginButton);
      await tester.pump();

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('should show error message on login failure', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Find form elements
      final emailField = find.byKey(const Key('loginForm_emailInput_textField'));
      final passwordField = find.byKey(const Key('loginForm_passwordInput_textField'));
      final loginButton = find.byKey(const Key('loginForm_submit_button'));

      // Enter invalid credentials (this will likely fail due to network/auth)
      await tester.enterText(emailField, 'invalid@example.com');
      await tester.enterText(passwordField, 'wrongpassword');
      await tester.pump();

      // Tap login button
      await tester.tap(loginButton);
      await tester.pump();

      // Wait for the request to complete and error to show
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should show error snackbar (may contain authentication failed message)
      expect(find.byType(SnackBar), findsWidgets);
    });
  });
}
