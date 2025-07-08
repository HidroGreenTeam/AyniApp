import '../datasources/subscription_data_source.dart';
import '../models/subscription_api_models.dart';

abstract class SubscriptionRepository {
  Future<List<SubscriptionPlanResource>> getAllSubscriptionPlans();
  Future<SubscriptionResource?> getSubscriptionById(int subscriptionId);
  Future<SubscriptionResource?> getSubscriptionByUserId(int userId);
  Future<SubscriptionResource> createSubscription(CreateSubscriptionResource request);
  Future<SubscriptionResource> renewSubscription(int subscriptionId, SubscriptionType newSubscriptionType, String? paymentReference);
  Future<SubscriptionResource> cancelSubscription(int subscriptionId, String reason);
  Future<Map<String, dynamic>> testNotification(TestNotificationRequest request);
  Future<Map<String, dynamic>> testUserService(int userId);
  Future<Map<String, dynamic>> healthCheck();
}

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionDataSource _dataSource;

  SubscriptionRepositoryImpl(this._dataSource);

  @override
  Future<List<SubscriptionPlanResource>> getAllSubscriptionPlans() async {
    try {
      return await _dataSource.getAllSubscriptionPlans();
    } catch (e) {
      throw Exception('Error getting subscription plans: $e');
    }
  }

  @override
  Future<SubscriptionResource?> getSubscriptionById(int subscriptionId) async {
    try {
      return await _dataSource.getSubscriptionById(subscriptionId);
    } catch (e) {
      throw Exception('Error getting subscription by ID: $e');
    }
  }

  @override
  Future<SubscriptionResource?> getSubscriptionByUserId(int userId) async {
    try {
      return await _dataSource.getSubscriptionByUserId(userId);
    } catch (e) {
      throw Exception('Error getting subscription by user ID: $e');
    }
  }

  @override
  Future<SubscriptionResource> createSubscription(CreateSubscriptionResource request) async {
    try {
      // Validaciones básicas
      if (request.userId <= 0) {
        throw Exception('User ID must be valid');
      }

      return await _dataSource.createSubscription(request);
    } catch (e) {
      throw Exception('Error creating subscription: $e');
    }
  }

  @override
  Future<SubscriptionResource> renewSubscription(int subscriptionId, SubscriptionType newSubscriptionType, String? paymentReference) async {
    try {
      // Validaciones básicas
      if (subscriptionId <= 0) {
        throw Exception('Subscription ID must be valid');
      }

      return await _dataSource.renewSubscription(subscriptionId, newSubscriptionType, paymentReference);
    } catch (e) {
      throw Exception('Error renewing subscription: $e');
    }
  }

  @override
  Future<SubscriptionResource> cancelSubscription(int subscriptionId, String reason) async {
    try {
      // Validaciones básicas
      if (subscriptionId <= 0) {
        throw Exception('Subscription ID must be valid');
      }

      if (reason.isEmpty) {
        throw Exception('Cancellation reason is required');
      }

      return await _dataSource.cancelSubscription(subscriptionId, reason);
    } catch (e) {
      throw Exception('Error cancelling subscription: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> testNotification(TestNotificationRequest request) async {
    try {
      // Validaciones básicas
      if (request.userId <= 0) {
        throw Exception('User ID must be valid');
      }

      if (request.email.isEmpty || !request.email.contains('@')) {
        throw Exception('Valid email is required');
      }

      if (request.notificationType.isEmpty) {
        throw Exception('Notification type is required');
      }

      return await _dataSource.testNotification(request);
    } catch (e) {
      throw Exception('Error testing notification: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> testUserService(int userId) async {
    try {
      // Validaciones básicas
      if (userId <= 0) {
        throw Exception('User ID must be valid');
      }

      return await _dataSource.testUserService(userId);
    } catch (e) {
      throw Exception('Error testing user service: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> healthCheck() async {
    try {
      return await _dataSource.healthCheck();
    } catch (e) {
      throw Exception('Error during health check: $e');
    }
  }
} 