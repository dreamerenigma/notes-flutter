import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/task_model.dart';
import '../models/task_view_model.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskCubit extends Bloc<TaskEvent, TaskState> {
  final TaskViewModel taskViewModel;

  TaskCubit(this.taskViewModel) : super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<DeleteTask>(_onDeleteTask);
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final notes = await taskViewModel.fetchAllTasks();
      emit(TaskLoaded(notes));
    } catch (e) {
      emit(const TaskError('Ошибка загрузки задач'));
    }
  }

  Future<void> _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    try {
      final note = TaskModel(id: 0, title: event.title, description: event.description, createdAt: DateTime.now(), dueDate: event.dueDate);
      await taskViewModel.addTask(note);
      add(LoadTasks());
    } catch (e) {
      emit(const TaskError('Ошибка добавления задачи'));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    try {
      final taskToDelete = taskViewModel.allTasks.firstWhere((task) => task.id == event.taskId);
      await taskViewModel.deleteTask(taskToDelete);
      add(LoadTasks());
    } catch (e) {
      emit(const TaskError('Ошибка удаления задачи'));
    }
  }
}
