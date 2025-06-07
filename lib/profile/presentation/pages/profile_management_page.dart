import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_theme.dart';
import '../../data/models/profile_models.dart';
import '../blocs/profile_bloc.dart';

class ProfileManagementPage extends StatelessWidget {
  const ProfileManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<ProfileBloc>()..add(const ProfileLoadCurrent()),
      child: const ProfileManagementView(),
    );
  }
}

class ProfileManagementView extends StatefulWidget {
  const ProfileManagementView({super.key});

  @override
  State<ProfileManagementView> createState() => _ProfileManagementViewState();
}

class _ProfileManagementViewState extends State<ProfileManagementView> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isEditing = false;
  String? _profileId;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _populateForm(ProfileModel profile) {
    _usernameController.text = profile.username;
    _emailController.text = profile.email;
    _phoneController.text = profile.phoneNumber;
    _profileId = profile.id;
  }

  void _clearForm() {
    _usernameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _profileId = null;
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;

    final request = _profileId == null
        ? CreateProfileRequest(
            username: _usernameController.text.trim(),
            email: _emailController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
            password: 'temp_password', // TODO: Handle password properly
          )
        : UpdateProfileRequest(
            username: _usernameController.text.trim(),
            phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          );

    if (_profileId == null) {
      context.read<ProfileBloc>().add(ProfileCreate(request as CreateProfileRequest));
    } else {
      context.read<ProfileBloc>().add(ProfileUpdate(_profileId!, request as UpdateProfileRequest));
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
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
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
        if (state.status == ProfileStatus.loaded && state.currentProfile != null) {
          _populateForm(state.currentProfile as ProfileModel);
          setState(() {
            _isEditing = true;
          });
        } else if (state.status == ProfileStatus.created || state.status == ProfileStatus.updated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.status == ProfileStatus.created 
                  ? 'Perfil creado exitosamente' 
                  : 'Perfil actualizado exitosamente'),
              backgroundColor: AppColors.success,
            ),
          );
          setState(() {
            _isEditing = true;
          });
        } else if (state.status == ProfileStatus.deleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perfil eliminado exitosamente'),
              backgroundColor: AppColors.success,
            ),
          );
          _clearForm();
          setState(() {
            _isEditing = false;
          });
        } else if (state.status == ProfileStatus.uploaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto de perfil actualizada exitosamente'),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state.status == ProfileStatus.error) {
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
            'Gestión de Perfil',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          backgroundColor: AppColors.white,
          elevation: 0,
          actions: [
            if (_isEditing)
              IconButton(
                onPressed: _deleteProfile,
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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

                    const SizedBox(height: 30),

                    // Basic Information
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
                      controller: _emailController,
                      label: 'Correo Electrónico',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!emailRegex.hasMatch(value)) {
                            return 'Ingrese un correo válido';
                          }
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
                               state.status == ProfileStatus.updating
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: AppColors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _isEditing ? 'Actualizar Perfil' : 'Crear Perfil',
                                style: const TextStyle(
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
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
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
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primaryGreen),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryGreen),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        filled: true,
        fillColor: AppColors.lightGray.withValues(alpha: 0.3),
      ),
    );
  }
}
