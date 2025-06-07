import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_theme.dart';
import '../../domain/entities/profile.dart';
import '../blocs/profile_bloc.dart';
import 'profile_detail_page.dart';

class ProfileSearchPage extends StatelessWidget {
  const ProfileSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<ProfileBloc>(),
      child: const ProfileSearchView(),
    );
  }
}

class ProfileSearchView extends StatefulWidget {
  const ProfileSearchView({super.key});

  @override
  State<ProfileSearchView> createState() => _ProfileSearchViewState();
}

class _ProfileSearchViewState extends State<ProfileSearchView> {
  final _searchController = TextEditingController();
  final _locationController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Load initial profiles
    context.read<ProfileBloc>().add(const ProfileSearch());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9) {
      final state = context.read<ProfileBloc>().state;
      if (state.hasMore && state.status != ProfileStatus.searching) {
        _performSearch(loadMore: true);
      }
    }
  }

  void _performSearch({bool loadMore = false}) {
    final page = loadMore ? context.read<ProfileBloc>().state.currentPage + 1 : 1;
    
    context.read<ProfileBloc>().add(ProfileSearch(
      search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
      location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
      page: page,
    ));
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _locationController.clear();
    });
    _performSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          'Buscar Perfiles',
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
              setState(() {
                _showFilters = !_showFilters;
              });
            },
            icon: Icon(
              _showFilters ? Icons.filter_list_off : Icons.filter_list,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onSubmitted: (_) => _performSearch(),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primaryGreen),
                suffixIcon: IconButton(
                  onPressed: _performSearch,
                  icon: const Icon(Icons.send, color: AppColors.primaryGreen),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.lightGray),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryGreen),
                ),
                filled: true,
                fillColor: AppColors.lightGray.withValues(alpha: 0.3),
              ),
            ),
          ),

          // Filters Section
          if (_showFilters)
            Container(
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: AppColors.lightGray.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location Filter
                  TextField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      labelText: 'Ubicación',
                      prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.primaryGreen),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.primaryGreen),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Filter Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _clearFilters,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primaryGreen),
                          ),
                          child: const Text(
                            'Limpiar',
                            style: TextStyle(color: AppColors.primaryGreen),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _performSearch,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                          ),
                          child: const Text(
                            'Aplicar',
                            style: TextStyle(color: AppColors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Results
          Expanded(
            child: BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                if (state.status == ProfileStatus.searching && state.searchResults.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.status == ProfileStatus.error) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.errorMessage ?? 'Error al buscar perfiles',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _performSearch,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                if (state.searchResults.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_search,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No se encontraron perfiles',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: state.searchResults.length + (state.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= state.searchResults.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final profile = state.searchResults[index];
                    return _buildProfileCard(profile);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(Profile profile) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (_) => ProfileDetailPage(profile: profile)
            )
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Profile Picture
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.lightGray,
                backgroundImage: profile.imageUrl != null
                    ? NetworkImage(profile.imageUrl!)
                    : null,
                child: profile.imageUrl == null
                    ? const Icon(Icons.person, size: 30, color: AppColors.textSecondary)
                    : null,
              ),

              const SizedBox(width: 16),

              // Profile Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.username,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 8),
                    Text(
                      profile.email,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),
                    Text(
                      profile.phoneNumber,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
