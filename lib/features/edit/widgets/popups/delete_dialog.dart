import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_sizes.dart';

void showDeleteDialog(BuildContext context, VoidCallback onDelete, {required int selectedCount, required int allCount, required String type}) {
  String getPlural(int count, {required String one, required String few, required String many}) {
    if (count % 100 >= 11 && count % 100 <= 14) {
      return many;
    }

    switch (count % 10) {
      case 1:
        return one;
      case 2:
      case 3:
      case 4:
        return few;
      default:
        return many;
    }
  }

  String getDeleteConfirmationText(int selectedCount, int allCount, {required String type}) {
    final isNote = type == 'note';

    final one = isNote ? 'заметку' : 'задачу';
    final few = isNote ? 'заметки' : 'задачи';
    final many = isNote ? 'заметок' : 'задач';

    if (selectedCount == 0) {
      return 'Нет элементов для удаления';
    }

    if (selectedCount == 1) {
      return 'Удалить эту $one?';
    }

    if (selectedCount == allCount) {
      return 'Удалить все ${getPlural(allCount, one: one, few: few, many: many)}?';
    }

    return 'Удалить $selectedCount ${getPlural(selectedCount, one: one, few: few, many: many)}?';
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
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                decoration: BoxDecoration(color: context.isDarkMode ? AppColors.greySlate : AppColors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(25), bottom: Radius.circular(25))),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(getDeleteConfirmationText(selectedCount, allCount, type: type), style: TextStyle(fontSize: AppSizes.fontSizeMd)),
                    const SizedBox(height: 16),
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
                                onDelete();
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
