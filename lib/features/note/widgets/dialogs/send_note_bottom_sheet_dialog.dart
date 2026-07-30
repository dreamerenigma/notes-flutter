import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';

import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_sizes.dart';
import '../../../../utils/constants/app_vectors.dart';

void showSendNoteBottomSheetDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) {
      return Dialog(
        insetPadding: const EdgeInsets.all(12),
        backgroundColor: AppColors.transparent,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.isDarkMode ? AppColors.greySlate : AppColors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(25), bottom: Radius.circular(25)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(padding: const EdgeInsets.only(left: 8, top: 4), child: Text('Отправить', style: TextStyle(fontSize: AppSizes.fontSizeBg))),
                const SizedBox(height: 12),
                _buildActionTile(
                  context,
                  icon: AppVectors.picture,
                  title: 'Как изображение',
                  onTap: () {},
                ),
                _buildActionTile(
                  context,
                  icon: AppVectors.image,
                  title: 'Как текст',
                  onTap: () {},
                ),
                _buildActionTile(
                  context,
                  icon: AppVectors.exportDocument,
                  title: 'Экспортировать как документ',
                  onTap: () {},
                ),
                _buildActionTile(
                  context,
                  icon: AppVectors.shareOnDevice,
                  title: 'На другое устройство',
                  onTap: () {},
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(foregroundColor: AppColors.lightBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                    child: Text('ОТМЕНА', style: TextStyle(fontSize: AppSizes.fontSizeLg, color: AppColors.blueAccent)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildActionTile(BuildContext context, {required String icon, required String title, required VoidCallback onTap}) {
  return Material(
    color: AppColors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      splashColor: context.isDarkMode ? AppColors.darkerGrey.withAlpha(80) : AppColors.grey.withAlpha(80),
      highlightColor: context.isDarkMode ? AppColors.darkerGrey.withAlpha(60) : AppColors.grey.withAlpha(60),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: [
            SvgPicture.asset(icon, width: 24, height: 24, colorFilter: ColorFilter.mode(context.isDarkMode ? AppColors.white : AppColors.black, BlendMode.srcIn)),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: TextStyle(fontSize: AppSizes.fontSizeMd))),
          ],
        ),
      ),
    ),
  );
}
