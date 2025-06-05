import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/constants/walkthrough_config.dart';
import '../blocs/walkthrough_bloc.dart';
import 'auth_method_selection_page.dart';

class WalkthroughPage extends StatelessWidget {
  const WalkthroughPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<WalkthroughBloc>()..add(const WalkthroughStarted()),
      child: const WalkthroughView(),
    );
  }
}

class WalkthroughView extends StatefulWidget {
  const WalkthroughView({super.key});

  @override
  State<WalkthroughView> createState() => _WalkthroughViewState();
}

class _WalkthroughViewState extends State<WalkthroughView>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationControllers = List.generate(
      WalkthroughData.items.length,
      (index) => AnimationController(
        duration: WalkthroughConfig.iconAnimationDuration,
        vsync: this,
      ),
    );

    _fadeAnimations = _animationControllers
        .map((controller) => Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: controller,
              curve: Curves.easeInOut,
            )))
        .toList();

    _slideAnimations = _animationControllers
        .map((controller) => Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: controller,
              curve: Curves.easeOutCubic,
            )))
        .toList();
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _animateCurrentPage(int index) {
    if (index < _animationControllers.length) {
      _animationControllers[index].forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WalkthroughBloc, WalkthroughState>(
      listenWhen: (previous, current) => 
          previous.status != current.status ||
          previous.currentPageIndex != current.currentPageIndex,      listener: (context, state) {        if (state.status == WalkthroughStatus.completed) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const AuthMethodSelectionPage(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: WalkthroughConfig.pageAnimationDuration,
            ),
          );
        }        if (_pageController.hasClients && 
            state.currentPageIndex != _pageController.page?.round()) {
          _pageController.animateToPage(
            state.currentPageIndex,
            duration: WalkthroughConfig.pageAnimationDuration,
            curve: Curves.easeInOut,
          );
        }

        _animateCurrentPage(state.currentPageIndex);
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: WalkthroughConfig.backgroundGradient,
          ),
          child: SafeArea(
            child: BlocBuilder<WalkthroughBloc, WalkthroughState>(
              builder: (context, state) {
                if (state.status == WalkthroughStatus.initial ||
                    state.status == WalkthroughStatus.loading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: WalkthroughConfig.primaryGreen,
                    ),
                  );
                }

                return Column(
                  children: [
                    // Skip button
                    _buildSkipButton(context, state),
                    
                    // Main content
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          context.read<WalkthroughBloc>().add(
                                WalkthroughPageChanged(index),
                              );
                        },
                        itemCount: state.items.length,
                        itemBuilder: (context, index) {
                          return _buildPage(
                            context,
                            state.items[index],
                            index,
                          );
                        },
                      ),
                    ),
                    
                    // Bottom section with indicators and buttons
                    _buildBottomSection(context, state),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkipButton(BuildContext context, WalkthroughState state) {
    if (state.isLastPage) return const SizedBox(height: 60);
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Align(
        alignment: Alignment.topRight,
        child: TextButton(
          onPressed: () {
            context.read<WalkthroughBloc>().add(const WalkthroughSkipPressed());
          },
          style: TextButton.styleFrom(
            foregroundColor: WalkthroughConfig.textColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text(
            'Saltar',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context, WalkthroughItem item, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: WalkthroughConfig.horizontalPadding,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with animation
          FadeTransition(
            opacity: _fadeAnimations[index],
            child: SlideTransition(
              position: _slideAnimations[index],
              child: _buildAnimatedIcon(item.icon, item.animationDelay),
            ),
          ),
          
          const SizedBox(height: 48),
          
          // Title
          FadeTransition(
            opacity: _fadeAnimations[index],
            child: Text(
              item.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: WalkthroughConfig.titleFontSize,
                fontWeight: WalkthroughConfig.titleFontWeight,
                color: WalkthroughConfig.textColor,
                height: 1.2,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Subtitle
          FadeTransition(
            opacity: _fadeAnimations[index],
            child: Text(
              item.subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: WalkthroughConfig.subtitleFontSize,
                fontWeight: WalkthroughConfig.subtitleFontWeight,
                color: WalkthroughConfig.textColor.withValues(alpha: 0.7),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedIcon(IconData iconData, Duration delay) {
    return TweenAnimationBuilder<double>(
      duration: WalkthroughConfig.iconAnimationDuration,
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: WalkthroughConfig.iconSize,
            height: WalkthroughConfig.iconSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: WalkthroughConfig.cardShadows,
            ),
            child: Icon(
              iconData,
              size: WalkthroughConfig.iconSize * 0.5,
              color: WalkthroughConfig.primaryGreen,
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomSection(BuildContext context, WalkthroughState state) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          // Page indicator
          SmoothPageIndicator(
            controller: _pageController,
            count: state.items.length,
            effect: ExpandingDotsEffect(
              activeDotColor: WalkthroughConfig.indicatorActiveColor,
              dotColor: WalkthroughConfig.indicatorInactiveColor,
              dotHeight: 8,
              dotWidth: 8,
              expansionFactor: 3,
              spacing: 8,
            ),
          ),
          
          const SizedBox(height: 48),
          
          // Navigation buttons
          Row(
            children: [
              // Previous button
              if (!state.isFirstPage)
                Expanded(
                  child: _buildSecondaryButton(
                    context,
                    'Anterior',
                    () {
                      context.read<WalkthroughBloc>().add(
                            const WalkthroughPreviousPressed(),
                          );
                    },
                  ),
                ),
              
              if (!state.isFirstPage) const SizedBox(width: 16),
              
              // Next/Start button
              Expanded(
                flex: state.isFirstPage ? 1 : 1,
                child: _buildPrimaryButton(
                  context,
                  state.isLastPage ? 'Comenzar' : 'Siguiente',
                  () {
                    context.read<WalkthroughBloc>().add(
                          const WalkthroughNextPressed(),
                        );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(
    BuildContext context,
    String text,
    VoidCallback onPressed,
  ) {
    return Container(
      height: WalkthroughConfig.buttonHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: WalkthroughConfig.buttonShadows,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: WalkthroughConfig.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: WalkthroughConfig.buttonFontWeight,
          ),
        ),
      ),
    );
  }
  Widget _buildSecondaryButton(
    BuildContext context,
    String text,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      height: WalkthroughConfig.buttonHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: WalkthroughConfig.textColor,
          side: BorderSide(
            color: WalkthroughConfig.textColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: WalkthroughConfig.buttonFontWeight,
          ),
        ),
      ),
    );
  }
}
