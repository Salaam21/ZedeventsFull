import 'package:flutter/material.dart';

import 'payment_models.dart';

/// Base class for all payment providers (MoMo, Airtel Money, Banks, etc.).
/// Add a new provider by extending this and registering it in [PaymentService].
abstract class PaymentProvider {
  /// Unique id for this provider (e.g. 'momo_mtn', 'airtel_money', 'bank_zanaco').
  String get id;

  /// Display name shown in checkout (e.g. 'MTN Mobile Money', 'Airtel Money').
  String get displayName;

  /// Short subtitle or hint (e.g. 'Pay with your MTN number').
  String get subtitle;

  /// Icon for the payment method (optional).
  IconData get icon;

  /// Whether this provider is currently available (e.g. feature flag or config).
  bool get isAvailable => true;

  /// Initiate payment. Returns [PaymentResult] when done (or pending for USSD push).
  /// For MoMo: typically triggers a prompt on the user's phone; result may be
  /// pending until user approves. For cards/banks: may redirect to 3DS then callback.
  Future<PaymentResult> pay(PaymentRequest request);
}
