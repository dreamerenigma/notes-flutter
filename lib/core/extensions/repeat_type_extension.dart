import '../enums/repeat_type.dart';

extension RepeatTypeX on RepeatType {
  String get label {
    switch (this) {
      case RepeatType.none:
        return 'Никогда';
      case RepeatType.daily:
        return 'Ежедневно';
      case RepeatType.weekly:
        return 'Еженедельно';
      case RepeatType.monthly:
        return 'Ежемесячно';
      case RepeatType.yearly:
        return 'Ежегодно';
    }
  }
}
