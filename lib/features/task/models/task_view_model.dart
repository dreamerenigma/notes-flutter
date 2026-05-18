import 'package:flutter/foundation.dart';
import 'package:notes/features/task/models/task_model.dart';
import '../../../database/database_helper.dart';

class TaskViewModel extends ChangeNotifier {
  List<TaskModel> allTasks = [];
  List<TaskModel> get allTask=> allTasks;
  int get taskCount => allTasks.length;

  TaskViewModel() {
    loadTasks();
  }

  Future<void> loadTasks() async {
    allTasks = await fetchAllTasks();
    notifyListeners();
  }

  Future<void> addTask(TaskModel task) async {
    await DatabaseHelper().insertTask(task.toMap(includeId: false));
    await loadTasks();
  }

  Future<void> updateTask(TaskModel task) async {
    await DatabaseHelper().updateTask(task);
    await loadTasks();
  }

  Future<void> updateTasks(List<TaskModel> tasks) async {
    final db = await DatabaseHelper().database;
    final batch = db.batch();

    for (final task in tasks) {
      batch.update('tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
    }

    await batch.commit(noResult: true);
    await loadTasks();
  }

  Future<void> deleteTask(TaskModel task) async {
    await DatabaseHelper().deleteTask(task.id);
    await loadTasks();
  }

  Future<List<TaskModel>> fetchAllTasks() async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');

    return List.generate(maps.length, (i) {
      return TaskModel.fromMap(maps[i]);
    });
  }
}
