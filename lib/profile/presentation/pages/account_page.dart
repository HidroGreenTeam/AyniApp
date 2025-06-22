import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_theme.dart';
import '../blocs/account_bloc.dart';
import '../../../auth/presentation/pages/splash_page.dart';
import 'profile_management_page.dart';
import 'profile_search_page.dart';
import 'profile_page.dart';
import 'appearance_settings_page.dart';
import 'payment_methods_page.dart';
import 'billing_page.dart';
import 'language_selection_page.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<AccountBloc>()..add(const AccountLoadUser()),
      child: const AccountView(),
    );
  }
}

class AccountView extends StatelessWidget {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountBloc, AccountState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == AccountStatus.signedOut) {
          // Navigate to splash page after successful logout
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const SplashPage()),
            (route) => false,
          );
        }        if (state.status == AccountStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'An error occurred'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.eco,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Cuenta',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: BlocBuilder<AccountBloc, AccountState>(
          builder: (context, state) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Section
                    _buildProfileSection(context, state),

                    const SizedBox(height: 30),

                    // Upgrade Plan Card
                    _buildUpgradePlanCard(context),                    const SizedBox(height: 30),

                    // Menu Options
                    _buildMenuItem(
                      context,
                      icon: Icons.person_outline,
                      title: 'Gestionar Perfil',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfileManagementPage(),
                          ),
                        );
                      },
                    ),

                    _buildMenuItem(
                      context,
                      icon: Icons.search_outlined,
                      title: 'Buscar Perfiles',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfileSearchPage(),
                          ),
                        );
                      },
                    ),

                    _buildMenuItem(
                      context,
                      icon: Icons.notifications_outlined,
                      title: 'Notificaciones',
                      onTap: () {
                        // TODO: Implement notifications
                      },
                    ),

                    _buildMenuItem(
                      context,
                      icon: Icons.shield_outlined,
                      title: 'Cuenta y Seguridad',
                      onTap: () {
                        // TODO: Implement account security
                      },
                    ),

                    _buildMenuItem(
                      context,
                      icon: Icons.star_outline,
                      title: 'Facturación y Suscripciones',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BillingPage(),
                          ),
                        );
                      },
                    ),

                    _buildMenuItem(
                      context,
                      icon: Icons.credit_card_outlined,
                      title: 'Métodos de Pago',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PaymentMethodsPage(),
                          ),
                        );
                      },
                    ),

                    _buildMenuItem(
                      context,
                      icon: Icons.remove_red_eye_outlined,
                      title: 'Apariencia de la App',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AppearanceSettingsPage(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 30),

                    // Language Button
                    _buildMenuItem(
                      context,
                      icon: Icons.language,
                      title: 'Cambio de Idioma',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LanguageSelectionPage(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // Sign Out Button
                    _buildSignOutMenuItem(context, state),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }  Widget _buildProfileSection(BuildContext context, AccountState state) {
    final user = state.user;
    final email = user?.email ?? 'test1@test1.com';
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ProfilePage(),
          ),
        );
      },
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Icon(
              Icons.person,
              size: 40,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                email,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                'Ver mi perfil',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const Spacer(),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradePlanCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const BillingPage(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.emoji_events,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '¡Mejora tu plan para desbloquear más!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Disfruta de todos los beneficios y explora más posibilidades',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSignOut = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: isSignOut
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).iconTheme.color,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isSignOut
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isSignOut
                    ? Theme.of(context).colorScheme.error.withOpacity(0.7)
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignOutMenuItem(BuildContext context, AccountState state) {
    final isLoading = state.status == AccountStatus.signingOut;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: isLoading ? null : () {
          _showSignOutDialog(context);
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
          child: Row(
            children: [
              if (isLoading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              else
                Icon(
                  Icons.logout,
                  size: 24,
                  color: Theme.of(context).colorScheme.error,
                ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  isLoading ? 'Cerrando sesión...' : 'Cerrar Sesión',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
              if (!isLoading)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Theme.of(context).colorScheme.error.withOpacity(0.7),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<AccountBloc>().add(const AccountSignOutRequested());
              },              child: const Text(
                'Cerrar Sesión',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],        );
      },
    );
  }
}