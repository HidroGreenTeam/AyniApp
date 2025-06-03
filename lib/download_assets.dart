import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

// This is a utility script to download placeholder images for plant categories
// You should run this once to generate the necessary assets
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // These are just placeholder URLs for demonstration
  // You should replace these with your actual image URLs
  final imageUrls = {
    'flowering.png': 'https://placehold.co/400x400/f8bbd0/ffffff?text=Flowering',
    'foliage.png': 'https://placehold.co/400x400/c8e6c9/ffffff?text=Foliage',
    'trees.png': 'https://placehold.co/400x400/a5d6a7/ffffff?text=Trees',
    'shrubs.png': 'https://placehold.co/400x400/b2dfdb/ffffff?text=Shrubs',
    'fruits.png': 'https://placehold.co/400x400/ffccbc/ffffff?text=Fruits',
    'vegetables.png': 'https://placehold.co/400x400/c5e1a5/ffffff?text=Vegetables',
    'herbs.png': 'https://placehold.co/400x400/dcedc8/ffffff?text=Herbs',
    'mushrooms.png': 'https://placehold.co/400x400/d7ccc8/ffffff?text=Mushrooms',
    'toxic.png': 'https://placehold.co/400x400/ffcdd2/ffffff?text=Toxic',
  };

  final directory = await getApplicationDocumentsDirectory();
  final assetsDir = Directory(path.join(directory.path, 'assets/images'));
  
  if (!await assetsDir.exists()) {
    await assetsDir.create(recursive: true);
  }

  for (final entry in imageUrls.entries) {
    final fileName = entry.key;
    final url = entry.value;
    
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      final file = File(path.join(assetsDir.path, fileName));
      await file.writeAsBytes(response.bodyBytes);      debugPrint('Downloaded $fileName');
    } else {
      debugPrint('Failed to download $fileName: ${response.statusCode}');
    }
  }
  
  debugPrint('All assets downloaded to ${assetsDir.path}');
  debugPrint('Copy these files to your assets/images directory in the project');
}
