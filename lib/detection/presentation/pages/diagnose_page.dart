import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ayni/core/di/service_locator.dart';
import 'package:ayni/auth/domain/usecases/get_current_user_use_case.dart';
import 'package:ayni/camera/presentation/pages/camera_page.dart';
import 'package:ayni/detection/services/hybrid_detection_service.dart';
import 'package:ayni/detection/data/models/detection_api_models.dart';
import '../../../core/theme/app_theme.dart';

class DiagnosePage extends StatefulWidget {
  final int? cropId;
  final String? cropName;

  const DiagnosePage({super.key, this.cropId, this.cropName});

  @override
  State<DiagnosePage> createState() => _DiagnosePageState();
}

class _DiagnosePageState extends State<DiagnosePage> {
  final HybridDetectionService _detectionService = serviceLocator<HybridDetectionService>();
  final GetCurrentUserUseCase _getCurrentUserUseCase = serviceLocator<GetCurrentUserUseCase>();
  
  List<DiagnosisApiResponse> _diagnoses = [];
  bool _isLoading = false;
  String? _error;
  int? _currentCropId;

  @override
  void initState() {
    super.initState();
    _currentCropId = widget.cropId;
    _initializeService();
    if (_currentCropId != null) {
      _loadDiagnoses();
    }
  }

  Future<void> _initializeService() async {
    await _detectionService.initialize();
  }

  Future<void> _loadDiagnoses() async {
    if (_currentCropId == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final diagnoses = await _detectionService.getDiagnosesByCrop(_currentCropId!);
      setState(() {
        _diagnoses = diagnoses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _startDiagnosis() async {
    final user = _getCurrentUserUseCase();
    if (user?.id == null) {
      _showSnackBar('Error: Usuario no autenticado', isError: true);
      return;
    }
    _currentCropId = 1;
    if (_currentCropId == null) {
      _showSnackBar('Error: ID de cultivo no válido', isError: true);
      return;
    }

    // Navegar a la cámara para tomar la foto
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CameraPage(),
      ),
    );

    if (result != null && result is File) {
      // Tenemos el archivo de imagen, ahora lo procesamos
      await _processImageDiagnosis(result);
    }
  }

  Future<void> _processImageDiagnosis(File imageFile) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Mostrar progreso
      _showSnackBar('Procesando imagen...', duration: const Duration(seconds: 30));

      final user = _getCurrentUserUseCase();
      
      // Crear diagnóstico completo usando el microservicio
      final diagnosis = await _detectionService.createDiagnosis(
        imageFile: imageFile,
        cropId: _currentCropId,
        profileId: int.tryParse(user!.id),
      );
      
      if (mounted) {
        // Ocultar el snackbar de progreso
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        
        if (diagnosis != null) {
          // Recargar la lista de diagnósticos
          await _loadDiagnoses();

          // Mostrar resultado
          _showDiagnosisResult(diagnosis);
        } else {
          throw Exception('No se pudo procesar el diagnóstico');
        }
        
        setState(() {
          _isLoading = false;
        });
      }
      
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      
      if (mounted) {
        // Ocultar el snackbar de progreso
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        
        // Intentar detección local como fallback
        if (await _detectionService.isLocalDetectionAvailable()) {
          _showFallbackDialog(imageFile);
        } else {
          _showSnackBar('Error al procesar diagnóstico: $e', isError: true);
        }
      }
    }
  }

