import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:url_launcher/url_launcher.dart';
import '../models/lunar_event.dart';
import '../utils/lunar_converter.dart';

class NotificationService {
  static NotificationService? _instance;
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  NotificationService._();

  static NotificationService get instance {
    _instance ??= NotificationService._();
    return _instance!;
  }

  Future<void> initialize() async {
    if (_initialized) return;
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(settings);
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    final android = await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    final ios = await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    return android ?? ios ?? false;
  }

  Future<void> scheduleEventReminders(LunarEvent event) async {
    if (event.id == null) return;
    await cancelEventReminders(event.id!);

    final now = DateTime.now();
    for (int yearOffset = 0; yearOffset <= 2; yearOffset++) {
      final targetYear = now.year + yearOffset;
      final lunarYear = event.recurrence == RecurrenceType.yearly
          ? LunarConverter.solarToLunar(DateTime(targetYear)).year
          : (event.lunarYear ?? targetYear);

      DateTime? solarDate = LunarConverter.lunarToSolar(
        event.lunarDay,
        event.lunarMonth,
        lunarYear,
        isLeap: event.isLeapMonth,
      );
      if (solarDate == null) continue;

      for (final reminder in event.reminders) {
        if (reminder.type == ReminderType.push) {
          final triggerDate = solarDate.subtract(Duration(days: reminder.offset.days));
          final scheduledTime = DateTime(
            triggerDate.year,
            triggerDate.month,
            triggerDate.day,
            reminder.hour,
            reminder.minute,
          );
          if (scheduledTime.isAfter(now)) {
            await _schedulePushNotification(event, reminder, scheduledTime, yearOffset);
          }
        }
      }
    }
  }

  Future<void> _schedulePushNotification(
    LunarEvent event,
    EventReminder reminder,
    DateTime scheduledTime,
    int yearOffset,
  ) async {
    final notifId = _notifId(event.id!, reminder.id ?? 0, yearOffset);
    final body = reminder.offset.days == 0
        ? 'Hôm nay: ${event.lunarDateString}'
        : 'Còn ${reminder.offset.days} ngày - ${event.lunarDateString}';

    await _plugin.zonedSchedule(
      notifId,
      event.title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'lunar_events',
          'Sự kiện lịch âm',
          channelDescription: 'Nhắc nhở sự kiện lịch âm',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: event.recurrence == RecurrenceType.yearly
          ? DateTimeComponents.dayOfMonthAndTime
          : null,
    );
  }

  Future<void> cancelEventReminders(int eventId) async {
    for (int r = 0; r < 10; r++) {
      for (int y = 0; y < 3; y++) {
        await _plugin.cancel(_notifId(eventId, r, y));
      }
    }
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  int _notifId(int eventId, int reminderId, int yearOffset) {
    return eventId * 1000 + reminderId * 10 + yearOffset;
  }

  Future<void> sendEmailReminder(LunarEvent event, String emailAddress) async {
    await composeEmail(to: [emailAddress], subject: 'Nhắc nhở: ${event.title}', body:
      'Sự kiện: ${event.title}\n'
      'Ngày âm: ${event.lunarDateString}\n'
      '${event.description != null ? "Ghi chú: ${event.description}" : ""}');
  }

  /// Mở ứng dụng email với NHIỀU người nhận + nội dung soạn sẵn (người dùng bấm Gửi).
  /// Dùng bcc để các người nhận không thấy email của nhau.
  Future<bool> composeEmail({
    required List<String> to,
    required String subject,
    required String body,
  }) async {
    final addrs = to.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (addrs.isEmpty) return false;
    final query = _buildQuery({
      'bcc': addrs.join(','),
      'subject': subject,
      'body': body,
    });
    final uri = Uri.parse('mailto:?$query');
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  /// Mở ứng dụng tin nhắn với NHIỀU số điện thoại + nội dung soạn sẵn.
  Future<bool> composeSms({
    required List<String> to,
    required String body,
  }) async {
    final nums = to.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (nums.isEmpty) return false;
    final uri = Uri.parse('sms:${nums.join(',')}?${_buildQuery({'body': body})}');
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  String _buildQuery(Map<String, String> params) => params.entries
      .where((e) => e.value.isNotEmpty)
      .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
      .join('&');
}
