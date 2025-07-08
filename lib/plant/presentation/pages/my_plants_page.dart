import 'package:ayni/core/di/service_locator.dart';
import 'package:ayni/core/services/storage_service.dart';
import 'package:ayni/plant/presentation/bolcs/crop_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import 'plant_form_page.dart';

class MyPlantsPage extends StatelessWidget {
  const MyPlantsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final token = serviceLocator<StorageService>().getToken();
    if (token == null || token.isEmpty) {
      Future.microtask(() {
        if (context.mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return BlocProvider(
      create: (_) => serviceLocator<CropBloc>()..add(FetchCrops()),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Mis Plantas'),
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: AppColors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () async {
                  if (context.mounted) {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: BlocProvider.of<CropBloc>(context),
                          child: const PlantFormPage(),
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          body: BlocBuilder<CropBloc, CropState>(
            builder: (context, state) {
              if (state.status == CropStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state.status == CropStatus.error) {
                final error = state.errorMessage ?? '';
                if (error.contains('401') || error.toLowerCase().contains('unauthorized')) {
                  Future.microtask(() {
                    if (context.mounted) {
                      Navigator.of(context).pushReplacementNamed('/login');
                    }
                  });
                  return const Center(child: Text('Sesión expirada. Redirigiendo...'));
                }
                return Center(child: Text('Error: $error'));
              } else if (state.crops.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.eco_outlined, size: 80, color: AppColors.grey400),
                      const SizedBox(height: 16),
                      Text(
                        'No tienes plantas añadidas',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.grey800),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Text(
                          'Añade plantas a tu colección para hacer seguimiento de su crecimiento y recibir recordatorios de cuidado',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: AppColors.grey600),
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          if (context.mounted) {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: BlocProvider.of<CropBloc>(context),
                                  child: const PlantFormPage(),
                                ),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Añade tu primera planta', style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.crops.length,
                itemBuilder: (context, index) {
                  final crop = state.crops[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          crop.cropName,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Ubicación: ${crop.location.isNotEmpty ? crop.location : 'No especificada'}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors.grey600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Estado: ${_getHealthStatusText(crop.healthStatus)}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: _getHealthStatusColor(crop.healthStatus),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Plantado: ${crop.plantingDate}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors.grey600,
                                          ),
                                        ),
                                        if (crop.notes.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            'Notas: ${crop.notes}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: AppColors.grey600,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    icon: Icon(Icons.more_vert, color: AppColors.grey600),
                                    onSelected: (value) async {
                                      if (value == 'edit') {
                                        if (context.mounted) {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => BlocProvider.value(
                                                value: BlocProvider.of<CropBloc>(context),
                                                child: PlantFormPage(crop: crop),
                                              ),
                                            ),
                                          );
                                        }
                                      } else if (value == 'diagnose') {
                                        // Navegar a la página de diagnóstico
                                        if (context.mounted) {
                                          Navigator.pushNamed(
                                            context,
                                            '/diagnose',
                                            arguments: {'cropId': crop.id, 'cropName': crop.cropName},
                                          );
                                        }
                                      } else if (value == 'status') {
                                        _showStatusUpdateDialog(context, crop);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit, color: Colors.blue),
                                            SizedBox(width: 8),
                                            Text('Editar'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'diagnose',
                                        child: Row(
                                          children: [
                                            Icon(Icons.camera_alt, color: Colors.green),
                                            SizedBox(width: 8),
                                            Text('Diagnosticar'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'status',
                                        child: Row(
                                          children: [
                                            Icon(Icons.health_and_safety, color: Colors.orange),
                                            SizedBox(width: 8),
                                            Text('Actualizar Estado'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  String _getHealthStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'HEALTHY':
        return 'Saludable';
      case 'DISEASED':
        return 'Enferma';
      case 'RECOVERING':
        return 'Recuperándose';
      default:
        return status;
    }
  }

  Color _getHealthStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'HEALTHY':
        return Colors.green;
      case 'DISEASED':
        return Colors.red;
      case 'RECOVERING':
        return Colors.orange;
      default:
        return AppColors.grey600;
    }
  }

  void _showStatusUpdateDialog(BuildContext context, crop) {
    String selectedStatus = crop.healthStatus;
    final notesController = TextEditingController(text: crop.notes);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Actualizar Estado de la Planta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Estado de Salud',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'HEALTHY', child: Text('Saludable')),
                DropdownMenuItem(value: 'DISEASED', child: Text('Enferma')),
                DropdownMenuItem(value: 'RECOVERING', child: Text('Recuperándose')),
              ],
              onChanged: (value) {
                selectedStatus = value!;
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notas',
                border: OutlineInputBorder(),
                hintText: 'Observaciones sobre el estado de la planta...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final statusData = {
                'healthStatus': selectedStatus,
                'notes': notesController.text,
              };
              context.read<CropBloc>().add(UpdateCropStatus(crop.id, statusData));
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}


