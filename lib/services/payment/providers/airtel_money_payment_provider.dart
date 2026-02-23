import 'package:flutter/material.dart';

import '../payment_models.dart';
import '../payment_provider.dart';

/// Airtel Money provider. Enable when ready to integrate with Airtel API.
class AirtelMoneyPaymentProvider extends PaymentProvider {
  @override
  String get id => 'airtel_money';

  @override
  String get displayName => 'Airtel Money';

  @override
  String get subtitle => 'Pay with your Airtel number';

  @override
  IconData get icon => Icons.phone_android;

  /// Set to true when Airtel API is integrated.
  @override
  bool get isAvailable => false;

  @override
  Future<PaymentResult> pay(PaymentRequest request) async {
    // TODO: Integrate with Airtel Money API.
    await Future.delayed(const Duration(seconds: 1));
    return PaymentResult.failed('Airtel Money is not yet available.');
  }
}
