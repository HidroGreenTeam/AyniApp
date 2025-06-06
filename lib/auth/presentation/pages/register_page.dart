import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import 'login_page.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc() : super(RegisterState.initial()) {
    on<NameChanged>(_onNameChanged);
    on<EmailChanged>(_onEmailChanged);
    on<PasswordChanged>(_onPasswordChanged);
    on<ConfirmPasswordChanged>(_onConfirmPasswordChanged);
    on<RegisterSubmitted>(_onRegisterSubmitted);
  }

  void _onNameChanged(NameChanged event, Emitter<RegisterState> emit) {
    final name = event.name;
    emit(state.copyWith(name: name, isNameValid: name.isNotEmpty));
  }

  void _onEmailChanged(EmailChanged event, Emitter<RegisterState> emit) {
    final email = event.email;
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    emit(state.copyWith(email: email, isEmailValid: emailRegex.hasMatch(email)));
  }

  void _onPasswordChanged(PasswordChanged event, Emitter<RegisterState> emit) {
    final password = event.password;
    emit(state.copyWith(
      password: password, 
      isPasswordValid: password.length >= 6,
      isFormValid: _validateForm(
        state.isNameValid, 
        state.isEmailValid, 
        password.length >= 6, 
        state.confirmPassword == password && password.isNotEmpty
      ),
    ));
  }

  void _onConfirmPasswordChanged(ConfirmPasswordChanged event, Emitter<RegisterState> emit) {
    final confirmPassword = event.confirmPassword;
    emit(state.copyWith(
      confirmPassword: confirmPassword, 
      isConfirmPasswordValid: confirmPassword == state.password && confirmPassword.isNotEmpty,
      isFormValid: _validateForm(
        state.isNameValid, 
        state.isEmailValid, 
        state.isPasswordValid, 
        confirmPassword == state.password && confirmPassword.isNotEmpty
      ),
    ));
  }

  void _onRegisterSubmitted(RegisterSubmitted event, Emitter<RegisterState> emit) async {
    if (state.isFormValid) {
      emit(state.copyWith(status: RegisterStatus.loading));
        try {
        // TODO: Implement actual registration API call
        // Create a sign-up request (will be used when API is implemented)
        // final signUpRequest = SignUpRequest(
        //   fullName: state.name,
        //   email: state.email,
        //   password: state.password,
        //   roles: ["ROLE_USER"], // Default role
        // );

        // Here you would typically call the repository to perform the API call
        // For now we'll simulate a successful registration
        await Future.delayed(const Duration(seconds: 2));
        
        emit(state.copyWith(status: RegisterStatus.success));
      } catch (e) {
        emit(state.copyWith(
          status: RegisterStatus.failure,
          errorMessage: 'Registration failed: ${e.toString()}',
        ));
      }
    }
  }

  bool _validateForm(bool isNameValid, bool isEmailValid, bool isPasswordValid, bool isConfirmPasswordValid) {
    return isNameValid && isEmailValid && isPasswordValid && isConfirmPasswordValid;
  }
}

// Events
abstract class RegisterEvent {}

class NameChanged extends RegisterEvent {
  final String name;
  NameChanged(this.name);
}

class EmailChanged extends RegisterEvent {
  final String email;
  EmailChanged(this.email);
}

class PasswordChanged extends RegisterEvent {
  final String password;
  PasswordChanged(this.password);
}

class ConfirmPasswordChanged extends RegisterEvent {
  final String confirmPassword;
  ConfirmPasswordChanged(this.confirmPassword);
}

class RegisterSubmitted extends RegisterEvent {
  RegisterSubmitted();
}

// State
enum RegisterStatus { initial, loading, success, failure }

class RegisterState {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;
  final bool isNameValid;
  final bool isEmailValid;
  final bool isPasswordValid;
  final bool isConfirmPasswordValid;
  final bool isFormValid;
  final RegisterStatus status;
  final String? errorMessage;

  RegisterState({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.isNameValid,
    required this.isEmailValid,
    required this.isPasswordValid,
    required this.isConfirmPasswordValid,
    required this.isFormValid,
    required this.status,
    this.errorMessage,
  });

  factory RegisterState.initial() {
    return RegisterState(
      name: '',
      email: '',
      password: '',
      confirmPassword: '',
      isNameValid: false,
      isEmailValid: false,
      isPasswordValid: false,
      isConfirmPasswordValid: false,
      isFormValid: false,
      status: RegisterStatus.initial,
    );
  }

