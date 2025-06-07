import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_theme.dart';
import '../../domain/entities/profile.dart';
import '../blocs/profile_bloc.dart';
import 'profile_management_page.dart';
import 'profile_search_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<ProfileBloc>()..add(const ProfileLoadCurrent()),
      child: const ProfileView(),
    );
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state.status == ProfileStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Error desconocido'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          title: const Text(
            'Mi Perfil',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          backgroundColor: AppColors.white,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () {
                context.read<ProfileBloc>().add(const ProfileLoadCurrent());
              },
              icon: const Icon(Icons.refresh, color: AppColors.primaryGreen),
            ),
          ],
        ),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state.status == ProfileStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header
                  _buildProfileHeader(context, state.currentProfile),
                  
                  const SizedBox(height: 30),
                  
                  // Profile Completion Card
                  if (state.currentProfile != null)
                    _buildProfileCompletionCard(context, state.currentProfile!),
                  
                  const SizedBox(height: 30),
                  
                  // Quick Actions
                  _buildQuickActions(context, state.currentProfile),
                  
                  const SizedBox(height: 30),
                  
                  // Profile Stats
                  if (state.currentProfile != null)
                    _buildProfileStats(context, state.currentProfile!),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, Profile? profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Profile Picture
          Stack(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.white.withOpacity(0.3),
                backgroundImage: profile?.imageUrl != null
                    ? NetworkImage(profile!.imageUrl!)
                    : null,
                child: profile?.imageUrl == null
                    ? const Icon(Icons.person, size: 40, color: AppColors.textSecondary)
                    : null,
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Username and email
          if (profile != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.username,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.email,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildProfileCompletionCard(BuildContext context, Profile profile) {
    final completion = _getProfileCompletionPercentage(profile);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.lightGreen.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGreen),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.trending_up,
                color: AppColors.primaryGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Completitud del Perfil',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${completion.round()}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          LinearProgressIndicator(
            value: completion / 100,
            backgroundColor: AppColors.lightGray,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            completion < 100 
                ? 'Completa tu perfil para obtener mejores resultados'
                : '¡Perfil completo! Excelente trabajo',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, Profile? profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Acciones Rápidas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.edit_outlined,
                title: 'Editar Perfil',
                subtitle: 'Actualizar información',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfileManagementPage(),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(width: 12),
            
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.search_outlined,
                title: 'Buscar',
                subtitle: 'Encontrar perfiles',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfileSearchPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.lightGray),
          boxShadow: [
            BoxShadow(
              color: AppColors.textSecondary.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColors.primaryGreen,
                size: 24,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 4),
            
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStats(BuildContext context, Profile profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Estadísticas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.lightGray),
          ),
          child: Column(
            children: [
              _buildStatItem(
                'Fecha de Registro',
                _formatDate(profile.createdAt),
                Icons.calendar_today_outlined,
              ),
              
              const Divider(height: 24),
              
              _buildStatItem(
                'Última Actualización',
                _formatDate(profile.updatedAt),
                Icons.update_outlined,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
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
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  double _getProfileCompletionPercentage(Profile profile) {
    int completedFields = 0;
    const int totalFields = 4; // username, email, phoneNumber, imageUrl
    if (profile.username.isNotEmpty) completedFields++;
    if (profile.email.isNotEmpty) completedFields++;
    if (profile.phoneNumber.isNotEmpty) completedFields++;
    if (profile.imageUrl != null && profile.imageUrl!.isNotEmpty) completedFields++;
    return (completedFields / totalFields) * 100;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
