import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../detection/data/models/disease_info.dart';
import '../../../detection/presentation/pages/disease_detail_page.dart';

/// Home page widget following MVVM architecture
/// 
/// This widget serves as the main entry point for the disease detection feature.
/// It displays a header with app branding, search functionality, and detectable diseases.
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildSearchBar(),
              _buildSectionTitle(),
              Expanded(child: _buildDiseasesGrid()),
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
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: AppColors.grey500, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Buscar enfermedades...',
                  hintStyle: TextStyle(
                    color: AppColors.grey500,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
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
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Enfermedades Detectables',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Ver Todas',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 2),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.primaryGreen,
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiseasesGrid() {
    // Get detectable diseases (excluding nodisease)
    final List<DiseaseInfo> diseases = DiseaseRepository.getDiseases();
    
    return GridView.builder(
      padding: const EdgeInsets.only(top: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.05,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: diseases.length,
      itemBuilder: (context, index) {
        return _buildDiseaseCard(context, diseases[index]);
      },
    );
  }

  Widget _buildDiseaseCard(BuildContext context, DiseaseInfo disease) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DiseaseDetailPage(disease: disease),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Disease icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getDiseaseIcon(disease.id),
                  color: AppColors.primaryGreen,
                  size: 20,
                ),
              ),
              const SizedBox(height: 8),
              // Disease name
              Text(
                disease.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Disease description preview
              Text(
                disease.description,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              // Learn more indicator
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Ver más',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.primaryGreen,
                    size: 14,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getDiseaseIcon(String diseaseId) {
    switch (diseaseId) {
      case 'miner':
        return Icons.bug_report;
      case 'phoma':
        return Icons.circle;
      case 'redspider':
        return Icons.bug_report;
      case 'rust':
        return Icons.warning;
      default:
        return Icons.eco;
    }
  }
}
