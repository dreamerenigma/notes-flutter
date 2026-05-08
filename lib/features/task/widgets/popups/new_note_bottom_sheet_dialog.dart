import 'package:flutter/material.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_sizes.dart';

void showNewNoteBottomSheetDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.blackGrey : AppColors.white,
    builder: (BuildContext context) {
      int selectedColorIndex = 0;
      List<Color> colors = [
        Colors.red,
        Colors.blue,
        Colors.green,
        Colors.yellow,
        Colors.orange,
        Colors.purple,
        Colors.teal
      ];

      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Text('Новый блокнот', style: TextStyle(fontSize: AppSizes.fontSizeXl, fontWeight: FontWeight.w400)),
                  ),
                  const SizedBox(height: 16),
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
                                  Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 15),
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(color: colors[index], shape: BoxShape.circle),
                                  ),
                                  if (selectedColorIndex == index)
                                    Container(
                                      height: 11,
                                      width: 11,
                                      decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                                    ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 30, top: 16, bottom: 16),
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
                          padding: const EdgeInsets.only(left: 20, right: 28),
                          child: TextSelectionTheme(
                            data: TextSelectionThemeData(
                              cursorColor: AppColors.blue,
                              selectionColor: AppColors.blue.withAlpha((0.3 * 255).toInt()),
                              selectionHandleColor: AppColors.blue,
                            ),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Имя',
                                hintStyle: TextStyle(fontSize: AppSizes.fontSizeMd),
                                border: InputBorder.none,
                                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.darkGrey)),
                                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.blueAccent)),
                              ),
                              textCapitalization: TextCapitalization.sentences,
                              style: TextStyle(fontSize: AppSizes.fontSizeMd),
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
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
                      Container(width: 1, height: 22, color: AppColors.darkerGrey),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('СОХРАНИТЬ', style: TextStyle(fontSize: AppSizes.fontSizeLg, color: AppColors.blueAccent)),
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
