import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/subscription_api_models.dart';
import '../blocs/subscription_bloc.dart';
import '../../../auth/domain/usecases/get_current_user_use_case.dart';
import '../../../core/di/service_locator.dart';
import '../../domain/usecases/subscription_usecases.dart';

class SubscriptionStatusPage extends StatelessWidget {
  const SubscriptionStatusPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Obtener el usuario autenticado actual
    final getCurrentUserUseCase = serviceLocator<GetCurrentUserUseCase>();
    final currentUser = getCurrentUserUseCase();
    
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mi Suscripción')),
        body: const Center(
          child: Text('Error: Usuario no autenticado'),
        ),
      );
    }
    
    final userId = int.parse(currentUser.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Suscripción'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<SubscriptionBloc>().add(LoadSubscriptionByUserId(userId));
            },
          ),
        ],
      ),
      body: BlocProvider(
        create: (context) => serviceLocator<SubscriptionBloc>()
          ..add(LoadSubscriptionByUserId(userId)),
        child: BlocBuilder<SubscriptionBloc, SubscriptionState>(
          builder: (context, state) {
            if (state is SubscriptionLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is SubscriptionLoaded) {
              return _buildSubscriptionDetails(context, state.subscription);
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
                        context.read<SubscriptionBloc>().add(LoadSubscriptionByUserId(userId));
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.subscriptions_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No tienes una suscripción activa',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Suscríbete a un plan para acceder a todas las funcionalidades',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/subscription-plans');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                      child: const Text('Ver Planes'),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildSubscriptionDetails(BuildContext context, SubscriptionResource subscription) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCard(subscription),
          const SizedBox(height: 16),
          _buildPlanDetailsCard(subscription),
          const SizedBox(height: 16),
          _buildDatesCard(subscription),
          const SizedBox(height: 16),
          _buildActionsCard(context, subscription),
        ],
      ),
    );
  }

  Widget _buildStatusCard(SubscriptionResource subscription) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getStatusIcon(subscription.status),
                  color: _getStatusColor(subscription.status),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Estado de Suscripción',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(subscription.status),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getStatusText(subscription.status),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Plan: ${subscription.subscriptionPlanName}',
              style: const TextStyle(fontSize: 16),
            ),
            if (subscription.daysRemaining > 0)
              Text(
                'Días restantes: ${subscription.daysRemaining}',
                style: const TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanDetailsCard(SubscriptionResource subscription) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detalles del Plan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Tipo', _getPlanTypeText(subscription.subscriptionType)),
            _buildDetailRow('Renovación automática', subscription.autoRenew ? 'Sí' : 'No'),
            if (subscription.paymentReference != null)
              _buildDetailRow('Referencia de pago', subscription.paymentReference!),
          ],
        ),
      ),
    );
  }

  Widget _buildDatesCard(SubscriptionResource subscription) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fechas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Fecha de inicio', _formatDate(subscription.startDate)),
            _buildDetailRow('Fecha de fin', _formatDate(subscription.endDate)),
            _buildDetailRow('Creada', _formatDate(subscription.createdAt)),
            _buildDetailRow('Actualizada', _formatDate(subscription.updatedAt)),
            if (subscription.cancelledAt != null)
              _buildDetailRow('Cancelada', _formatDate(subscription.cancelledAt!)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard(BuildContext context, SubscriptionResource subscription) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Acciones',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (subscription.status == SubscriptionStatus.ACTIVE)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showCancelDialog(context, subscription),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Cancelar Suscripción'),
                ),
              ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/subscription-plans');
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Cambiar Plan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.ACTIVE:
        return Icons.check_circle;
      case SubscriptionStatus.EXPIRED:
        return Icons.schedule;
      case SubscriptionStatus.CANCELLED:
        return Icons.cancel;
      case SubscriptionStatus.SUSPENDED:
        return Icons.pause_circle;
      case SubscriptionStatus.PENDING_PAYMENT:
        return Icons.payment;
    }
  }

  Color _getStatusColor(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.ACTIVE:
        return Colors.green;
      case SubscriptionStatus.EXPIRED:
        return Colors.orange;
      case SubscriptionStatus.CANCELLED:
        return Colors.red;
      case SubscriptionStatus.SUSPENDED:
        return Colors.yellow;
      case SubscriptionStatus.PENDING_PAYMENT:
        return Colors.blue;
    }
  }

  String _getStatusText(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.ACTIVE:
        return 'ACTIVA';
      case SubscriptionStatus.EXPIRED:
        return 'EXPIRADA';
      case SubscriptionStatus.CANCELLED:
        return 'CANCELADA';
      case SubscriptionStatus.SUSPENDED:
        return 'SUSPENDIDA';
      case SubscriptionStatus.PENDING_PAYMENT:
        return 'PENDIENTE DE PAGO';
    }
  }

  String _getPlanTypeText(SubscriptionType planType) {
    switch (planType) {
      case SubscriptionType.FREE:
        return 'Gratis';
      case SubscriptionType.BASIC:
        return 'Básico';
      case SubscriptionType.PREMIUM:
        return 'Premium';
      case SubscriptionType.ENTERPRISE:
        return 'Empresarial';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showCancelDialog(BuildContext context, SubscriptionResource subscription) {
    // Validar que la suscripción se puede cancelar
    if (subscription.status != SubscriptionStatus.ACTIVE) {
      _showErrorDialog(context, 'Solo se pueden cancelar suscripciones activas. Estado actual: ${_getStatusText(subscription.status)}');
      return;
    }
    
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancelar Suscripción'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '¿Estás seguro de que quieres cancelar tu suscripción?',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Motivo de cancelación',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor ingresa un motivo de cancelación'),
                  ),
                );
                return;
              }
              Navigator.of(dialogContext).pop();
              _cancelSubscription(context, subscription.id, reasonController.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _cancelSubscription(BuildContext context, int subscriptionId, String reason) async {
    print('Intentando cancelar suscripción ID: $subscriptionId con motivo: $reason');
    
    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Cancelando suscripción...'),
          ],
        ),
      ),
    );

    // Obtener userId para usar en callbacks
    final getCurrentUserUseCase = serviceLocator<GetCurrentUserUseCase>();
    final currentUser = getCurrentUserUseCase();
    final userId = currentUser != null ? int.parse(currentUser.id) : 0;

    try {
      // Cancelar suscripción directamente con el use case
      final subscriptionUseCases = serviceLocator<SubscriptionUseCases>();
      print('Llamando a cancelSubscription...');
      final cancelledSubscription = await subscriptionUseCases.cancelSubscription(subscriptionId, reason);
      print('Suscripción cancelada exitosamente: ${cancelledSubscription.id}');
      
      if (context.mounted) {
        Navigator.of(context).pop(); // Cerrar loading
        _showCancellationSuccessDialog(context, cancelledSubscription, userId);
      }
    } catch (e) {
      print('Error al cancelar suscripción: $e');
      if (context.mounted) {
        Navigator.of(context).pop(); // Cerrar loading
        _showErrorDialog(context, e.toString());
      }
    }
  }

  void _showCancellationSuccessDialog(BuildContext context, SubscriptionResource subscription, int userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Suscripción Cancelada'),
        icon: const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 48,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tu suscripción ha sido cancelada exitosamente.'),
            const SizedBox(height: 8),
            if (subscription.cancellationReason != null)
              Text('Motivo: ${subscription.cancellationReason}'),
            const SizedBox(height: 8),
            Text('Estado: ${_getStatusText(subscription.status)}'),
            const SizedBox(height: 8),
            const Text(
              'La información se actualizará automáticamente.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Recargar la página
              context.read<SubscriptionBloc>().add(LoadSubscriptionByUserId(userId));
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
} 