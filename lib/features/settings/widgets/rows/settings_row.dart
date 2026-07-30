import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_sizes.dart';

class SettingsRow extends StatefulWidget {
  final String title;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingsRow({
    super.key,
    required this.title,
    this.leading,
    this.trailing,
    this.onTap,
  });

  @override
  State<SettingsRow> createState() => _SettingsRowState();
}

class _SettingsRowState extends State<SettingsRow> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        splashFactory: NoSplash.splashFactory,
        borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
        splashColor: context.isDarkMode ? AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()) : AppColors.darkGrey.withAlpha((0.2 * 255).toInt()),
        highlightColor: context.isDarkMode ? AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()) : AppColors.darkGrey.withAlpha((0.2 * 255).toInt()),
        hoverColor: context.isDarkMode ? AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()) : AppColors.darkGrey.withAlpha((0.2 * 255).toInt()),
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          child: Row(
            children: [
              if (widget.leading != null) ...[
                ?widget.leading,
                const SizedBox(width: 14),
              ],
              Expanded(child: Text(widget.title, style: TextStyle(fontSize: AppSizes.fontSizeMd))),
              if (widget.trailing != null) ...[
                ?widget.trailing,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
