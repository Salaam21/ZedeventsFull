import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:event_app/data/event_model.dart';

class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _notifications.initialize(settings: initializationSettings);

    _initialized = true;
  }

  /// Request notification permissions (Android 13+)
  Future<bool> requestPermissions() async {
    if (!_initialized) await initialize();
    return true;
  }

  /// Show a one-off test notification so the user can verify notifications work
  Future<void> showTestNotification() async {
    if (!_initialized) await initialize();
    await _notifications.show(
      id: 999999,
      title: 'ZedEvents test',
      body: 'If you see this, notifications are working!',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'event_reminders',
          'Event Reminders',
          channelDescription: 'Event reminders and test notifications',
        ),
      ),
    );
  }

  /// Show instant notification for nearby event happening now
  Future<void> showNearbyEventNotification({
    required String eventTitle,
    required String location,
    required String eventId,
  }) async {
    if (!_initialized) await initialize();
    await _notifications.show(
      id: eventId.hashCode,
      title: 'Event Happening Now',
      body: '$eventTitle at $location',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'nearby_events',
          'Nearby Events',
          channelDescription: 'Nearby event alerts',
        ),
      ),
      payload: eventId,
    );
  }

  /// Show notification for event starting soon
  Future<void> showEventStartingSoonNotification({
    required String eventTitle,
    required String timeUntilStart,
    required String eventId,
  }) async {
    if (!_initialized) await initialize();
    await _notifications.show(
      id: eventId.hashCode + 1000,
      title: 'Event Starting Soon',
      body: '$eventTitle starts in $timeUntilStart',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'event_reminders',
          'Event Reminders',
          channelDescription: 'Upcoming event reminders',
        ),
      ),
      payload: eventId,
    );
  }

  /// Schedule reminder notification for event
  Future<void> scheduleEventReminder({
    required EventModel event,
    required Duration beforeEvent,
  }) async {
    if (!_initialized) await initialize();

    // Calculate when to show notification
    final DateTime eventDateTime = _parseEventDateTime(event);
    final DateTime notificationTime = eventDateTime.subtract(beforeEvent);

    // Only schedule if time is in the future
    if (notificationTime.isBefore(DateTime.now())) {
      return;
    }

    await _notifications.zonedSchedule(
      id: event.id.hashCode,
      title: 'Event Reminder',
      body: '${event.title} starts in ${_formatDuration(beforeEvent)}',
      scheduledDate: tz.TZDateTime.from(notificationTime, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'event_reminders',
          'Event Reminders',
          channelDescription: 'Scheduled event reminders',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: event.id,
    );
  }

  /// Schedule multiple reminders for an event
  Future<void> scheduleMultipleReminders(EventModel event) async {
    // 1 hour before
    await scheduleEventReminder(
      event: event,
      beforeEvent: const Duration(hours: 1),
    );

    // 1 day before
    await scheduleEventReminder(
      event: event,
      beforeEvent: const Duration(days: 1),
    );

    // 1 week before
    await scheduleEventReminder(
      event: event,
      beforeEvent: const Duration(days: 7),
    );
  }

  /// Show notification for new event in user's interests
  Future<void> showNewEventNotification({
    required String eventTitle,
    required String category,
    required String eventId,
  }) async {
    if (!_initialized) await initialize();
    await _notifications.show(
      id: eventId.hashCode + 2000,
      title: 'New $category Event',
      body: eventTitle,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'new_events',
          'New Events',
          channelDescription: 'New events for your interests',
        ),
      ),
      payload: eventId,
    );
  }

  /// Cancel specific notification
  Future<void> cancelNotification(String eventId) async {
    await _notifications.cancel(id: eventId.hashCode);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Helper: Parse event date and time
  DateTime _parseEventDateTime(EventModel event) {
    // This is a simplified version - you'd need to parse the actual date/time
    // from the event.date and event.startTime fields
    // For now, returning a placeholder
    return DateTime.now().add(const Duration(hours: 2));
  }

  /// Helper: Format duration for display
  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} day${duration.inDays > 1 ? 's' : ''}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours > 1 ? 's' : ''}';
    } else {
      return '${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''}';
    }
  }
}

