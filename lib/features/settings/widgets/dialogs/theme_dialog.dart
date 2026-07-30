import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../generated/l10n/l10n.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_sizes.dart';
import '../../../task/widgets/buttons/custom_radio_button.dart';
import '../../controllers/themes_controller.dart';

void showThemeDialog(BuildContext context, ThemesController themesController) {
  String tempTheme = themesController.selectedTheme.value;

  Get.dialog(
    StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          backgroundColor: context.isDarkMode ? AppColors.nightGrey : AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          actionsPadding: EdgeInsets.only(right: 25, top: 25, bottom: 25),
          insetPadding: EdgeInsets.symmetric(horizontal: 16),
          contentPadding: EdgeInsets.zero,
          title: Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(S.of(context).selectTheme, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600))),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Column(
                      children: [
                        _buildTile(context, tempTheme, (value) => setState(() => tempTheme = value), 'system', S.of(context).system, Icons.settings_outlined),
                        _buildTile(context, tempTheme, (value) => setState(() => tempTheme = value), 'light', S.of(context).light, Icons.light_mode_outlined),
                        _buildTile(context, tempTheme, (value) => setState(() => tempTheme = value), 'dark', S.of(context).dark, Icons.dark_mode_outlined),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Get.back(),
              style: ButtonStyle(
                side: WidgetStateProperty.all(BorderSide(color: context.isDarkMode ? AppColors.white : AppColors.darkerGrey, width: 1.5)),
                shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 8)),
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.pressed) || states.contains(WidgetState.hovered)) {
                    return Theme.of(Get.context!).brightness == Brightness.dark ? AppColors.white : AppColors.darkerGrey;
                  }
                  return AppColors.transparent;
                }),
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.pressed) || states.contains(WidgetState.hovered)) {
                    return Theme.of(Get.context!).brightness == Brightness.dark ? AppColors.darkerGrey : AppColors.white;
                  }
                  return context.isDarkMode ? AppColors.white : AppColors.darkerGrey;
                }),
              ),
              child: Text(S.of(context).cancel, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            ),
            SizedBox(width: 2),
            OutlinedButton(
              onPressed: () {
                themesController.setTheme(tempTheme);
                Get.back();
              },
              style: ButtonStyle(
                side: WidgetStateProperty.all(const BorderSide(color: AppColors.blueAccent, width: 1.5)),
                shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 8)),
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.pressed) || states.contains(WidgetState.hovered)) {
                    return AppColors.blueAccent;
                  }
                  return AppColors.transparent;
                }),
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.pressed) || states.contains(WidgetState.hovered)) {
                    return AppColors.white;
                  }
                  return AppColors.blueAccent;
                }),
              ),
              child: Text(S.of(context).apply, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            ),
          ],
        );
      },
    ),
  );
}

Widget _buildTile(BuildContext context, String selectedValue, void Function(String value) onSelect, String value, String title, IconData icon) {
  final isSelected = selectedValue == value;

  return Material(
    color: AppColors.transparent,
    child: InkWell(
      splashFactory: NoSplash.splashFactory,
      splashColor: context.isDarkMode ? AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()) : AppColors.grey.withAlpha((0.4 * 255).toInt()),
      highlightColor: context.isDarkMode ? AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()) : AppColors.grey.withAlpha((0.4 * 255).toInt()),
      hoverColor: context.isDarkMode ? AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()) : AppColors.grey.withAlpha((0.4 * 255).toInt()),
      onTap: () => onSelect(value),
      child: Container(
        padding: const EdgeInsets.only(left: 16, top: 6, bottom: 6),
        decoration: BoxDecoration(color: isSelected ? AppColors.blue.withAlpha((0.08 * 255).toInt()) : AppColors.transparent),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: TextStyle(fontSize: AppSizes.fontSizeMd, fontWeight: FontWeight.w400))),
            CustomRadioButton(value: isSelected ? 1 : 0, groupValue: 1, onChanged: (_) => onSelect(value)),
          ],
        ),
      ),
    ),
  );
}
