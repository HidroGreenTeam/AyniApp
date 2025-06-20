import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_theme.dart';
import '../blocs/payment_methods_bloc.dart';
import '../../data/models/payment_method_model.dart';
import 'add_payment_method_page.dart';

class PaymentMethodsPage extends StatelessWidget {
  const PaymentMethodsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<PaymentMethodsBloc>()..add(const PaymentMethodsLoad()),
      child: const PaymentMethodsView(),
    );
  }
}

class PaymentMethodsView extends StatelessWidget {
  const PaymentMethodsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentMethodsBloc, PaymentMethodsState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == PaymentMethodsStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'An error occurred'),
              backgroundColor: AppColors.error,
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
                  Icons.credit_card,
                  color: AppColors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Métodos de Pago',
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
        body: BlocBuilder<PaymentMethodsBloc, PaymentMethodsState>(
          builder: (context, state) {
            if (state.status == PaymentMethodsStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryGreen,
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: state.paymentMethods.isEmpty
                      ? _buildEmptyState()
                      : _buildPaymentMethodsList(context, state.paymentMethods),
                ),
                _buildAddButton(context),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.grey100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.credit_card_outlined,
              size: 40,
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No tienes métodos de pago',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Agrega un método de pago para comenzar',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsList(BuildContext context, List<PaymentMethodModel> paymentMethods) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: paymentMethods.length,
      itemBuilder: (context, index) {
        final paymentMethod = paymentMethods[index];
        return _buildPaymentMethodCard(context, paymentMethod);
      },
    );
  }

  Widget _buildPaymentMethodCard(BuildContext context, PaymentMethodModel paymentMethod) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: paymentMethod.isDefault ? AppColors.primaryGreen : AppColors.border,
          width: paymentMethod.isDefault ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showPaymentMethodOptions(context, paymentMethod),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildPaymentMethodIcon(paymentMethod),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            paymentMethod.displayName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (paymentMethod.isDefault)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Predeterminado',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getPaymentMethodSubtitle(paymentMethod),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.more_vert,
                color: AppColors.grey400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodIcon(PaymentMethodModel paymentMethod) {
    IconData iconData;
    Color iconColor;

    switch (paymentMethod.type) {
      case PaymentMethodType.creditCard:
      case PaymentMethodType.debitCard:
        iconData = Icons.credit_card;
        iconColor = _getCardBrandColor(paymentMethod.cardBrand);
        break;
      case PaymentMethodType.digitalWallet:
        iconData = Icons.account_balance_wallet;
        iconColor = AppColors.primaryGreen;
        break;
      case PaymentMethodType.bankTransfer:
        iconData = Icons.account_balance;
        iconColor = AppColors.primaryGreen;
        break;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 24,
      ),
    );
  }

  Color _getCardBrandColor(CardBrand? cardBrand) {
    switch (cardBrand) {
      case CardBrand.visa:
        return const Color(0xFF1A1F71);
      case CardBrand.mastercard:
        return const Color(0xFFEB001B);
      case CardBrand.americanExpress:
        return const Color(0xFF006FCF);
      case CardBrand.discover:
        return const Color(0xFFFF6000);
      case CardBrand.unknown:
      case null:
        return AppColors.grey600;
    }
  }

  String _getPaymentMethodSubtitle(PaymentMethodModel paymentMethod) {
    switch (paymentMethod.type) {
      case PaymentMethodType.creditCard:
        return '${paymentMethod.cardBrandName} • Expira ${paymentMethod.expiryDate}';
      case PaymentMethodType.debitCard:
        return '${paymentMethod.cardBrandName} • Expira ${paymentMethod.expiryDate}';
      case PaymentMethodType.digitalWallet:
        return 'Billetera digital';
      case PaymentMethodType.bankTransfer:
        return 'Transferencia bancaria';
    }
  }

  Widget _buildAddButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: () => _navigateToAddPaymentMethod(context),
          icon: const Icon(Icons.add, color: AppColors.white),
          label: const Text(
            'Agregar Método de Pago',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToAddPaymentMethod(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddPaymentMethodPage(),
      ),
    );
  }

  void _showPaymentMethodOptions(BuildContext context, PaymentMethodModel paymentMethod) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            if (!paymentMethod.isDefault)
              ListTile(
                leading: const Icon(Icons.star, color: AppColors.primaryGreen),
                title: const Text('Establecer como predeterminado'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<PaymentMethodsBloc>().add(
                    PaymentMethodSetDefault(paymentMethod.id),
                  );
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title: const Text(
                'Eliminar',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, paymentMethod);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, PaymentMethodModel paymentMethod) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar método de pago'),
          content: Text(
            '¿Estás seguro de que quieres eliminar ${paymentMethod.displayName}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<PaymentMethodsBloc>().add(
                  PaymentMethodDelete(paymentMethod.id),
                );
              },
              child: const Text(
                'Eliminar',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }
} 