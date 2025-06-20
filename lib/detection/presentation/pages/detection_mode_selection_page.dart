import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/connectivity_service.dart';
import '../../services/hybrid_detection_service.dart';
import '../../../camera/presentation/pages/camera_page.dart';

class DetectionModeSelectionPage extends StatefulWidget {
  const DetectionModeSelectionPage({super.key});

  @override
  State<DetectionModeSelectionPage> createState() => _DetectionModeSelectionPageState();
}

class _DetectionModeSelectionPageState extends State<DetectionModeSelectionPage> {
  final ConnectivityService _connectivityService = ConnectivityService();
  final HybridDetectionService _detectionService = HybridDetectionService();
  
  bool _isLoading = true;
  bool _hasInternetConnection = false;
  bool _localModelAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkAvailability();
  }

  Future<void> _checkAvailability() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final hasInternet = await _connectivityService.hasInternetConnection();
      final localAvailable = await _detectionService.isLocalDetectionAvailable();

      setState(() {
        _hasInternetConnection = hasInternet;
        _localModelAvailable = localAvailable;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Modo de Detección',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Elige cómo quieres detectar enfermedades',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Selecciona el modo que prefieras para analizar tus plantas',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Online Detection Option
                  if (_hasInternetConnection) ...[
                    _buildDetectionOption(
                      title: 'Detección Online',
                      subtitle: 'Modelo avanzado con mayor precisión',
                      icon: Icons.cloud,
                      color: AppColors.primaryGreen,
                      onTap: () => _navigateToDetection(true),
                      features: [
                        'Mayor precisión en la detección',
                        'Modelo actualizado constantemente',
                        'Análisis más detallado',
                        'Requiere conexión a internet',
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Local Detection Option
                  if (_localModelAvailable) ...[
                    _buildDetectionOption(
                      title: 'Detección Local',
                      subtitle: 'Modelo pequeño en el dispositivo',
                      icon: Icons.phone_android,
                      color: AppColors.warning,
                      onTap: () => _navigateToDetection(false),
                      features: [
                        'Funciona sin conexión a internet',
                        'Análisis rápido',
                        'Privacidad total',
                        'Modelo más pequeño (menor precisión)',
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Auto Detection Option
                  if (_hasInternetConnection && _localModelAvailable) ...[
                    _buildDetectionOption(
                      title: 'Detección Automática',
                      subtitle: 'Elige automáticamente el mejor modo',
                      icon: Icons.auto_awesome,
                      color: AppColors.info,
                      onTap: () => _navigateToDetection(null),
                      features: [
                        'Usa online cuando hay conexión',
                        'Cambia a local automáticamente',
                        'Mejor experiencia de usuario',
                        'Optimiza precisión y velocidad',
                      ],
                    ),
                  ],
                  
                  const Spacer(),
                  
                  // Status indicators
                  _buildStatusIndicators(),
                ],
              ),
            ),
    );
  }

  Widget _buildDetectionOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required List<String> features,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.grey400,
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: color,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicators() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estado del Sistema',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildStatusItem(
            'Conexión a Internet',
            _hasInternetConnection ? 'Disponible' : 'No disponible',
            _hasInternetConnection ? Icons.wifi : Icons.wifi_off,
            _hasInternetConnection ? AppColors.success : AppColors.error,
          ),
          const SizedBox(height: 8),
          _buildStatusItem(
            'Modelo Local',
            _localModelAvailable ? 'Disponible' : 'No disponible',
            _localModelAvailable ? Icons.check_circle : Icons.error,
            _localModelAvailable ? AppColors.success : AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, String status, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          status,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  void _navigateToDetection(bool? useOnline) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CameraPage(detectionMode: useOnline),
      ),
    );
  }
} 