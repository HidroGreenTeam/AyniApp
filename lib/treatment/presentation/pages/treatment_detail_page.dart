import 'package:flutter/material.dart';
import 'package:ayni/core/di/service_locator.dart';
import 'package:ayni/treatment/domain/repositories/treatment_repository.dart';
import 'package:ayni/treatment/data/models/treatment_models.dart';
import '../../../core/theme/app_theme.dart';

class TreatmentDetailPage extends StatefulWidget {
  final int treatmentId;

  const TreatmentDetailPage({super.key, required this.treatmentId});

  @override
  State<TreatmentDetailPage> createState() => _TreatmentDetailPageState();
}

class _TreatmentDetailPageState extends State<TreatmentDetailPage> {
  final TreatmentRepository _treatmentRepository = serviceLocator<TreatmentRepository>();
  
  TreatmentResponse? _treatment;
  List<TreatmentStepResponse> _steps = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTreatmentDetails();
  }

  Future<void> _loadTreatmentDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final treatment = await _treatmentRepository.getTreatmentById(widget.treatmentId);
      final steps = await _treatmentRepository.getStepsByTreatmentId(widget.treatmentId);
      
      setState(() {
        _treatment = treatment;
        _steps = steps;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _completeStep(int stepId) async {
    try {
      await _treatmentRepository.completeStep(stepId);
      _showSnackBar('Paso completado exitosamente', isSuccess: true);
      _loadTreatmentDetails(); // Recargar datos
    } catch (e) {
      _showSnackBar('Error al completar paso: $e', isError: true);
    }
  }

  Future<void> _skipStep(int stepId) async {
    try {
      await _treatmentRepository.skipStep(stepId);
      _showSnackBar('Paso omitido', isSuccess: true);
      _loadTreatmentDetails(); // Recargar datos
    } catch (e) {
      _showSnackBar('Error al omitir paso: $e', isError: true);
    }
  }

  Widget _buildTreatmentHeader() {
    if (_treatment == null) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _treatment!.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusChip(_treatment!.status),
              ],
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Icon(Icons.bug_report, color: _getSeverityColor(_treatment!.severity), size: 18),
                const SizedBox(width: 8),
                Text(
                  _treatment!.diseaseType,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            Text(
              _treatment!.description,
              style: TextStyle(
                color: AppColors.grey600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            
            // Barra de progreso
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Progreso General',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${_treatment!.progressPercentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _treatment!.progressPercentage / 100,
                  backgroundColor: AppColors.grey200,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Estadísticas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(
                  'Total',
                  _treatment!.activitiesCount.toString(),
                  Icons.list_alt,
                  AppColors.grey600,
                ),
                _buildStatColumn(
                  'Completadas',
                  _treatment!.completedActivitiesCount.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildStatColumn(
                  'Pendientes',
                  _treatment!.pendingActivitiesCount.toString(),
                  Icons.pending,
                  Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.grey600,
          ),
        ),
      ],
    );
  }

  Widget _buildStepCard(TreatmentStepResponse step) {
    final isSkipped = step.status.toUpperCase() == 'SKIPPED';
    final isPending = step.status.toUpperCase() == 'PENDING';
    final isOverdue = isPending && step.scheduledDate.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildStepIcon(step.status),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration: isSkipped ? TextDecoration.lineThrough : null,
                          color: isSkipped ? AppColors.grey500 : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step.description,
                        style: TextStyle(
                          color: AppColors.grey600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isOverdue)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Vencido',
                      style: TextStyle(
                        color: Colors.red.shade800,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: AppColors.grey500),
                const SizedBox(width: 4),
                Text(
                  'Programado: ${step.scheduledDate.toString().split('.').first}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.grey600,
                  ),
                ),
                if (step.completedDate != null) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.check, size: 16, color: Colors.green),
                  const SizedBox(width: 4),
                  Text(
                    'Completado: ${step.completedDate!.toString().split('.').first}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                    ),
                  ),
                ],
              ],
            ),
            
            if (step.hasReminder) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.notifications, size: 16, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(
                    'Recordatorio ${step.reminderMinutesBefore ?? 0} min antes',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
            
            if (isPending) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _confirmSkipStep(step),
                    icon: const Icon(Icons.skip_next, size: 16),
                    label: const Text('Omitir'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _confirmCompleteStep(step),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Completar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: AppColors.white,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStepIcon(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return CircleAvatar(
          radius: 16,
          backgroundColor: Colors.green,
          child: const Icon(Icons.check, color: Colors.white, size: 18),
        );
      case 'SKIPPED':
        return CircleAvatar(
          radius: 16,
          backgroundColor: Colors.orange,
          child: const Icon(Icons.skip_next, color: Colors.white, size: 18),
        );
      case 'PENDING':
      default:
        return CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.grey300,
          child: Icon(Icons.schedule, color: AppColors.grey600, size: 18),
        );
    }
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
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

  void _confirmCompleteStep(TreatmentStepResponse step) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Completar Paso'),
        content: Text('¿Estás seguro de que quieres marcar "${step.name}" como completado?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _completeStep(step.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
            ),
            child: const Text('Completar'),
          ),
        ],
      ),
    );
  }

  void _confirmSkipStep(TreatmentStepResponse step) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Omitir Paso'),
        content: Text('¿Estás seguro de que quieres omitir "${step.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _skipStep(step.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Omitir'),
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
        title: Text(_treatment?.title ?? 'Detalles del Tratamiento'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTreatmentDetails,
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
                        onPressed: _loadTreatmentDetails,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    _buildTreatmentHeader(),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Pasos del Tratamiento',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _steps.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.assignment_outlined, 
                                       size: 80, 
                                       color: AppColors.grey400),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No hay pasos definidos',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.grey600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 16),
                              itemCount: _steps.length,
                              itemBuilder: (context, index) {
                                return _buildStepCard(_steps[index]);
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
} 