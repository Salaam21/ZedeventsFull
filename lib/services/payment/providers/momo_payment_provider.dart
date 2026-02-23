import 'package:flutter/material.dart';

import '../payment_models.dart';
import '../payment_provider.dart';

/// Mobile Money provider (MTN MoMo). Airtel Money can be added as a separate
/// provider (e.g. [AirtelMoneyPaymentProvider]) using the same interface.
class MomoPaymentProvider extends PaymentProvider {
  @override
  String get id => 'momo_mtn';

  @override
  String get displayName => 'MTN Mobile Money';

  @override
  String get subtitle => 'Pay with your MTN number';

  @override
  IconData get icon => Icons.phone_android;

  @override
  Future<PaymentResult> pay(PaymentRequest request) async {
    // TODO: Integrate with MTN MoMo API (e.g. Collections API).
    // For now simulate: deduct from client MoMo after user confirms.
    await Future.delayed(const Duration(seconds: 2));
    return PaymentResult.completed(
      transactionId: 'MOM_${DateTime.now().millisecondsSinceEpoch}',
      providerReference: 'MTN-${request.reference}',
    );
  }
}
