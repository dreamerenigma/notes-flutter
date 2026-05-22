import 'dart:developer';
import 'package:notes/features/task/models/task_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../features/note/models/note_model.dart';
import '../features/settings/models/settings_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static DatabaseHelper get instance => _instance;
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();
  Database? _database;
  Future<Database>? _databaseFuture;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _databaseFuture ??= _initDB();
    _database = await _databaseFuture!;

    return _database!;
  }

  ///******************* Database *******************
  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'notes.db');
    final exists = await databaseExists(path);
    log("DB EXISTS: $exists");

    return await openDatabase(
      path,
      version: 17,
      onConfigure: (db) async {
        log("⚙️ DB CONFIGURE");
      },
      onOpen: (db) async {
        final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");

        log("✅ DB OPENED");
        log("TABLES: $tables");
      },
      onCreate: (db, version) async {
        log("🔥 DB CREATED");
        await db.execute('''
          CREATE TABLE notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            image_path TEXT,
            category TEXT,
            category_color INTEGER,
            is_favorite INTEGER DEFAULT 0,
            is_deleted INTEGER DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT,
            created_at TEXT NOT NULL,
            due_date TEXT,
            note TEXT,
            is_completed INTEGER DEFAULT 0,
            is_important INTEGER DEFAULT 0,
            category TEXT,
            category_color INTEGER,
            repeat_type TEXT DEFAULT 'none'
          )
        ''');
        await db.execute('''
          CREATE TABLE settings (
            id INTEGER PRIMARY KEY,
            theme TEXT,
            language TEXT,
            default_category INT,
            default_category_color INTEGER,
            password_enabled INTEGER,
            week_start INTEGER NOT NULL DEFAULT 1,
            watermark_text TEXT
          )
        ''');
        await db.insert(
          'settings',
          {
            'id': 1,
            'theme': 'light',
            'language': 'ru',
            'default_category': null,
            'default_category_color': null,
            'password_enabled': 0,
            'week_start': 1,
            'watermark_text': null,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        try {
          if (oldVersion < 17) {

          }
        } catch (e) {
          log("❌ MIGRATION ERROR: $e");
        }
      },
    );
  }

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      _databaseFuture = null;
    }
  }

  ///******************* Note *******************
  Future<void> insertNote(Map<String, dynamic> note) async {
    try {
      final db = await database;
      final id = await db.insert('notes', note, conflictAlgorithm: ConflictAlgorithm.ignore);
      log("🟢 INSERT RESULT ID: $id");
    } catch (e, stack) {
      log("❌ INSERT ERROR: $e");
      log("STACK: $stack");
    }
  }

  Future<List<NoteModel>> getAllNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('notes');

    return List.generate(maps.length, (i) {
      return NoteModel.fromMap(maps[i]);
    });
  }

  Future<void> updateNote(NoteModel note) async {
    final db = await database;

    await db.update('notes', note.toMap(), where: 'id = ?', whereArgs: [note.id]);
  }

  Future<void> deleteNote(int id) async {
    final db = await database;

    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  ///******************* Task *******************
  Future<void> insertTask(Map<String, dynamic> task) async {
    final db = await database;

    await db.insert('tasks', task, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<List<TaskModel>> getAllTask() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');

    return List.generate(maps.length, (i) {
      return TaskModel.fromMap(maps[i]);
    });
  }

  Future<void> updateTask(TaskModel task) async {
    final db = await database;

    await db.update('tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  Future<void> deleteTask(int id) async {
    final db = await database;

    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  ///******************* Settings *******************
  Future<void> updateSettings(SettingsModel settings) async {
    final db = await database;

    await db.update('settings', settings.toMap(), where: 'id = ?', whereArgs: [settings.id]);
  }

  Future<SettingsModel?> getSettings() async {
    final db = await database;
    final result = await db.query('settings', where: 'id = ?', whereArgs: [1]);

    if (result.isNotEmpty) {
      return SettingsModel.fromMap(result.first);
    }

    return null;
  }

  Future<void> updateLanguage(String lang) async {
    final db = await database;

    await db.update('settings', {'language': lang}, where: 'id = ?', whereArgs: [1]);
  }

  Future<String> getLanguage() async {
    final db = await database;
    final result = await db.query('settings', where: 'id = ?', whereArgs: [1]);

    return result.first['language'] as String? ?? 'ru';
  }
}
