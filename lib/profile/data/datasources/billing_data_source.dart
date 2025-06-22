import 'dart:convert';
import '../models/subscription_model.dart';
import '../../../core/services/storage_service.dart';

abstract class BillingDataSource {
  Future<List<SubscriptionPlan>> getSubscriptionPlans();
  Future<Subscription?> getCurrentSubscription();
  Future<List<BillingHistoryItem>> getBillingHistory();
  Future<Subscription> subscribeToPlan(String planId, BillingCycle billingCycle, String? paymentMethodId);
  Future<void> cancelSubscription();
  Future<void> updateBillingCycle(BillingCycle billingCycle);
  Future<void> updatePaymentMethod(String paymentMethodId);
}

class BillingDataSourceImpl implements BillingDataSource {
  final StorageService _storageService;
  static const String _plansKey = 'subscription_plans';
  static const String _currentSubscriptionKey = 'current_subscription';
  static const String _billingHistoryKey = 'billing_history';

  BillingDataSourceImpl(this._storageService);

  @override
  Future<List<SubscriptionPlan>> getSubscriptionPlans() async {
    try {
      final data = _storageService.getString(_plansKey);
      if (data == null || data.isEmpty) {
        // Return mock data for demonstration
        return _getMockSubscriptionPlans();
      }

      final List<dynamic> jsonList = json.decode(data);
      return jsonList
          .map((json) => SubscriptionPlan.fromJson(json))
          .toList();
    } catch (e) {
      // Return mock data if there's an error
      return _getMockSubscriptionPlans();
    }
  }

