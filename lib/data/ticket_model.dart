enum TicketType {
  free,
  paid,
  vip,
  earlyBird,
  regular,
}

extension TicketTypeExtension on TicketType {
  String get displayName {
    switch (this) {
      case TicketType.free:
        return 'Free';
      case TicketType.paid:
        return 'Paid';
      case TicketType.vip:
        return 'VIP';
      case TicketType.earlyBird:
        return 'Early Bird';
      case TicketType.regular:
        return 'Regular';
    }
  }

  static TicketType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'free':
        return TicketType.free;
      case 'paid':
        return TicketType.paid;
      case 'vip':
        return TicketType.vip;
      case 'earlybird':
      case 'early bird':
        return TicketType.earlyBird;
      case 'regular':
        return TicketType.regular;
      default:
        return TicketType.regular;
    }
  }
}

class TicketModel {
  final String id;
  final TicketType type;
  final double price;
  final int totalAvailable;
  final int sold;
  final String currency;

  TicketModel({
    required this.id,
    required this.type,
    required this.price,
    required this.totalAvailable,
    required this.sold,
    this.currency = 'USD',
  });

  int get available => totalAvailable - sold;
  
  bool get isSoldOut => available <= 0;
  
  double get percentageSold => totalAvailable > 0 ? (sold / totalAvailable) * 100 : 0;

  factory TicketModel.fromJson(Map<String, dynamic> json) => TicketModel(
        id: json["id"] ?? "",
        type: TicketTypeExtension.fromString(json["type"] ?? "regular"),
        price: (json["price"] ?? 0).toDouble(),
        totalAvailable: json["totalAvailable"] ?? 0,
        sold: json["sold"] ?? 0,
        currency: json["currency"] ?? "USD",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type.name,
        "price": price,
        "totalAvailable": totalAvailable,
        "sold": sold,
        "currency": currency,
      };
}

