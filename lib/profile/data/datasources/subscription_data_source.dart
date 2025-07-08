import 'dart:convert';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/network_client.dart';
import '../models/subscription_api_models.dart';

abstract class SubscriptionDataSource {
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

class SubscriptionDataSourceImpl implements SubscriptionDataSource {
  final NetworkClient _networkClient;

  SubscriptionDataSourceImpl(this._networkClient);

  @override
  Future<List<SubscriptionPlanResource>> getAllSubscriptionPlans() async {
    try {
      final response = await _networkClient.request<List<SubscriptionPlanResource>>(
        endpoint: '${ApiConstants.subscriptionServiceBaseUrl}${ApiConstants.subscriptionPlans}',
        method: RequestMethod.get,
        fromJson: (json) => (json as List)
            .map((item) => SubscriptionPlanResource.fromJson(item))
            .toList(),
        requiresAuth: false,
      );

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception('Failed to load subscription plans: ${response.error}');
      }
    } catch (e) {
      throw Exception('Error getting subscription plans: $e');
    }
  }

  @override
  Future<SubscriptionResource?> getSubscriptionById(int subscriptionId) async {
    try {
      final response = await _networkClient.request<SubscriptionResource>(
        endpoint: '${ApiConstants.subscriptionServiceBaseUrl}${ApiConstants.subscriptions}/$subscriptionId',
        method: RequestMethod.get,
        fromJson: (json) => SubscriptionResource.fromJson(json),
        requiresAuth: false,
      );

      if (response.success && response.data != null) {
        return response.data!;
      } else if (response.error?.contains('404') == true) {
        return null;
      } else {
        throw Exception('Failed to get subscription: ${response.error}');
      }
    } catch (e) {
      throw Exception('Error getting subscription by ID: $e');
    }
  }

  @override
  Future<SubscriptionResource?> getSubscriptionByUserId(int userId) async {
    try {
      final response = await _networkClient.request<SubscriptionResource>(
        endpoint: '${ApiConstants.subscriptionServiceBaseUrl}${ApiConstants.subscriptions}/user/$userId',
        method: RequestMethod.get,
        fromJson: (json) => SubscriptionResource.fromJson(json),
        requiresAuth: false,
      );

      if (response.success && response.data != null) {
        return response.data!;
      } else if (response.error?.contains('404') == true) {
        return null;
      } else {
        throw Exception('Failed to get subscription by user ID: ${response.error}');
      }
    } catch (e) {
      throw Exception('Error getting subscription by user ID: $e');
    }
  }

  @override
  Future<SubscriptionResource> createSubscription(CreateSubscriptionResource request) async {
    try {
      final response = await _networkClient.request<SubscriptionResource>(
        endpoint: '${ApiConstants.subscriptionServiceBaseUrl}${ApiConstants.subscriptions}',
        method: RequestMethod.post,
        data: request.toJson(),
        fromJson: (json) => SubscriptionResource.fromJson(json),
        requiresAuth: false,
      );

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception('Failed to create subscription: ${response.error}');
      }
    } catch (e) {
      throw Exception('Error creating subscription: $e');
    }
  }

  @override
  Future<SubscriptionResource> renewSubscription(int subscriptionId, SubscriptionType newSubscriptionType, String? paymentReference) async {
    try {
      final queryParams = <String, String>{
        'newSubscriptionType': newSubscriptionType.toString().split('.').last,
      };
      
      if (paymentReference != null) {
        queryParams['paymentReference'] = paymentReference;
      }

      final queryString = queryParams.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final response = await _networkClient.request<SubscriptionResource>(
        endpoint: '${ApiConstants.subscriptionServiceBaseUrl}${ApiConstants.subscriptions}/$subscriptionId/renew?$queryString',
        method: RequestMethod.put,
        fromJson: (json) => SubscriptionResource.fromJson(json),
        requiresAuth: false,
      );

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception('Failed to renew subscription: ${response.error}');
      }
    } catch (e) {
      throw Exception('Error renewing subscription: $e');
    }
  }

  @override
  Future<SubscriptionResource> cancelSubscription(int subscriptionId, String reason) async {
    try {
      final queryString = 'reason=${Uri.encodeComponent(reason)}';

      final response = await _networkClient.request<SubscriptionResource>(
        endpoint: '${ApiConstants.subscriptionServiceBaseUrl}${ApiConstants.subscriptions}/$subscriptionId/cancel?$queryString',
        method: RequestMethod.put,
        fromJson: (json) => SubscriptionResource.fromJson(json),
        requiresAuth: false,
      );

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception('Failed to cancel subscription: ${response.error}');
      }
    } catch (e) {
      throw Exception('Error cancelling subscription: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> testNotification(TestNotificationRequest request) async {
    try {
      final response = await _networkClient.request<Map<String, dynamic>>(
        endpoint: '${ApiConstants.subscriptionServiceBaseUrl}${ApiConstants.subscriptions}/test/notification',
        method: RequestMethod.post,
        data: request.toJson(),
        fromJson: (json) => json as Map<String, dynamic>,
        requiresAuth: false,
      );

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception('Failed to test notification: ${response.error}');
      }
    } catch (e) {
      throw Exception('Error testing notification: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> testUserService(int userId) async {
    try {
      final response = await _networkClient.request<Map<String, dynamic>>(
        endpoint: '${ApiConstants.subscriptionServiceBaseUrl}${ApiConstants.subscriptions}/test/user/$userId',
        method: RequestMethod.get,
        fromJson: (json) => json as Map<String, dynamic>,
        requiresAuth: false,
      );

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception('Failed to test user service: ${response.error}');
      }
    } catch (e) {
      throw Exception('Error testing user service: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await _networkClient.request<Map<String, dynamic>>(
        endpoint: '${ApiConstants.subscriptionServiceBaseUrl}${ApiConstants.subscriptions}/test/health',
        method: RequestMethod.get,
        fromJson: (json) => json as Map<String, dynamic>,
        requiresAuth: false,
      );

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception('Health check failed: ${response.error}');
      }
    } catch (e) {
      throw Exception('Error during health check: $e');
    }
  }
} 