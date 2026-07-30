import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:notes/utils/constants/app_colors.dart';

import '../../../settings/widgets/dialogs/light_dialog.dart';
import '../../../task/widgets/buttons/custom_radio_button.dart';

class CustomRadioListTile extends StatefulWidget {
  final IconData? icon;
  final Widget title;
  final String value;
  final String groupValue;
  final Function(String?) onChanged;
  final Color iconColor;
  final double iconSize;

  const CustomRadioListTile({
    super.key,
    this.icon,
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.iconColor,
    this.iconSize = 24,
  });

  @override
  CustomRadioListTileState createState() => CustomRadioListTileState();
}

class CustomRadioListTileState extends State<CustomRadioListTile> {
  @override
  Widget build(BuildContext context) {
    final bool isSelected = widget.value == widget.groupValue;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          splashFactory: NoSplash.splashFactory,
          borderRadius: BorderRadius.circular(8),
          splashColor: context.isDarkMode ? AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()) : AppColors.grey.withAlpha((0.4 * 255).toInt()),
          highlightColor: context.isDarkMode ? AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()) : AppColors.grey.withAlpha((0.4 * 255).toInt()),
          hoverColor: context.isDarkMode ? AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()) : AppColors.grey.withAlpha((0.4 * 255).toInt()),
          onTap: () {
            widget.onChanged(widget.value);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.only(left: 14, right: 12, top: 6, bottom: 6),
            decoration: BoxDecoration(color: isSelected ? AppColors.blue.withAlpha((0.15 * 255).toInt()) : AppColors.transparent, borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, color: widget.iconColor),
                      const SizedBox(width: 16),
                    ],
                    widget.title,
                  ],
                ),
                CustomRadioButton<String>(
                  value: widget.value,
                  groupValue: widget.groupValue,
                  activeColor: colorsController.getColor(colorsController.selectedColorScheme.value),
                  onChanged: widget.onChanged,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
