import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import '../../data/models/auth_models.dart';
import '../viewmodels/login_viewmodel.dart';

// Input validation models
class EmailInput extends FormzInput<String, String> {
  const EmailInput.pure() : super.pure('');
  const EmailInput.dirty([super.value = '']) : super.dirty();
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  @override
  String? validator(String value) {
    return _emailRegex.hasMatch(value) ? null : 'Invalid email format';
  }
}

class PasswordInput extends FormzInput<String, String> {
  const PasswordInput.pure() : super.pure('');
  const PasswordInput.dirty([super.value = '']) : super.dirty();

  @override
  String? validator(String value) {
    if (value.isEmpty) return 'Password cannot be empty';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }
}

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthEmailChanged extends AuthEvent {
  final String email;

  const AuthEmailChanged(this.email);

  @override
  List<Object> get props => [email];
}

class AuthPasswordChanged extends AuthEvent {
  final String password;

  const AuthPasswordChanged(this.password);

  @override
  List<Object> get props => [password];
}

class AuthLoginSubmitted extends AuthEvent {
  const AuthLoginSubmitted();
}

class AuthCheckStatus extends AuthEvent {
  const AuthCheckStatus();
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

// State
enum AuthStatus { initial, loading, authenticated, unauthenticated, failure }

class AuthState extends Equatable {
  final AuthStatus status;
  final EmailInput email;
  final PasswordInput password;
  final UserModel? user;
  final String? errorMessage;
  final bool isFormValid;

  const AuthState({
    required this.status,
    required this.email,
    required this.password,
    this.user,
    this.errorMessage,
    this.isFormValid = false,
  });

  factory AuthState.initial() {
    return const AuthState(
      status: AuthStatus.initial,
      email: EmailInput.pure(),
      password: PasswordInput.pure(),
    );
  }

  AuthState copyWith({
    AuthStatus? status,
    EmailInput? email,
    PasswordInput? password,
    UserModel? user,
    String? errorMessage,
    bool? isFormValid,
  }) {
    return AuthState(
      status: status ?? this.status,
      email: email ?? this.email,
      password: password ?? this.password,
      user: user ?? this.user,
      errorMessage: errorMessage,
      isFormValid: isFormValid ?? this.isFormValid,
    );
  }

  @override
  List<Object?> get props => [status, email, password, user, errorMessage, isFormValid];
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginViewModel _loginViewModel;

  AuthBloc({required LoginViewModel loginViewModel})
      : _loginViewModel = loginViewModel,
        super(AuthState.initial()) {
    on<AuthEmailChanged>(_onEmailChanged);
    on<AuthPasswordChanged>(_onPasswordChanged);
    on<AuthLoginSubmitted>(_onLoginSubmitted);
    on<AuthCheckStatus>(_onCheckStatus);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  void _onEmailChanged(AuthEmailChanged event, Emitter<AuthState> emit) {
    final email = EmailInput.dirty(event.email);
    emit(state.copyWith(
      email: email,
      isFormValid: _validateForm(email, state.password),
      status: AuthStatus.initial,
      errorMessage: null,
    ));
  }

  void _onPasswordChanged(AuthPasswordChanged event, Emitter<AuthState> emit) {
    final password = PasswordInput.dirty(event.password);
    emit(state.copyWith(
      password: password,
      isFormValid: _validateForm(state.email, password),
      status: AuthStatus.initial,
      errorMessage: null,
    ));
  }

  bool _validateForm(EmailInput email, PasswordInput password) {
    return email.isValid && password.isValid;
  }
  Future<void> _onLoginSubmitted(AuthLoginSubmitted event, Emitter<AuthState> emit) async {
    if (!state.isFormValid) return;
    
    emit(state.copyWith(status: AuthStatus.loading));
    
    try {
      final response = await _loginViewModel.signIn(
        state.email.value,
        state.password.value,
      );
      
      if (response.success && response.data != null) {
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: response.data!.user,
        ));
      } else {
        emit(state.copyWith(
          status: AuthStatus.failure,
          errorMessage: response.error ?? 'Authentication failed',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
  Future<void> _onCheckStatus(AuthCheckStatus event, Emitter<AuthState> emit) async {
    final isAuthenticated = _loginViewModel.isAuthenticated();
    
    if (isAuthenticated) {
      final user = _loginViewModel.getCurrentUser();
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      ));
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await _loginViewModel.signOut();
    emit(state.copyWith(
      status: AuthStatus.unauthenticated,
      user: null,
    ));
  }
}
