import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../domain/entities/profile.dart';

class ProfileDetailPage extends StatelessWidget {
  final Profile profile;

  const ProfileDetailPage({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          profile.username,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 30),
            _buildSection(
              title: 'Información de Contacto',
              child: Column(
                children: [
                  _buildInfoItem(
                    icon: Icons.email_outlined,
                    label: 'Correo',
                    value: profile.email,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoItem(
                    icon: Icons.phone_outlined,
                    label: 'Teléfono',
                    value: profile.phoneNumber,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildSection(
              title: 'Información del Perfil',
              child: Column(
                children: [
                  _buildInfoItem(
                    icon: Icons.calendar_today_outlined,
                    label: 'Fecha de registro',
                    value: _formatDate(profile.createdAt),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoItem(
                    icon: Icons.update_outlined,
                    label: 'Última actualización',
                    value: _formatDate(profile.updatedAt),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          // Profile Picture
          CircleAvatar(
            radius: 60,
            backgroundColor: AppColors.lightGray,
            backgroundImage: profile.imageUrl != null && profile.imageUrl!.isNotEmpty
                ? NetworkImage(profile.imageUrl!)
                : null,
            child: (profile.imageUrl == null || profile.imageUrl!.isEmpty)
                ? const Icon(Icons.person, size: 60, color: AppColors.textSecondary)
                : null,
          ),
          const SizedBox(height: 16),
          // Username
          Text(
            profile.username,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          // Email
          const SizedBox(height: 8),
          Text(
            profile.email,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.lightGray),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.primaryGreen,
          size: 20,
        ),
        
        const SizedBox(width: 12),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              
              const SizedBox(height: 2),
              
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }
}
