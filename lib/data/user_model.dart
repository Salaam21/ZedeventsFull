import 'package:event_app/data/category_enum.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? profileImage;
  final String? bio;
  final List<EventCategory> interests;
  final String? location;
  final DateTime? dateJoined;
  final List<String> savedEvents;
  final List<String> postedEvents;
  final List<String> attendedEvents;
  final bool isOrganizer;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profileImage,
    this.bio,
    this.interests = const [],
    this.location,
    this.dateJoined,
    this.savedEvents = const [],
    this.postedEvents = const [],
    this.attendedEvents = const [],
    this.isOrganizer = false,
  });

  // Check if user has selected interests
  bool get hasInterests => interests.isNotEmpty;

  // Check if user is a verified organizer
  bool get canPostEvents => isOrganizer;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    List<EventCategory> interestList = [];
    if (json["interests"] != null) {
      interestList = (json["interests"] as List)
          .map((interest) => EventCategoryExtension.fromString(interest))
          .toList();
    }

    return UserModel(
      id: json["id"] ?? "",
      name: json["name"] ?? "",
      email: json["email"] ?? "",
      phone: json["phone"],
      profileImage: json["profileImage"],
      bio: json["bio"],
      interests: interestList,
      location: json["location"],
      dateJoined: json["dateJoined"] != null
          ? DateTime.parse(json["dateJoined"])
          : null,
      savedEvents: json["savedEvents"] != null
          ? List<String>.from(json["savedEvents"])
          : [],
      postedEvents: json["postedEvents"] != null
          ? List<String>.from(json["postedEvents"])
          : [],
      attendedEvents: json["attendedEvents"] != null
          ? List<String>.from(json["attendedEvents"])
          : [],
      isOrganizer: json["isOrganizer"] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "phone": phone,
        "profileImage": profileImage,
        "bio": bio,
        "interests": interests.map((interest) => interest.name).toList(),
        "location": location,
        "dateJoined": dateJoined?.toIso8601String(),
        "savedEvents": savedEvents,
        "postedEvents": postedEvents,
        "attendedEvents": attendedEvents,
        "isOrganizer": isOrganizer,
      };

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    String? bio,
    List<EventCategory>? interests,
    String? location,
    DateTime? dateJoined,
    List<String>? savedEvents,
    List<String>? postedEvents,
    List<String>? attendedEvents,
    bool? isOrganizer,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      bio: bio ?? this.bio,
      interests: interests ?? this.interests,
      location: location ?? this.location,
      dateJoined: dateJoined ?? this.dateJoined,
      savedEvents: savedEvents ?? this.savedEvents,
      postedEvents: postedEvents ?? this.postedEvents,
      attendedEvents: attendedEvents ?? this.attendedEvents,
      isOrganizer: isOrganizer ?? this.isOrganizer,
    );
  }
}

