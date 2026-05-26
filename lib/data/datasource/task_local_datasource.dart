import 'dart:developer';

import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';

class TaskLocalDataSource {
  final DatabaseHelper dbHelper;

  TaskLocalDataSource(this.dbHelper);

  Future<Database> get _db async => await dbHelper.database;

  Future<int> insert(Map<String, dynamic> task) async {
    final db = await _db;

    log("🟢 INSERT RAW TASK MAP: $task");

    final id = await db.insert(
      'tasks',
      task,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    log("🟢 INSERT RESULT ID: $id");

    return id;
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await _db;

    return await db.query('tasks');
  }

  Future<void> update(Map<String, dynamic> task) async {
    final db = await _db;

    await db.update('tasks', task, where: 'id = ?', whereArgs: [task['id']]);
  }

  Future<void> delete(int id) async {
    final db = await _db;

    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateBatch(List<Map<String, dynamic>> tasks) async {
    final db = await _db;

    final batch = db.batch();

    for (final task in tasks) {
      batch.update('tasks', task, where: 'id = ?', whereArgs: [task['id']]);
    }

    await batch.commit(noResult: true);
  }
}
