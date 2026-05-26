import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_sizes.dart';

void showDeleteFolderDialog(BuildContext context) {
  showDialog(
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
                decoration: BoxDecoration(color: context.isDarkMode ? AppColors.greySlate : AppColors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(25), bottom: Radius.circular(25))),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Удалить эту заметку и всё её содержимое?', style: TextStyle(fontSize: AppSizes.fontSizeMd)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: TextButton.styleFrom(foregroundColor: AppColors.blueAccent, overlayColor: AppColors.blueAccent.withAlpha((0.2 * 255).toInt()), backgroundColor: AppColors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                              child: Text('ОТМЕНА', style: TextStyle(fontSize: AppSizes.fontSizeLg, color: AppColors.blueAccent)),
                            ),
                          ),
                        ),
                        Container(width: 1, height: 22, color: AppColors.darkerGrey),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: TextButton.styleFrom(foregroundColor: AppColors.red, overlayColor: AppColors.red.withAlpha((0.3 * 255).toInt()), backgroundColor: AppColors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                              child: Text('УДАЛИТЬ', style: TextStyle(fontSize: AppSizes.fontSizeLg, color: AppColors.red)),
                            ),
                          ),
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
  );
}
