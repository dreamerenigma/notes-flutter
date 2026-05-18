import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_sizes.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final VoidCallback? onBack;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: AppColors.black.withAlpha((0.1 * 255).toInt()), spreadRadius: 1, blurRadius: 3, offset: const Offset(0, 1)),
        ],
      ),
      child: AppBar(
        elevation: 0,
        titleSpacing: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.transparent,
        automaticallyImplyLeading: false,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, size: 36), onPressed: onBack ?? () => Navigator.of(context).pop()),
        title: Text(title, style: TextStyle(fontSize: AppSizes.fontSizeMg, color: context.isDarkMode ? AppColors.white : AppColors.black, fontWeight: FontWeight.w400)),
        actions: actions,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
