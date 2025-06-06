import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class DiagnosePage extends StatelessWidget {
  const DiagnosePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(      appBar: AppBar(
        title: const Text('Plant Diagnosis'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [            Icon(Icons.search, size: 80, color: AppColors.grey400),
            const SizedBox(height: 16),
            Text(
              'Diagnose Plant Health',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.grey800,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'Take a photo of your plant to diagnose diseases or identify issues',
                textAlign: TextAlign.center,                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.grey600,
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                // TODO: Implement diagnosis feature
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take Photo for Diagnosis', style: TextStyle(fontSize: 16)),
            )
          ],
        ),
      ),
    );
  }
}
