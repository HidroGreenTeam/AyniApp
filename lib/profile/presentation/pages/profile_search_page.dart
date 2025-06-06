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
  final List<String> _selectedInterests = [];
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
      interests: _selectedInterests.isEmpty ? null : _selectedInterests,
      page: page,
    ));
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _locationController.clear();
      _selectedInterests.clear();
    });
    _performSearch();
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        _selectedInterests.add(interest);
      }
    });
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

                  // Interests Filter
                  const Text(
                    'Intereses:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      'Agricultura',
                      'Jardinería',
                      'Sostenibilidad',
                      'Plantas',
                      'Cultivos',
                      'Orgánico',
                      'Permacultura',
                      'Hidroponía',
                    ].map((interest) => FilterChip(
                      label: Text(interest),
                      selected: _selectedInterests.contains(interest),
                      onSelected: (_) => _toggleInterest(interest),
                      backgroundColor: AppColors.lightGray,
                      selectedColor: AppColors.lightGreen,
                      checkmarkColor: AppColors.primaryGreen,
                    )).toList(),
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
                          Icons.search_off,
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
      child: InkWell(        onTap: () {
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
                backgroundImage: profile.profilePicture != null
                    ? NetworkImage(profile.profilePicture!)
                    : null,
                child: profile.profilePicture == null
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
                      profile.fullName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    
                    if (profile.location != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            profile.location!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],

                    if (profile.bio != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        profile.bio!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    if (profile.interests != null && profile.interests!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: profile.interests!.take(3).map((interest) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.lightGreen,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            interest,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        )).toList(),
                      ),
                    ],
                  ],
                ),
              ),

              // Verified Badge
              if (profile.isVerified)
                const Icon(
                  Icons.verified,
                  color: AppColors.primaryGreen,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
