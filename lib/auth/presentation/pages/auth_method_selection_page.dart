import 'package:flutter/material.dart';
import 'login_form_page.dart';
import 'register_page.dart';

class AuthMethodSelectionPage extends StatelessWidget {
  const AuthMethodSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 80),
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF0F9F4),
                ),
                child: const Icon(
                  Icons.eco,
                  size: 60,
                  color: Color(0xFF00C851),
                ),
              ),
              const SizedBox(height: 48),
              const Text(
                'Let\'s Get Started!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E3A2F),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Let\'s dive into your account',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF7A8471),
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const RegisterPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C851),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Sign up',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const LoginFormPage(),
                    ),
                  );
                },
                child: const Text(
                  'Log in',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF00C851),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Privacy Policy',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7A8471),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  SizedBox(width: 16),
                  Text(
                    'Terms of Service',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7A8471),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
