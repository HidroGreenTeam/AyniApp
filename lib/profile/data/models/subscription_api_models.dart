import 'package:equatable/equatable.dart';

enum SubscriptionType {
  FREE,
  BASIC,
  PREMIUM,
  ENTERPRISE,
}

enum SubscriptionStatus {
  ACTIVE,
  EXPIRED,
  CANCELLED,
  SUSPENDED,
  PENDING_PAYMENT,
}

class SubscriptionResource extends Equatable {
  final int id;
  final int userId;
  final SubscriptionType subscriptionType;
  final String subscriptionPlanName;
  final SubscriptionStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final bool autoRenew;
  final String? paymentReference;
  final int daysRemaining;
  final bool isActive;
  final bool isExpired;
  final String? cancellationReason;
  final DateTime? cancelledAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SubscriptionResource({
    required this.id,
    required this.userId,
    required this.subscriptionType,
    required this.subscriptionPlanName,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.autoRenew,
    this.paymentReference,
    required this.daysRemaining,
    required this.isActive,
    required this.isExpired,
    this.cancellationReason,
    this.cancelledAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubscriptionResource.fromJson(Map<String, dynamic> json) {
    return SubscriptionResource(
      id: json['id'] as int,
      userId: json['userId'] as int,
      subscriptionType: SubscriptionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['subscriptionType'],
        orElse: () => SubscriptionType.FREE,
      ),
      subscriptionPlanName: json['subscriptionPlanName'] as String,
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => SubscriptionStatus.EXPIRED,
      ),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      autoRenew: json['autoRenew'] as bool,
      paymentReference: json['paymentReference'] as String?,
      daysRemaining: json['daysRemaining'] as int,
      isActive: json['isActive'] as bool,
      isExpired: json['isExpired'] as bool,
      cancellationReason: json['cancellationReason'] as String?,
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.parse(json['cancelledAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'subscriptionType': subscriptionType.toString().split('.').last,
      'subscriptionPlanName': subscriptionPlanName,
      'status': status.toString().split('.').last,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'autoRenew': autoRenew,
      'paymentReference': paymentReference,
      'daysRemaining': daysRemaining,
      'isActive': isActive,
      'isExpired': isExpired,
      'cancellationReason': cancellationReason,
      'cancelledAt': cancelledAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        subscriptionType,
        subscriptionPlanName,
        status,
        startDate,
        endDate,
        autoRenew,
        paymentReference,
        daysRemaining,
        isActive,
        isExpired,
        cancellationReason,
        cancelledAt,
        createdAt,
        updatedAt,
      ];
}

class CreateSubscriptionResource extends Equatable {
  final int userId;
  final SubscriptionType subscriptionType;
  final bool autoRenew;
  final String? paymentReference;

  const CreateSubscriptionResource({
    required this.userId,
    required this.subscriptionType,
    required this.autoRenew,
    this.paymentReference,
  });

  factory CreateSubscriptionResource.fromJson(Map<String, dynamic> json) {
    return CreateSubscriptionResource(
      userId: json['userId'] as int,
      subscriptionType: SubscriptionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['subscriptionType'],
        orElse: () => SubscriptionType.FREE,
      ),
      autoRenew: json['autoRenew'] as bool,
      paymentReference: json['paymentReference'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'subscriptionType': subscriptionType.toString().split('.').last,
      'autoRenew': autoRenew,
      'paymentReference': paymentReference,
    };
  }

  @override
  List<Object?> get props => [
        userId,
        subscriptionType,
        autoRenew,
        paymentReference,
      ];
}

class SubscriptionPlanResource extends Equatable {
  final int id;
  final SubscriptionType planType;
  final String name;
  final String description;
  final double price;
  final int durationDays;
  final int maxCrops;
  final int maxReports;
  final bool hasPrioritySupport;
  final bool hasAdvancedAnalytics;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SubscriptionPlanResource({
    required this.id,
    required this.planType,
    required this.name,
    required this.description,
    required this.price,
    required this.durationDays,
    required this.maxCrops,
    required this.maxReports,
    required this.hasPrioritySupport,
    required this.hasAdvancedAnalytics,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubscriptionPlanResource.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanResource(
      id: json['id'] as int,
      planType: SubscriptionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['planType'],
        orElse: () => SubscriptionType.FREE,
      ),
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      durationDays: json['durationDays'] as int,
      maxCrops: json['maxCrops'] as int,
      maxReports: json['maxReports'] as int,
      hasPrioritySupport: json['hasPrioritySupport'] as bool,
      hasAdvancedAnalytics: json['hasAdvancedAnalytics'] as bool,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'planType': planType.toString().split('.').last,
      'name': name,
      'description': description,
      'price': price,
      'durationDays': durationDays,
      'maxCrops': maxCrops,
      'maxReports': maxReports,
      'hasPrioritySupport': hasPrioritySupport,
      'hasAdvancedAnalytics': hasAdvancedAnalytics,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        planType,
        name,
        description,
        price,
        durationDays,
        maxCrops,
        maxReports,
        hasPrioritySupport,
        hasAdvancedAnalytics,
        isActive,
        createdAt,
        updatedAt,
      ];
}

class TestNotificationRequest extends Equatable {
  final int userId;
  final String email;
  final String notificationType;

  const TestNotificationRequest({
    required this.userId,
    required this.email,
    required this.notificationType,
  });

  factory TestNotificationRequest.fromJson(Map<String, dynamic> json) {
    return TestNotificationRequest(
      userId: json['userId'] as int,
      email: json['email'] as String,
      notificationType: json['notificationType'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'notificationType': notificationType,
    };
  }

  @override
  List<Object?> get props => [
        userId,
        email,
        notificationType,
      ];
} 