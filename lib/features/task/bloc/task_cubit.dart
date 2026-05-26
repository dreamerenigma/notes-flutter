import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/tasks_repository.dart';
import '../models/task_model.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskCubit extends Bloc<TaskEvent, TaskState> {
  final TaskRepository repository;

  TaskCubit(this.repository) : super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<DeleteTask>(_onDeleteTask);
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final tasks = await repository.getTasks();
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(const TaskError('Ошибка загрузки задач'));
    }
  }

  Future<void> _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    try {
      final task = TaskModel(id: null, title: event.title, description: event.description, createdAt: DateTime.now(), dueDate: event.dueDate);
      await repository.addTask(task);
      add(LoadTasks());
    } catch (e) {
      emit(const TaskError('Ошибка добавления задачи'));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    try {
      await repository.deleteTask(event.taskId);
      add(LoadTasks());
    } catch (e) {
      emit(const TaskError('Ошибка удаления задачи'));
    }
  }
}
