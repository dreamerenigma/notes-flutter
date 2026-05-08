import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_vectors.dart';

class TaskFAB extends StatelessWidget {
  const TaskFAB({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: AppColors.blueAccent.withAlpha((0.6 * 255).toInt()), blurRadius: 6, spreadRadius: 2),
          BoxShadow(color: AppColors.blueAccent.withAlpha((0.3 * 255).toInt()), blurRadius: 6, spreadRadius: 2),
        ],
      ),
      child: FloatingActionButton(
        heroTag: 'task',
        onPressed: onPressed,
        backgroundColor: AppColors.blueAccent,
        shape: const CircleBorder(),
        child: SvgPicture.asset(AppVectors.add, width: 22, height: 22, colorFilter: ColorFilter.mode(context.isDarkMode ? AppColors.white : AppColors.black, BlendMode.srcIn)),
      ),
    );
  }
}
