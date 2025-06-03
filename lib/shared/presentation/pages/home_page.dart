import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                height: 35,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.eco,
                  color: Color(0xFF00C851),
                  size: 35,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Ayni',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          
          // Notification and bookmark buttons
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Stack(
                    children: [
                      const Icon(Icons.notifications_outlined, color: Colors.black54),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
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
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.bookmark_outline, color: Colors.black54),
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
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.grey[500]),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search plants...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
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
        children: [
          const Text(
            'Explore Plants',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Row(
              children: const [
                Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF00C851),
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward,
                  color: Color(0xFF00C851),
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildPlantCategories() {
    // List of plant categories with their images and icon backups
    final List<Map<String, dynamic>> categories = [
      {
        'name': 'Succulents\n&Cacti', 
        'image': 'assets/images/succulents.png',
        'icon': Icons.spa,
        'color': Colors.green[200],
      },
      {
        'name': 'Flowering\nPlants', 
        'image': 'assets/images/flowering.png',
        'icon': Icons.local_florist,
        'color': Colors.pink[100],
      },
      {
        'name': 'Foliage\nPlants', 
        'image': 'assets/images/foliage.png',
        'icon': Icons.eco,
        'color': Colors.green[300],
      },
      {
        'name': 'Trees', 
        'image': 'assets/images/trees.png',
        'icon': Icons.park,
        'color': Colors.green[700],
      },
      {
        'name': 'Weeds &\nShrubs', 
        'image': 'assets/images/shrubs.png',
        'icon': Icons.grass,
        'color': Colors.teal[300],
      },
      {
        'name': 'Fruits', 
        'image': 'assets/images/fruits.png',
        'icon': Icons.emoji_food_beverage,
        'color': Colors.deepOrange[200],
      },
      {
        'name': 'Vegetables', 
        'image': 'assets/images/vegetables.png',
        'icon': Icons.set_meal,
        'color': Colors.lightGreen[300],
      },
      {
        'name': 'Herbs', 
        'image': 'assets/images/herbs.png',
        'icon': Icons.emoji_nature,
        'color': Colors.lightGreen[100],
      },
      {
        'name': 'Mushrooms', 
        'image': 'assets/images/mushrooms.png',
        'icon': Icons.filter_vintage,
        'color': Colors.brown[200],
      },
      {
        'name': 'Toxic Plants', 
        'image': 'assets/images/toxic.png',
        'icon': Icons.warning,
        'color': Colors.red[200],
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
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
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
                    color: Colors.black87,
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
                    color: category['color'] ?? Colors.grey[300],
                    child: Icon(
                      category['icon'] ?? Icons.eco,
                      color: Colors.white,
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
