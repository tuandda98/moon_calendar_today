import 'package:flutter/foundation.dart';
import '../models/lunar_event.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../utils/lunar_converter.dart';

class _EventWithDate {
  final LunarEvent event;
  final DateTime date;
  const _EventWithDate(this.event, this.date);
}

class EventsProvider extends ChangeNotifier {
  List<LunarEvent> _events = [];
  bool _loading = false;

  List<LunarEvent> get events => _events;
  bool get loading => _loading;

  Future<void> loadEvents() async {
    _loading = true;
    notifyListeners();
    _events = await DatabaseService.instance.getAllEvents();
    _loading = false;
    notifyListeners();
  }

  Future<void> addEvent(LunarEvent event) async {
    final id = await DatabaseService.instance.insertEvent(event);
    final saved = event.copyWith(id: id);
    _events.add(saved);
    _sortEvents();
    await NotificationService.instance.scheduleEventReminders(saved);
    notifyListeners();
  }

  Future<void> updateEvent(LunarEvent event) async {
    await DatabaseService.instance.updateEvent(event);
    final idx = _events.indexWhere((e) => e.id == event.id);
    if (idx != -1) _events[idx] = event;
    await NotificationService.instance.cancelEventReminders(event.id!);
    await NotificationService.instance.scheduleEventReminders(event);
    notifyListeners();
  }

  Future<void> deleteEvent(int id) async {
    await DatabaseService.instance.deleteEvent(id);
    await NotificationService.instance.cancelEventReminders(id);
    _events.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void _sortEvents() {
    _events.sort((a, b) {
      final mCmp = a.lunarMonth.compareTo(b.lunarMonth);
      if (mCmp != 0) return mCmp;
      return a.lunarDay.compareTo(b.lunarDay);
    });
  }

  List<LunarEvent> getEventsForLunarDate(int day, int month) {
    return _events.where((e) => e.lunarDay == day && e.lunarMonth == month).toList();
  }

  List<LunarEvent> getUpcomingEvents(DateTime from, {int? daysAhead}) {
    final fromDate = DateTime(from.year, from.month, from.day);
    final toDate = daysAhead != null ? fromDate.add(Duration(days: daysAhead)) : null;
    final List<_EventWithDate> dated = [];

    for (final event in _events) {
      DateTime? found;
      // Tìm lần xảy ra kế tiếp vào hoặc sau hôm nay (thử năm âm hiện tại rồi 2 năm sau).
      for (int yOffset = 0; yOffset <= 2; yOffset++) {
        final solar = _nextSolarDate(event, from.year + yOffset);
        if (solar != null && !solar.isBefore(fromDate)) {
          found = solar;
          break;
        }
      }
      if (found == null) continue;
      if (toDate != null && !found.isBefore(toDate)) continue;
      dated.add(_EventWithDate(event, found));
    }
    dated.sort((a, b) => a.date.compareTo(b.date));
    return dated.map((e) => e.event).toList();
  }

  Map<DateTime, List<LunarEvent>> getEventsForMonth(int year, int month) {
    final result = <DateTime, List<LunarEvent>>{};
    for (final event in _events) {
      for (int yOffset = -1; yOffset <= 1; yOffset++) {
        final solar = _nextSolarDate(event, year + yOffset);
        if (solar != null &&
            solar.year == year &&
            solar.month == month) {
          final key = DateTime(solar.year, solar.month, solar.day);
          result[key] = [...(result[key] ?? []), event];
        }
      }
    }
    return result;
  }

  DateTime? _nextSolarDate(LunarEvent event, int solarYear) {
    try {
      final lunarYear = event.lunarYear ?? LunarConverter.solarToLunar(DateTime(solarYear, 6, 1)).year;
      return LunarConverter.lunarToSolar(
        event.lunarDay,
        event.lunarMonth,
        lunarYear,
        isLeap: event.isLeapMonth,
      );
    } catch (_) {
      return null;
    }
  }

  DateTime? getSolarDate(LunarEvent event, int forSolarYear) => _nextSolarDate(event, forSolarYear);

  /// Ngày dương của lần xảy ra kế tiếp, vào hoặc sau [from].
  /// Sự kiện hàng năm sẽ tự nhảy sang năm sau nếu năm nay đã qua;
  /// sự kiện một lần trả về ngày cố định của nó (có thể đã qua).
  DateTime? getNextOccurrence(LunarEvent event, DateTime from) {
    if (event.recurrence == RecurrenceType.once) {
      return _nextSolarDate(event, event.lunarYear ?? from.year);
    }
    final fromDate = DateTime(from.year, from.month, from.day);
    for (int yOffset = 0; yOffset <= 2; yOffset++) {
      final solar = _nextSolarDate(event, from.year + yOffset);
      if (solar != null && !solar.isBefore(fromDate)) return solar;
    }
    return _nextSolarDate(event, from.year);
  }
}

class DateTimeRange {
  final DateTime start;
  final DateTime end;
  const DateTimeRange({required this.start, required this.end});
}
