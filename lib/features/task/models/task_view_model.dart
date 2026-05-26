import 'package:flutter/foundation.dart';
import 'package:notes/features/task/models/task_model.dart';
import '../../../data/repositories/tasks_repository.dart';

class TaskViewModel extends ChangeNotifier {
  final TaskRepository repository;

  TaskViewModel(this.repository) {
    loadTasks();
  }

  List<TaskModel> allTasks = [];

  int get taskCount => allTasks.length;

  Future<void> loadTasks() async {
    allTasks = await repository.getTasks();
    notifyListeners();
  }

  Future<void> addTask(TaskModel task) async {
    await repository.addTask(task);
    await loadTasks();
  }

  Future<void> updateTask(TaskModel task) async {
    await repository.updateTask(task);
    await loadTasks();
  }

  Future<void> deleteTask(TaskModel task) async {
    final id = task.id;
    if (id == null) return;

    await repository.deleteTask(id);
    await loadTasks();
  }

  Future<void> updateTasks(List<TaskModel> tasks) async {
    await repository.updateTasksBatch(tasks);
    await loadTasks();
  }
}
