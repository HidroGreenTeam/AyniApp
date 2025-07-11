import 'dart:io';
import 'package:pay/pay.dart';

/// Servicio para gestionar pagos con Google Pay y Apple Pay usando la librería `pay`.
/// Devuelve el token de pago (`paymentReference`) si el usuario completa el pago,
/// o `null` si cancela o ocurre un error.
class PaymentService {
  static const String _googlePayConfig = 'assets/payments/google_pay_config.json';
  static const String _applePayConfig = 'assets/payments/apple_pay_config.json';

  Pay? _pay;

  Future<void> _ensurePayInitialized() async {
    if (_pay != null) return;

    final googleConfig = await PaymentConfiguration.fromAsset(_googlePayConfig);
    final appleConfig = await PaymentConfiguration.fromAsset(_applePayConfig);

    _pay = Pay({
      PayProvider.google_pay: googleConfig,
      PayProvider.apple_pay: appleConfig,
    });
  }

  /// Inicia el flujo de pago y devuelve el token de pago si la operación se
  /// completa exitosamente.
  /// [amount] Importe total a cobrar.
  /// [currencyCode] Código de la moneda (p. ej. "USD").
  /// [label] Etiqueta que se muestra al usuario, por defecto "Total".
  Future<String?> pay({
    required double amount,
    required String currencyCode,
    String label = 'Total',
  }) async {
    final paymentItems = <PaymentItem>[
      PaymentItem(
        label: label,
        amount: amount.toStringAsFixed(2),
        status: PaymentItemStatus.final_price,
      ),
    ];

    final provider = Platform.isAndroid
        ? PayProvider.google_pay
        : PayProvider.apple_pay;

    try {
      await _ensurePayInitialized();

      final result = await _pay!.showPaymentSelector(
        provider,
        paymentItems,
      );

      // Estructura de la respuesta difiere entre proveedores.
      String? token;
      if (provider == PayProvider.google_pay) {
        token = result['paymentMethodData']?['tokenizationData']?['token'];
      } else {
        token = result['token'];
      }
      return token;
    } catch (_) {
      // El usuario canceló o ocurrió un error.
      return null;
    }
  }
} 