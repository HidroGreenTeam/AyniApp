import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Home page widget following MVVM architecture
/// 
/// This widget serves as the main entry point for the plant exploration feature.
/// It displays a header with app branding, search functionality, and plant categories.
/// 
/// Architecture: View layer in MVVM pattern
/// - Stateless widget for optimal performance
/// - Uses centralized theme system for consistent styling
/// - Implements responsive design patterns
class HomePage extends StatelessWidget {
  /// Creates a new instance of [HomePage]
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildSearchBar(),
              _buildSectionTitle(),
              Expanded(child: _buildPlantCategories()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo and title
          Row(
            children: [
              Image.asset(
                'assets/icons/plant_logo.png',
                width: 35,
                height: 35,                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.eco,
                  color: AppColors.primaryGreen,
                  size: 35,
                ),
              ),
              const SizedBox(width: 8),              const Text(
                'Ayni',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          
          // Notification and bookmark buttons
          Row(
            children: [              Container(
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Stack(
                    children: [
                      const Icon(Icons.notifications_outlined, color: AppColors.textSecondary),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.bookmark_outline, color: AppColors.textSecondary),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: AppColors.grey500),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search plants...',
                  hintStyle: TextStyle(color: AppColors.grey500),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [          const Text(
            'Explore Plants',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Row(
              children: const [
                Text(                'View All',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.primaryGreen,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward,
                  color: AppColors.primaryGreen,
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }  Widget _buildPlantCategories() {
    // List of plant categories with their images and icon backups
    final List<Map<String, dynamic>> categories = [
      {
        'name': 'Succulents\n&Cacti', 
        'image': 'assets/images/succulents.png',
        'icon': Icons.spa,
        'color': AppColors.foliage,
      },
      {
        'name': 'Flowering\nPlants', 
        'image': 'assets/images/flowering.png',
        'icon': Icons.local_florist,
        'color': AppColors.flowering,
      },
      {
        'name': 'Foliage\nPlants', 
        'image': 'assets/images/foliage.png',
        'icon': Icons.eco,
        'color': AppColors.foliage,
      },
      {
        'name': 'Trees', 
        'image': 'assets/images/trees.png',
        'icon': Icons.park,
        'color': AppColors.trees,
      },
      {
        'name': 'Weeds &\nShrubs', 
        'image': 'assets/images/shrubs.png',
        'icon': Icons.grass,
        'color': AppColors.shrubs,
      },
      {
        'name': 'Fruits', 
        'image': 'assets/images/fruits.png',
        'icon': Icons.emoji_food_beverage,
        'color': AppColors.fruits,
      },
      {
        'name': 'Vegetables', 
        'image': 'assets/images/vegetables.png',
        'icon': Icons.set_meal,
        'color': AppColors.vegetables,
      },
      {
        'name': 'Herbs', 
        'image': 'assets/images/herbs.png',
        'icon': Icons.emoji_nature,
        'color': AppColors.herbs,
      },
      {
        'name': 'Mushrooms', 
        'image': 'assets/images/mushrooms.png',
        'icon': Icons.filter_vintage,
        'color': AppColors.mushrooms,
      },
      {
        'name': 'Toxic Plants', 
        'image': 'assets/images/toxic.png',
        'icon': Icons.warning,
        'color': AppColors.toxic,
      },
    ];

    return GridView.builder(
      padding: const EdgeInsets.only(top: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.4,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return _buildCategoryItem(categories[index]);
      },
    );
  }
  Widget _buildCategoryItem(Map<String, dynamic> category) {
    return GestureDetector(      onTap: () {
        // TODO: Navigate to the specific plant category page
        // Navigate to category: category['name']
      },
      child: Container(        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  category['name']!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  category['image'],
                  width: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 80,
                    height: 80,
                    color: category['color'] ?? AppColors.grey300,
                    child: Icon(
                      category['icon'] ?? Icons.eco,
                      color: AppColors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
