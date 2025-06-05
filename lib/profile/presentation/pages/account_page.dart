import 'package:flutter/material.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(0xFF00C851),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.eco,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Cuenta',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Section
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey[300],
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'test1@test1.com',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Upgrade Plan Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C851),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.emoji_events,
                        color: Color(0xFF00C851),
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

              const SizedBox(height: 30),

              // Menu Options
              _buildMenuItem(
                icon: Icons.notifications_outlined,
                title: 'Notificaciones',
                onTap: () {
                  // TODO: Implement notifications
                },
              ),

              _buildMenuItem(
                icon: Icons.shield_outlined,
                title: 'Cuenta y Seguridad',
                onTap: () {
                  // TODO: Implement account security
                },
              ),

              _buildMenuItem(
                icon: Icons.star_outline,
                title: 'Facturación y Suscripciones',
                onTap: () {
                  // TODO: Implement billing
                },
              ),

              _buildMenuItem(
                icon: Icons.credit_card_outlined,
                title: 'Métodos de Pago',
                onTap: () {
                  // TODO: Implement payment methods
                },
              ),

              _buildMenuItem(
                icon: Icons.link,
                title: 'Cuentas Vinculadas',
                onTap: () {
                  // TODO: Implement linked accounts
                },
              ),

              _buildMenuItem(
                icon: Icons.remove_red_eye_outlined,
                title: 'Apariencia de la App',
                onTap: () {
                  // TODO: Implement app appearance
                },
              ),

              _buildMenuItem(
                icon: Icons.analytics_outlined,
                title: 'Datos y Analíticas',
                onTap: () {
                  // TODO: Implement data analytics
                },
              ),

              const SizedBox(height: 30),

              // Language Button
              _buildMenuItem(
                icon: Icons.language,
                title: 'Cambio de Idioma',
                onTap: () {
                  // TODO: Implement language change
                },
              ),

              const SizedBox(height: 20),

              // Sign Out Button
              _buildMenuItem(
                icon: Icons.logout,
                title: 'Cerrar Sesión',
                onTap: () {
                  // TODO: Implement sign out
                },
                isSignOut: true,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
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
                color: isSignOut ? Colors.red : Colors.grey[600],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isSignOut ? Colors.red : Colors.black,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}