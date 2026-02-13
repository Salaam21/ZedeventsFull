import 'dart:convert';
import 'package:event_app/data/event_model.dart';
import 'package:event_app/data/user_model.dart';
import 'package:event_app/data/category_enum.dart';

/// API Service for backend integration
/// Currently uses mock data, but structured for easy API implementation
class ApiService {
  // Base URL for API (to be configured when backend is ready)
  static const String baseUrl = 'https://api.zedevents.com';

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Mock current user (replace with actual authentication)
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  // Authentication Methods
  Future<UserModel?> login(String email, String password) async {
    // TODO: Implement actual API call
    // For now, return mock user
    await Future.delayed(const Duration(seconds: 1));
    
    _currentUser = UserModel(
      id: 'user_001',
      name: 'John Doe',
      email: email,
      phone: '+1-234-567-8900',
      profileImage: 'https://images.unsplash.com/photo-1633332755192-727a05c4013d?w=400',
      bio: 'Event enthusiast and organizer',
      interests: [EventCategory.music, EventCategory.sports, EventCategory.concerts],
      location: 'New York, USA',
      dateJoined: DateTime.now().subtract(const Duration(days: 365)),
      isOrganizer: true,
    );
    
    return _currentUser;
  }

  Future<UserModel?> signup({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    // TODO: Implement actual API call
    await Future.delayed(const Duration(seconds: 1));
    
    _currentUser = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      phone: phone,
      dateJoined: DateTime.now(),
      isOrganizer: false,
    );
    
    return _currentUser;
  }

  Future<void> logout() async {
    // TODO: Implement actual API call
    _currentUser = null;
  }

  Future<bool> updateUserInterests(List<EventCategory> interests) async {
    // TODO: Implement actual API call
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(interests: interests);
      return true;
    }
    return false;
  }

  // Event Methods
  Future<List<EventModel>> getAllEvents() async {
    // TODO: Replace with actual API call
    final jsonString = await EventModel.getJson();
    List<dynamic> jsonResult = json.decode(jsonString);
    return jsonResult.map((e) => EventModel.fromJson(e)).toList();
  }

  Future<List<EventModel>> getEventsByCategory(EventCategory category) async {
    final allEvents = await getAllEvents();
    return allEvents.where((event) => event.category == category).toList();
  }

  Future<List<EventModel>> getRecommendedEvents() async {
    // Get events based on user interests
    final allEvents = await getAllEvents();
    
    if (_currentUser == null || _currentUser!.interests.isEmpty) {
      return allEvents;
    }
    
    // Filter events by user interests
    final recommended = allEvents.where((event) {
      return _currentUser!.interests.contains(event.category);
    }).toList();
    
    // If no matches, return featured events
    if (recommended.isEmpty) {
      return allEvents.where((event) => event.isFeatured).toList();
    }
    
    return recommended;
  }

  Future<List<EventModel>> searchEvents(String query) async {
    final allEvents = await getAllEvents();
    final lowercaseQuery = query.toLowerCase();
    
    return allEvents.where((event) {
      return event.title.toLowerCase().contains(lowercaseQuery) ||
          event.description.toLowerCase().contains(lowercaseQuery) ||
          event.location.toLowerCase().contains(lowercaseQuery) ||
          event.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  Future<EventModel?> getEventById(String eventId) async {
    final allEvents = await getAllEvents();
    try {
      return allEvents.firstWhere((event) => event.id == eventId);
    } catch (e) {
      return null;
    }
  }

  Future<bool> createEvent(EventModel event) async {
    // TODO: Implement actual API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Add event to user's posted events
    if (_currentUser != null) {
      final updatedPostedEvents = [..._currentUser!.postedEvents, event.id];
      _currentUser = _currentUser!.copyWith(postedEvents: updatedPostedEvents);
    }
    
    return true;
  }

  Future<bool> updateEvent(EventModel event) async {
    // TODO: Implement actual API call
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<bool> deleteEvent(String eventId) async {
    // TODO: Implement actual API call
    await Future.delayed(const Duration(seconds: 1));
    
    if (_currentUser != null) {
      final updatedPostedEvents = _currentUser!.postedEvents
          .where((id) => id != eventId)
          .toList();
      _currentUser = _currentUser!.copyWith(postedEvents: updatedPostedEvents);
    }
    
    return true;
  }

  Future<List<EventModel>> getMyPostedEvents() async {
    if (_currentUser == null || _currentUser!.postedEvents.isEmpty) {
      return [];
    }
    
    final allEvents = await getAllEvents();
    return allEvents
        .where((event) => _currentUser!.postedEvents.contains(event.id))
        .toList();
  }

  // Ticket Methods
  Future<bool> bookTicket(String eventId, String ticketId, int quantity) async {
    // TODO: Implement actual API call
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  // User Profile Methods
  Future<bool> updateUserProfile(UserModel user) async {
    // TODO: Implement actual API call
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = user;
    return true;
  }

  Future<bool> saveEvent(String eventId) async {
    // TODO: Implement actual API call
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (_currentUser != null) {
      final updatedSavedEvents = [..._currentUser!.savedEvents, eventId];
      _currentUser = _currentUser!.copyWith(savedEvents: updatedSavedEvents);
      return true;
    }
    return false;
  }

  Future<bool> unsaveEvent(String eventId) async {
    // TODO: Implement actual API call
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (_currentUser != null) {
      final updatedSavedEvents = _currentUser!.savedEvents
          .where((id) => id != eventId)
          .toList();
      _currentUser = _currentUser!.copyWith(savedEvents: updatedSavedEvents);
      return true;
    }
    return false;
  }

  bool isEventSaved(String eventId) {
    return _currentUser?.savedEvents.contains(eventId) ?? false;
  }
}



