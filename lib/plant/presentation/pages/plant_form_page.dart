import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../domain/entities/crop.dart';

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

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final cropData = {
        'cropName': _nameController.text,
        'area': int.tryParse(_areaController.text) ?? 0,
        'irrigationType': _irrigationTypeController.text,
        'plantingDate': _plantingDateController.text,
      };
      Navigator.pop(context, cropData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.crop == null ? 'Add Plant' : 'Edit Plant'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Plant Name'),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _areaController,
                decoration: const InputDecoration(labelText: 'Area'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _irrigationTypeController,
                decoration: const InputDecoration(labelText: 'Irrigation Type'),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _plantingDateController,
                decoration: const InputDecoration(labelText: 'Planting Date'),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: AppColors.white,
                ),
                child: Text(widget.crop == null ? 'Add Plant' : 'Update Plant'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
