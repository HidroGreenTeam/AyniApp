import '../datasources/billing_data_source.dart';
import '../models/subscription_model.dart';

abstract class BillingRepository {
  Future<List<SubscriptionPlan>> getSubscriptionPlans();
  Future<Subscription?> getCurrentSubscription();
  Future<List<BillingHistoryItem>> getBillingHistory();
  Future<Subscription> subscribeToPlan(String planId, BillingCycle billingCycle, String? paymentMethodId);
  Future<void> cancelSubscription();
  Future<void> updateBillingCycle(BillingCycle billingCycle);
  Future<void> updatePaymentMethod(String paymentMethodId);
}

class BillingRepositoryImpl implements BillingRepository {
  final BillingDataSource _dataSource;

  BillingRepositoryImpl(this._dataSource);

  @override
  Future<List<SubscriptionPlan>> getSubscriptionPlans() async {
    try {
      return await _dataSource.getSubscriptionPlans();
    } catch (e) {
      throw Exception('Failed to get subscription plans: $e');
    }
  }

  @override
  Future<Subscription?> getCurrentSubscription() async {
    try {
      return await _dataSource.getCurrentSubscription();
    } catch (e) {
      throw Exception('Failed to get current subscription: $e');
    }
  }

  @override
  Future<List<BillingHistoryItem>> getBillingHistory() async {
    try {
      return await _dataSource.getBillingHistory();
    } catch (e) {
      throw Exception('Failed to get billing history: $e');
    }
  }

  @override
  Future<Subscription> subscribeToPlan(String planId, BillingCycle billingCycle, String? paymentMethodId) async {
    try {
      return await _dataSource.subscribeToPlan(planId, billingCycle, paymentMethodId);
    } catch (e) {
      throw Exception('Failed to subscribe to plan: $e');
    }
  }

  @override
  Future<void> cancelSubscription() async {
    try {
      await _dataSource.cancelSubscription();
    } catch (e) {
      throw Exception('Failed to cancel subscription: $e');
    }
  }

  @override
  Future<void> updateBillingCycle(BillingCycle billingCycle) async {
    try {
      await _dataSource.updateBillingCycle(billingCycle);
    } catch (e) {
      throw Exception('Failed to update billing cycle: $e');
    }
  }

  @override
  Future<void> updatePaymentMethod(String paymentMethodId) async {
    try {
      await _dataSource.updatePaymentMethod(paymentMethodId);
    } catch (e) {
      throw Exception('Failed to update payment method: $e');
    }
  }
} 