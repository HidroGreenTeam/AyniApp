import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../domain/entities/crop.dart';
import '../bolcs/crop_bloc.dart';

class PlantFormPage extends StatefulWidget {
  final Crop? crop;
  const PlantFormPage({super.key, this.crop});

  @override
  State<PlantFormPage> createState() => _PlantFormPageState();
}

class _PlantFormPageState extends State<PlantFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _plantingDateController;
  late TextEditingController _notesController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.crop?.cropName ?? '');
    _locationController = TextEditingController(text: widget.crop?.location ?? '');
    _plantingDateController = TextEditingController(text: widget.crop?.plantingDate ?? '');
    _notesController = TextEditingController(text: widget.crop?.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _plantingDateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
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
      setState(() {
        _plantingDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final cropData = {
        'cropName': _nameController.text,
        'location': _locationController.text,
        'plantingDate': _plantingDateController.text,
        'notes': _notesController.text,
      };

      if (widget.crop != null) {
        // Para editar, solo actualizamos el estado
        final statusData = {
          'healthStatus': widget.crop!.healthStatus,
          'notes': _notesController.text,
        };
        context.read<CropBloc>().add(UpdateCropStatus(widget.crop!.id, statusData));
      } else {
        context.read<CropBloc>().add(AddCrop(cropData));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CropBloc, CropState>(
      listener: (context, state) {
        if (state.status == CropStatus.loading) {
          setState(() => _isLoading = true);
        } else {
          setState(() => _isLoading = false);
          if (state.status == CropStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Error al guardar la planta')),
            );
          } else if (state.status == CropStatus.loaded) {
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.crop == null ? 'Añadir Planta' : 'Editar Planta'),
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: AppColors.white,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Nombre
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre de la Planta',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: Icon(Icons.eco, color: AppColors.primaryGreen),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa el nombre de la planta';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Ubicación
                  TextFormField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      labelText: 'Ubicación',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: Icon(Icons.location_on, color: AppColors.primaryGreen),
                      hintText: 'Ej: Jardín trasero, Balcón, Invernadero...',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Fecha de plantación
                  TextFormField(
                    controller: _plantingDateController,
                    readOnly: true,
                    onTap: _selectDate,
                    decoration: InputDecoration(
                      labelText: 'Fecha de Plantación',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: Icon(Icons.calendar_today, color: AppColors.primaryGreen),
                      suffixIcon: Icon(Icons.date_range, color: AppColors.primaryGreen),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor selecciona la fecha de plantación';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Notas
                  TextFormField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelText: 'Notas',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: Icon(Icons.note, color: AppColors.primaryGreen),
                      hintText: 'Observaciones sobre la planta...',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // Botón de guardar
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
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
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                            ),
                          )
                        : Text(
                            widget.crop == null ? 'Añadir Planta' : 'Guardar Cambios',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
