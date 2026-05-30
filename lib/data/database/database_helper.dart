import 'dart:developer';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
      version: 20,
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
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            theme TEXT,
            language TEXT,
            default_category INT,
            default_category_color INTEGER,
            password_enabled INTEGER,
            week_start INTEGER NOT NULL DEFAULT 1,
            watermark_text TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE folders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            icon TEXT,
            position INTEGER NOT NULL DEFAULT 0,
            created_at INTEGER,
            updated_at INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE categories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            folder_id INTEGER,
            title TEXT NOT NULL,
            color INTEGER,
            stripe_color INTEGER,
            position INTEGER,
            created_at INTEGER,
            updated_at INTEGER,
            svg_asset TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        try {
          if (oldVersion < 20) {

          }
        } catch (e) {
          log("❌ MIGRATION ERROR: $e");
        }
      },
    );
  }

  Future<void> closeDatabase() async {
    if (_database != null) {
      log("🧹 Closing database");
      await _database!.close();
      _database = null;
      _databaseFuture = null;
    }
  }
}
