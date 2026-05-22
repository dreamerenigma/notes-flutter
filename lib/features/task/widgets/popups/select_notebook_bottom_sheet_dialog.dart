import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:notes/features/task/widgets/buttons/custom_radio_button.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_sizes.dart';
import '../../../note/models/category_item.dart';
import '../../../note/widgets/tiles/category_tile.dart';
import '../tiles/category_item_tile.dart';

Future<CategoryItem?> selectNotebookBottomSheetDialog({required BuildContext context, required List<CategoryItem> categories, required CategoryItem? selected}) {
  String current = selected?.title ?? 'Без категории';
  int selectedValue = categories.firstWhere((e) => e.title == current, orElse: () => categories.last).value;

  return showModalBottomSheet<CategoryItem>(
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
                    padding: const EdgeInsets.only(left: 24, right: 24, top: 18),
                    child: Text('Выбор блокнота', style: TextStyle(fontSize: AppSizes.fontSizeBg, fontWeight: FontWeight.w400)),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      children: [
                        ...categories.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          final isLast = index == categories.length - 1;

                          void selectCategory() {
                            setState(() {
                              current = item.title;
                              selectedValue = item.value;
                            });

                            Navigator.pop(context, item);
                          }

                          return Column(
                            children: [
                              CategoryItemTile(
                                text: item.title,
                                color: item.color,
                                svgAsset: item.svgAsset,
                                isSelected: current == item.title,
                                onTap: selectCategory,
                                trailing: CustomRadioButton(
                                  value: item.value,
                                  groupValue: selectedValue,
                                  onChanged: (_) {
                                    selectCategory();
                                  },
                                  padding: EdgeInsets.only(left: 20, top: 4, bottom: 4),
                                ),
                                padding: item.svgAsset != null ? const EdgeInsets.only(left: 16, right: 20, top: 10, bottom: 10) : const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              ),
                              if (!isLast) const Divider(height: 0, indent: 57, endIndent: 20, color: AppColors.softNight),
                            ],
                          );
                        }),
                        const Divider(height: 0, indent: 57, endIndent: 20, color: AppColors.softNight),
                        PopupMenuItem(
                          enabled: false,
                          padding: EdgeInsets.zero,
                          child: CategoryTile(item: CategoryItem(title: 'Создать', color: AppColors.red, value: 999), isSelected: false, onTap: () {}),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.blueAccent,
                              overlayColor: AppColors.blueAccent.withAlpha((0.2 * 255).toInt()),
                              backgroundColor: AppColors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            child: Text('ОТМЕНА', style: TextStyle(fontSize: AppSizes.fontSizeLg, color: AppColors.blueAccent)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
