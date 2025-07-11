import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/subscription_api_models.dart';
import '../blocs/subscription_bloc.dart';
import '../../../auth/domain/usecases/get_current_user_use_case.dart';
import '../../../core/services/payment_service.dart';
import '../../../core/di/service_locator.dart';

class SubscriptionPlansPage extends StatefulWidget {
  const SubscriptionPlansPage({super.key});

  @override
  State<SubscriptionPlansPage> createState() => _SubscriptionPlansPageState();
}

class _SubscriptionPlansPageState extends State<SubscriptionPlansPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planes de Suscripción'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: BlocProvider(
        create: (context) => serviceLocator<SubscriptionBloc>()
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
      builder: (dialogContext) => AlertDialog(
        title: Text('Confirmar ${plan.name}'),
        content: Text(
          '¿Estás seguro de que quieres suscribirte al plan ${plan.name} por \$${plan.price.toStringAsFixed(2)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
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

  Future<void> _createSubscription(BuildContext context, SubscriptionPlanResource plan) async {
    // Obtener el usuario autenticado actual
    final getCurrentUserUseCase = serviceLocator<GetCurrentUserUseCase>();
    final currentUser = getCurrentUserUseCase();
    
    if (currentUser == null) {
      _showErrorDialogSafe(context, 'Error: Usuario no autenticado');
      return;
    }
    
    final userId = int.parse(currentUser.id);
    String? paymentReference;

    // Solo intentar pago para planes que no sean gratuitos
    if (plan.planType != SubscriptionType.FREE) {
      // Mostrar diálogo de carga para el pago
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Iniciando pago...'),
            ],
          ),
        ),
      );
      
      try {
        final paymentService = serviceLocator<PaymentService>();
        paymentReference = await paymentService.pay(
          amount: plan.price,
          currencyCode: 'USD',
          label: plan.name,
        );
      } catch (e) {
        print('Error en el pago: $e');
      }

      Navigator.of(context).pop(); // Cerrar diálogo de carga

      if (paymentReference == null) {
        // El usuario canceló o falló el pago - preguntar qué hacer
        if (mounted) {
          _showPaymentFailedDialog(context, plan, userId);
        }
        return;
      }
    }

    // Crear la suscripción
    _proceedWithSubscriptionCreation(context, plan, userId, paymentReference);
  }

  void _showPaymentFailedDialog(BuildContext context, SubscriptionPlanResource plan, int userId) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<SubscriptionBloc>(),
        child: AlertDialog(
          title: const Text('Pago Cancelado'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('El pago fue cancelado o falló.'),
              const SizedBox(height: 16),
              const Text('¿Qué deseas hacer?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Volver'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Reintentar el pago
                _createSubscription(context, plan);
              },
              child: const Text('Reintentar Pago'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Crear suscripción sin referencia de pago (pendiente de pago)
                _proceedWithSubscriptionCreation(context, plan, userId, null);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Crear sin Pago'),
            ),
          ],
        ),
      ),
    );
  }

  void _proceedWithSubscriptionCreation(BuildContext context, SubscriptionPlanResource plan, int userId, String? paymentReference) {
    final request = CreateSubscriptionResource(
      userId: userId,
      subscriptionType: plan.planType,
      autoRenew: plan.planType != SubscriptionType.FREE,
      paymentReference: paymentReference,
    );

    // Despachar el evento
    context.read<SubscriptionBloc>().add(CreateSubscription(request));

    // Mostrar loading con BlocListener
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<SubscriptionBloc>(),
        child: BlocListener<SubscriptionBloc, SubscriptionState>(
          listener: (listenerContext, state) {
            if (state is SubscriptionCreated) {
              // Cerrar loading de forma segura
              if (Navigator.canPop(dialogContext)) {
                Navigator.of(dialogContext).pop();
              }
              
              // Verificar que el widget sigue montado antes de continuar
              if (!mounted) return;
              
              // Si hay paymentReference, activar la suscripción automáticamente
              if (paymentReference != null && paymentReference.isNotEmpty) {
                _activateSubscription(context, state.subscription, paymentReference);
              } else {
                _showSuccessDialogSafe(context, state.subscription);
              }
            } else if (state is SubscriptionError) {
              // Cerrar loading de forma segura
              if (Navigator.canPop(dialogContext)) {
                Navigator.of(dialogContext).pop();
              }
              
              // Verificar que el widget sigue montado
              if (!mounted) return;
              
              _showErrorDialogSafe(context, state.message);
            }
          },
          child: const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Creando suscripción...'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _activateSubscription(BuildContext context, SubscriptionResource subscription, String paymentReference) {
    // Crear el request de activación
    final activateRequest = ActivateSubscriptionResource(
      paymentReference: paymentReference,
    );

    // Despachar el evento
    context.read<SubscriptionBloc>().add(
      ActivateSubscription(subscription.id, activateRequest)
    );

    // Mostrar loading con BlocListener
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<SubscriptionBloc>(),
        child: BlocListener<SubscriptionBloc, SubscriptionState>(
          listener: (listenerContext, state) {
            if (state is SubscriptionLoaded) {
              // Cerrar loading de forma segura
              if (Navigator.canPop(dialogContext)) {
                Navigator.of(dialogContext).pop();
              }
              
              // Verificar que el widget sigue montado
              if (!mounted) return;
              
              _showSuccessDialogSafe(context, state.subscription);
            } else if (state is SubscriptionError) {
              // Cerrar loading de forma segura
              if (Navigator.canPop(dialogContext)) {
                Navigator.of(dialogContext).pop();
              }
              
              // Verificar que el widget sigue montado
              if (!mounted) return;
              
              _showActivationErrorDialogSafe(context, subscription, state.message);
            }
          },
          child: const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Activando suscripción...'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showActivationErrorDialogSafe(BuildContext context, SubscriptionResource subscription, String error) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<SubscriptionBloc>(),
        child: AlertDialog(
          icon: const Icon(
            Icons.warning,
            color: Colors.orange,
            size: 64,
          ),
          title: const Text('Suscripción Creada'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('La suscripción fue creada exitosamente, pero no se pudo activar automáticamente.'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.orange, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Error de activación:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error,
                      style: const TextStyle(fontSize: 12, color: Colors.orange),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Puedes intentar activarla manualmente desde la página de estado de suscripción.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (Navigator.canPop(dialogContext)) {
                  Navigator.of(dialogContext).pop();
                }
                if (mounted) {
                  _activateSubscription(context, subscription, subscription.paymentReference ?? '');
                }
              },
              child: const Text('Reintentar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (Navigator.canPop(dialogContext)) {
                  Navigator.of(dialogContext).pop();
                }
                if (mounted && Navigator.canPop(context)) {
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Continuar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialogSafe(BuildContext context, SubscriptionResource subscription) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 64,
        ),
        title: const Text('¡Suscripción Creada!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Plan', subscription.subscriptionPlanName),
            _buildInfoRow('Estado', _getStatusText(subscription.status)),
            _buildInfoRow('Días restantes', '${subscription.daysRemaining} días'),
            _buildInfoRow('Válido hasta', _formatDate(subscription.endDate)),
            if (subscription.paymentReference != null)
              _buildInfoRow('Ref. Pago', subscription.paymentReference!),
            const SizedBox(height: 16),
            if (subscription.status == SubscriptionStatus.PENDING_PAYMENT)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Suscripción pendiente de pago. Completa el pago para activarla.',
                        style: TextStyle(fontSize: 12, color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              // Cerrar el diálogo actual de forma segura
              if (Navigator.canPop(dialogContext)) {
                Navigator.of(dialogContext).pop();
              }
              
              // Navegar hacia atrás de forma segura
              if (mounted && Navigator.canPop(context)) {
                Navigator.of(context).pop();
              }
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.ACTIVE:
        return 'Activa ✓';
      case SubscriptionStatus.PENDING_PAYMENT:
        return 'Pendiente de Pago ⏳';
      case SubscriptionStatus.EXPIRED:
        return 'Expirada ❌';
      case SubscriptionStatus.CANCELLED:
        return 'Cancelada ❌';
      case SubscriptionStatus.SUSPENDED:
        return 'Suspendida ⚠️';
    }
  }

  void _showErrorDialogSafe(BuildContext context, String message) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (Navigator.canPop(dialogContext)) {
                Navigator.of(dialogContext).pop();
              }
            },
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