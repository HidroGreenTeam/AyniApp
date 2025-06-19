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
  late TextEditingController _areaController;
  late TextEditingController _irrigationTypeController;
  late TextEditingController _plantingDateController;
  File? _selectedImage;
  final _imagePicker = ImagePicker();
  bool _isLoading = false;

  final List<String> _irrigationTypes = [
    'Goteo',
    'Aspersión',
    'Manual',
    'Otro'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.crop?.cropName ?? '');
    _areaController = TextEditingController(text: widget.crop?.area.toString() ?? '');
    _irrigationTypeController = TextEditingController(text: widget.crop?.irrigationType ?? '');
    _plantingDateController = TextEditingController(text: widget.crop?.plantingDate ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _areaController.dispose();
    _irrigationTypeController.dispose();
    _plantingDateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al seleccionar la imagen')),
        );
      }
    }
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
        'area': int.tryParse(_areaController.text) ?? 0,
        'irrigationType': _irrigationTypeController.text,
        'plantingDate': _plantingDateController.text,
      };

      if (widget.crop != null) {
        context.read<CropBloc>().add(
          UpdateCrop(widget.crop!.id, cropData, imageFile: _selectedImage),
        );
      } else {
        context.read<CropBloc>().add(
          AddCrop(cropData, imageFile: _selectedImage),
        );
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
                  // Imagen
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppColors.grey200,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.grey400),
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : widget.crop?.imageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    widget.crop!.imageUrl!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_photo_alternate,
                                        size: 48, color: AppColors.grey600),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Toca para añadir una imagen',
                                      style: TextStyle(color: AppColors.grey600),
                                    ),
                                  ],
                                ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Nombre
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre de la Planta',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.eco),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 16),

                  // Área
                  TextFormField(
                    controller: _areaController,
                    decoration: InputDecoration(
                      labelText: 'Área (m²)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.square_foot),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 16),

                  // Tipo de Irrigación
                  DropdownButtonFormField<String>(
                    value: _irrigationTypeController.text.isEmpty
                        ? null
                        : _irrigationTypeController.text,
                    decoration: InputDecoration(
                      labelText: 'Tipo de Irrigación',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.water_drop),
                    ),
                    items: _irrigationTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      if (value != null) {
                        _irrigationTypeController.text = value;
                      }
                    },
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 16),

                  // Fecha de Plantación
                  TextFormField(
                    controller: _plantingDateController,
                    decoration: InputDecoration(
                      labelText: 'Fecha de Plantación',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.calendar_today),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_month),
                        onPressed: _selectDate,
                      ),
                    ),
                    readOnly: true,
                    onTap: _selectDate,
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 24),

                  // Botón de Guardar
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
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            widget.crop == null ? 'Añadir Planta' : 'Actualizar Planta',
                            style: const TextStyle(fontSize: 16),
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
