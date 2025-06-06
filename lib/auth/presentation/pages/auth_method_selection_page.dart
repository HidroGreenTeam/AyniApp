import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'login_page.dart';
import 'register_page.dart';

class AuthMethodSelectionPage extends StatelessWidget {
  const AuthMethodSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,            colors: [
              Color(0xFF00C851), // Verde brillante
              Color(0xFF007E33), // Verde oscuro
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const Spacer(flex: 2),
                
                // Logo y título
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white,                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.2),
                        blurRadius: 15,
                        spreadRadius: 2,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),                  child: const Icon(
                    Icons.eco,
                    color: AppColors.primaryGreen,
                    size: 60,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                const Text(
                  'Ayni',                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                    letterSpacing: 2,
                  ),
                ),
                
                const SizedBox(height: 16),
                  Text(
                  'Conectando agricultores\ncon tecnología sostenible',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.white.withValues(alpha: 0.7),
                    height: 1.4,
                  ),
                ),
                
                const Spacer(flex: 3),
                
                // Botones de acción
                Column(
                  children: [
                    // Botón de Registro
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const RegisterPage(),
                            ),
                          );
                        },                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.white,
                          foregroundColor: AppColors.primaryGreen,
                          elevation: 4,
                          shadowColor: AppColors.black.withValues(alpha: 0.26),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: const Text(
                          'Crear cuenta',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Botón de Login
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        },                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.white,
                          side: BorderSide(
                            color: AppColors.white,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: const Text(
                          'Iniciar sesión',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                  // Enlaces de términos y políticas
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Política de Privacidad',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.white.withValues(alpha: 0.7),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Términos de Servicio',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.white.withValues(alpha: 0.7),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