  void _showFallbackDialog(File imageFile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conexión Limitada'),
        content: const Text(
          'No se pudo conectar al servicio en línea. ¿Deseas usar el análisis local? '
          'Nota: La precisión puede ser menor.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processLocalDiagnosis(imageFile);
            },
            child: const Text('Usar Local'),
          ),
        ],
      ),
    );
  }

  Future<void> _processLocalDiagnosis(File imageFile) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      _showSnackBar('Procesando con modelo local...', duration: const Duration(seconds: 30));

      final result = await _detectionService.detectLocalOnly(imageFile);
      
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        
        if (result != null) {
          _showLocalDetectionResult(result);
        } else {
          throw Exception('No se pudo procesar la imagen localmente');
        }
      }
      
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      
          if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _showSnackBar('Error en análisis local: $e', isError: true);
    }
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  void _showDiagnosisResult(DiagnosisApiResponse diagnosis) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(diagnosis.diseaseDetected ? 'Enfermedad Detectada' : 'Planta Saludable'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (diagnosis.diseaseDetected) ...[
              Text('Enfermedad: ${_formatDiseaseName(diagnosis.predictedClass)}'),
              const SizedBox(height: 8),
              Text('Confianza: ${(diagnosis.confidence * 100).toStringAsFixed(1)}%'),
              const SizedBox(height: 8),
              Text('Severidad: ${diagnosis.severity}'),
              if (diagnosis.requiresTreatment) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange, size: 16),
                      SizedBox(width: 8),
                      Expanded(child: Text('Requiere tratamiento', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
              ],
              if (diagnosis.recommendations != null) ...[
                const SizedBox(height: 16),
                const Text('Recomendaciones:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(diagnosis.recommendations!),
              ],
            ] else ...[
              const Text('No se detectaron enfermedades en la planta.'),
              const SizedBox(height: 8),
              Text('Confianza: ${(diagnosis.confidence * 100).toStringAsFixed(1)}%'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showLocalDetectionResult(DetectionResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              result.diseaseDetected ? Icons.warning : Icons.check_circle,
              color: result.diseaseDetected ? Colors.orange : Colors.green,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(result.diseaseDetected ? 'Posible Enfermedad' : 'Planta Saludable'),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (result.warningMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.blue, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(result.warningMessage!)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text('Resultado: ${result.formattedDiseaseName}'),
            const SizedBox(height: 8),
            Text('Confianza: ${(result.confidence * 100).toStringAsFixed(1)}%'),
            const SizedBox(height: 16),
            const Text('Recomendaciones:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(result.recommendation),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  String _formatDiseaseName(String diseaseName) {
    if (diseaseName == 'nodisease') {
      return 'Sin Enfermedad';
    } else if (diseaseName == 'unknown') {
      return 'Desconocido';
    }
    
    return diseaseName.split('_').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  void _showSnackBar(String message, {bool isError = false, Duration? duration}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
        duration: duration ?? const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cropName != null ? 'Diagnosticar: ${widget.cropName}' : 'Diagnóstico'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDiagnoses,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: AppColors.grey400),
                      const SizedBox(height: 16),
                      Text('Error: $_error', 
                           style: TextStyle(color: AppColors.grey600),
                           textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadDiagnoses,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Botón para iniciar diagnóstico
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton.icon(
                        onPressed: _startDiagnosis,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.camera_alt, size: 24),
                        label: const Text('Tomar Foto para Diagnóstico', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    
                    // Lista de diagnósticos previos
                    if (_diagnoses.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Diagnósticos Previos',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _diagnoses.length,
                          itemBuilder: (context, index) {
                            final diagnosis = _diagnoses[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: Icon(
                                  diagnosis.diseaseDetected ? Icons.warning : Icons.check_circle,
                                  color: diagnosis.diseaseDetected ? Colors.red : Colors.green,
                                ),
                                title: Text(
                                  diagnosis.diseaseDetected 
                                      ? _formatDiseaseName(diagnosis.predictedClass)
                                      : 'Planta Saludable',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Confianza: ${(diagnosis.confidence * 100).toStringAsFixed(1)}%'),
                                    Text('Fecha: ${diagnosis.diagnosisDate.toString().split('.').first}'),
                                    Text('Estado: ${diagnosis.status}'),
                                    if (diagnosis.requiresTreatment)
                                      Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade100,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text('Requiere tratamiento', 
                                                         style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                      ),
                                  ],
                                ),
                                trailing: diagnosis.requiresTreatment 
                                    ? const Icon(Icons.medical_services, color: Colors.orange)
                                    : const Icon(Icons.check_circle, color: Colors.green),
                              ),
                            );
                          },
                        ),
                      ),
                    ] else ...[
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt_outlined, size: 80, color: AppColors.grey400),
                              const SizedBox(height: 16),
                              Text(
                                'No hay diagnósticos previos',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.grey800),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Toma una foto para realizar el primer diagnóstico',
                                style: TextStyle(fontSize: 14, color: AppColors.grey600),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
    );
  }
}
