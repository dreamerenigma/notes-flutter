import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../features/task/widgets/buttons/custom_radio_button.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';

class PopupMenuItems {
  static PopupMenuItem<int> item({required BuildContext context, required int value, required String text, VoidCallback? onTap, Widget? trailing}) {
    return PopupMenuItem<int>(
      value: value,
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
          splashColor: context.isDarkMode ? AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()) : AppColors.lightBackground,
          highlightColor: context.isDarkMode ? AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()) : AppColors.lightBackground,
          hoverColor: context.isDarkMode ? AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()) : AppColors.lightBackground,
          onTap: () {
            Navigator.pop(context, value);
            onTap?.call();
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(child: Text(text, style: TextStyle(fontSize: AppSizes.fontSizeMd))),
                if (trailing != null) ...[
                  trailing,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static PopupMenuItem<int> radioItem({required BuildContext context, required int value, required String text, required int groupValue, required ValueChanged<int?> onChanged}) {
    return item(
      context: context,
      value: value,
      text: text,
      onTap: () => onChanged(value),
      trailing: CustomRadioButton(value: value, groupValue: groupValue, onChanged: onChanged, padding: EdgeInsets.zero),
    );
  }

  static PopupMenuDivider divider(BuildContext context) {
    return PopupMenuDivider(height: 1, indent: 16, endIndent: 20, color: context.isDarkMode ? AppColors.darkSlate : AppColors.buttonDisabled);
  }
}
