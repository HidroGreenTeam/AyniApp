import 'package:flutter/material.dart';
import 'package:ayni/core/di/service_locator.dart';
import 'package:ayni/treatment/domain/repositories/treatment_repository.dart';
import 'package:ayni/treatment/data/models/treatment_models.dart';
import '../../../core/theme/app_theme.dart';

class AddTreatmentStepPage extends StatefulWidget {
  final int treatmentId;
  final String treatmentTitle;

  const AddTreatmentStepPage({
    super.key,
    required this.treatmentId,
    required this.treatmentTitle,
  });

  @override
  State<AddTreatmentStepPage> createState() => _AddTreatmentStepPageState();
}

class _AddTreatmentStepPageState extends State<AddTreatmentStepPage> {
  final TreatmentRepository _treatmentRepository = serviceLocator<TreatmentRepository>();
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  DateTime _scheduledDate = DateTime.now().add(const Duration(hours: 1));
  bool _hasReminder = false;
  int _reminderMinutesBefore = 30;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createStep() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final request = CreateTreatmentStepRequest(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        scheduledDate: _scheduledDate,
        hasReminder: _hasReminder,
        reminderMinutesBefore: _hasReminder ? _reminderMinutesBefore : null,
      );

      await _treatmentRepository.createStep(widget.treatmentId, request);
      
      if (mounted) {
        _showSnackBar('Paso agregado exitosamente', isSuccess: true);
        Navigator.pop(context, true); // Retorna true para indicar éxito
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error al agregar paso: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryGreen,
              onPrimary: AppColors.white,
              surface: AppColors.white,
              onSurface: AppColors.grey800,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final TimeOfDay? timePicked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_scheduledDate),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: AppColors.primaryGreen,
                onPrimary: AppColors.white,
                surface: AppColors.white,
                onSurface: AppColors.grey800,
              ),
            ),
            child: child!,
          );
        },
      );

      if (timePicked != null) {
        setState(() {
          _scheduledDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            timePicked.hour,
            timePicked.minute,
          );
        });
      }
    }
  }

  Widget _buildStepTemplates() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: AppColors.primaryGreen),
                const SizedBox(width: 8),
                Text(
                  'Plantillas Sugeridas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTemplateChip('Inspección visual', 'Revisar el estado general de la planta'),
            _buildTemplateChip('Aplicar tratamiento', 'Aplicar medicamento o fertilizante según indicaciones'),
            _buildTemplateChip('Riego especializado', 'Regar con cuidado según las necesidades de la planta'),
            _buildTemplateChip('Monitoreo de progreso', 'Verificar la evolución del tratamiento'),
            _buildTemplateChip('Limpieza de hojas', 'Limpiar hojas afectadas o dañadas'),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateChip(String name, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _nameController.text = name;
            _descriptionController.text = description;
          });
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.grey200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: AppColors.grey600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
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
        title: const Text('Agregar Paso'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Información del tratamiento
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: AppColors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Agregando paso a:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.treatmentTitle,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),

            // Plantillas sugeridas
            _buildStepTemplates(),

            // Formulario
            Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Información del Paso',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Nombre del paso
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nombre del paso *',
                        hintText: 'Ej: Aplicar fungicida',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.assignment),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor ingresa el nombre del paso';
                        }
                        if (value.trim().length < 3) {
                          return 'El nombre debe tener al menos 3 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Descripción
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Descripción *',
                        hintText: 'Describe detalladamente qué hacer en este paso',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.description),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor ingresa una descripción';
                        }
                        if (value.trim().length < 10) {
                          return 'La descripción debe tener al menos 10 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Fecha y hora programada
                    const Text(
                      'Programación',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    InkWell(
                      onTap: _selectDate,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.grey400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, color: AppColors.grey600),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Fecha y hora programada',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_scheduledDate.day}/${_scheduledDate.month}/${_scheduledDate.year} - ${_scheduledDate.hour.toString().padLeft(2, '0')}:${_scheduledDate.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Recordatorio
                    const Text(
                      'Recordatorio',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    SwitchListTile(
                      title: const Text('Activar recordatorio'),
                      subtitle: const Text('Recibir notificación antes del paso'),
                      value: _hasReminder,
                      onChanged: (value) {
                        setState(() {
                          _hasReminder = value;
                        });
                      },
                      activeColor: AppColors.primaryGreen,
                    ),
                    
                    if (_hasReminder) ...[
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: _reminderMinutesBefore,
                        decoration: InputDecoration(
                          labelText: 'Minutos antes',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.notifications),
                        ),
                        items: [
                          5, 10, 15, 30, 60, 120, 240, 480, 1440
                        ].map((minutes) {
                          String label;
                          if (minutes < 60) {
                            label = '$minutes minutos';
                          } else if (minutes < 1440) {
                            label = '${minutes ~/ 60} horas';
                          } else {
                            label = '${minutes ~/ 1440} días';
                          }
                          return DropdownMenuItem(
                            value: minutes,
                            child: Text(label),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _reminderMinutesBefore = value;
                            });
                          }
                        },
                      ),
                    ],
                    
                    const SizedBox(height: 32),
                    
                    // Botón de crear
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _createStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Crear Paso',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Botón de cancelar
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 