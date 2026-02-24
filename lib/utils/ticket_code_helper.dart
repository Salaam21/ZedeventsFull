import 'dart:convert';

/// Generates a unique, scannable ticket code from event name, expected audience, and order.
/// Format: ZE-{eventCode}-{audience}-{uniqueId} so it's deterministic per booking.
String generateTicketCode({
  required String eventId,
  required String eventTitle,
  required int expectedAudience,
  required String orderId,
  int? quantity,
}) {
  // Event code: from id (e.g. zm_001 -> ZM001) or first letters of title
  final eventCode = eventId.replaceAll('_', '').toUpperCase().padRight(5).substring(0, 5);
  // Audience/capacity (max 6 digits)
  final audience = expectedAudience.clamp(0, 999999).toString().padLeft(6, '0');
  // Unique part: hash of orderId + quantity so same booking = same code
  final seed = '$orderId-${quantity ?? 1}';
  final hash = _shortHash(seed);
  return 'ZE-$eventCode-$audience-$hash';
}

/// Short alphanumeric hash (6 chars) for uniqueness.
String _shortHash(String input) {
  final bytes = utf8.encode(input);
  int h = 0;
  for (final b in bytes) {
    h = ((h << 5) - h) + b;
    h = h & 0x7FFFFFFF;
  }
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // no 0,O,1,I
  final v = h.abs();
  return List.generate(6, (i) => chars[(v >> (i * 5)) % chars.length]).join();
}
