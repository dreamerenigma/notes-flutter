import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import '../../../../../utils/constants/app_colors.dart';
import '../../../../../utils/constants/app_sizes.dart';

class AddEditNoteAppBar extends StatefulWidget {
  final TextEditingController titleController;
  final FocusNode titleFocusNode;
  final String displayTime;
  final Color selectedColor;
  final String? selectedCategoryText;
  final bool isEditing;
  final VoidCallback? onCategoryTap;
  final GlobalKey categoryKey;

  const AddEditNoteAppBar({
    super.key,
    required this.titleController,
    required this.titleFocusNode,
    required this.displayTime,
    required this.selectedColor,
    required this.selectedCategoryText,
    required this.isEditing,
    required this.categoryKey,
    this.onCategoryTap,
  });

  @override
  State<AddEditNoteAppBar> createState() => _AddEditNoteAppBarState();
}
class _AddEditNoteAppBarState extends State<AddEditNoteAppBar> {
  final List<String> undoStack = [];
  final List<String> redoStack = [];
  bool isPressed = false;
  Timer? _debounce;

  @override
  Widget build(BuildContext context) {
    log(widget.selectedColor.withValues(alpha: 0.4).toString());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextSelectionTheme(
            data: TextSelectionThemeData(cursorColor: AppColors.blue, selectionColor: AppColors.blue.withAlpha((0.3 * 255).toInt()), selectionHandleColor: AppColors.blue),
            child: TextField(
              controller: widget.titleController,
              focusNode: widget.titleFocusNode,
              onChanged: (value) {
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 400), () {
                  undoStack.add(value);
                  redoStack.clear();
                });
              },
              decoration: const InputDecoration(
                hintText: 'Название',
                hintStyle: TextStyle(fontSize: 32, fontWeight: FontWeight.w400, color: AppColors.darkGrey),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w500),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(widget.displayTime, style: TextStyle(fontSize: AppSizes.fontSizeLm, fontWeight: FontWeight.w400, color: AppColors.darkGrey)),
                const SizedBox(width: 8),
                Material(
                  color: AppColors.transparent,
                  borderRadius: BorderRadius.circular(AppSizes.spaceBtwInputFields),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppSizes.spaceBtwInputFields),
                    splashColor: context.isDarkMode ? AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()) : AppColors.grey.withAlpha((0.4 * 255).toInt()),
                    highlightColor: context.isDarkMode ? AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()) : AppColors.grey.withAlpha((0.4 * 255).toInt()),
                    hoverColor: context.isDarkMode ? AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()) : AppColors.grey.withAlpha((0.4 * 255).toInt()),
                    onTap: () async {
                      final currentFocus = FocusScope.of(context).focusedChild;

                      widget.onCategoryTap?.call();

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        currentFocus?.requestFocus();
                      });

                      isPressed = !isPressed;
                    },
                    child: Container(
                      key: widget.categoryKey,
                      padding: const EdgeInsets.only(left: 8, right: 4, top: 2, bottom: 2),
                      decoration: BoxDecoration(color: widget.selectedColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(25)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(widget.selectedCategoryText ?? 'Без категории', style: TextStyle(color: AppColors.darkGrey, fontSize: AppSizes.fontSizeLm, fontWeight: FontWeight.w400)),
                          const Icon(Icons.arrow_drop_down_outlined, size: 22, color: AppColors.darkGrey),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
