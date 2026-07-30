import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_sizes.dart';
import '../../../../utils/constants/app_vectors.dart';

class EditMessageBottomNavBar extends StatelessWidget {
  final VoidCallback onList;
  final VoidCallback onTextStyle;
  final VoidCallback onGallery;
  final VoidCallback onHandwritingInput;

  const EditMessageBottomNavBar({
    super.key,
    required this.onList,
    required this.onTextStyle,
    required this.onGallery,
    required this.onHandwritingInput,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 70,
      color: AppColors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            _buildBottomAppBarItem(context, Icon(Icons.check_circle_outline, color: context.isDarkMode ? AppColors.white : AppColors.black, size: 25), 'Список', onList),
            _buildBottomAppBarItem(
              context,
              SvgPicture.asset(AppVectors.textStyle, width: 22, height: 22, colorFilter: ColorFilter.mode(context.isDarkMode ? AppColors.white : AppColors.black, BlendMode.srcIn)),
              'Стиль',
              onTextStyle,
            ),
            _buildBottomAppBarItem(context, SvgPicture.asset(AppVectors.gallery, width: 25, height: 25, colorFilter: ColorFilter.mode(context.isDarkMode ? AppColors.white : AppColors.black, BlendMode.srcIn)), 'Галерея', onGallery),
            _buildBottomAppBarItem(context, Icon(Icons.draw_outlined, color: context.isDarkMode ? AppColors.white : AppColors.black, size: 25), 'Рисунок', onHandwritingInput),
          ],
        )
      ),
    );
  }

  Widget _buildBottomAppBarItem(BuildContext context, Widget icon, String label, VoidCallback onTap) {
    return Expanded(
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: context.isDarkMode ? AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()) : AppColors.grey.withAlpha((0.4 * 255).toInt()),
          highlightColor: context.isDarkMode ? AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()) : AppColors.grey.withAlpha((0.4 * 255).toInt()),
          hoverColor: context.isDarkMode ? AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()) : AppColors.grey.withAlpha((0.4 * 255).toInt()),
          child: SizedBox.expand(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(color: context.isDarkMode ? AppColors.white : AppColors.black, fontSize: AppSizes.fontSizeXs, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis, softWrap: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
