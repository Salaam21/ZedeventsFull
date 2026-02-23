import 'package:event_app/data/notification_model.dart';

/// In-app notifications list (can be wired to NotificationService + backend later).
class NotificationsRepository {
  NotificationsRepository._();
  static final NotificationsRepository _instance = NotificationsRepository._();
  factory NotificationsRepository() => _instance;

  final List<NotificationModel> _items = [
    NotificationModel(
      id: 'n1',
      title: 'Lusaka Music Festival tomorrow',
      body: 'Your event "Lusaka Music & Arts Festival" is tomorrow at Showgrounds.',
      eventId: 'zm_001',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    NotificationModel(
      id: 'n2',
      title: 'New reel from Zed Culture Live',
      body: 'Check out their latest clip from the festival.',
      reelId: 'r1',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    NotificationModel(
      id: 'n3',
      title: 'Ticket confirmed',
      body: 'You’re going to Zambia Super League Derby Night. Show your ticket at the gate.',
      eventId: 'zm_003',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    NotificationModel(
      id: 'n4',
      title: 'Reminder: Copperbelt Expo',
      body: 'Trade Fair Grounds, Ndola — starts in 2 days.',
      eventId: 'zm_002',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  List<NotificationModel> get notifications => List.unmodifiable(_items);
  int get unreadCount => _items.where((n) => !n.read).length;

  Future<List<NotificationModel>> fetch() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return notifications;
  }

  Future<void> markAsRead(String id) async {
    final i = _items.indexWhere((n) => n.id == id);
    if (i >= 0) _items[i] = _items[i].copyWith(read: true);
  }

  Future<void> markAllRead() async {
    for (var i = 0; i < _items.length; i++) {
      _items[i] = _items[i].copyWith(read: true);
    }
  }
}
