import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_sizes.dart';

Future<DateTime?> showCustomCalendarDialog(BuildContext context) {
  return showDialog<DateTime>(
    context: context,
    builder: (BuildContext context) {
      return CustomCalendarDialog();
    },
  );
}

class CustomCalendarDialog extends StatefulWidget {
  const CustomCalendarDialog({super.key});

  @override
  CustomCalendarDialogState createState() => CustomCalendarDialogState();
}

class CustomCalendarDialogState extends State<CustomCalendarDialog> {
  final List<String> hours = List.generate(24, (index) => index.toString().padLeft(2, '0'));
  final List<String> minutes = List.generate(60, (index) => index.toString().padLeft(2, '0'));
  late DateTime selectedDateTime;

  @override
  void initState() {
    super.initState();
    selectedDateTime = DateTime.now();
  }

  String formatSelectedDate(DateTime dateTime) {
    return DateFormat('E, d MMM yyyy г.').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().startOfDay;
    final initialDateIndex = List.generate(10 * 372, (index) {
      final yearOffset = (index ~/ 372);
      final monthIndex = (index % 372) ~/ 31;
      final dayIndex = (index % 372) % 31;
      final year = DateTime.now().year + yearOffset;
      final month = monthIndex + 1;
      final day = dayIndex + 1;
      final date = DateTime(year, month, day);
      return date.isAtSameMomentAs(today) ? index : -1;
    }).firstWhere((index) => index != -1, orElse: () => 0);

    return Dialog(
      insetPadding: const EdgeInsets.all(12),
      backgroundColor: AppColors.transparent,
      child: Stack(
        children: [
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? AppColors.greySlate : AppColors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(25), bottom: Radius.circular(25)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formatSelectedDate(selectedDateTime),
                    style: TextStyle(fontSize: AppSizes.fontSizeBg, color: Theme.of(context).brightness == Brightness.dark ? AppColors.white : AppColors.black),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 30),
                          child: SizedBox(
                            height: 200,
                            child: ListWheelScrollView.useDelegate(
                              itemExtent: 40,
                              diameterRatio: 1.5,
                              controller: FixedExtentScrollController(initialItem: initialDateIndex),
                              childDelegate: ListWheelChildBuilderDelegate(
                                builder: (context, index) {
                                  final yearOffset = (index ~/ 372);
                                  final monthIndex = (index % 372) ~/ 31;
                                  final dayIndex = (index % 372) % 31;

                                  final year = DateTime.now().year + yearOffset;
                                  final month = monthIndex + 1;
                                  final day = dayIndex + 1;

                                  final date = DateTime(year, month, day);
                                  final isToday = date.isAtSameMomentAs(today);
                                  final formattedDate = isToday ? 'Сегодня' : '$day ${DateFormat('MMM').format(date)}';

                                  return ListTile(
                                    title: Text(
                                      formattedDate,
                                      style: TextStyle(color: selectedDateTime.day == day && selectedDateTime.month == month ? AppColors.blueAccent : Theme.of(context).brightness == Brightness.dark ? AppColors.white : AppColors.black, fontSize: AppSizes.fontSizeLg),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        selectedDateTime = DateTime(year, month, day, selectedDateTime.hour, selectedDateTime.minute);
                                      });
                                    },
                                  );
                                },
                                childCount: 10 * 372,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height: 200,
                          child: ListWheelScrollView.useDelegate(
                            itemExtent: 40,
                            diameterRatio: 1.5,
                            controller: FixedExtentScrollController(initialItem: selectedDateTime.hour),
                            childDelegate: ListWheelChildBuilderDelegate(
                              builder: (context, index) {
                                final hour = hours[index % hours.length];
                                final isCurrentHour = selectedDateTime.hour.toString().padLeft(2, '0') == hour;

                                return ListTile(
                                  title: Text(
                                    hour,
                                    style: TextStyle(color: isCurrentHour ? AppColors.blueAccent : Theme.of(context).brightness == Brightness.dark ? AppColors.white : AppColors.black, fontSize: AppSizes.fontSizeLg),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      selectedDateTime = DateTime(selectedDateTime.year, selectedDateTime.month, selectedDateTime.day, int.parse(hour));
                                    });
                                  },
                                );
                              },
                              childCount: hours.length * 3,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height: 200,
                          child: ListWheelScrollView.useDelegate(
                            itemExtent: 40,
                            diameterRatio: 1.5,
                            controller: FixedExtentScrollController(initialItem: selectedDateTime.minute),
                            childDelegate: ListWheelChildBuilderDelegate(
                              builder: (context, index) {
                                final minute = minutes[index % minutes.length];
                                final isCurrentMinute = selectedDateTime.minute.toString().padLeft(2, '0') == minute;

                                return ListTile(
                                  title: Text(
                                    minute,
                                    style: TextStyle(
                                      color: isCurrentMinute ? AppColors.blueAccent : Theme.of(context).brightness == Brightness.dark ? AppColors.white : AppColors.black,
                                      fontSize: AppSizes.fontSizeLg,
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      selectedDateTime = DateTime(
                                        selectedDateTime.year,
                                        selectedDateTime.month,
                                        selectedDateTime.day,
                                        selectedDateTime.hour,
                                        int.parse(minute),
                                      );
                                    });
                                  },
                                );
                              },
                              childCount: minutes.length * 3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.blueAccent,
                            overlayColor: AppColors.blueAccent.withAlpha((0.2 * 255).toInt()),
                            backgroundColor: AppColors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: Text('ОТМЕНА', style: TextStyle(fontSize: AppSizes.fontSizeLg, color: AppColors.blueAccent)),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(width: 1, height: 22, color: AppColors.darkerGrey),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context, selectedDateTime);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.blueAccent,
                            overlayColor: AppColors.blueAccent.withAlpha((0.2 * 255).toInt()),
                            backgroundColor: AppColors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: Text('ОК', style: TextStyle(fontSize: AppSizes.fontSizeLg, color: AppColors.blueAccent)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension DateTimeExtension on DateTime {
  DateTime get startOfDay => DateTime(year, month, day);
  bool isAtSameMomentAs(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
