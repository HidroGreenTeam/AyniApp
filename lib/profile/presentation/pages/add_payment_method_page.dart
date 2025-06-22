import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';
import '../../../core/theme/app_theme.dart';
import '../blocs/payment_methods_bloc.dart';
import '../../data/models/payment_method_model.dart';

class AddPaymentMethodPage extends StatefulWidget {
  const AddPaymentMethodPage({super.key});

  @override
  State<AddPaymentMethodPage> createState() => _AddPaymentMethodPageState();
}

class _AddPaymentMethodPageState extends State<AddPaymentMethodPage> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();
  
  PaymentMethodType _selectedType = PaymentMethodType.creditCard;
  CardBrand? _detectedCardBrand;
  bool _isLoading = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentMethodsBloc, PaymentMethodsState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == PaymentMethodsStatus.loaded) {
          Navigator.of(context).pop();
        } else if (state.status == PaymentMethodsStatus.failure) {
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
                  Icons.add,
                  color: AppColors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Agregar Método de Pago',
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPaymentTypeSelector(),
                const SizedBox(height: 24),
                if (_selectedType == PaymentMethodType.creditCard || _selectedType == PaymentMethodType.debitCard) ...[
                  _buildCardNumberField(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildExpiryField()),
                      const SizedBox(width: 16),
                      Expanded(child: _buildCvvField()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildNameField(),
                ] else ...[
                  _buildNameField(),
                ],
                const SizedBox(height: 32),
                _buildAddButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de método de pago',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: PaymentMethodType.values.map((type) {
            final isSelected = _selectedType == type;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedType = type;
                  if (type != PaymentMethodType.creditCard && type != PaymentMethodType.debitCard) {
                    _detectedCardBrand = null;
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryGreen : AppColors.grey100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryGreen : AppColors.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getPaymentTypeIcon(type),
                      color: isSelected ? AppColors.white : AppColors.grey600,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getPaymentTypeName(type),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? AppColors.white : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  IconData _getPaymentTypeIcon(PaymentMethodType type) {
    switch (type) {
      case PaymentMethodType.creditCard:
        return Icons.credit_card;
      case PaymentMethodType.debitCard:
        return Icons.credit_card;
      case PaymentMethodType.digitalWallet:
        return Icons.account_balance_wallet;
      case PaymentMethodType.bankTransfer:
        return Icons.account_balance;
    }
  }

  String _getPaymentTypeName(PaymentMethodType type) {
    switch (type) {
      case PaymentMethodType.creditCard:
        return 'Tarjeta de Crédito';
      case PaymentMethodType.debitCard:
        return 'Tarjeta de Débito';
      case PaymentMethodType.digitalWallet:
        return 'Billetera Digital';
      case PaymentMethodType.bankTransfer:
        return 'Transferencia Bancaria';
    }
  }

  Widget _buildCardNumberField() {
    return TextFormField(
      controller: _cardNumberController,
      decoration: InputDecoration(
        labelText: 'Número de tarjeta',
        hintText: '1234 5678 9012 3456',
        prefixIcon: _detectedCardBrand != null
            ? Container(
                margin: const EdgeInsets.all(12),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _getCardBrandColor(_detectedCardBrand),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.credit_card,
                  color: AppColors.white,
                  size: 16,
                ),
              )
            : const Icon(Icons.credit_card, color: AppColors.grey400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(16),
        _CardNumberFormatter(),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa el número de tarjeta';
        }
        if (value.replaceAll(' ', '').length < 13) {
          return 'Número de tarjeta inválido';
        }
        return null;
      },
      onChanged: (value) {
        _detectCardBrand(value.replaceAll(' ', ''));
      },
    );
  }

  Widget _buildExpiryField() {
    return TextFormField(
      controller: _expiryController,
      decoration: InputDecoration(
        labelText: 'MM/AA',
        hintText: '12/25',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
        _ExpiryFormatter(),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Requerido';
        }
        if (value.length < 5) {
          return 'MM/AA';
        }
        return null;
      },
    );
  }

  Widget _buildCvvField() {
    return TextFormField(
      controller: _cvvController,
      decoration: InputDecoration(
        labelText: 'CVV',
        hintText: '123',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Requerido';
        }
        if (value.length < 3) {
          return 'CVV inválido';
        }
        return null;
      },
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: _selectedType == PaymentMethodType.creditCard || _selectedType == PaymentMethodType.debitCard
            ? 'Nombre en la tarjeta'
            : 'Nombre del método',
        hintText: _selectedType == PaymentMethodType.creditCard || _selectedType == PaymentMethodType.debitCard
            ? 'Juan Pérez'
            : 'Mi método de pago',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      textCapitalization: TextCapitalization.words,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa un nombre';
        }
        return null;
      },
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _addPaymentMethod,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: AppColors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Agregar Método de Pago',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
      ),
    );
  }

  void _detectCardBrand(String cardNumber) {
    if (cardNumber.isEmpty) {
      setState(() {
        _detectedCardBrand = null;
      });
      return;
    }

    CardBrand? brand;
    if (cardNumber.startsWith('4')) {
      brand = CardBrand.visa;
    } else if (cardNumber.startsWith('5')) {
      brand = CardBrand.mastercard;
    } else if (cardNumber.startsWith('3')) {
      brand = CardBrand.americanExpress;
    } else if (cardNumber.startsWith('6')) {
      brand = CardBrand.discover;
    }

    setState(() {
      _detectedCardBrand = brand;
    });
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

  void _addPaymentMethod() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final paymentMethod = PaymentMethodModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      type: _selectedType,
      lastFourDigits: _selectedType == PaymentMethodType.creditCard || _selectedType == PaymentMethodType.debitCard
          ? _cardNumberController.text.replaceAll(' ', '').substring(max(0, _cardNumberController.text.replaceAll(' ', '').length - 4))
          : null,
      cardBrand: _detectedCardBrand,
      expiryMonth: _selectedType == PaymentMethodType.creditCard || _selectedType == PaymentMethodType.debitCard
          ? _expiryController.text.split('/').first
          : null,
      expiryYear: _selectedType == PaymentMethodType.creditCard || _selectedType == PaymentMethodType.debitCard
          ? _expiryController.text.split('/').last
          : null,
      createdAt: DateTime.now(),
    );

    context.read<PaymentMethodsBloc>().add(PaymentMethodAdd(paymentMethod));
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final text = newValue.text;
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i == 2 && text.length > 2) {
        buffer.write('/');
      }
      buffer.write(text[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
} 