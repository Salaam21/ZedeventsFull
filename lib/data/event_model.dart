import 'dart:convert';

import 'package:event_app/data/category_enum.dart';
import 'package:event_app/data/organizer_model.dart';
import 'package:event_app/data/ticket_model.dart';
import 'package:flutter/services.dart' show rootBundle;

class EventModel {
  EventModel({
    required this.id,
    required this.title,
    required this.image,
    required this.date,
    required this.location,
    required this.description,
    required this.category,
    required this.organizer,
    required this.tickets,
    this.latitude,
    this.longitude,
    this.capacity,
    this.startTime,
    this.endTime,
    this.isOnline = false,
    this.meetingUrl,
    this.tags = const [],
    this.attendees = 0,
    this.isFeatured = false,
    this.createdAt,
  });

  String id;
  String title;
  String image;
  String date;
  String location;
  String description;
  double? latitude;
  double? longitude;
  EventCategory category;
  OrganizerModel organizer;
  List<TicketModel> tickets;
  int? capacity;
  String? startTime;
  String? endTime;
  bool isOnline;
  String? meetingUrl;
  List<String> tags;
  int attendees;
  bool isFeatured;
  DateTime? createdAt;

  static Future<String> getJson() {
    return rootBundle.loadString('assets/json/data_event.json');
  }

  // Get the cheapest ticket price
  double get minPrice {
    if (tickets.isEmpty) return 0;
    return tickets.map((t) => t.price).reduce((a, b) => a < b ? a : b);
  }

  // Get the most expensive ticket price
  double get maxPrice {
    if (tickets.isEmpty) return 0;
    return tickets.map((t) => t.price).reduce((a, b) => a > b ? a : b);
  }

  // Check if any tickets are available
  bool get hasAvailableTickets {
    return tickets.any((ticket) => !ticket.isSoldOut);
  }

  // Get total tickets available
  int get totalAvailableTickets {
    return tickets.fold(0, (sum, ticket) => sum + ticket.available);
  }

  // Check if event is free
  bool get isFree {
    return tickets.every((ticket) => ticket.price == 0);
  }

  factory EventModel.fromRawJson(String str) =>
      EventModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory EventModel.fromJson(Map<String, dynamic> json) {
    // Parse tickets
    List<TicketModel> ticketList = [];
    if (json["tickets"] != null) {
      ticketList = (json["tickets"] as List)
          .map((ticket) => TicketModel.fromJson(ticket))
          .toList();
    }

    // Parse tags
    List<String> tagList = [];
    if (json["tags"] != null) {
      tagList = List<String>.from(json["tags"]);
    }

    return EventModel(
      id: json["id"] ?? "",
      title: json["title"] ?? "",
      image: json["image"] ?? "",
      date: json["date"] ?? "",
      location: json["location"] ?? "",
      description: json["description"] ?? "",
      category: EventCategoryExtension.fromString(json["category"] ?? "other"),
      organizer: OrganizerModel.fromJson(json["organizer"] ?? {}),
      tickets: ticketList,
      latitude: json["latitude"]?.toDouble(),
      longitude: json["longitude"]?.toDouble(),
      capacity: json["capacity"],
      startTime: json["startTime"],
      endTime: json["endTime"],
      isOnline: json["isOnline"] ?? false,
      meetingUrl: json["meetingUrl"],
      tags: tagList,
      attendees: json["attendees"] ?? 0,
      isFeatured: json["isFeatured"] ?? false,
      createdAt: json["createdAt"] != null
          ? DateTime.parse(json["createdAt"])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "image": image,
        "date": date,
        "location": location,
        "description": description,
        "category": category.name,
        "organizer": organizer.toJson(),
        "tickets": tickets.map((ticket) => ticket.toJson()).toList(),
        "latitude": latitude,
        "longitude": longitude,
        "capacity": capacity,
        "startTime": startTime,
        "endTime": endTime,
        "isOnline": isOnline,
        "meetingUrl": meetingUrl,
        "tags": tags,
        "attendees": attendees,
        "isFeatured": isFeatured,
        "createdAt": createdAt?.toIso8601String(),
      };
}
