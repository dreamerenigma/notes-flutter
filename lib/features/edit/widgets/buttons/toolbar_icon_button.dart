import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import '../../../../utils/constants/app_colors.dart';

class ToolbarIconButton extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  final double size;
  final Color? color;

  const ToolbarIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.active = false,
    this.size = 32,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? (active ? AppColors.blueAccent : context.isDarkMode ? AppColors.white : AppColors.black);

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        splashColor: AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()),
        highlightColor: AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()),
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(6), child: Icon(icon, size: size, color: resolvedColor)),
      ),
    );
  }
}
