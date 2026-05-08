import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:notes/features/task/models/task_model.dart';
import '../../../database/database_helper.dart';

class TaskViewModel extends ChangeNotifier {
  List<TaskModel> allTasks = [];
  List<TaskModel> get allTask=> allTasks;

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
    log('Task updated: ${task.title}');
    await loadTasks();
  }

  Future<void> deleteTask(TaskModel task) async {
    log('Attempting to delete task: ${task.id}');
    await DatabaseHelper().deleteTask(task.id);
    log('Task deleted: ${task.id}');
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
