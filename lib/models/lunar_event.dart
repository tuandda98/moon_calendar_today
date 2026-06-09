enum ReminderType { push, email }

enum RecurrenceType { once, yearly }

enum ReminderOffset { onDay, oneDayBefore, threeDaysBefore, sevenDaysBefore }

enum RecipientChannel { email, sms }

extension RecipientChannelExt on RecipientChannel {
  String get label => this == RecipientChannel.email ? 'Email' : 'SMS';
}

extension ReminderOffsetExt on ReminderOffset {
  int get days {
    switch (this) {
      case ReminderOffset.onDay: return 0;
      case ReminderOffset.oneDayBefore: return 1;
      case ReminderOffset.threeDaysBefore: return 3;
      case ReminderOffset.sevenDaysBefore: return 7;
    }
  }

  String get label {
    switch (this) {
      case ReminderOffset.onDay: return 'Ngay hôm đó';
      case ReminderOffset.oneDayBefore: return '1 ngày trước';
      case ReminderOffset.threeDaysBefore: return '3 ngày trước';
      case ReminderOffset.sevenDaysBefore: return '7 ngày trước';
    }
  }
}

class EventReminder {
  final int? id;
  final int eventId;
  final ReminderType type;
  final ReminderOffset offset;
  final String? contactInfo;
  final int hour;
  final int minute;

  const EventReminder({
    this.id,
    required this.eventId,
    required this.type,
    required this.offset,
    this.contactInfo,
    this.hour = 8,
    this.minute = 0,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'event_id': eventId,
    'type': type.index,
    'offset': offset.index,
    'contact_info': contactInfo,
    'hour': hour,
    'minute': minute,
  };

  factory EventReminder.fromMap(Map<String, dynamic> map) => EventReminder(
    id: map['id'] as int?,
    eventId: map['event_id'] as int,
    type: ReminderType.values[map['type'] as int],
    offset: ReminderOffset.values[map['offset'] as int],
    contactInfo: map['contact_info'] as String?,
    hour: map['hour'] as int? ?? 8,
    minute: map['minute'] as int? ?? 0,
  );

  EventReminder copyWith({
    int? id,
    int? eventId,
    ReminderType? type,
    ReminderOffset? offset,
    String? contactInfo,
    int? hour,
    int? minute,
  }) => EventReminder(
    id: id ?? this.id,
    eventId: eventId ?? this.eventId,
    type: type ?? this.type,
    offset: offset ?? this.offset,
    contactInfo: contactInfo ?? this.contactInfo,
    hour: hour ?? this.hour,
    minute: minute ?? this.minute,
  );
}

/// Người nhận nhắc nhở cho một sự kiện (để 1 người nhắc nhiều người).
/// [address] là email hoặc số điện thoại tùy [channel].
class EventRecipient {
  final int? id;
  final int eventId;
  final RecipientChannel channel;
  final String address;

  const EventRecipient({
    this.id,
    required this.eventId,
    required this.channel,
    required this.address,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'event_id': eventId,
    'channel': channel.index,
    'address': address,
  };

  factory EventRecipient.fromMap(Map<String, dynamic> map) => EventRecipient(
    id: map['id'] as int?,
    eventId: map['event_id'] as int,
    channel: RecipientChannel.values[map['channel'] as int],
    address: map['address'] as String,
  );

  EventRecipient copyWith({int? id, int? eventId, RecipientChannel? channel, String? address}) =>
      EventRecipient(
        id: id ?? this.id,
        eventId: eventId ?? this.eventId,
        channel: channel ?? this.channel,
        address: address ?? this.address,
      );
}

class LunarEvent {
  final int? id;
  final String title;
  final String? description;
  final int lunarDay;
  final int lunarMonth;
  final int? lunarYear;
  final bool isLeapMonth;
  final RecurrenceType recurrence;
  final int colorIndex;
  final List<EventReminder> reminders;
  final List<EventRecipient> recipients;
  final DateTime? createdAt;

  const LunarEvent({
    this.id,
    required this.title,
    this.description,
    required this.lunarDay,
    required this.lunarMonth,
    this.lunarYear,
    this.isLeapMonth = false,
    this.recurrence = RecurrenceType.yearly,
    this.colorIndex = 0,
    this.reminders = const [],
    this.recipients = const [],
    this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'title': title,
    'description': description,
    'lunar_day': lunarDay,
    'lunar_month': lunarMonth,
    'lunar_year': lunarYear,
    'is_leap_month': isLeapMonth ? 1 : 0,
    'recurrence': recurrence.index,
    'color_index': colorIndex,
    'created_at': (createdAt ?? DateTime.now()).millisecondsSinceEpoch,
  };

  factory LunarEvent.fromMap(Map<String, dynamic> map, {List<EventReminder> reminders = const [], List<EventRecipient> recipients = const []}) => LunarEvent(
    id: map['id'] as int?,
    title: map['title'] as String,
    description: map['description'] as String?,
    lunarDay: map['lunar_day'] as int,
    lunarMonth: map['lunar_month'] as int,
    lunarYear: map['lunar_year'] as int?,
    isLeapMonth: (map['is_leap_month'] as int? ?? 0) == 1,
    recurrence: RecurrenceType.values[map['recurrence'] as int? ?? 0],
    colorIndex: map['color_index'] as int? ?? 0,
    reminders: reminders,
    recipients: recipients,
    createdAt: map['created_at'] != null
        ? DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int)
        : null,
  );

  LunarEvent copyWith({
    int? id,
    String? title,
    String? description,
    int? lunarDay,
    int? lunarMonth,
    int? lunarYear,
    bool? isLeapMonth,
    RecurrenceType? recurrence,
    int? colorIndex,
    List<EventReminder>? reminders,
    List<EventRecipient>? recipients,
    DateTime? createdAt,
  }) => LunarEvent(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    lunarDay: lunarDay ?? this.lunarDay,
    lunarMonth: lunarMonth ?? this.lunarMonth,
    lunarYear: lunarYear ?? this.lunarYear,
    isLeapMonth: isLeapMonth ?? this.isLeapMonth,
    recurrence: recurrence ?? this.recurrence,
    colorIndex: colorIndex ?? this.colorIndex,
    reminders: reminders ?? this.reminders,
    recipients: recipients ?? this.recipients,
    createdAt: createdAt ?? this.createdAt,
  );

  String get lunarDateString {
    String s = '${lunarDay.toString().padLeft(2, '0')}/${lunarMonth.toString().padLeft(2, '0')}';
    if (lunarYear != null) s += '/$lunarYear';
    if (isLeapMonth) s += ' (nhuận)';
    return s;
  }
}

const List<String> eventColorNames = [
  'Đỏ',
  'Vàng',
  'Xanh dương',
  'Xanh lá',
  'Tím',
  'Cam',
];
