import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:event_app/data/event_model.dart';

/// Builds start/end DateTime from event date string and optional times.
DateTime? _parseEventStart(EventModel event) {
  final dateStr = event.date.trim();
  final parts = dateStr.split(RegExp(r'\s+'));
  if (parts.length < 2) return null;
  const months = {
    'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
    'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
  };
  final day = int.tryParse(parts[0]);
  final month = months[parts[1]];
  if (day == null || month == null) return null;
  var year = DateTime.now().year;
  if (month < DateTime.now().month || (month == DateTime.now().month && day < DateTime.now().day)) {
    year += 1;
  }
  int hour = 10, minute = 0;
  if (event.startTime != null) {
    final t = event.startTime!.split(':');
    if (t.length >= 2) {
      hour = int.tryParse(t[0]) ?? 10;
      minute = int.tryParse(t[1]) ?? 0;
    }
  }
  return DateTime(year, month, day, hour, minute);
}

DateTime? _parseEventEnd(EventModel event) {
  final start = _parseEventStart(event);
  if (start == null) return null;
  if (event.endTime != null) {
    final t = event.endTime!.split(':');
    if (t.length >= 2) {
      final h = int.tryParse(t[0]) ?? 22;
      final m = int.tryParse(t[1]) ?? 0;
      return DateTime(start.year, start.month, start.day, h, m);
    }
  }
  return start.add(const Duration(hours: 2));
}

/// Adds the event to the device calendar. Returns true if the add-calendar UI was shown.
Future<bool> addEventToCalendar(EventModel event) async {
  final start = _parseEventStart(event);
  final end = _parseEventEnd(event);
  if (start == null || end == null) return false;
  final calEvent = Event(
    title: event.title,
    description: event.description,
    location: event.location,
    startDate: start,
    endDate: end,
  );
  await Add2Calendar.addEvent2Cal(calEvent);
  return true;
}
