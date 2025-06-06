import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../core/theme/app_theme.dart';

// This is a utility class to create placeholder images for plant categories
class PlaceholderImageGenerator {
  static Future<void> generatePlaceholderImages() async {
    final categories = [
      'flowering',
      'foliage',
      'trees',
      'shrubs',
      'fruits',
      'vegetables',
      'herbs',
      'mushrooms',
      'toxic',
    ];
    
    final directory = await getApplicationDocumentsDirectory();
    final tempDir = Directory(path.join(directory.path, 'temp_images'));
    
    if (!await tempDir.exists()) {
      await tempDir.create(recursive: true);
    }
      for (final category in categories) {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      
      // Draw a colored rectangle with text
      final paint = Paint()..color = _getColorForCategory(category);
      final textPainter = TextPainter(        text: TextSpan(
          text: category.toUpperCase(),
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      
      // Create a 200x200 image
      const size = 200.0;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size, size),
        paint,
      );
      
      // Center the text
      final textX = (size - textPainter.width) / 2;
      final textY = (size - textPainter.height) / 2;
      textPainter.paint(canvas, Offset(textX, textY));
        final picture = recorder.endRecording();
      final img = await picture.toImage(size.toInt(), size.toInt());
      final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);
      
      if (pngBytes != null) {
        final file = File(path.join(tempDir.path, '$category.png'));
        await file.writeAsBytes(
          pngBytes.buffer.asUint8List(
            pngBytes.offsetInBytes,
            pngBytes.lengthInBytes,
          ),
        );
        debugPrint('Created placeholder for $category at ${file.path}');
      }
    }
    
    debugPrint('Done! Copy these images to your assets/images directory');
  }
  static Color _getColorForCategory(String category) {
    switch (category) {
      case 'flowering':
        return AppColors.flowering;
      case 'foliage':
        return AppColors.foliage;
      case 'trees':
        return AppColors.trees;
      case 'shrubs':
        return AppColors.shrubs;
      case 'fruits':
        return AppColors.fruits;
      case 'vegetables':
        return AppColors.vegetables;
      case 'herbs':
        return AppColors.herbs;
      case 'mushrooms':
        return AppColors.mushrooms;
      case 'toxic':
        return AppColors.toxic;
      default:
        return AppColors.grey400;
    }
  }
}
