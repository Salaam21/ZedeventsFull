import 'package:flutter/material.dart';
import 'package:event_app/services/payment/payment_models.dart';
import 'package:event_app/services/payment/payment_provider.dart';
import 'package:event_app/services/payment/payment_service.dart';

/// Checkout dialog: select payment method and pay. Used when user buys paid tickets.
class CheckoutDialog extends StatefulWidget {
  final String orderDescription;
  final double totalAmount;
  final String currency;
  final String reference;
  final void Function(PaymentResult result) onComplete;

  const CheckoutDialog({
    super.key,
    required this.orderDescription,
    required this.totalAmount,
    this.currency = 'ZMW',
    required this.reference,
    required this.onComplete,
  });

  @override
  State<CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends State<CheckoutDialog> {
  final PaymentService _paymentService = PaymentService();
  PaymentProvider? _selectedProvider;
  bool _isProcessing = false;
  String? _phoneHint;

  String get _amountLabel =>
      widget.totalAmount == 0 ? 'Free' : '${widget.currency} ${widget.totalAmount.toStringAsFixed(2)}';

  @override
  void initState() {
    super.initState();
    final list = _paymentService.availableProviders;
    _selectedProvider = _paymentService.preferredProvider ?? (list.isNotEmpty ? list.first : null);
  }

  Future<void> _pay() async {
    if (_selectedProvider == null || _isProcessing) return;
    setState(() => _isProcessing = true);
    final request = PaymentRequest(
      reference: widget.reference,
      description: widget.orderDescription,
      amount: widget.totalAmount,
      currency: widget.currency,
      customerPhone: _phoneHint,
      metadata: {'source': 'zed_events_checkout'},
    );
    final result = await _selectedProvider!.pay(request);
    if (!mounted) return;
    setState(() => _isProcessing = false);
    widget.onComplete(result);
  }

  @override
  Widget build(BuildContext context) {
    final providers = _paymentService.availableProviders;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Text('Checkout', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => widget.onComplete(PaymentResult.cancelled())),
                ],
              ),
              const SizedBox(height: 8),
              Text(widget.orderDescription, style: TextStyle(color: Colors.grey.shade700)),
              const SizedBox(height: 8),
              Text('Total: $_amountLabel', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              const Text('Payment method', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              if (providers.isEmpty)
                const Text('No payment method available.', style: TextStyle(color: Colors.red))
              else
                ...providers.map((p) => _PaymentMethodTile(
                      provider: p,
                      isSelected: _selectedProvider?.id == p.id,
                      onTap: () => setState(() => _selectedProvider = p),
                    )),
              if (_selectedProvider != null && _selectedProvider!.id.contains('momo')) ...[
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Mobile number (optional)',
                    hintText: '260 97 123 4567',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  onChanged: (v) => _phoneHint = v.isEmpty ? null : v.trim(),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isProcessing || _selectedProvider == null
                    ? null
                    : _pay,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isProcessing
                    ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text('Pay $_amountLabel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final PaymentProvider provider;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodTile({
    required this.provider,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isSelected ? Colors.blue.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(provider.icon, size: 28, color: isSelected ? Colors.blue.shade700 : Colors.grey.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(provider.displayName, style: TextStyle(fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500)),
                      Text(provider.subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                Icon(isSelected ? Icons.check_circle : Icons.radio_button_unchecked, color: isSelected ? Colors.blue : Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
