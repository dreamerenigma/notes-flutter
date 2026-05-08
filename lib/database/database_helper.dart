import 'dart:developer';
import 'package:notes/features/task/models/task_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../features/note/models/note_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'notes.db');
    // await deleteDatabase(path);

    return await openDatabase(
      path,
      version: 7,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE notes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          created_at TEXT NOT NULL,
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
          is_completed INTEGER DEFAULT 0,
          is_important INTEGER DEFAULT 0
        )
      ''');
        await db.execute('PRAGMA journal_mode=WAL');
      },

      onUpgrade: (db, oldVersion, newVersion) async {},
    );
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
