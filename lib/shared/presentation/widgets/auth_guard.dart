import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/service_locator.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../../auth/presentation/pages/splash_page.dart';

/// AuthGuard widget that ensures only authenticated users can access protected content
/// Redirects unauthenticated users to the splash page for proper authentication flow
class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<AuthBloc>()..add(const AuthCheckStatus()),
      child: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == AuthStatus.unauthenticated || state.status == AuthStatus.failure) {
            // Redirect to splash page for proper authentication flow
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const SplashPage()),
              (route) => false,
            );
          }
        },
        buildWhen: (previous, current) => previous.status != current.status,
        builder: (context, state) {
          switch (state.status) {
            case AuthStatus.initial:
            case AuthStatus.loading:
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF00C851),
                  ),
                ),
              );
            case AuthStatus.authenticated:
              return child;
            case AuthStatus.unauthenticated:
            case AuthStatus.failure:
              // Show loading while redirecting
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF00C851),
                  ),
                ),
              );
          }
        },
      ),
    );
  }
}
