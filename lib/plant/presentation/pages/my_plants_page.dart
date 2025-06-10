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
        Navigator.of(context).pushReplacementNamed('/login');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
      return BlocProvider(
      create: (_) => serviceLocator<CropBloc>()..add(FetchCrops()),
      child: BlocBuilder<CropBloc, CropState>(
        builder: (context, state) {
          if (state.status == CropStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.status == CropStatus.error) {
            final error = state.errorMessage ?? '';
            if (error.contains('401') || error.toLowerCase().contains('unauthorized')) {
              Future.microtask(() {
                Navigator.of(context).pushReplacementNamed('/login');
              });
              return const Scaffold(
                body: Center(child: Text('Sesión expirada. Redirigiendo...')),
              );
            }
            return Center(child: Text('Error: $error'));
          } else if (state.status == CropStatus.loaded) {
            if (state.crops.isEmpty) {
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
                    subtitle: Text('Area: \\${crop.area} | Irrigation: \\${crop.irrigationType}'),
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
                            if (confirm == true) {
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
          }
          return const SizedBox.shrink();
        },
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
                          if (confirm == true) {
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
