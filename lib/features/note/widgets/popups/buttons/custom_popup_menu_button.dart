import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:notes/utils/constants/app_colors.dart';
import 'package:notes/utils/constants/app_vectors.dart';

class CustomPopupMenuButton extends StatelessWidget {
  final List<PopupMenuEntry<int>> items;
  final ValueChanged<int> onSelected;

  const CustomPopupMenuButton({
    super.key,
    required this.items,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      position: PopupMenuPosition.under,
      color: context.isDarkMode ? AppColors.greySlate : AppColors.white,
      icon: SvgPicture.asset(AppVectors.moreGrid, width: 18, height: 18, colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn)),
      onSelected: onSelected,
      itemBuilder: (context) => items,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    );
  }
}
