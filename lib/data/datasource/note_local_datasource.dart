import 'package:sqflite/sqflite.dart';
import '../../features/note/models/note_model.dart';
import '../database/database_helper.dart';

class NoteLocalDataSource {
  final DatabaseHelper dbHelper;

  NoteLocalDataSource(this.dbHelper);

  Future<Database> get _db async => await dbHelper.database;

  Future<int> insert(Map<String, dynamic> note) async {
    final db = await _db;

    return db.insert('notes', note, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await _db;

    return await db.query('notes');
  }

  Future<void> update(NoteModel note) async {
    final db = await _db;

    await db.update('notes', note.toMap(), where: 'id = ?', whereArgs: [note.id]);
  }

  Future<void> delete(int id) async {
    final db = await _db;

    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }
}
