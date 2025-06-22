import 'package:equatable/equatable.dart';

enum SubscriptionPlanType {
  free,
  basic,
  premium,
  pro,
}

enum BillingCycle {
  monthly,
  yearly,
}

enum SubscriptionStatus {
  active,
  inactive,
  cancelled,
  expired,
  pending,
}

class SubscriptionPlan extends Equatable {
  final String id;
  final String name;
  final String description;
  final SubscriptionPlanType type;
  final double monthlyPrice;
  final double yearlyPrice;
  final List<String> features;
  final bool isPopular;
  final bool isCurrent;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.features,
    this.isPopular = false,
    this.isCurrent = false,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: SubscriptionPlanType.values.firstWhere(
        (e) => e.toString() == 'SubscriptionPlanType.${json['type']}',
        orElse: () => SubscriptionPlanType.free,
      ),
      monthlyPrice: (json['monthlyPrice'] as num).toDouble(),
      yearlyPrice: (json['yearlyPrice'] as num).toDouble(),
      features: List<String>.from(json['features'] ?? []),
      isPopular: json['isPopular'] as bool? ?? false,
      isCurrent: json['isCurrent'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.toString().split('.').last,
      'monthlyPrice': monthlyPrice,
      'yearlyPrice': yearlyPrice,
      'features': features,
      'isPopular': isPopular,
      'isCurrent': isCurrent,
    };
  }

  SubscriptionPlan copyWith({
    String? id,
    String? name,
    String? description,
    SubscriptionPlanType? type,
    double? monthlyPrice,
    double? yearlyPrice,
    List<String>? features,
    bool? isPopular,
    bool? isCurrent,
  }) {
    return SubscriptionPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      monthlyPrice: monthlyPrice ?? this.monthlyPrice,
      yearlyPrice: yearlyPrice ?? this.yearlyPrice,
      features: features ?? this.features,
      isPopular: isPopular ?? this.isPopular,
      isCurrent: isCurrent ?? this.isCurrent,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        type,
        monthlyPrice,
        yearlyPrice,
        features,
        isPopular,
        isCurrent,
      ];
}

class Subscription extends Equatable {
  final String id;
  final String userId;
  final SubscriptionPlan plan;
  final SubscriptionStatus status;
  final BillingCycle billingCycle;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? nextBillingDate;
  final double amount;
  final String? paymentMethodId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Subscription({
    required this.id,
    required this.userId,
    required this.plan,
    required this.status,
    required this.billingCycle,
    required this.startDate,
    this.endDate,
    this.nextBillingDate,
    required this.amount,
    this.paymentMethodId,
    required this.createdAt,
    this.updatedAt,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as String,
      userId: json['userId'] as String,
      plan: SubscriptionPlan.fromJson(json['plan'] as Map<String, dynamic>),
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.toString() == 'SubscriptionStatus.${json['status']}',
        orElse: () => SubscriptionStatus.inactive,
      ),
      billingCycle: BillingCycle.values.firstWhere(
        (e) => e.toString() == 'BillingCycle.${json['billingCycle']}',
        orElse: () => BillingCycle.monthly,
      ),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      nextBillingDate: json['nextBillingDate'] != null
          ? DateTime.parse(json['nextBillingDate'] as String)
          : null,
      amount: (json['amount'] as num).toDouble(),
      paymentMethodId: json['paymentMethodId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'plan': plan.toJson(),
      'status': status.toString().split('.').last,
      'billingCycle': billingCycle.toString().split('.').last,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'nextBillingDate': nextBillingDate?.toIso8601String(),
      'amount': amount,
      'paymentMethodId': paymentMethodId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Subscription copyWith({
    String? id,
    String? userId,
    SubscriptionPlan? plan,
    SubscriptionStatus? status,
    BillingCycle? billingCycle,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? nextBillingDate,
    double? amount,
    String? paymentMethodId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Subscription(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      plan: plan ?? this.plan,
      status: status ?? this.status,
      billingCycle: billingCycle ?? this.billingCycle,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      nextBillingDate: nextBillingDate ?? this.nextBillingDate,
      amount: amount ?? this.amount,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isActive => status == SubscriptionStatus.active;
  bool get isExpired => status == SubscriptionStatus.expired;
  bool get isCancelled => status == SubscriptionStatus.cancelled;

  @override
  List<Object?> get props => [
        id,
        userId,
        plan,
        status,
        billingCycle,
        startDate,
        endDate,
        nextBillingDate,
        amount,
        paymentMethodId,
        createdAt,
        updatedAt,
      ];
}

class BillingHistoryItem extends Equatable {
  final String id;
  final String subscriptionId;
  final double amount;
  final String description;
  final DateTime date;
  final String status;
  final String? invoiceUrl;

  const BillingHistoryItem({
    required this.id,
    required this.subscriptionId,
    required this.amount,
    required this.description,
    required this.date,
    required this.status,
    this.invoiceUrl,
  });

  factory BillingHistoryItem.fromJson(Map<String, dynamic> json) {
    return BillingHistoryItem(
      id: json['id'] as String,
      subscriptionId: json['subscriptionId'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String,
      invoiceUrl: json['invoiceUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subscriptionId': subscriptionId,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'status': status,
      'invoiceUrl': invoiceUrl,
    };
  }

  @override
  List<Object?> get props => [
        id,
        subscriptionId,
        amount,
        description,
        date,
        status,
        invoiceUrl,
      ];
} 