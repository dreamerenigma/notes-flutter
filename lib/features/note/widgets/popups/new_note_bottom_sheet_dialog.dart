import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_sizes.dart';
import '../../models/category_model.dart';

Future<CategoryModel?> showNewNoteBottomSheetDialog(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: false,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    backgroundColor: AppColors.transparent,
    builder: (_) => const NewNoteBottomSheet(),
  );
}

class NewNoteBottomSheet extends StatefulWidget {
  const NewNoteBottomSheet({super.key});

  @override
  State<NewNoteBottomSheet> createState() => _NewNoteBottomSheetState();
}

class _NewNoteBottomSheetState extends State<NewNoteBottomSheet> {
  late final FocusNode focusNode;
  late final TextEditingController controller;
  final colors = AppColors.categoryColors;
  bool isValid = false;
  int selectedColorIndex = 0;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    controller = TextEditingController();

    controller.addListener(() {
      final valid = controller.text.trim().isNotEmpty;

      if (valid != isValid) {
        setState(() {
          isValid = valid;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(left: 12, right: 12, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 12),
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
              child: Text('Новый блокнот', style: TextStyle(fontSize: AppSizes.fontSizeXl, fontWeight: FontWeight.w400)),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (int index = 0; index < colors.length; index++)
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedColorIndex = index;
                          });
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(margin: const EdgeInsets.symmetric(horizontal: 15), width: 40, height: 40, decoration: BoxDecoration(color: colors[index], shape: BoxShape.circle)),
                            if (selectedColorIndex == index)
                              Container(height: 11, width: 11, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 30, top: 18, bottom: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(color: colors[selectedColorIndex].withAlpha((0.15 * 255).toInt()), borderRadius: BorderRadius.circular(8)),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 4,
                            height: 24,
                            decoration: BoxDecoration(color: colors[selectedColorIndex], borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8))),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 28, top: 14),
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
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: 'Имя',
                          hintStyle: TextStyle(fontSize: AppSizes.fontSizeMd, fontWeight: FontWeight.w400),
                          border: InputBorder.none,
                          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.darkGrey)),
                          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.blueAccent)),
                          contentPadding: EdgeInsets.only(bottom: 3),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        style: TextStyle(color: context.isDarkMode ? AppColors.white : AppColors.black, fontSize: AppSizes.fontSizeMd, fontWeight: FontWeight.w400),
                        maxLines: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Container(width: 1, height: 22, color: AppColors.darkerGrey),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: isValid
                        ? () {
                            final item = CategoryModel(id: DateTime.now().millisecondsSinceEpoch, title: controller.text, color: colors[selectedColorIndex], stripeColor: colors[selectedColorIndex]);

                            if (context.mounted) {
                              Navigator.of(context).pop(item);
                            }
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
