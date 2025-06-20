import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_theme.dart';
import '../blocs/billing_bloc.dart';
import '../blocs/payment_methods_bloc.dart';
import '../../data/models/subscription_model.dart';
import '../../data/models/payment_method_model.dart';
import 'payment_methods_page.dart';

class BillingPage extends StatelessWidget {
  const BillingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => serviceLocator<BillingBloc>()..add(const BillingLoad()),
        ),
        BlocProvider(
          create: (_) => serviceLocator<PaymentMethodsBloc>()..add(const PaymentMethodsLoad()),
        ),
      ],
      child: const BillingView(),
    );
  }
}

class BillingView extends StatelessWidget {
  const BillingView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<BillingBloc, BillingState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == BillingStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'An error occurred'),
              backgroundColor: AppColors.error,
            ),
          );
        } else if (state.status == BillingStatus.loaded && 
                   state.currentSubscription != null &&
                   state.currentSubscription!.isActive) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Suscripción activada exitosamente!'),
              backgroundColor: AppColors.primaryGreen,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          title: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.star,
                  color: AppColors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Facturación y Suscripciones',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: BlocBuilder<BillingBloc, BillingState>(
          builder: (context, state) {
            if (state.status == BillingStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryGreen,
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current Subscription Section
                  if (state.currentSubscription != null)
                    _buildCurrentSubscriptionSection(context, state.currentSubscription!),

                  const SizedBox(height: 30),

                  // Subscription Plans Section
                  _buildSubscriptionPlansSection(context, state),

                  const SizedBox(height: 30),

                  // Billing History Section
                  _buildBillingHistorySection(context, state.billingHistory),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCurrentSubscriptionSection(BuildContext context, Subscription subscription) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryGreen, Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified,
                  color: AppColors.primaryGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subscription.plan.name,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Suscripción Activa',
                      style: TextStyle(
                        color: AppColors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '\$${subscription.amount.toStringAsFixed(2)}/${subscription.billingCycle == BillingCycle.monthly ? 'mes' : 'año'}',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Próximo cobro',
                      style: TextStyle(
                        color: AppColors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      _formatDate(subscription.nextBillingDate),
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => _showCancelSubscriptionDialog(context),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.white.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionPlansSection(BuildContext context, BillingState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Planes de Suscripción',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Elige el plan que mejor se adapte a tus necesidades',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 20),
        ...state.subscriptionPlans.map((plan) => _buildPlanCard(context, plan, state.currentSubscription)),
      ],
    );
  }

  Widget _buildPlanCard(BuildContext context, SubscriptionPlan plan, Subscription? currentSubscription) {
    final isCurrentPlan = currentSubscription?.plan.id == plan.id;
    final isFreePlan = plan.type == SubscriptionPlanType.free;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentPlan ? AppColors.primaryGreen : AppColors.border,
          width: isCurrentPlan ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (plan.isPopular)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: const Text(
                'MÁS POPULAR',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            plan.description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isCurrentPlan)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'ACTUAL',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      isFreePlan ? 'Gratis' : '\$${plan.monthlyPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    if (!isFreePlan) ...[
                      const Text(
                        '/mes',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'o \$${plan.yearlyPrice.toStringAsFixed(2)}/año',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                ...plan.features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.primaryGreen,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 20),
                if (!isCurrentPlan)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => _showSubscribeDialog(context, plan),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Suscribirse',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingHistorySection(BuildContext context, List<BillingHistoryItem> history) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Historial de Facturación',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        if (history.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.receipt_long,
                  size: 48,
                  color: AppColors.grey400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay historial de facturación',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
          )
        else
          ...history.map((item) => _buildBillingHistoryItem(context, item)),
      ],
    );
  }

  Widget _buildBillingHistoryItem(BuildContext context, BillingHistoryItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.receipt,
              color: AppColors.primaryGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.description,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  _formatDate(item.date),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${item.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(item.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(item.status),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSubscribeDialog(BuildContext context, SubscriptionPlan plan) {
    BillingCycle selectedCycle = BillingCycle.monthly;
    String? selectedPaymentMethodId;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Suscribirse a ${plan.name}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Billing Cycle Selection
                  const Text(
                    'Ciclo de facturación:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<BillingCycle>(
                          title: Text('Mensual (\$${plan.monthlyPrice.toStringAsFixed(2)})'),
                          value: BillingCycle.monthly,
                          groupValue: selectedCycle,
                          onChanged: (BillingCycle? value) {
                            setState(() {
                              selectedCycle = value!;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<BillingCycle>(
                          title: Text('Anual (\$${plan.yearlyPrice.toStringAsFixed(2)})'),
                          value: BillingCycle.yearly,
                          groupValue: selectedCycle,
                          onChanged: (BillingCycle? value) {
                            setState(() {
                              selectedCycle = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Payment Method Selection
                  BlocBuilder<PaymentMethodsBloc, PaymentMethodsState>(
                    builder: (context, paymentState) {
                      if (paymentState.status == PaymentMethodsStatus.loaded) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Método de pago:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (paymentState.paymentMethods.isEmpty)
                              const Text(
                                'No hay métodos de pago disponibles',
                                style: TextStyle(
                                  color: AppColors.error,
                                  fontSize: 14,
                                ),
                              )
                            else
                              ...paymentState.paymentMethods.map((method) => RadioListTile<String>(
                                title: Text(method.displayName),
                                value: method.id,
                                groupValue: selectedPaymentMethodId,
                                onChanged: (String? value) {
                                  setState(() {
                                    selectedPaymentMethodId = value;
                                  });
                                },
                              )),
                          ],
                        );
                      }
                      return const CircularProgressIndicator();
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: selectedPaymentMethodId != null
                      ? () {
                          Navigator.of(dialogContext).pop();
                          context.read<BillingBloc>().add(BillingSubscribeToPlan(
                            planId: plan.id,
                            billingCycle: selectedCycle,
                            paymentMethodId: selectedPaymentMethodId,
                          ));
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                  ),
                  child: const Text(
                    'Suscribirse',
                    style: TextStyle(color: AppColors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCancelSubscriptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Cancelar Suscripción'),
          content: const Text(
            '¿Estás seguro de que quieres cancelar tu suscripción? '
            'Podrás seguir usando los servicios hasta el final del período facturado.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Mantener'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<BillingBloc>().add(const BillingCancelSubscription());
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
              ),
              child: const Text('Cancelar Suscripción'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppColors.primaryGreen;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return AppColors.error;
      default:
        return AppColors.grey600;
    }
  }
} 