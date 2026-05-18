import 'dart:developer';
import 'package:notes/features/task/models/task_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../features/note/models/note_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
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
    await deleteDatabase(path);

    log("DB PATH: $path");
    log("DATABASE EXISTS: $exists");

    return await openDatabase(
      path,
      version: 12,
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
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        try {
          if (oldVersion < 12) {
            await db.execute('''ALTER TABLE notes ADD COLUMN updated_at TEXT''');
            await db.execute('''UPDATE notes SET updated_at = created_at''');
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
    log('Deleting note with id: $id');
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
    log('Note deleted: $id');
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
    log('Deleting task with id: $id');
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
    log('Task deleted: $id');
  }
}
