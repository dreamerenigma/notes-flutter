import 'package:flutter/material.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_sizes.dart';

void showAddWatermarkDialog(BuildContext context, Function(String) onSave, String initialText) {
  final TextEditingController controller = TextEditingController(text: initialText);
  final FocusNode focusNode = FocusNode();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      Future.delayed(Duration.zero, () {
        focusNode.requestFocus();
        controller.selection = TextSelection(baseOffset: 0, extentOffset: controller.text.length);
      });

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
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? AppColors.greySlate : AppColors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(25), bottom: Radius.circular(25)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8, top: 6),
                      child: Text('Водяной знак', style: TextStyle(fontSize: AppSizes.fontSizeLg)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      child: Text('Отображается, когда заметки отправляються как изображения.', style: TextStyle(fontSize: AppSizes.fontSizeXs, color: AppColors.darkGrey)),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      child: TextSelectionTheme(
                        data: TextSelectionThemeData(
                          cursorColor: AppColors.blue,
                          selectionColor: AppColors.blue.withAlpha((0.3 * 255).toInt()),
                          selectionHandleColor: AppColors.blue,
                        ),
                        child: TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            hintText: 'Название',
                            contentPadding: EdgeInsets.zero,
                            hintStyle: TextStyle(fontSize: AppSizes.fontSizeMd, fontWeight: FontWeight.w400, color: AppColors.darkGrey),
                            border: InputBorder.none,
                            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.darkGrey)),
                            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.blueAccent)),
                          ),
                          textCapitalization: TextCapitalization.sentences,
                          style: TextStyle(fontSize: AppSizes.fontSizeMd, fontWeight: FontWeight.w300),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('ОТМЕНА', style: TextStyle(fontSize: AppSizes.fontSizeLg, color: AppColors.blueAccent)),
                          ),
                        ),
                        Container(width: 1, height: 25, color: AppColors.darkGrey),
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              onSave(controller.text);
                            },
                            child: Text('СОХРАНИТЬ', style: TextStyle(fontSize: AppSizes.fontSizeLg, color: AppColors.blueAccent)),
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
