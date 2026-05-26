import '../enums/week_start_type.dart';

extension WeekStartX on WeekStartType {
  int get value => switch (this) {
    WeekStartType.monday => 1,
    WeekStartType.sunday => 0,
  };

  static WeekStartType fromInt(int value) {
    return value == 1 ? WeekStartType.monday : WeekStartType.sunday;
  }
}
