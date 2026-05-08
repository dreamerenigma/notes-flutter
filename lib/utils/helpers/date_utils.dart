import 'package:intl/intl.dart';

class DateUtil {
  static String formatDate(DateTime dateTime) {
    final dateFormatter = DateFormat('dd MMM yyyy г., HH:mm');

    String formattedDate = dateFormatter.format(dateTime);

    final monthNames = {
      'Jan': 'янв.',
      'Feb': 'фев.',
      'Mar': 'март',
      'Apr': 'апр.',
      'May': 'май',
      'Jun': 'июн.',
      'Jul': 'июл.',
      'Aug': 'авг.',
      'Sep': 'сен.',
      'Oct': 'окт.',
      'Nov': 'ноя.',
      'Dec': 'дек.',
    };

    for (var month in monthNames.keys) {
      formattedDate = formattedDate.replaceFirst(month, monthNames[month]!);
    }

    return formattedDate;
  }
}
