import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_sizes.dart';
import 'new_note_bottom_sheet_dialog.dart';

class CustomCategoryDialog extends StatefulWidget {
  const CustomCategoryDialog({super.key});

  @override
  CustomCategoryDialogState createState() => CustomCategoryDialogState();
}

class CustomCategoryDialogState extends State<CustomCategoryDialog> {
  final box = GetStorage();
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    selectedCategory = box.read('selectedCategory');
  }

  void _onCategorySelected(String category, Color color) {
    setState(() {
      selectedCategory = category;
    });
    box.write('selectedCategory', category);
    Navigator.pop(context, {'text': category, 'color': color});
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.isDarkMode ? AppColors.greySlate : AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 200,
        child: Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogItem('Путешествия', AppColors.secondary, AppColors.secondary),
              _buildDivider(context),
              _buildDialogItem('Личное', AppColors.lightBlue, AppColors.lightBlue),
              _buildDivider(context),
              _buildDialogItem('Повседневное', AppColors.lightGreen, AppColors.lightGreen),
              _buildDivider(context),
              _buildDialogItem('Работа', AppColors.red, AppColors.red),
              _buildDivider(context),
              _buildDialogItemNoCategory('Без категории', AppColors.darkGrey),
              _buildDivider(context),
              _buildDialogCreateCategory('Создать'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 60, right: 20),
      child: Divider(
        height: 0,
        thickness: 1,
        color: context.isDarkMode ? AppColors.darkSlate : AppColors.buttonDisabled,
      ),
    );
  }

  Widget _buildDialogItem(String text, Color containerColor, Color stripeColor) {
    bool isSelected = selectedCategory == text;

    return InkWell(
      borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
      onTap: () => _onCategorySelected(text, containerColor),
      splashColor: AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()),
      highlightColor: AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()),
      hoverColor: AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? containerColor.withAlpha((0.2 * 255).toInt()) : AppColors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(color: containerColor.withAlpha((0.15 * 255).toInt()), borderRadius: BorderRadius.circular(8)),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(color: stripeColor, borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8))),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Text(
                text,
                style: TextStyle(
                  fontSize: AppSizes.fontSizeMd,
                  color: isSelected ? containerColor : context.isDarkMode ? AppColors.white : AppColors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogItemNoCategory(String text, Color containerColor) {
    bool isSelected = selectedCategory == text;
    return InkWell(
      borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
      onTap: () => _onCategorySelected(text, containerColor),
      splashColor: AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()),
      highlightColor: AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()),
      hoverColor: AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkGrey.withAlpha((0.2 * 255).toInt()) : AppColors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              const Icon(Icons.book_outlined, size: 26, color: AppColors.white),
              const SizedBox(width: 19),
              Text(text, style: TextStyle(fontSize: AppSizes.fontSizeMd)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogCreateCategory(String text) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
      splashColor: AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()),
      highlightColor: AppColors.blueAccent.withAlpha((0.4 * 255).toInt()),
      hoverColor: AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()),
      onTap: () {
        showNewNoteBottomSheetDialog(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 16),
        child: Row(
          children: [
            const SizedBox(width: 25),
            Text(text, style: TextStyle(fontSize: AppSizes.fontSizeMd, color: AppColors.blueAccent)),
          ],
        ),
      ),
    );
  }
}
