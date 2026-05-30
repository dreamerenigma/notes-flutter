import 'package:flutter/material.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_sizes.dart';
import '../popups/new_note_bottom_sheet_dialog.dart';
import '../../models/category_model.dart';

class CategoryTile extends StatelessWidget {
  final CategoryModel item;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryTile({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        splashFactory: NoSplash.splashFactory,
        borderRadius: BorderRadius.circular(12),
        splashColor: AppColors.darkerGrey.withAlpha((0.25 * 255).toInt()),
        highlightColor: AppColors.darkerGrey.withAlpha((0.15 * 255).toInt()),
        onTap: () {
          Navigator.pop(context);
          Future.delayed(Duration.zero, () {
            showNewNoteBottomSheetDialog(context);
          });
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 57, top: 16, bottom: 16),
          child: Row(
            children: [
              Text('Создать', style: TextStyle(color: AppColors.blueAccent, fontSize: AppSizes.fontSizeMd, fontWeight: FontWeight.w400)),
            ],
          ),
        ),
      ),
    );
  }
}