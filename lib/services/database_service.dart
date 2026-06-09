import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/lunar_event.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static Database? _db;

  DatabaseService._();

  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'moon_calendar.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE events (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT,
            lunar_day INTEGER NOT NULL,
            lunar_month INTEGER NOT NULL,
            lunar_year INTEGER,
            is_leap_month INTEGER DEFAULT 0,
            recurrence INTEGER DEFAULT 0,
            color_index INTEGER DEFAULT 0,
            created_at INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE reminders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            event_id INTEGER NOT NULL,
            type INTEGER NOT NULL,
            offset INTEGER NOT NULL,
            contact_info TEXT,
            hour INTEGER DEFAULT 8,
            minute INTEGER DEFAULT 0,
            FOREIGN KEY (event_id) REFERENCES events (id) ON DELETE CASCADE
          )
        ''');
        await _createRecipientsTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createRecipientsTable(db);
        }
      },
    );
  }

  Future<void> _createRecipientsTable(Database db) async {
    await db.execute('''
      CREATE TABLE recipients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        event_id INTEGER NOT NULL,
        channel INTEGER NOT NULL,
        address TEXT NOT NULL,
        FOREIGN KEY (event_id) REFERENCES events (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<int> insertEvent(LunarEvent event) async {
    final db = await database;
    final id = await db.insert('events', event.toMap());
    for (final reminder in event.reminders) {
      await db.insert('reminders', reminder.copyWith(eventId: id).toMap());
    }
    for (final recipient in event.recipients) {
      await db.insert('recipients', recipient.copyWith(eventId: id).toMap());
    }
    return id;
  }

  Future<void> updateEvent(LunarEvent event) async {
    final db = await database;
    await db.update('events', event.toMap(), where: 'id = ?', whereArgs: [event.id]);
    await db.delete('reminders', where: 'event_id = ?', whereArgs: [event.id]);
    for (final reminder in event.reminders) {
      await db.insert('reminders', reminder.copyWith(eventId: event.id!).toMap());
    }
    await db.delete('recipients', where: 'event_id = ?', whereArgs: [event.id]);
    for (final recipient in event.recipients) {
      await db.insert('recipients', recipient.copyWith(eventId: event.id!).toMap());
    }
  }

  Future<void> deleteEvent(int id) async {
    final db = await database;
    await db.delete('events', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<LunarEvent>> getAllEvents() async {
    final db = await database;
    final eventMaps = await db.query('events', orderBy: 'lunar_month ASC, lunar_day ASC');
    return Future.wait(eventMaps.map((map) async {
      final reminderMaps = await db.query('reminders', where: 'event_id = ?', whereArgs: [map['id']]);
      final reminders = reminderMaps.map(EventReminder.fromMap).toList();
      final recipientMaps = await db.query('recipients', where: 'event_id = ?', whereArgs: [map['id']]);
      final recipients = recipientMaps.map(EventRecipient.fromMap).toList();
      return LunarEvent.fromMap(map, reminders: reminders, recipients: recipients);
    }));
  }

  Future<List<EventReminder>> getRemindersForEvent(int eventId) async {
    final db = await database;
    final maps = await db.query('reminders', where: 'event_id = ?', whereArgs: [eventId]);
    return maps.map(EventReminder.fromMap).toList();
  }
}
