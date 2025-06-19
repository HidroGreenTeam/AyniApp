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
                        if (crop.imageUrl != null)
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child: Image.network(
                              crop.imageUrl!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 200,
                                  color: AppColors.grey200,
                                  child: Icon(Icons.image_not_supported, size: 48, color: AppColors.grey400),
                                );
                              },
                            ),
                          ),
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
                                          'Área: ${crop.area} m² • ${crop.irrigationType}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors.grey600,
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
                                      } else if (value == 'delete') {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text('Eliminar Planta'),
                                            content: const Text('¿Estás seguro de que quieres eliminar esta planta?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(ctx, false),
                                                child: const Text('Cancelar'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(ctx, true),
                                                style: TextButton.styleFrom(
                                                  foregroundColor: Colors.red,
                                                ),
                                                child: const Text('Eliminar'),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true && context.mounted) {
                                          context.read<CropBloc>().add(DeleteCrop(crop.id));
                                        }
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
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete, color: Colors.red),
                                            SizedBox(width: 8),
                                            Text('Eliminar'),
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
}

class MyPlantsView extends StatelessWidget {
  const MyPlantsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Plants'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PlantFormPage()),
              );
              if (result != null && context.mounted) {
                context.read<CropBloc>().add(AddCrop(result));
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
            return Center(child: Text(state.errorMessage ?? 'Error loading crops'));
          } else if (state.crops.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.eco_outlined, size: 80, color: AppColors.grey400),
                  const SizedBox(height: 16),
                  Text('No Plants Added Yet', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.grey800)),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text('Add plants to your collection to track their growth and get care reminders', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: AppColors.grey600)),
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
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PlantFormPage()),
                      );
                      if (result == true && context.mounted) {
                        context.read<CropBloc>().add(FetchCrops());
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Your First Plant', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: state.crops.length,
            itemBuilder: (context, index) {
              final crop = state.crops[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: crop.imageUrl != null
                      ? Image.network(crop.imageUrl!, width: 48, height: 48, fit: BoxFit.cover)
                      : Icon(Icons.eco, color: AppColors.primaryGreen),
                  title: Text(crop.cropName),
                  subtitle: Text('Area: ${crop.area} | Irrigation: ${crop.irrigationType}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => PlantFormPage(crop: crop)),
                          );
                          if (result != null && context.mounted) {
                            context.read<CropBloc>().add(UpdateCrop(crop.id, result));
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete Plant'),
                              content: const Text('Are you sure you want to delete this plant?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                              ],
                            ),
                          );
                          if (confirm == true && context.mounted) {
                            context.read<CropBloc>().add(DeleteCrop(crop.id));
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
