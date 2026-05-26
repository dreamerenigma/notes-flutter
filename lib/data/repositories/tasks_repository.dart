import 'dart:developer';

import '../../features/task/models/task_model.dart';
import '../datasource/task_local_datasource.dart';

class TaskRepository {
  final TaskLocalDataSource local;

  TaskRepository(this.local);

  Future<void> addTask(TaskModel task) async {
    final map = task.toMap();
    log("🟡 toMap OUTPUT: $map");

    await local.insert(map);
  }

  Future<List<TaskModel>> getTasks() async {
    final maps = await local.getAll();

    return maps.map((e) => TaskModel.fromMap(e)).toList();
  }

  Future<void> updateTask(TaskModel task) async {
    await local.update(task.toMap());
  }

  Future<void> deleteTask(int id) async {
    await local.delete(id);
  }

  Future<void> updateTasksBatch(List<TaskModel> tasks) async {
    await local.updateBatch(tasks.map((e) => e.toMap()).toList());
  }
}
