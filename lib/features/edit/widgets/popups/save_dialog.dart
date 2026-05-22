import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_sizes.dart';

Future<bool> showSaveDialog(BuildContext context) async {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: const EdgeInsets.all(12),
        backgroundColor: AppColors.transparent,
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.isDarkMode ? AppColors.greySlate : AppColors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(25), bottom: Radius.circular(25)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Сохранить изменения?', style: TextStyle(fontSize: AppSizes.fontSizeMd)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          style: TextButton.styleFrom(foregroundColor: AppColors.lightBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                          child: Text('НЕ СОХРАНЯТЬ', style: TextStyle(fontSize: AppSizes.fontSizeLg, color: AppColors.blueAccent)),
                        ),
                        Container(width: 1, height: 22, color: AppColors.darkerGrey),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          style: TextButton.styleFrom(foregroundColor: AppColors.lightBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                          child: Text('СОХРАНИТЬ', style: TextStyle(fontSize: AppSizes.fontSizeLg, color: AppColors.blueAccent)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  ).then((value) => value ?? false);
}
