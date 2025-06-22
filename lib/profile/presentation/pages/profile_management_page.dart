import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_theme.dart';
import '../../../auth/data/models/auth_models.dart';
import '../../../auth/domain/usecases/get_current_user_use_case.dart';
import '../../data/models/profile_models.dart';
import '../../domain/entities/profile.dart';
import '../blocs/profile_bloc.dart';

class ProfileManagementPage extends StatelessWidget {
  final bool isEditing;
  final Profile? existingProfile;
  
  const ProfileManagementPage({
    super.key,
    this.isEditing = false,
    this.existingProfile,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<ProfileBloc>()
        ..add(existingProfile != null 
            ? ProfileLoadCached() 
            : const ProfileLoadCurrent()),
      child: ProfileManagementView(
        initialIsEditing: isEditing,
        initialProfile: existingProfile,
      ),
    );
  }
}

class ProfileManagementView extends StatefulWidget {
  final bool initialIsEditing;
  final Profile? initialProfile;
  
  const ProfileManagementView({
    super.key,
    this.initialIsEditing = false,
    this.initialProfile,
  });

  @override
  State<ProfileManagementView> createState() => _ProfileManagementViewState();
}

class _ProfileManagementViewState extends State<ProfileManagementView> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isEditing = false;
  String? _profileId;
  UserModel? _authenticatedUser;
  bool _isUserAuthenticated = false;
  // Add a flag to track if the initial load has been processed
  bool _initialLoadProcessed = false;

  @override
  void initState() {
    super.initState();
    _loadAuthenticatedUser();
    
    if (widget.initialProfile != null) {
      _populateFormFromProfile(widget.initialProfile!);
      _isEditing = true; // If an existing profile is passed, we are editing.
      _initialLoadProcessed = true; // Mark initial load as processed if profile is passed directly
    } else {
      // initialProfile is null. ProfileLoadCurrent is being dispatched by the Page widget.
      // _isEditing will be determined by the BlocListener.
      // _initialLoadProcessed is false, indicating we are waiting for the initial load.
    }
  }void _loadAuthenticatedUser() {
    try {
      final getCurrentUserUseCase = serviceLocator<GetCurrentUserUseCase>();
      _authenticatedUser = getCurrentUserUseCase.call();
      _isUserAuthenticated = _authenticatedUser != null;
      
      // Pre-populate form with authenticated user data for new profiles
      if (_authenticatedUser != null && !_isEditing) {
        _usernameController.text = _authenticatedUser!.username.isNotEmpty 
            ? _authenticatedUser!.username 
            : _authenticatedUser!.email.split('@')[0]; // Fallback to email prefix
        if (_authenticatedUser!.phoneNumber.isNotEmpty) {
          _phoneController.text = _authenticatedUser!.phoneNumber;
        }
      }
    } catch (e) {
      _isUserAuthenticated = false;
    }
  }
  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
  
  void _populateFormFromProfile(Profile profile) {
    _usernameController.text = profile.username;
    _phoneController.text = profile.phoneNumber;
    _profileId = profile.id;
  }

  void _clearForm() {
    _usernameController.clear();
    _phoneController.clear();
    _profileId = null;
  }  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;

    // Siempre usamos UPDATE (PUT) ya que el perfil existe en el backend
    final userIdForUpdate = _profileId ?? _authenticatedUser?.id;
    if (userIdForUpdate != null) {
      final updateRequest = UpdateProfileRequest(
        username: _usernameController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      );
      context.read<ProfileBloc>().add(ProfileUpdate(userIdForUpdate, updateRequest));
    }
  }

  void _deleteProfile() {
    if (_profileId == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Perfil'),
        content: const Text('¿Estás seguro de que quieres eliminar tu perfil? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ProfileBloc>().add(ProfileDelete(_profileId!));
            },
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
  Future<void> _pickAndUploadImage() async {
    if (_profileId == null) return;

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );

    if (image != null && mounted) {
      context.read<ProfileBloc>().add(ProfileUploadPicture(_profileId!, image.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        // Handle initial profile loading determination
        if (!_initialLoadProcessed && widget.initialProfile == null) {
          if (state.status == ProfileStatus.loaded && state.currentProfile != null) {
            _populateFormFromProfile(state.currentProfile!);
            setState(() {
              _isEditing = true;
              _initialLoadProcessed = true;
            });
          } else if (state.status == ProfileStatus.noProfile ||
                     (state.status == ProfileStatus.error &&
                      (state.errorMessage?.toLowerCase().contains('not found') == true ||
                       state.errorMessage?.toLowerCase().contains('no profile') == true))) {
            _clearForm();
            setState(() {
              _isEditing = false;
              _initialLoadProcessed = true;
            });
            // Pre-populate with authenticated user data if available and in create mode
            if (_authenticatedUser != null && !_isEditing) {
              _usernameController.text = _authenticatedUser!.username.isNotEmpty
                  ? _authenticatedUser!.username
                  : _authenticatedUser!.email.split('@')[0];
              if (_authenticatedUser!.phoneNumber.isNotEmpty) {
                _phoneController.text = _authenticatedUser!.phoneNumber;
              }
            }
          } else if (state.status == ProfileStatus.error) { // Other errors during initial load
            _clearForm();
            setState(() {
              _isEditing = false; // Fallback to create mode
              _initialLoadProcessed = true;
            });
          }
          // If status is initial or loading, _initialLoadProcessed remains false, and loader shows.
        }
        // Handle subsequent state changes after initial load or if initialProfile was provided
        else if (_initialLoadProcessed || widget.initialProfile != null) {
          if (state.status == ProfileStatus.loaded && state.currentProfile != null) {
            // Profile reloaded (e.g. after update or manual refresh), update form
            _populateFormFromProfile(state.currentProfile!);
            if (!_isEditing) { // Should be editing if profile is loaded
              setState(() {
                _isEditing = true;
              });
            } else {
              // If already editing, just ensure UI reflects any changes from re-population
              setState(() {});
            }
          }
          else if (state.status == ProfileStatus.created || state.status == ProfileStatus.updated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.status == ProfileStatus.created
                    ? 'Perfil creado exitosamente'
                    : 'Perfil actualizado exitosamente'),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
            
            if (state.currentProfile != null) {
              _populateFormFromProfile(state.currentProfile!);
            }
            setState(() {
              _isEditing = true; // After create or update, we are in "editing" mode
            });

            // For new profile creation that came from a flow expecting a profile afterwards
            // (e.g., not just editing an existing one), navigate back.
            // This condition might need to be more specific based on app flow.
            if (state.status == ProfileStatus.created && !widget.initialIsEditing) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          } else if (state.status == ProfileStatus.deleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Perfil eliminado exitosamente'),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
            _clearForm();
            setState(() {
              _isEditing = false; // Go back to create mode or an appropriate state
            });
            // Consider navigation after deletion, e.g., Navigator.of(context).pop();
          } else if (state.status == ProfileStatus.uploaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Foto de perfil actualizada exitosamente'),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
            // Optionally reload profile to show new image if not automatically reflected
            if (state.currentProfile != null) {
               _populateFormFromProfile(state.currentProfile!); // Ensure form/UI reflects this
               setState((){}); // Refresh UI
            }
          } else if (state.status == ProfileStatus.error) {
            // Generic error after initial load processed
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Error desconocido'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          title: Text(
            _isEditing ? 'Gestión de Perfil' : 'Crear tu Perfil',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          leading: _isEditing ? null : IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface),
          ),
          actions: [
            if (_isEditing)
              IconButton(
                onPressed: _deleteProfile,
                icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
              ),
          ],
        ),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            // Show loader if:
            // 1. Initial profile was not provided AND initial load determination is not yet processed
            // OR 2. The bloc is in a general loading state (e.g. user initiated refresh)
            if ((widget.initialProfile == null && !_initialLoadProcessed) ||
                state.status == ProfileStatus.loading) {
              return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [                    // Welcome message for new users
                    if (!_isEditing) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.emoji_people,
                              color: Theme.of(context).colorScheme.primary,
                              size: 40,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _isUserAuthenticated ? '¡Bienvenido de vuelta!' : '¡Bienvenido a Ayni!',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isUserAuthenticated 
                                  ? 'Completa la configuración de tu perfil con algunos datos adicionales.'
                                  : 'Para comenzar, necesitamos algunos datos básicos para crear tu perfil.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],

                    // Profile Picture Section
                    Center(
                      child: GestureDetector(
                        onTap: _isEditing ? _pickAndUploadImage : null,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: AppColors.lightGray,
                              backgroundImage: state.currentProfile?.imageUrl != null
                                  ? NetworkImage(state.currentProfile!.imageUrl!)
                                  : null,
                              child: state.currentProfile?.imageUrl == null
                                  ? const Icon(Icons.person, size: 60, color: AppColors.textSecondary)
                                  : null,
                            ),
                            if (_isEditing)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryGreen,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: AppColors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),                    // Basic Information
                    _buildSectionTitle('Información Básica'),
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: _usernameController,
                      label: 'Nombre de usuario',
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El nombre de usuario es requerido';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _phoneController,
                      label: 'Teléfono',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 40),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state.status == ProfileStatus.creating || 
                                 state.status == ProfileStatus.updating
                            ? null
                            : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: state.status == ProfileStatus.creating || 
                               state.status == ProfileStatus.updating                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _isEditing ? 'Actualizar Perfil' : 'Crear Perfil',                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),      ),
    );
  }
}
