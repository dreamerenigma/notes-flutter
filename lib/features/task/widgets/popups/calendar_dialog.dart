import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:notes/features/utils/widgets/scrolls/no_glow_scroll_behavior.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_sizes.dart';
import '../../../../utils/extensions/date_time_extension.dart';

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
  late final DateTime baseDate;
  late final List<DateTime> days;
  late final DateTime today;
  late DateTime selectedDateTime;
  late FixedExtentScrollController minuteController;
  late FixedExtentScrollController hourController;
  late FixedExtentScrollController dayController;
  double dayOffset = 0;
  double hourOffset = 0;
  double minuteOffset = 0;
  int selectedDayIndex = 0;
  int selectedHourIndex = 0;
  int selectedMinuteIndex = 0;

  @override
  void initState() {
    super.initState();
    selectedDateTime = DateTime.now();
    baseDate = DateTime.now().startOfDay;
    days = List.generate(3650, (i) => baseDate.add(Duration(days: i)));

    minuteController = FixedExtentScrollController(initialItem: selectedDateTime.minute);
    hourController = FixedExtentScrollController(initialItem: selectedDateTime.hour);
    dayController = FixedExtentScrollController(initialItem: 0);

    today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    selectedHourIndex = DateTime.now().hour;
  }

  String formatSelectedDate(DateTime dateTime) {
    return DateFormat('E, d MMM yyyy г.').format(dateTime);
  }

  int getInitialDateIndex(DateTime today) {
    return List.generate(10 * 372, (index) {
      final yearOffset = (index ~/ 372);
      final monthIndex = (index % 372) ~/ 31;
      final dayIndex = (index % 372) % 31;
      final year = DateTime.now().year + yearOffset;
      final month = monthIndex + 1;
      final day = dayIndex + 1;
      final date = DateTime(year, month, day);

      return date.isSameDay(today) ? index : -1;
    }).firstWhere((index) => index != -1, orElse: () => 0);
  }

  @override
  Widget build(BuildContext context) {
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
                  Stack(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 30),
                              child: SizedBox(
                                height: 200,
                                child: ScrollConfiguration(
                                  behavior: NoGlowScrollBehavior(),
                                  child: NotificationListener<ScrollNotification>(
                                    onNotification: (notification) {
                                      if (notification is ScrollUpdateNotification) {
                                        setState(() {
                                          dayOffset = notification.metrics.pixels;
                                        });
                                      }
                                      return false;
                                    },
                                    child: ListWheelScrollView.useDelegate(
                                      controller: dayController,
                                      itemExtent: 44,
                                      diameterRatio: 1.6,
                                      perspective: 0.003,
                                      physics: const FixedExtentScrollPhysics(),
                                      onSelectedItemChanged: (index) {
                                        final safeIndex = index.clamp(0, days.length - 1);
                                        final date = days[safeIndex];

                                        setState(() {
                                          selectedDayIndex = safeIndex;
                                          selectedDateTime = DateTime(date.year, date.month, date.day, selectedDateTime.hour, selectedDateTime.minute);
                                        });
                                      },
                                      childDelegate: ListWheelChildBuilderDelegate(
                                        childCount: days.length,
                                        builder: (context, index) {
                                          final date = days[index];
                                          final isToday = date.isSameDay(today);
                                          final isSelected = date.isSameDay(selectedDateTime);
                                          final formattedDate = isToday ? 'Сегодня' : '${date.day} ${DateFormat('MMM').format(date)}';
                                          final isInCenter = index == selectedDayIndex;

                                          return Center(
                                            child: Material(
                                              color: AppColors.transparent,
                                              clipBehavior: Clip.antiAlias,
                                              child: InkWell(
                                                onTap: isInCenter
                                                  ? () {
                                                      setState(() {
                                                        selectedDateTime = DateTime(date.year, date.month, date.day, selectedDateTime.hour, selectedDateTime.minute);
                                                      });
                                                    }
                                                  : null,
                                                borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
                                                splashColor: AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()),
                                                highlightColor: AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()),
                                                hoverColor: AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()),
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                                  child: AnimatedDefaultTextStyle(
                                                    duration: const Duration(milliseconds: 150),
                                                    style: TextStyle(color: isSelected ? AppColors.blueAccent : context.isDarkMode ? AppColors.white : AppColors.black, fontSize: isSelected ? AppSizes.fontSizeLg : 17, fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400),
                                                    child: Text(formattedDate),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SizedBox(
                              height: 200,
                              child: ScrollConfiguration(
                                behavior: NoGlowScrollBehavior(),
                                child: NotificationListener<ScrollNotification>(
                                  onNotification: (n) {
                                    if (n is ScrollUpdateNotification) {
                                      setState(() {
                                        hourOffset = n.metrics.pixels;
                                      });
                                    }
                                    return false;
                                  },
                                  child: ListWheelScrollView.useDelegate(
                                    controller: hourController,
                                    itemExtent: 44,
                                    diameterRatio: 1.6,
                                    perspective: 0.003,
                                    physics: const FixedExtentScrollPhysics(),
                                    onSelectedItemChanged: (index) {
                                      final hour = ((index % 24) + 24) % 24;

                                      setState(() {
                                        selectedHourIndex = hour;
                                        selectedDateTime = DateTime(selectedDateTime.year, selectedDateTime.month, selectedDateTime.day, hour, selectedDateTime.minute);
                                      });
                                    },
                                    childDelegate: ListWheelChildBuilderDelegate(
                                      builder: (context, index) {
                                        final safeIndex = index % 24;
                                        final hour = (safeIndex + 24) % 24;
                                        final isSelected = hour == selectedHourIndex;
                                        final itemExtent = 44.0;
                                        final viewportCenter = 100.0;
                                        final itemCenter = index * itemExtent;
                                        final distanceToCenter = (itemCenter - (hourOffset + viewportCenter)).abs();
                                        final maxDistance = 200.0;
                                        final opacity = (1 - (distanceToCenter / maxDistance)).clamp(0.0, 1.0);

                                        return Center(
                                          child: Material(
                                            color: AppColors.transparent,
                                            child: InkWell(
                                              onTap: isSelected
                                                ? () {
                                                    setState(() {
                                                      selectedHourIndex = hour;
                                                      selectedDateTime = DateTime(selectedDateTime.year, selectedDateTime.month, selectedDateTime.day, hour, selectedDateTime.minute);
                                                    });
                                                  }
                                                : null,
                                              borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
                                              splashColor: AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()),
                                              highlightColor: AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()),
                                              hoverColor: AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                                child: AnimatedDefaultTextStyle(
                                                  duration: const Duration(milliseconds: 150),
                                                  style: TextStyle(color: isSelected ? AppColors.blueAccent : Theme.of(context).brightness == Brightness.dark ? AppColors.white : AppColors.black, fontSize: isSelected ? AppSizes.fontSizeLg : 17, fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400),
                                                  child: Text(hour.toString().padLeft(2, '0')),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SizedBox(
                              height: 200,
                              child: ScrollConfiguration(
                                behavior: NoGlowScrollBehavior(),
                                child: ListWheelScrollView.useDelegate(
                                  controller: minuteController,
                                  itemExtent: 44,
                                  diameterRatio: 1.6,
                                  perspective: 0.003,
                                  physics: const FixedExtentScrollPhysics(),
                                  onSelectedItemChanged: (index) {
                                    final minute = ((index % 60) + 60) % 60;

                                    setState(() {
                                      selectedMinuteIndex = minute;
                                      selectedDateTime = DateTime(selectedDateTime.year, selectedDateTime.month, selectedDateTime.day, selectedDateTime.hour, minute);
                                    });
                                  },
                                  childDelegate: ListWheelChildBuilderDelegate(
                                    builder: (context, index) {
                                      final minute = ((index % 60) + 60) % 60;
                                      final isSelected = selectedDateTime.minute == minute;

                                      return Center(
                                        child: Material(
                                          color: AppColors.transparent,
                                          child: InkWell(
                                            onTap: isSelected
                                              ? () {
                                                  setState(() {
                                                    selectedDateTime = DateTime(selectedDateTime.year, selectedDateTime.month, selectedDateTime.day, selectedDateTime.minute, index);
                                                  });
                                                }
                                              : null,
                                            borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
                                            splashColor: AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()),
                                            highlightColor: AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()),
                                            hoverColor: AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                              child: AnimatedDefaultTextStyle(
                                                duration: const Duration(milliseconds: 150),
                                                style: TextStyle(color: isSelected ? AppColors.blueAccent : context.isDarkMode ? AppColors.white : AppColors.black, fontSize: isSelected ? AppSizes.fontSizeLg : 17, fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400),
                                                child: Text(minute.toString().padLeft(2, '0')),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: 14), color: AppColors.darkerGrey.withAlpha((0.6 * 255).toInt())),
                                const SizedBox(height: 50),
                                Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: 14), color: AppColors.darkerGrey.withAlpha((0.6 * 255).toInt())),
                              ],
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
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
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
                      ),
                      Container(width: 1, height: 25, color: AppColors.darkerGrey),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
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