  RegisterState copyWith({
    String? name,
    String? email,
    String? password,
    String? confirmPassword,
    bool? isNameValid,
    bool? isEmailValid,
    bool? isPasswordValid,
    bool? isConfirmPasswordValid,
    bool? isFormValid,
    RegisterStatus? status,
    String? errorMessage,
  }) {
    return RegisterState(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isNameValid: isNameValid ?? this.isNameValid,
      isEmailValid: isEmailValid ?? this.isEmailValid,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
      isConfirmPasswordValid: isConfirmPasswordValid ?? this.isConfirmPasswordValid,
      isFormValid: isFormValid ?? this.isFormValid,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegisterBloc(),
      child: const RegisterView(),
    );
  }
}

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterBloc, RegisterState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == RegisterStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(            const SnackBar(
              content: Text('Registration successful! Please log in.'),
              backgroundColor: AppColors.success,
            ),
          );
          // Navigate to the login page after successful registration
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        }
        if (state.status == RegisterStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(            SnackBar(
              content: Text(state.errorMessage ?? 'Registration failed'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: BlocBuilder<RegisterBloc, RegisterState>(
              builder: (context, state) {
                return Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      // Title and profile icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Join Ayni Today',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryGreen,
                              shape: BoxShape.circle,
                            ),                            child: const Icon(
                              Icons.person_outline,
                              color: AppColors.white,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Subtitle
                      const Text(
                        'Create Your Blooming Account',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // Full Name input
                      const Text(
                        'Full Name',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _NameInput(),
                      const SizedBox(height: 24),
                      
                      // Email input
                      const Text(
                        'Email',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _EmailInput(),
                      const SizedBox(height: 24),
                      
                      // Password input
                      const Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _PasswordInput(),
                      const SizedBox(height: 24),
                      
                      // Confirm Password input
                      const Text(
                        'Confirm Password',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _ConfirmPasswordInput(),
                      const SizedBox(height: 32),
                      
                      // Register Button
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: state.isFormValid && state.status != RegisterStatus.loading
                              ? () {
                                  context.read<RegisterBloc>().add(RegisterSubmitted());
                                }
                              : null,
                          style: ElevatedButton.styleFrom(                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: AppColors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: state.status == RegisterStatus.loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,                                  child: CircularProgressIndicator(
                                    color: AppColors.white,
                                    strokeWidth: 2.0,
                                  ),
                                )
                              : const Text(
                                  'Sign up',
                                  style: TextStyle(fontSize: 18),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Already have an account
                      Center(
                        child: TextButton(
                          onPressed: () {
                            // Navigate to login form page for existing users
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const LoginPage(),
                              ),
                            );
                          },
                          child: RichText(                            text: const TextSpan(
                              text: 'Already have an account? ',
                              style: TextStyle(color: AppColors.textSecondary),
                              children: [
                                TextSpan(
                                  text: 'Log in',
                                  style: TextStyle(color: AppColors.primaryGreen),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _NameInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      buildWhen: (previous, current) => previous.name != current.name,
      builder: (context, state) {
        return TextFormField(
          onChanged: (name) => context.read<RegisterBloc>().add(NameChanged(name)),          decoration: InputDecoration(
            hintText: 'Enter your full name',
            prefixIcon: const Icon(Icons.person, color: AppColors.grey500),
            filled: true,
            fillColor: AppColors.grey100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            errorText: !state.isNameValid && state.name.isNotEmpty
                ? 'Please enter a valid name'
                : null,
          ),
        );
      },
    );
  }
}

class _EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return TextFormField(
          onChanged: (email) => context.read<RegisterBloc>().add(EmailChanged(email)),
          keyboardType: TextInputType.emailAddress,          decoration: InputDecoration(
            hintText: 'Enter your email',
            prefixIcon: const Icon(Icons.email, color: AppColors.grey500),
            filled: true,
            fillColor: AppColors.grey100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            errorText: !state.isEmailValid && state.email.isNotEmpty
                ? 'Please enter a valid email'
                : null,
          ),
        );
      },
    );
  }
}

class _PasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return TextFormField(
          onChanged: (password) => context.read<RegisterBloc>().add(PasswordChanged(password)),
          obscureText: true,
          decoration: InputDecoration(            hintText: 'Enter your password',
            prefixIcon: const Icon(Icons.lock, color: AppColors.grey500),
            suffixIcon: const Icon(Icons.visibility_off, color: AppColors.grey500),
            filled: true,
            fillColor: AppColors.grey100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            errorText: !state.isPasswordValid && state.password.isNotEmpty
                ? 'Password must be at least 6 characters'
                : null,
          ),
        );
      },
    );
  }
}

class _ConfirmPasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      buildWhen: (previous, current) => 
          previous.confirmPassword != current.confirmPassword || 
          previous.password != current.password,
      builder: (context, state) {
        return TextFormField(
          onChanged: (confirmPassword) => 
              context.read<RegisterBloc>().add(ConfirmPasswordChanged(confirmPassword)),
          obscureText: true,
          decoration: InputDecoration(            hintText: 'Confirm your password',
            prefixIcon: const Icon(Icons.lock, color: AppColors.grey500),
            suffixIcon: const Icon(Icons.visibility_off, color: AppColors.grey500),
            filled: true,
            fillColor: AppColors.grey100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            errorText: !state.isConfirmPasswordValid && state.confirmPassword.isNotEmpty
                ? 'Passwords do not match'
                : null,
          ),
        );
      },
    );
  }
}
