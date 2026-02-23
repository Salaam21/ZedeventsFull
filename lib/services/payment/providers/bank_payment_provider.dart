import 'package:flutter/material.dart';

import '../payment_models.dart';
import '../payment_provider.dart';

/// Bank / card payment placeholder. Can be extended per bank (Zanaco, Stanbic, etc.)
/// or use a single provider that supports multiple banks via a payment gateway.
class BankPaymentProvider extends PaymentProvider {
  final String _bankName;

  BankPaymentProvider({String bankName = 'Bank / Card'}) : _bankName = bankName;

  @override
  String get id => 'bank_${_bankName.toLowerCase().replaceAll(' ', '_')}';

  @override
  String get displayName => _bankName;

  @override
  String get subtitle => 'Pay with card or bank account';

  @override
  IconData get icon => Icons.credit_card;

  @override
  Future<PaymentResult> pay(PaymentRequest request) async {
    // TODO: Integrate with payment gateway (e.g. PayStack, Flutterwave, or direct bank API).
    await Future.delayed(const Duration(seconds: 2));
    return PaymentResult.completed(
      transactionId: 'BANK_${DateTime.now().millisecondsSinceEpoch}',
      providerReference: 'BANK-${request.reference}',
    );
  }
}
