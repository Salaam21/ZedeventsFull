import 'package:event_app/services/payment/payment_models.dart';
import 'package:event_app/services/payment/payment_provider.dart';
import 'package:event_app/services/payment/providers/airtel_money_payment_provider.dart';
import 'package:event_app/services/payment/providers/bank_payment_provider.dart';
import 'package:event_app/services/payment/providers/momo_payment_provider.dart';

/// Central payment service. Register all providers here.
///
/// To add a new provider (e.g. Airtel Money, another bank):
/// 1. Create a class that extends [PaymentProvider] and implements [pay].
/// 2. Add it to [_providers] below or call [registerProvider] at startup.
/// 3. Set [isAvailable] to true when the integration is ready.
class PaymentService {
  PaymentService._();
  static final PaymentService _instance = PaymentService._();
  factory PaymentService() => _instance;

  final List<PaymentProvider> _providers = [
    MomoPaymentProvider(),
    AirtelMoneyPaymentProvider(),
    BankPaymentProvider(),
  ];

  PaymentProvider? _preferredProvider;

  /// All registered providers that are currently available.
  List<PaymentProvider> get availableProviders =>
      _providers.where((p) => p.isAvailable).toList();

  /// Preferred provider (e.g. last used). Can be set after user selects one.
  PaymentProvider? get preferredProvider => _preferredProvider;

  set preferredProvider(PaymentProvider? value) {
    _preferredProvider = value;
  }

  /// Register an additional provider (e.g. when adding a new bank or Airtel).
  void registerProvider(PaymentProvider provider) {
    if (!_providers.any((p) => p.id == provider.id)) {
      _providers.add(provider);
    }
  }

  /// Run checkout with the given [request]. If [provider] is null, uses [preferredProvider]
  /// or the first available provider.
  Future<PaymentResult> checkout(PaymentRequest request, {PaymentProvider? provider}) async {
    final list = availableProviders;
    final p = provider ?? _preferredProvider ?? (list.isNotEmpty ? list.first : null);
    if (p == null) return PaymentResult.failed('No payment method available.');
    _preferredProvider = p;
    return p.pay(request);
  }
}
