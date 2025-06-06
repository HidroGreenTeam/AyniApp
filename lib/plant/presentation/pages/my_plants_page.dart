import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class MyPlantsPage extends StatelessWidget {
  const MyPlantsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(      appBar: AppBar(
        title: const Text('My Plants'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Implement adding a new plant
            },
          ),
        ],
      ),
      body: Center(        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.eco_outlined, size: 80, color: AppColors.grey400),
            const SizedBox(height: 16),
            Text(
              'No Plants Added Yet',
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
                'Add plants to your collection to track their growth and get care reminders',
                textAlign: TextAlign.center,
                style: TextStyle(
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
                // TODO: Implement add plant feature
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Your First Plant', style: TextStyle(fontSize: 16)),
            )
          ],
        ),
      ),
    );
  }
}
