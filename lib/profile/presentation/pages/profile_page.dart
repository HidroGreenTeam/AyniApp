import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/service_locator.dart';
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
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        } else if (state.status == ProfileStatus.noProfile) {
          // Redirect to profile creation when no profile exists
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const ProfileManagementPage(),
              ),
            );
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Mi Perfil',
          ),
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () {
                context.read<ProfileBloc>().add(const ProfileLoadCurrent());
              },
              icon: Icon(Icons.refresh, color: Theme.of(context).colorScheme.primary),
            ),
          ],
        ),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state.status == ProfileStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == ProfileStatus.noProfile) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_add,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Configura tu Perfil',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Para comenzar, necesitas crear tu perfil',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
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
                backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.3),
                backgroundImage: profile?.imageUrl != null
                    ? NetworkImage(profile!.imageUrl!)
                    : null,
                child: profile?.imageUrl == null
                    ? Icon(Icons.person, size: 40, color: Theme.of(context).colorScheme.onSurfaceVariant)
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
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.email,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Completitud del Perfil',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${completion.round()}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          LinearProgressIndicator(
            value: completion / 100,
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            completion < 100 
                ? 'Completa tu perfil para obtener mejores resultados'
                : '¡Perfil completo! Excelente trabajo',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
          ),
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(              child: _buildActionCard(
                context,
                icon: Icons.edit_outlined,
                title: 'Editar Perfil',
                subtitle: 'Actualizar información',
                onTap: () {
                  final currentProfile = context.read<ProfileBloc>().state.currentProfile;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileManagementPage(
                        isEditing: true,
                        existingProfile: currentProfile,
                      ),
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
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
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
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                size: 24,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 4),
            
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
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
          ),
        ),
        
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          child: Column(
            children: [
              _buildStatItem(
                context,
                'Fecha de Registro',
                _formatDate(profile.createdAt),
                Icons.calendar_today_outlined,
              ),
              
              const Divider(height: 24),
              
              _buildStatItem(
                context,
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

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
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
