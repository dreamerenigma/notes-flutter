import 'dart:developer';
import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _timeFormat = DateFormat('HH:mm', 'ru_RU');
  static final DateFormat _dateFormat = DateFormat('d MMMM yyyy', 'ru_RU');

  static String formatTime(DateTime createdAt) {
    try {
      final diff = DateTime.now().difference(createdAt);

      if (diff.inMinutes < 1) {
        return 'Только что';
      }

      if (diff.inMinutes < 60) {
        return '${diff.inMinutes} минут${_plural(diff.inMinutes)} назад';
      }

      if (diff.inHours < 24) {
        return 'Сегодня ${_timeFormat.format(createdAt)}';
      }

      if (diff.inDays == 1) {
        return 'Вчера ${_timeFormat.format(createdAt)}';
      }

      return _dateFormat.format(createdAt);
    } catch (e) {
      log("DateFormatter error: $e");
      return createdAt.toString();
    }
  }

  static String _plural(int value) {
    if (value % 10 == 1 && value % 100 != 11) {
      return 'а';
    }

    if (value % 10 >= 2 && value % 10 <= 4 && (value % 100 < 10 || value % 100 >= 20)) {
      return 'ы';
    }

    return '';
  }
}
