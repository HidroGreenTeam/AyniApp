import 'dart:io';
import 'package:flutter/material.dart';

class ImageResultWidget extends StatelessWidget {
  final File image;
  final String? detectedDisease;
  final double? confidence;
  final VoidCallback onTakePhoto;
  final VoidCallback onSelectFromGallery;

  const ImageResultWidget({
    super.key,
    required this.image,
    this.detectedDisease,
    this.confidence,
    required this.onTakePhoto,
    required this.onSelectFromGallery,
  });

  String _formatDiseaseName(String diseaseName) {
    switch (diseaseName) {
      case 'nodisease':
        return 'Healthy Plant';
      case 'miner':
        return 'Leaf Miner';
      case 'phoma':
        return 'Phoma Leaf Spot';
      case 'redspider':
        return 'Red Spider Mite';
      case 'rust': 
        return 'Leaf Rust';
      default:
        return diseaseName.split('_').map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1);
        }).join(' ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.5),
                spreadRadius: 2,
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.file(
              image,
              height: 320,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (detectedDisease != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: detectedDisease == 'nodisease' 
                  ? [Theme.of(context).colorScheme.primary.withValues(alpha: 0.1), Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)]
                  : [Theme.of(context).colorScheme.error.withValues(alpha: 0.1), Theme.of(context).colorScheme.error.withValues(alpha: 0.2)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: detectedDisease == 'nodisease' 
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
                  : Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  detectedDisease == 'nodisease' ? Icons.eco : Icons.bug_report,
                  size: 40,
                  color: detectedDisease == 'nodisease' 
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 12),
                Text(
                  _formatDiseaseName(detectedDisease!),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: detectedDisease == 'nodisease' 
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: detectedDisease == 'nodisease' 
                      ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                      : Theme.of(context).colorScheme.error.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Confidence: ${(confidence! * 100).toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: detectedDisease == 'nodisease' 
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                onPressed: onTakePhoto,
                icon: const Icon(Icons.camera_alt),
                label: Text(
                  'New Photo', 
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                onPressed: onSelectFromGallery,
                icon: const Icon(Icons.photo_library),
                label: Text(
                  'Gallery', 
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
} 