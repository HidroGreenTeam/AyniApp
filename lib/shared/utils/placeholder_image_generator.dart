import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

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
      final textPainter = TextPainter(
        text: TextSpan(
          text: category.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
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
        return Colors.pink[200]!;
      case 'foliage':
        return Colors.green[200]!;
      case 'trees':
        return Colors.green[400]!;
      case 'shrubs':
        return Colors.teal[200]!;
      case 'fruits':
        return Colors.deepOrange[200]!;
      case 'vegetables':
        return Colors.lightGreen[300]!;
      case 'herbs':
        return Colors.lightGreen[100]!;
      case 'mushrooms':
        return Colors.brown[200]!;
      case 'toxic':
        return Colors.red[200]!;
      default:
        return Colors.grey[400]!;
    }
  }
}
