import 'package:flutter/material.dart';
import 'login_page_new.dart';

class AuthMethodSelectionPageUpdated extends StatelessWidget {
  const AuthMethodSelectionPageUpdated({super.key});

  @override
  Widget build(BuildContext context) {
    // Immediately redirect to our new login page that has the UI from the image
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    });
    
    // Return an empty scaffold while redirecting
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