  @override
  Future<Subscription?> getCurrentSubscription() async {
    try {
      final data = _storageService.getString(_currentSubscriptionKey);
      if (data == null || data.isEmpty) {
        return null;
      }

      final json = jsonDecode(data);
      return Subscription.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<BillingHistoryItem>> getBillingHistory() async {
    try {
      final data = _storageService.getString(_billingHistoryKey);
      if (data == null || data.isEmpty) {
        // Return mock data for demonstration
        return _getMockBillingHistory();
      }

      final List<dynamic> jsonList = json.decode(data);
      return jsonList
          .map((json) => BillingHistoryItem.fromJson(json))
          .toList();
    } catch (e) {
      // Return mock data if there's an error
      return _getMockBillingHistory();
    }
  }

  @override
  Future<Subscription> subscribeToPlan(String planId, BillingCycle billingCycle, String? paymentMethodId) async {
    try {
      final plans = await getSubscriptionPlans();
      final selectedPlan = plans.firstWhere((plan) => plan.id == planId);
      
      final subscription = Subscription(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'current_user', // This should come from auth service
        plan: selectedPlan,
        status: SubscriptionStatus.active,
        billingCycle: billingCycle,
        startDate: DateTime.now(),
        nextBillingDate: billingCycle == BillingCycle.monthly 
            ? DateTime.now().add(const Duration(days: 30))
            : DateTime.now().add(const Duration(days: 365)),
        amount: billingCycle == BillingCycle.monthly 
            ? selectedPlan.monthlyPrice 
            : selectedPlan.yearlyPrice,
        paymentMethodId: paymentMethodId,
        createdAt: DateTime.now(),
      );

      await _saveCurrentSubscription(subscription);
      
      // Add to billing history
      final history = await getBillingHistory();
      final billingItem = BillingHistoryItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        subscriptionId: subscription.id,
        amount: subscription.amount,
        description: 'Suscripción a ${selectedPlan.name}',
        date: DateTime.now(),
        status: 'completed',
      );
      
      history.insert(0, billingItem);
      await _saveBillingHistory(history);

      return subscription;
    } catch (e) {
      throw Exception('Failed to subscribe to plan: $e');
    }
  }

  @override
  Future<void> cancelSubscription() async {
    try {
      final subscription = await getCurrentSubscription();
      if (subscription != null) {
        final cancelledSubscription = subscription.copyWith(
          status: SubscriptionStatus.cancelled,
          endDate: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        await _saveCurrentSubscription(cancelledSubscription);
      }
    } catch (e) {
      throw Exception('Failed to cancel subscription: $e');
    }
  }

  @override
  Future<void> updateBillingCycle(BillingCycle billingCycle) async {
    try {
      final subscription = await getCurrentSubscription();
      if (subscription != null) {
        final updatedSubscription = subscription.copyWith(
          billingCycle: billingCycle,
          amount: billingCycle == BillingCycle.monthly 
              ? subscription.plan.monthlyPrice 
              : subscription.plan.yearlyPrice,
          nextBillingDate: billingCycle == BillingCycle.monthly 
              ? DateTime.now().add(const Duration(days: 30))
              : DateTime.now().add(const Duration(days: 365)),
          updatedAt: DateTime.now(),
        );
        
        await _saveCurrentSubscription(updatedSubscription);
      }
    } catch (e) {
      throw Exception('Failed to update billing cycle: $e');
    }
  }

  @override
  Future<void> updatePaymentMethod(String paymentMethodId) async {
    try {
      final subscription = await getCurrentSubscription();
      if (subscription != null) {
        final updatedSubscription = subscription.copyWith(
          paymentMethodId: paymentMethodId,
          updatedAt: DateTime.now(),
        );
        
        await _saveCurrentSubscription(updatedSubscription);
      }
    } catch (e) {
      throw Exception('Failed to update payment method: $e');
    }
  }

  Future<void> _saveCurrentSubscription(Subscription subscription) async {
    final data = json.encode(subscription.toJson());
    await _storageService.setString(_currentSubscriptionKey, data);
  }

  Future<void> _saveBillingHistory(List<BillingHistoryItem> history) async {
    final jsonList = history.map((item) => item.toJson()).toList();
    final data = json.encode(jsonList);
    await _storageService.setString(_billingHistoryKey, data);
  }

  List<SubscriptionPlan> _getMockSubscriptionPlans() {
    return [
      SubscriptionPlan(
        id: 'free',
        name: 'Gratis',
        description: 'Plan básico con funcionalidades limitadas',
        type: SubscriptionPlanType.free,
        monthlyPrice: 0.0,
        yearlyPrice: 0.0,
        features: [
          'Detección de enfermedades básica',
          'Historial limitado (10 detecciones)',
          'Soporte por email',
        ],
        isCurrent: true,
      ),
      SubscriptionPlan(
        id: 'basic',
        name: 'Básico',
        description: 'Plan ideal para usuarios ocasionales',
        type: SubscriptionPlanType.basic,
        monthlyPrice: 4.99,
        yearlyPrice: 49.99,
        features: [
          'Detección de enfermedades avanzada',
          'Historial ilimitado',
          'Recomendaciones personalizadas',
          'Soporte prioritario',
          'Sin anuncios',
        ],
        isPopular: true,
      ),
      SubscriptionPlan(
        id: 'premium',
        name: 'Premium',
        description: 'Plan completo para usuarios activos',
        type: SubscriptionPlanType.premium,
        monthlyPrice: 9.99,
        yearlyPrice: 99.99,
        features: [
          'Todo del plan Básico',
          'Detección en tiempo real',
          'Análisis de múltiples plantas',
          'Reportes detallados',
          'Soporte 24/7',
          'Acceso a expertos',
        ],
      ),
      SubscriptionPlan(
        id: 'pro',
        name: 'Profesional',
        description: 'Plan para agricultores y profesionales',
        type: SubscriptionPlanType.pro,
        monthlyPrice: 19.99,
        yearlyPrice: 199.99,
        features: [
          'Todo del plan Premium',
          'API de integración',
          'Análisis de cultivos completos',
          'Reportes avanzados',
          'Soporte dedicado',
          'Capacitación incluida',
        ],
      ),
    ];
  }

  List<BillingHistoryItem> _getMockBillingHistory() {
    return [
      BillingHistoryItem(
        id: '1',
        subscriptionId: 'current_sub',
        amount: 9.99,
        description: 'Suscripción Premium - Enero 2024',
        date: DateTime.now().subtract(const Duration(days: 15)),
        status: 'completed',
      ),
      BillingHistoryItem(
        id: '2',
        subscriptionId: 'current_sub',
        amount: 9.99,
        description: 'Suscripción Premium - Diciembre 2023',
        date: DateTime.now().subtract(const Duration(days: 45)),
        status: 'completed',
      ),
      BillingHistoryItem(
        id: '3',
        subscriptionId: 'current_sub',
        amount: 4.99,
        description: 'Suscripción Básica - Noviembre 2023',
        date: DateTime.now().subtract(const Duration(days: 75)),
        status: 'completed',
      ),
    ];
  }
} 