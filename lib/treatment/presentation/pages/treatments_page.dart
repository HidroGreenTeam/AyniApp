import 'package:flutter/material.dart';
import 'package:ayni/core/di/service_locator.dart';
import 'package:ayni/auth/domain/usecases/get_current_user_use_case.dart';
import 'package:ayni/treatment/domain/repositories/treatment_repository.dart';
import 'package:ayni/treatment/data/models/treatment_models.dart';
import 'package:ayni/treatment/services/treatment_service.dart';
import '../../../core/theme/app_theme.dart';

class TreatmentsPage extends StatefulWidget {
  final Map<String, dynamic>? arguments;
  
  const TreatmentsPage({super.key, this.arguments});

  @override
  State<TreatmentsPage> createState() => _TreatmentsPageState();
}

class _TreatmentsPageState extends State<TreatmentsPage> {
  final TreatmentRepository _treatmentRepository = serviceLocator<TreatmentRepository>();
  final GetCurrentUserUseCase _getCurrentUserUseCase = serviceLocator<GetCurrentUserUseCase>();
  final TreatmentService _treatmentService = serviceLocator<TreatmentService>();
  
  List<TreatmentResponse> _treatments = [];
  List<CreateTreatmentStepRequest> _suggestedSteps = [];
  bool _isLoading = false;
  String? _error;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _loadTreatments();
    _checkForDiagnosisArguments();
  }

  void _checkForDiagnosisArguments() {
    if (widget.arguments != null) {
      final diseaseType = widget.arguments!['diseaseType'] as String?;
      if (diseaseType != null) {
        setState(() {
          _showSuggestions = true;
          _suggestedSteps = _treatmentService.generateTreatmentSteps(diseaseType);
        });
      }
    }
  }

  Future<void> _loadTreatments() async {
    final user = _getCurrentUserUseCase();
    if (user?.id == null) {
      setState(() {
        _error = 'Usuario no autenticado';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final treatments = await _treatmentRepository.getTreatmentsByProfileId(int.parse(user!.id));
      setState(() {
        _treatments = treatments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Widget _buildTreatmentCard(TreatmentResponse treatment) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con título y estado
            Row(
              children: [
                Expanded(
                  child: Text(
                    treatment.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusChip(treatment.status),
              ],
            ),
            const SizedBox(height: 8),
            
            // Información de la enfermedad
            Row(
              children: [
                Icon(Icons.bug_report, color: _getSeverityColor(treatment.severity), size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    treatment.diseaseType,
                    style: TextStyle(
                      color: AppColors.grey600,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.analytics, color: AppColors.grey500, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${(treatment.confidence * 100).toStringAsFixed(1)}%',
                  style: TextStyle(color: AppColors.grey600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Barra de progreso
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progreso del tratamiento',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.grey700,
                      ),
                    ),
                    Text(
                      '${treatment.progressPercentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: treatment.progressPercentage / 100,
                  backgroundColor: AppColors.grey200,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Estadísticas de actividades
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Flexible(
                  child: _buildStatItem(
                    icon: Icons.list_alt,
                    label: 'Total',
                    value: treatment.activitiesCount.toString(),
                    color: AppColors.grey600,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: _buildStatItem(
                    icon: Icons.check_circle,
                    label: 'Completadas',
                    value: treatment.completedActivitiesCount.toString(),
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: _buildStatItem(
                    icon: Icons.pending,
                    label: 'Pendientes',
                    value: treatment.pendingActivitiesCount.toString(),
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Fecha y botón de acción
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Creado: ${treatment.createdAt.toString().split('.').first}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.grey500,
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToTreatmentDetail(treatment),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: const Text('Ver Detalles'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        break;
      case 'COMPLETED':
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        break;
      case 'PAUSED':
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        break;
      default:
        backgroundColor = AppColors.grey200;
        textColor = AppColors.grey700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getSeverityColor(String? severity) {
    if (severity == null) return AppColors.grey500;
    
    switch (severity.toUpperCase()) {
      case 'HIGH':
        return Colors.red;
      case 'MEDIUM':
        return Colors.orange;
      case 'LOW':
        return Colors.yellow.shade700;
      default:
        return AppColors.grey500;
    }
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.grey500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _navigateToTreatmentDetail(TreatmentResponse treatment) {
    Navigator.pushNamed(
      context,
      '/treatment-detail',
      arguments: {'treatmentId': treatment.id},
    );
  }

  Widget _buildTreatmentSuggestions() {
    if (!_showSuggestions || _suggestedSteps.isEmpty) {
      return const SizedBox.shrink();
    }

    final diseaseType = widget.arguments!['diseaseType'] as String;
    final title = _treatmentService.generateTreatmentTitle(diseaseType);
    final description = _treatmentService.generateTreatmentDescription(diseaseType, 0.85);

    return Card(
      margin: const EdgeInsets.all(16),
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tratamiento Sugerido',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                color: AppColors.grey600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Pasos recomendados: ${_suggestedSteps.length}',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.grey700,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _createTreatmentFromSuggestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.add),
                label: const Text('Crear Tratamiento'),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () => _showSuggestionDetails(),
                child: const Text('Ver Detalles'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createTreatmentFromSuggestion() async {
    final diseaseType = widget.arguments!['diseaseType'] as String;
    final diagnosisId = widget.arguments!['diagnosisId'] as int?;
    final cropId = widget.arguments!['cropId'] as int?;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear Tratamiento'),
        content: const Text(
          'Esto creará un plan de tratamiento personalizado con pasos específicos para esta enfermedad. ¿Deseas continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processTreatmentCreation(diseaseType, diagnosisId, cropId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  Future<void> _processTreatmentCreation(String diseaseType, int? diagnosisId, int? cropId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Aquí simularíamos la creación del tratamiento
      // En una implementación real, se llamaría al backend
      _showSnackBar('Tratamiento creado exitosamente', isSuccess: true);
      
      setState(() {
        _showSuggestions = false;
        _isLoading = false;
      });
      
      // Recargar tratamientos
      await _loadTreatments();
      
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Error al crear tratamiento: $e', isError: true);
    }
  }

  void _showSuggestionDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalles del Tratamiento'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _suggestedSteps.length,
            itemBuilder: (context, index) {
              final step = _suggestedSteps[index];
              return ListTile(
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primaryGreen,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                title: Text(
                  step.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(step.description),
                    const SizedBox(height: 4),
                    Text(
                      'Programado: ${step.scheduledDate.toString().split('.').first}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.grey600,
                      ),
                    ),
                  ],
                ),
                isThreeLine: true,
              );
            },
          ),
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

  void _showSnackBar(String message, {bool isError = false, bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError 
            ? Colors.red 
            : isSuccess 
                ? Colors.green 
                : null,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Tratamientos'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTreatments,
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
                      Text(
                        'Error: $_error',
                        style: TextStyle(color: AppColors.grey600),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadTreatments,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Widget de sugerencias de tratamiento
                    _buildTreatmentSuggestions(),
                    
                    // Lista de tratamientos o mensaje vacío
                    Expanded(
                      child: _treatments.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.medical_services_outlined, 
                                       size: 80, 
                                       color: AppColors.grey400),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No hay tratamientos activos',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.grey800,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Los tratamientos aparecerán aquí cuando diagnostiques enfermedades que requieran tratamiento',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.grey600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: _treatments.length,
                              itemBuilder: (context, index) {
                                return _buildTreatmentCard(_treatments[index]);
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
} 