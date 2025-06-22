import 'dart:convert';
import '../models/payment_method_model.dart';
import '../../../core/services/storage_service.dart';

abstract class PaymentMethodDataSource {
  Future<List<PaymentMethodModel>> getPaymentMethods();
  Future<PaymentMethodModel> addPaymentMethod(PaymentMethodModel paymentMethod);
  Future<PaymentMethodModel> updatePaymentMethod(PaymentMethodModel paymentMethod);
  Future<void> deletePaymentMethod(String id);
  Future<void> setDefaultPaymentMethod(String id);
}

class PaymentMethodDataSourceImpl implements PaymentMethodDataSource {
  final StorageService _storageService;
  static const String _storageKey = 'payment_methods';

  PaymentMethodDataSourceImpl(this._storageService);

  @override
  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    try {
      final data = _storageService.getString(_storageKey);
      if (data == null || data.isEmpty) {
        // Return mock data for demonstration
        return _getMockPaymentMethods();
      }

      final List<dynamic> jsonList = json.decode(data);
      return jsonList
          .map((json) => PaymentMethodModel.fromJson(json))
          .toList();
    } catch (e) {
      // Return mock data if there's an error
      return _getMockPaymentMethods();
    }
  }

  @override
  Future<PaymentMethodModel> addPaymentMethod(PaymentMethodModel paymentMethod) async {
    try {
      final methods = await getPaymentMethods();
      
      // If this is the first payment method, make it default
      final updatedMethod = methods.isEmpty 
          ? paymentMethod.copyWith(isDefault: true)
          : paymentMethod;
      
      methods.add(updatedMethod);
      await _savePaymentMethods(methods);
      
      return updatedMethod;
    } catch (e) {
      throw Exception('Failed to add payment method: $e');
    }
  }

  @override
  Future<PaymentMethodModel> updatePaymentMethod(PaymentMethodModel paymentMethod) async {
    try {
      final methods = await getPaymentMethods();
      final index = methods.indexWhere((method) => method.id == paymentMethod.id);
      
      if (index == -1) {
        throw Exception('Payment method not found');
      }
      
      methods[index] = paymentMethod.copyWith(updatedAt: DateTime.now());
      await _savePaymentMethods(methods);
      
      return methods[index];
    } catch (e) {
      throw Exception('Failed to update payment method: $e');
    }
  }

  @override
  Future<void> deletePaymentMethod(String id) async {
    try {
      final methods = await getPaymentMethods();
      final methodToDelete = methods.firstWhere((method) => method.id == id);
      
      methods.removeWhere((method) => method.id == id);
      
      // If we deleted the default method and there are other methods, make the first one default
      if (methodToDelete.isDefault && methods.isNotEmpty) {
        methods[0] = methods[0].copyWith(isDefault: true);
      }
      
      await _savePaymentMethods(methods);
    } catch (e) {
      throw Exception('Failed to delete payment method: $e');
    }
  }

  @override
  Future<void> setDefaultPaymentMethod(String id) async {
    try {
      final methods = await getPaymentMethods();
      
      // Remove default from all methods
      for (int i = 0; i < methods.length; i++) {
        methods[i] = methods[i].copyWith(isDefault: false);
      }
      
      // Set the specified method as default
      final index = methods.indexWhere((method) => method.id == id);
      if (index != -1) {
        methods[index] = methods[index].copyWith(
          isDefault: true,
          updatedAt: DateTime.now(),
        );
      }
      
      await _savePaymentMethods(methods);
    } catch (e) {
      throw Exception('Failed to set default payment method: $e');
    }
  }

  Future<void> _savePaymentMethods(List<PaymentMethodModel> methods) async {
    final jsonList = methods.map((method) => method.toJson()).toList();
    final data = json.encode(jsonList);
    await _storageService.setString(_storageKey, data);
  }

  List<PaymentMethodModel> _getMockPaymentMethods() {
    return [
      PaymentMethodModel(
        id: '1',
        name: 'Visa ending in 4242',
        type: PaymentMethodType.creditCard,
        lastFourDigits: '4242',
        cardBrand: CardBrand.visa,
        expiryMonth: '12',
        expiryYear: '25',
        isDefault: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      PaymentMethodModel(
        id: '2',
        name: 'Mastercard ending in 5555',
        type: PaymentMethodType.creditCard,
        lastFourDigits: '5555',
        cardBrand: CardBrand.mastercard,
        expiryMonth: '08',
        expiryYear: '26',
        isDefault: false,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      PaymentMethodModel(
        id: '3',
        name: 'PayPal',
        type: PaymentMethodType.digitalWallet,
        isDefault: false,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];
  }
} 