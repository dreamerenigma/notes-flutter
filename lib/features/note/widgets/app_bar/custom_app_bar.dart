import 'package:flutter/material.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_sizes.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? popupMenuButton;
  final Widget? leading;

  const CustomAppBar({super.key, this.popupMenuButton, this.leading});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withAlpha((0.1 * 255).toInt()),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: AppBar(
          backgroundColor: AppColors.transparent,
          automaticallyImplyLeading: false,
          titleTextStyle: TextStyle(fontSize: AppSizes.fontSizeMg, color: Theme.of(context).brightness == Brightness.dark ? AppColors.white : AppColors.black),
          actions: [popupMenuButton ?? const SizedBox.shrink()],
          leading: leading,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
