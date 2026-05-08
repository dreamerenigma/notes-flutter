import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_sizes.dart';
import '../../../../utils/constants/app_vectors.dart';
import '../popups/calendar_dialog.dart';

class ReminderCard extends StatefulWidget {
  final bool hasReminder;
  final DateTime? selectedDateTime;
  final VoidCallback onTap;

  const ReminderCard({
    super.key,
    required this.hasReminder,
    required this.selectedDateTime,
    required this.onTap,
  });

  @override
  State<ReminderCard> createState() => _ReminderCardState();
}

class _ReminderCardState extends State<ReminderCard> {
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
          decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.dark ? AppColors.greySlate : AppColors.softGrey, borderRadius: BorderRadius.circular(16)),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: widget.hasReminder ? _buildReminderContent(context) : _buildAddReminderContent(() async {
              final result = await showCustomCalendarDialog(context);

              if (result != null) {}
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildAddReminderContent(VoidCallback onTap) {
    return Material(
      color: AppColors.transparent,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashFactory: NoSplash.splashFactory,
        splashColor: AppColors.softNight,
        highlightColor: AppColors.softNight,
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

  Widget _buildReminderContent(BuildContext context) {
    return Column(
      key: const ValueKey('hasReminder'),
      children: [
        Material(
          color: AppColors.transparent,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(12),
            splashFactory: NoSplash.splashFactory,
            splashColor: AppColors.softNight,
            highlightColor: AppColors.softNight,
            hoverColor: AppColors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
              child: Row(
                children: [
                  const Icon(Icons.notifications_active, color: AppColors.blueAccent, size: 26),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Напоминание установлено', style: TextStyle(fontSize: AppSizes.fontSizeMd, fontWeight: FontWeight.w400, color: AppColors.blueAccent))),
                  SvgPicture.asset(AppVectors.close, width: 20, height: 20, colorFilter: ColorFilter.mode(context.isDarkMode ? AppColors.white : AppColors.black, BlendMode.srcIn)),
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
            onTap: () {},
            borderRadius: BorderRadius.circular(12),
            splashFactory: NoSplash.splashFactory,
            splashColor: AppColors.softNight,
            highlightColor: AppColors.softNight,
            hoverColor: AppColors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
              child: Row(
                children: [
                  SvgPicture.asset(AppVectors.repeat, width: 20, height: 20, colorFilter: ColorFilter.mode(context.isDarkMode ? AppColors.white : AppColors.black, BlendMode.srcIn)),
                  const SizedBox(width: 10),
                  Text('Повтор', style: TextStyle(fontSize: AppSizes.fontSizeMd, color: context.isDarkMode ? AppColors.white : AppColors.black, fontWeight: FontWeight.w400)),
                  const Spacer(),
                  Text('Никогда', style: TextStyle(fontSize: AppSizes.fontSizeSm, color: AppColors.darkGrey, fontWeight: FontWeight.w400)),
                  const Icon(Icons.keyboard_arrow_right, color: AppColors.darkGrey),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
