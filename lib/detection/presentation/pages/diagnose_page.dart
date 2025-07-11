import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ayni/core/di/service_locator.dart';
import 'package:ayni/plant/domain/entities/diagnosis.dart';
import 'package:ayni/plant/domain/usecases/start_diagnosis_usecase.dart';
import 'package:ayni/plant/domain/usecases/get_diagnoses_by_crop_usecase.dart';
import 'package:ayni/auth/domain/usecases/get_current_user_use_case.dart';
import 'package:ayni/camera/presentation/pages/camera_page.dart';
import 'package:ayni/core/services/image_upload_service.dart';
import '../../../core/theme/app_theme.dart';

class DiagnosePage extends StatefulWidget {
  final int? cropId;
  final String? cropName;

  const DiagnosePage({super.key, this.cropId, this.cropName});

  @override
  State<DiagnosePage> createState() => _DiagnosePageState();
}

class _DiagnosePageState extends State<DiagnosePage> {
  final StartDiagnosisUseCase _startDiagnosisUseCase = serviceLocator<StartDiagnosisUseCase>();
  final GetDiagnosesByCropUseCase _getDiagnosesUseCase = serviceLocator<GetDiagnosesByCropUseCase>();
  final GetCurrentUserUseCase _getCurrentUserUseCase = serviceLocator<GetCurrentUserUseCase>();
  final ImageUploadService _imageUploadService = serviceLocator<ImageUploadService>();
  
  List<Diagnosis> _diagnoses = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.cropId != null) {
      _loadDiagnoses();
    }
  }

  Future<void> _loadDiagnoses() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final diagnoses = await _getDiagnosesUseCase(widget.cropId!);
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Usuario no autenticado')),
      );
      return;
    }

    if (widget.cropId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: ID de cultivo no válido')),
      );
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
      // Tenemos el archivo de imagen, ahora lo subimos
      await _uploadImageAndProcessDiagnosis(result);
    }
  }

  Future<void> _uploadImageAndProcessDiagnosis(File imageFile) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Mostrar progreso de subida
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              CircularProgressIndicator(strokeWidth: 2),
              SizedBox(width: 16),
              Text('Subiendo imagen...'),
            ],
          ),
          duration: Duration(seconds: 30),
        ),
      );

      // Subir imagen al servidor
      final imageUrl = await _imageUploadService.uploadImage(imageFile);
      
      // Procesar el diagnóstico con la URL de la imagen
      await _processDiagnosis(imageUrl);
      
      // Ocultar el snackbar de progreso
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      
      // Ocultar el snackbar de progreso
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al subir imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _processDiagnosis(String imageUrl) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = _getCurrentUserUseCase();
      final diagnosisData = {
        'cropId': widget.cropId,
        'profileId': int.parse(user!.id),
        'imageUrl': imageUrl,
      };

      final diagnosis = await _startDiagnosisUseCase(diagnosisData);
      
      // Recargar la lista de diagnósticos
      await _loadDiagnoses();

      // Mostrar resultado
      if (mounted) {
        _showDiagnosisResult(diagnosis);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al procesar diagnóstico: $e')),
        );
      }
    }
  }

  void _showDiagnosisResult(Diagnosis diagnosis) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(diagnosis.diseaseDetected ? 'Enfermedad Detectada' : 'Planta Saludable'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (diagnosis.diseaseDetected) ...[
              Text('Enfermedad: ${diagnosis.detectedDisease}'),
              const SizedBox(height: 8),
              Text('Confianza: ${(diagnosis.confidenceScore * 100).toStringAsFixed(1)}%'),
              const SizedBox(height: 16),
              if (diagnosis.recommendations.isNotEmpty) ...[
                const Text('Recomendaciones:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(diagnosis.recommendations),
              ],
            ] else ...[
              const Text('No se detectaron enfermedades en la planta.'),
              const SizedBox(height: 8),
              Text('Confianza: ${(diagnosis.confidenceScore * 100).toStringAsFixed(1)}%'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
                '/diagnosis-detail',
                arguments: {'diagnosisId': diagnosis.id},
              );
            },
            child: const Text('Ver Detalles'),
          ),
        ],
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
                      Text('Error: $_error', style: TextStyle(color: AppColors.grey600)),
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
                                  diagnosis.diseaseDetected ? diagnosis.detectedDisease : 'Planta Saludable',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Confianza: ${(diagnosis.confidenceScore * 100).toStringAsFixed(1)}%'),
                                    Text('Fecha: ${diagnosis.analyzedAt}'),
                                    Text('Estado: ${diagnosis.status}'),
                                  ],
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/diagnosis-detail',
                                    arguments: {'diagnosisId': diagnosis.id},
                                  );
                                },
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
