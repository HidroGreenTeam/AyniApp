import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;
import '../../../core/di/service_locator.dart';
import '../blocs/auth_bloc.dart';
import '../viewmodels/walkthrough_viewmodel.dart';
import '../../../shared/presentation/pages/main_app.dart';
import 'walkthrough_page.dart';
import 'auth_method_selection_page.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<AuthBloc>()..add(const AuthCheckStatus()),
      child: const SplashView(),
    );
  }
}

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _loadingController;
  late AnimationController _rotationController;
  
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    // Configurar controladores de animación
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    // Configurar animaciones
    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeIn,
    ));

    _textOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    ));

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    // Iniciar animaciones en secuencia
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    
    await Future.delayed(const Duration(milliseconds: 500));
    _textController.forward();
    
    await Future.delayed(const Duration(milliseconds: 300));
    _loadingController.forward();
      // Iniciar rotación suave continua
    _rotationController.repeat();
      // Timer de seguridad: solo en modo release para evitar problemas en tests
    if (!kDebugMode) {
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted && context.mounted) {
          _handleTimeoutNavigation(context);
        }
      });
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _loadingController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        // Agregar un pequeño delay para mostrar el splash
        if (state.status != AuthStatus.initial && state.status != AuthStatus.loading) {
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted && context.mounted) {
              _navigateBasedOnAuthStatus(context, state.status);
            }
          });
        }
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF00C851), // Verde más brillante arriba
                Color(0xFF007E33), // Verde más oscuro abajo
              ],
            ),
          ),
          child: Stack(
            children: [
              // Efecto de ondas en el fondo
              AnimatedBuilder(
                animation: _rotationController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: WavesPainter(_rotationAnimation.value),
                    size: Size.infinite,
                  );
                },
              ),
              
              // Contenido principal
              SafeArea(
                child: Column(
                  children: [
                    // Espacio superior
                    const Spacer(flex: 2),
                      // Logo animado con diseño personalizado
                    AnimatedBuilder(
                      animation: Listenable.merge([_logoController, _rotationController]),
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _logoScaleAnimation.value,
                          child: Opacity(
                            opacity: _logoOpacityAnimation.value,
                            child: Transform.rotate(
                              angle: _rotationAnimation.value * 0.1, // Rotación muy sutil
                              child: _buildCustomLogo(),
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 20),
                      // Texto "Ayni" animado
                    AnimatedBuilder(
                      animation: _textController,
                      builder: (context, child) {
                        return SlideTransition(
                          position: _textSlideAnimation,
                          child: FadeTransition(
                            opacity: _textOpacityAnimation,
                            child: Text(
                              'Ayni',
                              style: TextStyle(
                                fontSize: 64,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF2E7D32), // Verde más oscuro como en la imagen
                                letterSpacing: 3,
                                shadows: [
                                  Shadow(
                                    offset: const Offset(0, 4),
                                    blurRadius: 12,
                                    color: Colors.black.withValues(alpha: 0.3),
                                  ),
                                  Shadow(
                                    offset: const Offset(0, 2),
                                    blurRadius: 6,
                                    color: Colors.black.withValues(alpha: 0.2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    
                    // Espacio flexible
                    const Spacer(flex: 3),
                      // Indicador de carga en la parte inferior
                    FadeTransition(
                      opacity: _loadingController,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 60),
                        child: AnimatedBuilder(
                          animation: _rotationController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 1.0 + (0.1 * (1.0 + (_rotationAnimation.value * 2 - 1).abs())), // Efecto de pulsación
                              child: SizedBox(
                                width: 32,
                                height: 32,
                                child: CircularProgressIndicator(
                                  value: null, // Animación continua
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                  strokeWidth: 3,
                                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _navigateBasedOnAuthStatus(BuildContext context, AuthStatus authStatus) {
    if (authStatus == AuthStatus.authenticated) {
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const MainApp(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    } else if (authStatus == AuthStatus.unauthenticated || authStatus == AuthStatus.failure) {
      _navigateToUnauthenticatedFlow(context);
    }
  }

  void _navigateToUnauthenticatedFlow(BuildContext context) {
    // Check if walkthrough has been completed
    final walkthroughViewModel = serviceLocator<WalkthroughViewModel>();
    final isWalkthroughCompleted = walkthroughViewModel.isWalkthroughCompleted();
    
    if (isWalkthroughCompleted) {
      // Go directly to AuthMethodSelectionPage instead of LoginPage
      // This gives users the choice between login and register
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const AuthMethodSelectionPage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    } else {
      // Show walkthrough first
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const WalkthroughPage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    }
  }

  void _handleTimeoutNavigation(BuildContext context) {
    // Fallback navigation if auth check doesn't complete in time
    _navigateToUnauthenticatedFlow(context);
  }

  Widget _buildCustomLogo() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Contenedor principal del logo
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.15),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
        ),
        
        // Logo principal con hoja
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Hoja principal
              Positioned(
                left: 25,
                top: 30,
                child: Transform.rotate(
                  angle: -0.3,
                  child: Container(
                    width: 35,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.green.shade600,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: CustomPaint(
                      painter: LeafVeinsPainter(),
                    ),
                  ),
                ),
              ),
              
              // Lupa/círculo de búsqueda
              Positioned(
                right: 20,
                bottom: 25,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.shade700,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.search,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              
              // Pequeños puntos decorativos (representando conectividad/WiFi)
              Positioned(
                top: 15,
                right: 30,
                child: _buildConnectivityDots(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConnectivityDots() {
    return Column(
      children: [
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green.shade600,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: 3,
          height: 3,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green.shade600,
          ),
        ),
      ],
    );
  }
}

// Custom painter para dibujar ondas animadas en el fondo
class WavesPainter extends CustomPainter {
  final double animationValue;

  WavesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withValues(alpha: 0.1);

    final path = Path();
    final waveHeight = 20.0;
    final waveLength = size.width / 2;
    final offset = animationValue * waveLength;

    // Primera onda
    path.moveTo(-waveLength + offset, size.height * 0.3);
    for (double x = -waveLength + offset; x <= size.width + waveLength; x += waveLength / 50) {
      final y = size.height * 0.3 + 
          waveHeight * (1 + math.sin(x / waveLength * 2 * math.pi)) / 2;
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Segunda onda (más sutil)
    final paint2 = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withValues(alpha: 0.05);

    final path2 = Path();
    path2.moveTo(-waveLength - offset, size.height * 0.7);
    for (double x = -waveLength - offset; x <= size.width + waveLength; x += waveLength / 50) {
      final y = size.height * 0.7 + 
          waveHeight * 0.5 * (1 + math.sin(x / waveLength * 2 * math.pi + math.pi)) / 2;
      path2.lineTo(x, y);
    }
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(WavesPainter oldDelegate) => 
      oldDelegate.animationValue != animationValue;
}

// Custom painter para dibujar las venas de la hoja
class LeafVeinsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.shade800
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    // Vena central
    path.moveTo(size.width / 2, size.height * 0.9);
    path.lineTo(size.width / 2, size.height * 0.1);
    
    // Venas laterales
    path.moveTo(size.width / 2, size.height * 0.3);
    path.lineTo(size.width * 0.2, size.height * 0.5);
    
    path.moveTo(size.width / 2, size.height * 0.3);
    path.lineTo(size.width * 0.8, size.height * 0.5);
    
    path.moveTo(size.width / 2, size.height * 0.6);
    path.lineTo(size.width * 0.3, size.height * 0.8);
    
    path.moveTo(size.width / 2, size.height * 0.6);
    path.lineTo(size.width * 0.7, size.height * 0.8);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
