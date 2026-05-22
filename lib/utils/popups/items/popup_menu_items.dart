import 'package:flutter/material.dart';
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
          splashColor: AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()),
          highlightColor: AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()),
          hoverColor: AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()),
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

  static PopupMenuDivider divider() => const PopupMenuDivider(height: 1, indent: 16, endIndent: 20);
}
