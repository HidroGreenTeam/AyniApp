import 'package:flutter/material.dart';
import 'login_page_new.dart';
import 'register_page_new.dart';

// This method will replace the original auth method selection page
// to use our new login and register pages
class AuthMethodSelectionPageUpdated extends StatelessWidget {
  const AuthMethodSelectionPageUpdated({super.key});

  @override
  Widget build(BuildContext context) {
    // We're directly routing to our updated login page which has the design from the image
    // The login page now shows the registration form and has a link to the login form
    return const LoginPage();
  }
}

// Helper function to update routes in the app
void updateRoutes(BuildContext context) {
  // This will replace the current page with our new login page
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (_) => const LoginPage()),
  );
}
