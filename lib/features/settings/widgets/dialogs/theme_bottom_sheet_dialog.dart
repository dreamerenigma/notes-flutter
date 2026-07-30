import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:notes/features/settings/controllers/themes_controller.dart';
import 'package:notes/features/task/widgets/buttons/custom_radio_button.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_sizes.dart';

void showThemeBottomSheetDialog(BuildContext context, ThemesController themesController) {
  String tempTheme = themesController.selectedTheme.value;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    showDragHandle: false,
    backgroundColor: AppColors.transparent,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(left: 12, right: 12, bottom: 12, top: 24),
            child: Container(
              decoration: BoxDecoration(
                color: context.isDarkMode ? AppColors.blackGrey : AppColors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(color: AppColors.black.withAlpha((0.2 * 255).toInt()), blurRadius: 30, offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 24, right: 24, top: 18, bottom: 12),
                    child: Text('Выберите тему', style: TextStyle(fontSize: AppSizes.fontSizeBg, fontWeight: FontWeight.w400)),
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          children: [
                            _buildTile(context, tempTheme, (value) => setState(() => tempTheme = value), 'system', 'Системная', Icons.settings_outlined),
                            _buildTile(context, tempTheme, (value) => setState(() => tempTheme = value), 'light', 'Светлая', Icons.light_mode_outlined),
                            _buildTile(context, tempTheme, (value) => setState(() => tempTheme = value), 'dark', 'Темная', Icons.dark_mode_outlined),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: SizedBox(
                                width: double.infinity,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  style: TextButton.styleFrom(
                                    overlayColor: AppColors.lightBlue,
                                    foregroundColor: AppColors.lightBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                  ),
                                  child: Text('ОТМЕНА', style: TextStyle(fontSize: AppSizes.fontSizeLg, color: AppColors.blueAccent)),
                                ),
                              ),
                            ),
                          ),
                          Container(width: 1, height: 25, color: AppColors.darkGrey),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: TextButton(
                                onPressed: () {
                                  themesController.setTheme(tempTheme);
                                  Navigator.pop(context);
                                },
                                style: TextButton.styleFrom(foregroundColor: AppColors.lightBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                                child: Text('СОХРАНИТЬ', style: TextStyle(fontSize: AppSizes.fontSizeLg, color: AppColors.blueAccent)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          );
        }
      );
    },
  );
}

Widget _buildTile(BuildContext context, String selectedValue, void Function(String value) onSelect, String value, String title, IconData icon) {
  final isSelected = selectedValue == value;

  return Material(
    color: AppColors.transparent,
    child: InkWell(
      splashFactory: NoSplash.splashFactory,
      borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
      splashColor: context.isDarkMode ? AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()) : AppColors.lightBackground,
      highlightColor: context.isDarkMode ? AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()) : AppColors.lightBackground,
      hoverColor: context.isDarkMode ? AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()) : AppColors.lightBackground,
      onTap: () => onSelect(value),
      child: Container(
        padding: const EdgeInsets.only(left: 16, top: 6, bottom: 6),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: isSelected ? AppColors.blue.withAlpha((0.08 * 255).toInt()) : AppColors.transparent),
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
