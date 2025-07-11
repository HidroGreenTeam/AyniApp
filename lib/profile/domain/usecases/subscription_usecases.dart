import '../../data/models/subscription_api_models.dart';
import '../../data/repositories/subscription_repository.dart';

abstract class SubscriptionUseCases {
  Future<List<SubscriptionPlanResource>> getAllSubscriptionPlans();
  Future<SubscriptionResource?> getSubscriptionById(int subscriptionId);
  Future<SubscriptionResource?> getSubscriptionByUserId(int userId);
  Future<SubscriptionResource> createSubscription(CreateSubscriptionResource request);
  Future<Map<String, dynamic>> activateSubscription(int subscriptionId, ActivateSubscriptionResource request);
  Future<SubscriptionResource> renewSubscription(int subscriptionId, SubscriptionType newSubscriptionType, String? paymentReference);
  Future<SubscriptionResource> cancelSubscription(int subscriptionId, String reason);
  Future<Map<String, dynamic>> testNotification(TestNotificationRequest request);
  Future<Map<String, dynamic>> testUserService(int userId);
  Future<Map<String, dynamic>> healthCheck();
}

class SubscriptionUseCasesImpl implements SubscriptionUseCases {
  final SubscriptionRepository _repository;

  SubscriptionUseCasesImpl(this._repository);

  @override
  Future<List<SubscriptionPlanResource>> getAllSubscriptionPlans() async {
    try {
      final plans = await _repository.getAllSubscriptionPlans();
      
      // Filtrar solo planes activos
      return plans.where((plan) => plan.isActive).toList();
    } catch (e) {
      throw Exception('Error getting subscription plans: $e');
    }
  }

  @override
  Future<SubscriptionResource?> getSubscriptionById(int subscriptionId) async {
    try {
      return await _repository.getSubscriptionById(subscriptionId);
    } catch (e) {
      throw Exception('Error getting subscription by ID: $e');
    }
  }

  @override
  Future<SubscriptionResource?> getSubscriptionByUserId(int userId) async {
    try {
      return await _repository.getSubscriptionByUserId(userId);
    } catch (e) {
      throw Exception('Error getting subscription by user ID: $e');
    }
  }

  @override
  Future<SubscriptionResource> createSubscription(CreateSubscriptionResource request) async {
    try {
      // Lógica de negocio adicional
      if (request.subscriptionType == SubscriptionType.FREE) {
        // Para suscripciones gratuitas, siempre autoRenew debe ser false
        final updatedRequest = CreateSubscriptionResource(
          userId: request.userId,
          subscriptionType: request.subscriptionType,
          autoRenew: false,
          paymentReference: request.paymentReference,
        );
        return await _repository.createSubscription(updatedRequest);
      }

      return await _repository.createSubscription(request);
    } catch (e) {
      throw Exception('Error creating subscription: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> activateSubscription(int subscriptionId, ActivateSubscriptionResource request) async {
    try {
      return await _repository.activateSubscription(subscriptionId, request);
    } catch (e) {
      throw Exception('Error activating subscription: $e');
    }
  }

  @override
  Future<SubscriptionResource> renewSubscription(int subscriptionId, SubscriptionType newSubscriptionType, String? paymentReference) async {
    try {
      // Lógica de negocio adicional
      if (newSubscriptionType == SubscriptionType.FREE && paymentReference != null) {
        throw Exception('Payment reference should not be provided for free subscriptions');
      }

      if (newSubscriptionType != SubscriptionType.FREE && paymentReference == null) {
        throw Exception('Payment reference is required for paid subscriptions');
      }

      return await _repository.renewSubscription(subscriptionId, newSubscriptionType, paymentReference);
    } catch (e) {
      throw Exception('Error renewing subscription: $e');
    }
  }

  @override
  Future<SubscriptionResource> cancelSubscription(int subscriptionId, String reason) async {
    try {
      // Lógica de negocio adicional
      final subscription = await _repository.getSubscriptionById(subscriptionId);
      if (subscription == null) {
        throw Exception('Subscription not found');
      }

      if (subscription.status == SubscriptionStatus.CANCELLED) {
        throw Exception('Subscription is already cancelled');
      }

      if (subscription.status == SubscriptionStatus.EXPIRED) {
        throw Exception('Cannot cancel an expired subscription');
      }

      return await _repository.cancelSubscription(subscriptionId, reason);
    } catch (e) {
      throw Exception('Error cancelling subscription: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> testNotification(TestNotificationRequest request) async {
    try {
      return await _repository.testNotification(request);
    } catch (e) {
      throw Exception('Error testing notification: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> testUserService(int userId) async {
    try {
      return await _repository.testUserService(userId);
    } catch (e) {
      throw Exception('Error testing user service: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> healthCheck() async {
    try {
      return await _repository.healthCheck();
    } catch (e) {
      throw Exception('Error during health check: $e');
    }
  }
} 