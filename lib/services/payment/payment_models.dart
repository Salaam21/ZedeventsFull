/// Represents a payment request (e.g. ticket purchase).
class PaymentRequest {
  final String reference;
  final String description;
  final double amount;
  final String currency;
  final String? customerPhone;
  final String? customerEmail;
  final Map<String, dynamic>? metadata;

  const PaymentRequest({
    required this.reference,
    required this.description,
    required this.amount,
    this.currency = 'ZMW',
    this.customerPhone,
    this.customerEmail,
    this.metadata,
  });
}

/// Result of a payment attempt.
enum PaymentStatus {
  pending,
  completed,
  failed,
  cancelled,
}

class PaymentResult {
  final bool success;
  final PaymentStatus status;
  final String? transactionId;
  final String? providerReference;
  final String? errorMessage;

  const PaymentResult({
    required this.success,
    required this.status,
    this.transactionId,
    this.providerReference,
    this.errorMessage,
  });

  factory PaymentResult.completed({String? transactionId, String? providerReference}) =>
      PaymentResult(success: true, status: PaymentStatus.completed, transactionId: transactionId, providerReference: providerReference);

  factory PaymentResult.failed(String message) =>
      PaymentResult(success: false, status: PaymentStatus.failed, errorMessage: message);

  factory PaymentResult.cancelled() =>
      PaymentResult(success: false, status: PaymentStatus.cancelled);

  factory PaymentResult.pending({String? providerReference}) =>
      PaymentResult(success: false, status: PaymentStatus.pending, providerReference: providerReference);
}
