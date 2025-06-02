import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import '../../../core/di/service_locator.dart';
import '../blocs/auth_bloc.dart';
import 'home_page.dart';

// Input validation para confirmación de contraseña
class PasswordConfirmationInput extends FormzInput<String, String> {
  final String password;

  const PasswordConfirmationInput.pure([this.password = '']) : super.pure('');
  const PasswordConfirmationInput.dirty({required this.password, String value = ''}) : super.dirty(value);

  @override
  String? validator(String value) {
    if (value.isEmpty) return 'Confirma tu contraseña';
    if (value != password) return 'Las contraseñas no coinciden';
    return null;
  }
}

// Input validation para nombre
class NameInput extends FormzInput<String, String> {
  const NameInput.pure() : super.pure('');
  const NameInput.dirty([super.value = '']) : super.dirty();

  @override
  String? validator(String value) {
    if (value.isEmpty) return 'Ingresa tu nombre';
    if (value.trim().length < 2) return 'El nombre debe tener al menos 2 caracteres';
    return null;
  }
}

class RegisterFormPage extends StatelessWidget {
  const RegisterFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<AuthBloc>(),
      child: const RegisterFormView(),
    );
  }
}

class RegisterFormView extends StatefulWidget {
  const RegisterFormView({super.key});

  @override
  State<RegisterFormView> createState() => _RegisterFormViewState();
}

class _RegisterFormViewState extends State<RegisterFormView>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  bool _obscurePassword = true;
  bool _obscurePasswordConfirmation = true;
  bool _acceptTerms = false;

  // Form inputs state
  final NameInput _name = const NameInput.pure();
  final EmailInput _email = const EmailInput.pure();
  final PasswordInput _password = const PasswordInput.pure();
  PasswordConfirmationInput _passwordConfirmation = const PasswordConfirmationInput.pure();

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

  bool get _isFormValid {
    return _name.isValid &&
           _email.isValid &&
           _password.isValid &&
           _passwordConfirmation.isValid &&
           _acceptTerms;
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
              content: Text(state.errorMessage ?? 'Error al crear la cuenta'),
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
            'Crear Cuenta',
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
                _buildRegisterForm(),
                const SizedBox(height: 24),
                _buildTermsCheckbox(),
                const SizedBox(height: 32),
                _buildRegisterButton(),
                const SizedBox(height: 24),
                _buildLoginLink(),
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
          '¡Únete a Ayni!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E2E2E),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Crea tu cuenta y comienza a cuidar tus plantas como un experto',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      children: [
        _buildNameInput(),
        const SizedBox(height: 20),
        _buildEmailInput(),
        const SizedBox(height: 20),
        _buildPasswordInput(),
        const SizedBox(height: 20),
        _buildPasswordConfirmationInput(),
      ],
    );
  }

  Widget _buildNameInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nombre completo',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E2E2E),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          onChanged: (value) {
            setState(() {
              // Update name state here if needed
            });
          },
          decoration: InputDecoration(
            hintText: 'Tu nombre completo',
            prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF00C851)),
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
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
        ),
      ],
    );
  }

  Widget _buildEmailInput() {
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
          onChanged: (value) {
            setState(() {
              // Update email state here if needed
            });
          },
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
      ],
    );
  }

  Widget _buildPasswordInput() {
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
          onChanged: (value) {
            setState(() {
              _passwordConfirmation = PasswordConfirmationInput.dirty(
                password: value,
                value: _passwordConfirmation.value,
              );
            });
          },
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: 'Mínimo 6 caracteres',
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
          textInputAction: TextInputAction.next,
        ),
      ],
    );
  }

  Widget _buildPasswordConfirmationInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Confirmar contraseña',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E2E2E),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          onChanged: (value) {
            setState(() {
              _passwordConfirmation = PasswordConfirmationInput.dirty(
                password: _password.value,
                value: value,
              );
            });
          },
          obscureText: _obscurePasswordConfirmation,
          decoration: InputDecoration(
            hintText: 'Confirma tu contraseña',
            prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF00C851)),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePasswordConfirmation ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey.shade600,
              ),
              onPressed: () {
                setState(() {
                  _obscurePasswordConfirmation = !_obscurePasswordConfirmation;
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
        ),
        if (_passwordConfirmation.displayError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _passwordConfirmation.displayError!,
              style: TextStyle(
                color: Colors.red.shade600,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _acceptTerms,
          onChanged: (value) {
            setState(() {
              _acceptTerms = value ?? false;
            });
          },
          activeColor: const Color(0xFF00C851),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _acceptTerms = !_acceptTerms;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                  children: [
                    const TextSpan(text: 'Acepto los '),
                    TextSpan(
                      text: 'Términos y Condiciones',
                      style: TextStyle(
                        color: const Color(0xFF00C851),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const TextSpan(text: ' y la '),
                    TextSpan(
                      text: 'Política de Privacidad',
                      style: TextStyle(
                        color: const Color(0xFF00C851),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _acceptTerms && state.status != AuthStatus.loading
                ? () {
                    // TODO: Implementar registro
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Funcionalidad de registro próximamente disponible'),
                        backgroundColor: Colors.orange.shade700,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
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
                    'Crear Cuenta',
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

  Widget _buildLoginLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '¿Ya tienes cuenta? ',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Inicia Sesión',
              style: TextStyle(
                color: Color(0xFF00C851),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
