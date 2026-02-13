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

    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    // Navigate to event details or relevant page
    print('Notification tapped: ${response.payload}');
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    if (!_initialized) await initialize();

    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    final bool? granted = await androidPlugin?.requestNotificationsPermission();
    return granted ?? false;
  }

  /// Show instant notification for nearby event happening now
  Future<void> showNearbyEventNotification({
    required String eventTitle,
    required String location,
    required String eventId,
  }) async {
    if (!_initialized) await initialize();

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'nearby_events',
      'Nearby Events',
      channelDescription: 'Notifications for events happening near you',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notifications.show(
      eventId.hashCode,
      '🎉 Event Happening Now!',
      '$eventTitle at $location - Tap to view details',
      details,
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

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'event_reminders',
      'Event Reminders',
      channelDescription: 'Reminders for upcoming events',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notifications.show(
      eventId.hashCode + 1000, // Different ID for reminder
      '⏰ Event Starting Soon!',
      '$eventTitle starts in $timeUntilStart',
      details,
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

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'event_reminders',
      'Event Reminders',
      channelDescription: 'Reminders for your upcoming events',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notifications.zonedSchedule(
      event.id.hashCode,
      '⏰ Event Reminder',
      '${event.title} starts in ${_formatDuration(beforeEvent)}',
      tz.TZDateTime.from(notificationTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
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

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'new_events',
      'New Events',
      channelDescription: 'Notifications for new events matching your interests',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notifications.show(
      eventId.hashCode + 2000,
      '✨ New $category Event',
      eventTitle,
      details,
      payload: eventId,
    );
  }

  /// Cancel specific notification
  Future<void> cancelNotification(String eventId) async {
    await _notifications.cancel(eventId.hashCode);
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

