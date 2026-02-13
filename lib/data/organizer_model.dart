class OrganizerModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profileImage;
  final String? description;
  final double rating;
  final int eventsHosted;

  OrganizerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage,
    this.description,
    this.rating = 0.0,
    this.eventsHosted = 0,
  });

  factory OrganizerModel.fromJson(Map<String, dynamic> json) => OrganizerModel(
        id: json["id"] ?? "",
        name: json["name"] ?? "",
        email: json["email"] ?? "",
        phone: json["phone"] ?? "",
        profileImage: json["profileImage"],
        description: json["description"],
        rating: (json["rating"] ?? 0.0).toDouble(),
        eventsHosted: json["eventsHosted"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "phone": phone,
        "profileImage": profileImage,
        "description": description,
        "rating": rating,
        "eventsHosted": eventsHosted,
      };
}

