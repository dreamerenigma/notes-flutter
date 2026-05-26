import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_sizes.dart';
import '../../../../utils/constants/app_vectors.dart';
import '../../models/folder_model.dart';

Future<FolderModel?> showFolderBottomSheetDialog(BuildContext context, {required String title, required String hintText, String? initialText, Widget? actionIcon, VoidCallback? onActionTap}) {
  final TextEditingController controller = TextEditingController(text: initialText ?? '');
  final FocusNode focusNode = FocusNode();

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    showDragHandle: false,
    backgroundColor: AppColors.transparent,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
          bool isValid = controller.text.trim().isNotEmpty;

          return AnimatedPadding(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(left: 12, right: 12, bottom: keyboardHeight + 12, top: 24),
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
                    child: Row(
                      children: [
                        Expanded(child: Text(title, style: TextStyle(fontSize: AppSizes.fontSizeXl, fontWeight: FontWeight.w400))),
                        if (actionIcon != null) ...[
                          const SizedBox(width: 8),
                          Material(
                            color: AppColors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
                              splashColor: AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()),
                              highlightColor: AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()),
                              hoverColor: AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()),
                              onTap: onActionTap,
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: actionIcon,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(AppVectors.folder, width: 24, height: 24, colorFilter: ColorFilter.mode(context.isDarkMode ? AppColors.white : AppColors.black, BlendMode.srcIn)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: TextSelectionTheme(
                            data: TextSelectionThemeData(
                              cursorColor: AppColors.blue,
                              selectionColor: AppColors.blue.withAlpha((0.3 * 255).toInt()),
                              selectionHandleColor: AppColors.blue,
                            ),
                            child: TextField(
                              controller: controller,
                              focusNode: focusNode,
                              autofocus: true,
                              onChanged: (_) {
                                setState(() {});
                              },
                              decoration: InputDecoration(
                                hintText: hintText,
                                hintStyle: TextStyle(color: AppColors.darkGrey, fontSize: AppSizes.fontSizeMd, fontWeight: FontWeight.w400),
                                border: UnderlineInputBorder(borderSide: BorderSide(color: context.isDarkMode ? AppColors.white : AppColors.black, width: 0.3)),
                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: context.isDarkMode ? AppColors.white : AppColors.black, width: 0.3)),
                                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: context.isDarkMode ? AppColors.white : AppColors.black, width: 0.3)),
                                isDense: true,
                              ),
                              textCapitalization: TextCapitalization.none,
                              style: TextStyle(fontSize: AppSizes.fontSizeMd, fontWeight: FontWeight.w400, color: context.isDarkMode ? AppColors.white : AppColors.black, decoration: TextDecoration.none),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: isValid ? AppColors.blueAccent : AppColors.darkGrey,
                              overlayColor: AppColors.blueAccent.withAlpha((0.2 * 255).toInt()),
                              backgroundColor: AppColors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            child: Text('ОТМЕНА', style: TextStyle(fontSize: AppSizes.fontSizeLg, color: AppColors.blueAccent)),
                          ),
                        ),
                      ),
                      Container(width: 1, height: 22, color: AppColors.darkerGrey),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: TextButton(
                            onPressed: isValid
                              ? () {
                                  final result = FolderModel(title: controller.text, icon: '');
                                  Navigator.pop(context, result);
                                }
                              : null,
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.blueAccent,
                              overlayColor: AppColors.blueAccent.withAlpha((0.2 * 255).toInt()),
                              backgroundColor: AppColors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            child: Text('СОХРАНИТЬ', style: TextStyle(fontSize: AppSizes.fontSizeLg, color: isValid ? AppColors.blueAccent : AppColors.blue.withAlpha((0.7 * 255).toInt()))),
                          ),
                        ),
                      ),
                    ],
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
