import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import '../../../../generated/l10n/l10n.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_sizes.dart';
import '../../../note/widgets/tiles/custom_radio_list_tile.dart';
import '../../controllers/colors_controller.dart';

Future<void> showColorSchemeSelectionDialog(BuildContext context) async {
  final colorsController = Get.find<ColorsController>();
  String tempColorScheme = colorsController.selectedColorScheme.value;

  Widget buildColorOption({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required String groupValue,
    required void Function(String?) onChanged,
    double iconSize = 24,
  }) {
    return CustomRadioListTile(
      icon: icon,
      title: Text(title, style: TextStyle(fontSize: AppSizes.fontSizeMd, fontWeight: FontWeight.w400)),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      iconColor: color,
      iconSize: iconSize,
    );
  }

  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierColor: AppColors.black54,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) => Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: context.isDarkMode ? AppColors.blackGrey : AppColors.white, borderRadius: BorderRadius.circular(28)),
            child: Material(
              color: AppColors.transparent,
              child: Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Align(alignment: Alignment.centerLeft, child: Text(S.of(context).selectColorScheme, style: TextStyle(fontSize: AppSizes.fontSizeLg, fontWeight: FontWeight.w400))),
                    ),
                    const SizedBox(height: 12),
                    buildColorOption(
                      icon: Icons.color_lens,
                      title: S.of(context).system,
                      value: 'default',
                      color: AppColors.blue,
                      iconSize: 38,
                      groupValue: tempColorScheme,
                      onChanged: (value) => setState(() => tempColorScheme = value as String),
                    ),
                    buildColorOption(
                      icon: Icons.color_lens,
                      title: S.of(context).blueColor,
                      value: 'blue',
                      color: AppColors.blue,
                      iconSize: 38,
                      groupValue: tempColorScheme,
                      onChanged: (value) => setState(() => tempColorScheme = value as String),
                    ),
                    buildColorOption(
                      icon: Icons.color_lens,
                      title: S.of(context).redColor,
                      value: 'red',
                      color: AppColors.red,
                      iconSize: 38,
                      groupValue: tempColorScheme,
                      onChanged: (value) => setState(() => tempColorScheme = value as String),
                    ),
                    buildColorOption(
                      icon: Icons.color_lens,
                      title: S.of(context).greenColor,
                      value: 'green',
                      color: AppColors.green,
                      iconSize: 38,
                      groupValue: tempColorScheme,
                      onChanged: (value) => setState(() => tempColorScheme = value as String),
                    ),
                    buildColorOption(
                      icon: Icons.color_lens,
                      title: S.of(context).orangeColor,
                      value: 'orange',
                      color: AppColors.orange,
                      iconSize: 38,
                      groupValue: tempColorScheme,
                      onChanged: (value) => setState(() => tempColorScheme = value as String),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: TextButton.styleFrom(foregroundColor: AppColors.lightBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                              child: Text('ОТМЕНА', style: TextStyle(fontSize: AppSizes.fontSizeLg, color: AppColors.blueAccent)),
                            ),
                          ),
                        ),
                        Container(width: 1, height: 25, color: AppColors.darkGrey),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: TextButton(
                              onPressed: () {
                                colorsController.setColorScheme(tempColorScheme);
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
              ),
            ),
          ),
        ),
      );
    },
  );
}
