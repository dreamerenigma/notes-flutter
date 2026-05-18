extension DateTimeExtension on DateTime {
  DateTime get startOfDay => DateTime(year, month, day);

  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
