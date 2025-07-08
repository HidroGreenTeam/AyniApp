import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/subscription_api_models.dart';
import '../blocs/subscription_bloc.dart';

class SubscriptionPlansPage extends StatelessWidget {
  const SubscriptionPlansPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planes de Suscripción'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: BlocProvider(
        create: (context) => context.read<SubscriptionBloc>()
          ..add(LoadSubscriptionPlans()),
        child: BlocBuilder<SubscriptionBloc, SubscriptionState>(
          builder: (context, state) {
            if (state is SubscriptionLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is SubscriptionPlansLoaded) {
              return _buildPlansList(context, state.plans);
            } else if (state is SubscriptionError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${state.message}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<SubscriptionBloc>().add(LoadSubscriptionPlans());
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            } else {
              return const Center(
                child: Text('No hay planes disponibles'),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildPlansList(BuildContext context, List<SubscriptionPlanResource> plans) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: plans.length,
      itemBuilder: (context, index) {
        final plan = plans[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        plan.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getPlanColor(plan.planType),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getPlanTypeText(plan.planType),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  plan.description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      '\$${plan.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '/ ${plan.durationDays} días',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildFeatureList(plan),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _selectPlan(context, plan),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Seleccionar Plan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureList(SubscriptionPlanResource plan) {
    final features = <String>[];
    
    features.add('${plan.maxCrops} cultivos máximos');
    features.add('${plan.maxReports} reportes máximos');
    
    if (plan.hasPrioritySupport) {
      features.add('Soporte prioritario');
    }
    
    if (plan.hasAdvancedAnalytics) {
      features.add('Analíticas avanzadas');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: features.map((feature) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  feature,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getPlanColor(SubscriptionType planType) {
    switch (planType) {
      case SubscriptionType.FREE:
        return Colors.grey;
      case SubscriptionType.BASIC:
        return Colors.blue;
      case SubscriptionType.PREMIUM:
        return Colors.green;
      case SubscriptionType.ENTERPRISE:
        return Colors.purple;
    }
  }

  String _getPlanTypeText(SubscriptionType planType) {
    switch (planType) {
      case SubscriptionType.FREE:
        return 'GRATIS';
      case SubscriptionType.BASIC:
        return 'BÁSICO';
      case SubscriptionType.PREMIUM:
        return 'PREMIUM';
      case SubscriptionType.ENTERPRISE:
        return 'EMPRESARIAL';
    }
  }

  void _selectPlan(BuildContext context, SubscriptionPlanResource plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar ${plan.name}'),
        content: Text(
          '¿Estás seguro de que quieres suscribirte al plan ${plan.name} por \$${plan.price.toStringAsFixed(2)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _createSubscription(context, plan);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _createSubscription(BuildContext context, SubscriptionPlanResource plan) {
    // Aquí deberías obtener el userId del usuario actual
    // Por ahora usamos un ID de ejemplo
    final userId = 1; // Esto debería venir del servicio de autenticación
    
    final request = CreateSubscriptionResource(
      userId: userId,
      subscriptionType: plan.planType,
      autoRenew: plan.planType != SubscriptionType.FREE,
      paymentReference: plan.planType == SubscriptionType.FREE ? null : 'PAYMENT_REF_${DateTime.now().millisecondsSinceEpoch}',
    );

    context.read<SubscriptionBloc>().add(CreateSubscription(request));

    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Creando suscripción...'),
          ],
        ),
      ),
    );

    // Escuchar el resultado
    context.read<SubscriptionBloc>().stream.listen((state) {
      if (state is SubscriptionCreated) {
        Navigator.of(context).pop(); // Cerrar loading
        _showSuccessDialog(context, state.subscription);
      } else if (state is SubscriptionError) {
        Navigator.of(context).pop(); // Cerrar loading
        _showErrorDialog(context, state.message);
      }
    });
  }

  void _showSuccessDialog(BuildContext context, SubscriptionResource subscription) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¡Suscripción Creada!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Plan: ${subscription.subscriptionPlanName}'),
            Text('Estado: ${subscription.status.toString().split('.').last}'),
            Text('Días restantes: ${subscription.daysRemaining}'),
            if (subscription.endDate != null)
              Text('Válido hasta: ${_formatDate(subscription.endDate)}'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Volver a la página anterior
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 