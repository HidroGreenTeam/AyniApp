import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/service_locator.dart';
import '../blocs/auth_bloc.dart';
import 'home_page.dart';

class LoginFormPage extends StatelessWidget {
  const LoginFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<AuthBloc>(),
      child: const LoginFormView(),
    );
  }
}

class LoginFormView extends StatefulWidget {
  const LoginFormView({super.key});

  @override
  State<LoginFormView> createState() => _LoginFormViewState();
}

class _LoginFormViewState extends State<LoginFormView>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));
  }

  void _startAnimations() {
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const HomePage(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 500),
            ),
            (route) => false,
          );
        }

        if (state.status == AuthStatus.failure) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Error al iniciar sesión'),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF00C851)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Iniciar Sesión',
            style: TextStyle(
              color: Color(0xFF00C851),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildWelcomeText(),
                const SizedBox(height: 40),
                _buildLoginForm(),
                const SizedBox(height: 32),
                _buildLoginButton(),
                const SizedBox(height: 24),
                _buildForgotPassword(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '¡Bienvenido de vuelta!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E2E2E),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Inicia sesión para continuar cuidando tus plantas',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        _buildEmailInput(),
        const SizedBox(height: 20),
        _buildPasswordInput(),
      ],
    );
  }

  Widget _buildEmailInput() {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Correo electrónico',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E2E2E),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              key: const Key('loginForm_emailInput_textField'),
              onChanged: (email) =>
                  context.read<AuthBloc>().add(AuthEmailChanged(email)),
              decoration: InputDecoration(
                hintText: 'ejemplo@correo.com',
                prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF00C851)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF00C851), width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.red.shade400),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.red.shade400, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            if (state.email.displayError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  state.email.displayError!,
                  style: TextStyle(
                    color: Colors.red.shade600,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildPasswordInput() {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contraseña',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E2E2E),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              key: const Key('loginForm_passwordInput_textField'),
              onChanged: (password) =>
                  context.read<AuthBloc>().add(AuthPasswordChanged(password)),
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                hintText: 'Tu contraseña',
                prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF00C851)),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey.shade600,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF00C851), width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.red.shade400),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.red.shade400, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) {
                if (state.isFormValid) {
                  context.read<AuthBloc>().add(const AuthLoginSubmitted());
                }
              },
            ),
            if (state.password.displayError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  state.password.displayError!,
                  style: TextStyle(
                    color: Colors.red.shade600,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildLoginButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            key: const Key('loginForm_continue_raisedButton'),
            onPressed: state.isFormValid && state.status != AuthStatus.loading
                ? () => context.read<AuthBloc>().add(const AuthLoginSubmitted())
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C851),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: state.status == AuthStatus.loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Iniciar Sesión',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildForgotPassword() {
    return Center(
      child: TextButton(
        onPressed: () {
          // TODO: Implementar recuperación de contraseña
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Funcionalidad próximamente disponible'),
              backgroundColor: Colors.orange.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
        child: const Text(
          '¿Olvidaste tu contraseña?',
          style: TextStyle(
            color: Color(0xFF00C851),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
