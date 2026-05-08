import 'package:flutter/material.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_sizes.dart';

void showDeleteDialog(BuildContext context, VoidCallback onDelete, {required int selectedCount, required int allCount, required String type}) {

  String getDeleteConfirmationText(int selectedCount, int allCount, {required String type}) {
    final singular = type == 'note' ? 'заметку' : 'задача';
    final plural = type == 'note' ? 'заметки' : 'задачи';

    if (selectedCount == allCount) {
      return 'Удалить все $plural?';
    } else if (selectedCount == 1) {
      return 'Удалить эту $singular?';
    } else if (selectedCount == 0) {
      return 'Нет $plural для удаления.';
    } else {
      return 'Удалить $selectedCount $plural?';
    }
  }

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
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? AppColors.greySlate : AppColors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(25), bottom: Radius.circular(25)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(getDeleteConfirmationText(selectedCount, allCount, type: type), style: TextStyle(fontSize: AppSizes.fontSizeMd)),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: TextButton.styleFrom(foregroundColor: AppColors.lightBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                            child: Text('ОТМЕНА', style: TextStyle(fontSize: AppSizes.fontSizeLg, color: AppColors.blueAccent)),
                          ),
                          Container(width: 1, height: 22, color: AppColors.darkerGrey),
                          TextButton(
                            onPressed: () {
                              onDelete();
                              Navigator.pop(context);
                            },
                            style: TextButton.styleFrom(foregroundColor: AppColors.red.withAlpha((0.3 * 255).toInt()), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                            child: Text('УДАЛИТЬ', style: TextStyle(fontSize: AppSizes.fontSizeLg, color: AppColors.red)),
                          ),
                        ],
                      ),
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
