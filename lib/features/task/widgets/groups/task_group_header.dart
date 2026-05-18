import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_sizes.dart';

class TaskGroupHeader extends StatelessWidget {
  final String title;
  final bool isExpanded;
  final bool canCollapse;
  final VoidCallback onTap;

  const TaskGroupHeader({
    super.key,
    required this.title,
    required this.isExpanded,
    required this.canCollapse,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        splashFactory: NoSplash.splashFactory,
        splashColor: AppColors.transparent,
        highlightColor: AppColors.transparent,
        hoverColor: AppColors.transparent,
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 14),
          child: Row(
            children: [
              Text(title, style: TextStyle(fontSize: AppSizes.fontSizeMd, color: context.isDarkMode ? AppColors.white : AppColors.black, fontWeight: FontWeight.w400)),
              const Spacer(),
              if (canCollapse)
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOutCubicEmphasized,
                  child: const Icon(Icons.keyboard_arrow_down_rounded, size: 25, color: AppColors.steelGrey),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
