import 'package:flutter/material.dart';

class ProcessingWidget extends StatelessWidget {
  final Animation<double> pulseAnimation;
  final bool? detectionMode; // true = online, false = local, null = auto

  const ProcessingWidget({
    super.key,
    required this.pulseAnimation,
    this.detectionMode,
  });

  String _getProcessingText() {
    switch (detectionMode) {
      case true:
        return 'Analizando con Microservicio Azure...';
      case false:
        return 'Analizando con TensorFlow Lite...';
      default:
        return 'Analizando Imagen...';
    }
  }

  String _getProcessingSubtext() {
    switch (detectionMode) {
      case true:
        return 'Nuestro modelo de IA avanzado está examinando tu planta para detectar enfermedades...';
      case false:
        return 'Nuestro modelo local está analizando tu planta para detectar enfermedades...';
      default:
        return 'Nuestra IA está examinando tu planta para detectar enfermedades...';
    }
  }

  IconData _getProcessingIcon() {
    switch (detectionMode) {
      case true:
        return Icons.cloud_queue;
      case false:
        return Icons.phone_android;
      default:
        return Icons.psychology;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: pulseAnimation.value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getProcessingIcon(),
                  size: 40,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            _getProcessingText(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getProcessingSubtext(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.7),
            ),
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
            backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          ),
        ],
      ),
    );
  }
} 