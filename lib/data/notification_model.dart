/// In-app notification (event reminders, new reels, ticket confirmations, etc.)
class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String? eventId;
  final String? reelId;
  final DateTime createdAt;
  final bool read;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.eventId,
    this.reelId,
    required this.createdAt,
    this.read = false,
  });

  NotificationModel copyWith({bool? read}) => NotificationModel(
        id: id,
        title: title,
        body: body,
        eventId: eventId,
        reelId: reelId,
        createdAt: createdAt,
        read: read ?? this.read,
      );
}
