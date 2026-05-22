import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_sizes.dart';
import '../../controllers/language_controller.dart';

void showLanguageBottomSheetDialog(BuildContext context, Function(String) onSave, LanguagesController controller) {
  final tempLanguage = controller.selectedLanguage.value.obs;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    showDragHandle: false,
    backgroundColor: AppColors.transparent,
    builder: (BuildContext context) {
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
                child: Text('Выберите язык', style: TextStyle(fontSize: AppSizes.fontSizeBg, fontWeight: FontWeight.w400)),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    _buildLanguageTile(context, tempLanguage, 'ru', 'Русский'),
                    _buildLanguageTile(context, tempLanguage, 'en', 'English'),
                    _buildLanguageTile(context, tempLanguage, 'es', 'Español'),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
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
                      padding: const EdgeInsets.all(8),
                      child: TextButton(
                        onPressed: () {
                          controller.setLanguage(tempLanguage.value);
                          onSave(tempLanguage.value);
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
        ));
      },
  );
}

Widget _buildLanguageTile(BuildContext context, RxString tempLanguage, String value, String title) {
  return Obx(() {
    final isSelected = tempLanguage.value == value;

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        splashFactory: NoSplash.splashFactory,
        borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
        splashColor: AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()),
        highlightColor: AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()),
        hoverColor: AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()),
        onTap: () {
          tempLanguage.value = value;
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(color: isSelected ? AppColors.blue.withAlpha((0.08 * 255).toInt()) : AppColors.transparent, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Expanded(child: Text(title)),
              if (isSelected)
                const Icon(Icons.check, color: AppColors.blueAccent),
            ],
          ),
        ),
      ),
    );
  });
}
