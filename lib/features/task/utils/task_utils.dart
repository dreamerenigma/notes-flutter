import '../../../core/enums/screen_type.dart';
import '../models/task_model.dart';

class TaskUtils {
  static bool isToday(DateTime date) {
    final now = DateTime.now();

    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  static bool isTomorrow(DateTime date) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));

    return date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day;
  }

  static String getElementSuffix(int count) {
    if (count % 10 >= 2 && count % 10 <= 4 && (count % 100 < 10 || count % 100 >= 20)) {
      return 'а';
    } else {
      return 'ов';
    }
  }

  static String getTasksText(int count) {
    if (count % 100 >= 11 && count % 100 <= 14) {
      return '$count задач';
    }

    switch (count % 10) {
      case 1:
        return '$count задача';
      case 2:
      case 3:
      case 4:
        return '$count задачи';
      default:
        return '$count задач';
    }
  }

  static Map<String, List<TaskModel>> groupTasks(List<TaskModel> tasks, bool showCompleted) {
    final Map<String, List<TaskModel>> grouped = {};
    final now = DateTime.now();

    for (var task in tasks) {
      if (!showCompleted && task.isCompleted) {
        continue;
      }

      String key;

      if (task.isCompleted) {
        key = 'ВЫПОЛНЕНО';
      } else if (task.dueDate == null) {
        key = 'НЕТ ДАТЫ';
      } else if (task.dueDate!.isBefore(now) && !isToday(task.dueDate!)) {
        key = 'ИСТЁК СРОК';
      } else if (isToday(task.dueDate!)) {
        key = 'СЕГОДНЯ';
      } else if (isTomorrow(task.dueDate!)) {
        key = 'ПОЗЖЕ';
      } else {
        key = 'ДРУГОЕ';
      }

      grouped.putIfAbsent(key, () => []).add(task);
    }

    return grouped;
  }

  static String getNoteCountText(int count) {
    if (count % 10 == 1 && count % 100 != 11) {
      return 'заметка';
    } else if (count % 10 >= 2 && count % 10 <= 4 && (count % 100 < 10 || count % 100 >= 20)) {
      return 'заметки';
    } else {
      return 'заметок';
    }
  }

  static String getTitleText({required bool selectionMode, required int selectedCount, required ScreenType type}) {
    if (!selectionMode) {
      return type == ScreenType.notes ? 'Все заметки' : 'Все задачи';
    }

    if (selectedCount == 0) return 'Не выбрано';

    if (type == ScreenType.notes) {
      final word = getNoteCountText(selectedCount);

      if (selectedCount == 1) {
        return 'Выбрана 1 $word';
      }

      return 'Выбрано $selectedCount $word';
    }


    if (type == ScreenType.tasks) {
      return selectedCount == 1 ? 'Выбрана 1 задача' : 'Выбрано $selectedCount ${getTasksText(selectedCount).replaceFirst('$selectedCount ', '')}';
    }

    return 'Выбрано $selectedCount задач';
  }
}
