import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:intl/intl.dart';
import '../../../../core/enums/repeat_type.dart';
import '../../../../core/extensions/repeat_type_extension.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_sizes.dart';
import '../../../../utils/constants/app_vectors.dart';
import '../popups/calendar_dialog.dart';
import '../popups/repeat_bottom_sheet_dialog.dart';

class ReminderCard extends StatefulWidget {
  final bool hasReminder;
  final DateTime? selectedDateTime;
  final VoidCallback onTap;
  final ValueChanged<DateTime?> onChanged;
  final ValueChanged<RepeatType> onRepeatChanged;
  final VoidCallback onRemove;
  final RepeatType repeatType;

  const ReminderCard({
    super.key,
    required this.hasReminder,
    required this.selectedDateTime,
    required this.onTap,
    required this.onChanged,
    required this.onRepeatChanged,
    required this.onRemove,
    required this.repeatType,
  });

  @override
  State<ReminderCard> createState() => _ReminderCardState();
}

class _ReminderCardState extends State<ReminderCard> {
  Future<void> _openDialog() async {
    final result = await showCustomCalendarDialog(context, widget.selectedDateTime);

    if (result != null) {
      widget.onChanged(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColors.softNight,
        highlightColor: AppColors.softNight,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: context.isDarkMode ? AppColors.greySlate : AppColors.softGrey, borderRadius: BorderRadius.circular(16)),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: widget.hasReminder ? _buildReminderContent(context, _openDialog) : _buildAddReminderContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildAddReminderContent() {
    return Material(
      color: AppColors.transparent,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        splashFactory: NoSplash.splashFactory,
        splashColor: AppColors.softNight,
        highlightColor: AppColors.softNight,
        hoverColor: AppColors.softNight.withAlpha((0.1 * 255).toInt()),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          child: Row(
            key: const ValueKey('addReminder'),
            children: [
              const Icon(Icons.notifications_none, color: AppColors.darkGrey, size: 30),
              const SizedBox(width: 12),
              Expanded(child: Text('Добавить напоминание', style: TextStyle(fontSize: AppSizes.fontSizeMd, fontWeight: FontWeight.w400, color: AppColors.blueAccent))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReminderContent(BuildContext context, VoidCallback onTap) {
    return Column(
      key: const ValueKey('hasReminder'),
      children: [
        Material(
          color: AppColors.transparent,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            splashFactory: NoSplash.splashFactory,
            splashColor: AppColors.softNight,
            highlightColor: AppColors.softNight,
            hoverColor: AppColors.transparent,
            child: Padding(
              padding: const EdgeInsets.only(left: 10, top: 4, bottom: 4),
              child: Row(
                children: [
                  SvgPicture.asset(AppVectors.notifications, colorFilter: ColorFilter.mode(context.isDarkMode ? AppColors.white : AppColors.black, BlendMode.srcIn), width: 26, height: 26),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.selectedDateTime != null
                        ? (() {
                            final date = widget.selectedDateTime!;
                            final now = DateTime.now();
                            final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
                            final tomorrow = DateTime(now.year, now.month, now.day + 1);
                            final isTomorrow = date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day + 1;

                            if (isToday) {
                              return DateFormat('HH:mm').format(date);
                            }

                            if (isTomorrow) {
                              return DateFormat('dd MMM, HH:mm').format(date);
                            }

                            final isSameYear = date.year == now.year;

                            if (isSameYear) {
                              return DateFormat('dd MMM, HH:mm').format(date);
                            }

                            return DateFormat('d MMMM yyyy г., HH:mm').format(date);
                          })()
                        : 'Напоминание установлено',
                      style: TextStyle(fontSize: AppSizes.fontSizeMd, fontWeight: FontWeight.w400, color: AppColors.blueAccent),
                    ),
                  ),
                  InkWell(
                    onTap: widget.onRemove,
                    borderRadius: BorderRadius.circular(12),
                    splashColor: AppColors.softNight,
                    highlightColor: AppColors.softNight,
                    hoverColor: AppColors.softNight,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: SvgPicture.asset(AppVectors.close, width: 20, height: 20, colorFilter: ColorFilter.mode(context.isDarkMode ? AppColors.white : AppColors.black, BlendMode.srcIn)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Divider(height: 0, thickness: 1, color: AppColors.darkGrey.withAlpha((0.3 * 255).toInt()), indent: 15, endIndent: 20),
        Material(
          color: AppColors.transparent,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () async {
              final result = await showRepeatBottomSheetDialog(context, currentValue: widget.repeatType);

              if (result != null) {
                widget.onRepeatChanged(result);
              }
            },
            borderRadius: BorderRadius.circular(12),
            splashFactory: NoSplash.splashFactory,
            splashColor: AppColors.softNight,
            highlightColor: AppColors.softNight,
            hoverColor: AppColors.transparent,
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 6, top: 14, bottom: 14),
              child: Row(
                children: [
                  SvgPicture.asset(AppVectors.repeat, width: 25, height: 25, colorFilter: ColorFilter.mode(context.isDarkMode ? AppColors.white : AppColors.black, BlendMode.srcIn)),
                  const SizedBox(width: 12),
                  Text('Повтор', style: TextStyle(fontSize: AppSizes.fontSizeMd, color: context.isDarkMode ? AppColors.white : AppColors.black, fontWeight: FontWeight.w400)),
                  const Spacer(),
                  Text(widget.repeatType.label, style: TextStyle(fontSize: AppSizes.fontSizeSm, color: AppColors.darkGrey, fontWeight: FontWeight.w400)),
                  const Icon(Icons.keyboard_arrow_right_rounded, color: AppColors.darkGrey),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
