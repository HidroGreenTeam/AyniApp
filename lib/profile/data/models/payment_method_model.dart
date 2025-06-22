import 'package:equatable/equatable.dart';

enum PaymentMethodType {
  creditCard,
  debitCard,
  digitalWallet,
  bankTransfer,
}

enum CardBrand {
  visa,
  mastercard,
  americanExpress,
  discover,
  unknown,
}

class PaymentMethodModel extends Equatable {
  final String id;
  final String name;
  final PaymentMethodType type;
  final String? lastFourDigits;
  final CardBrand? cardBrand;
  final String? expiryMonth;
  final String? expiryYear;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PaymentMethodModel({
    required this.id,
    required this.name,
    required this.type,
    this.lastFourDigits,
    this.cardBrand,
    this.expiryMonth,
    this.expiryYear,
    this.isDefault = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: PaymentMethodType.values.firstWhere(
        (e) => e.toString() == 'PaymentMethodType.${json['type']}',
        orElse: () => PaymentMethodType.creditCard,
      ),
      lastFourDigits: json['lastFourDigits'] as String?,
      cardBrand: json['cardBrand'] != null
          ? CardBrand.values.firstWhere(
              (e) => e.toString() == 'CardBrand.${json['cardBrand']}',
              orElse: () => CardBrand.unknown,
            )
          : null,
      expiryMonth: json['expiryMonth'] as String?,
      expiryYear: json['expiryYear'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString().split('.').last,
      'lastFourDigits': lastFourDigits,
      'cardBrand': cardBrand?.toString().split('.').last,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  PaymentMethodModel copyWith({
    String? id,
    String? name,
    PaymentMethodType? type,
    String? lastFourDigits,
    CardBrand? cardBrand,
    String? expiryMonth,
    String? expiryYear,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentMethodModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      lastFourDigits: lastFourDigits ?? this.lastFourDigits,
      cardBrand: cardBrand ?? this.cardBrand,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get displayName {
    switch (type) {
      case PaymentMethodType.creditCard:
      case PaymentMethodType.debitCard:
        return lastFourDigits != null ? '•••• $lastFourDigits' : name;
      case PaymentMethodType.digitalWallet:
        return name;
      case PaymentMethodType.bankTransfer:
        return name;
    }
  }

  String get cardBrandName {
    switch (cardBrand) {
      case CardBrand.visa:
        return 'Visa';
      case CardBrand.mastercard:
        return 'Mastercard';
      case CardBrand.americanExpress:
        return 'American Express';
      case CardBrand.discover:
        return 'Discover';
      case CardBrand.unknown:
      case null:
        return 'Card';
    }
  }

  String get expiryDate {
    if (expiryMonth != null && expiryYear != null) {
      return '$expiryMonth/$expiryYear';
    }
    return '';
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        lastFourDigits,
        cardBrand,
        expiryMonth,
        expiryYear,
        isDefault,
        createdAt,
        updatedAt,
      ];
} 