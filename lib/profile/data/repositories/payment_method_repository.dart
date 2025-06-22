import '../datasources/payment_method_data_source.dart';
import '../models/payment_method_model.dart';

abstract class PaymentMethodRepository {
  Future<List<PaymentMethodModel>> getPaymentMethods();
  Future<PaymentMethodModel> addPaymentMethod(PaymentMethodModel paymentMethod);
  Future<PaymentMethodModel> updatePaymentMethod(PaymentMethodModel paymentMethod);
  Future<void> deletePaymentMethod(String id);
  Future<void> setDefaultPaymentMethod(String id);
}

class PaymentMethodRepositoryImpl implements PaymentMethodRepository {
  final PaymentMethodDataSource _dataSource;

  PaymentMethodRepositoryImpl(this._dataSource);

  @override
  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    try {
      return await _dataSource.getPaymentMethods();
    } catch (e) {
      throw Exception('Failed to get payment methods: $e');
    }
  }

  @override
  Future<PaymentMethodModel> addPaymentMethod(PaymentMethodModel paymentMethod) async {
    try {
      return await _dataSource.addPaymentMethod(paymentMethod);
    } catch (e) {
      throw Exception('Failed to add payment method: $e');
    }
  }

  @override
  Future<PaymentMethodModel> updatePaymentMethod(PaymentMethodModel paymentMethod) async {
    try {
      return await _dataSource.updatePaymentMethod(paymentMethod);
    } catch (e) {
      throw Exception('Failed to update payment method: $e');
    }
  }

  @override
  Future<void> deletePaymentMethod(String id) async {
    try {
      await _dataSource.deletePaymentMethod(id);
    } catch (e) {
      throw Exception('Failed to delete payment method: $e');
    }
  }

  @override
  Future<void> setDefaultPaymentMethod(String id) async {
    try {
      await _dataSource.setDefaultPaymentMethod(id);
    } catch (e) {
      throw Exception('Failed to set default payment method: $e');
    }
  }
} 