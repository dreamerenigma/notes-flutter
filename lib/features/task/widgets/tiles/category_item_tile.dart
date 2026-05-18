import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_sizes.dart';

class CategoryItemTile extends StatelessWidget {
  final String text;
  final Color color;
  final bool isSelected;
  final String? svgAsset;
  final Widget? trailing;
  final VoidCallback onTap;
  final EdgeInsetsGeometry? padding;

  const CategoryItemTile({
    super.key,
    required this.text,
    required this.color,
    required this.isSelected,
    required this.onTap,
    this.svgAsset,
    this.trailing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        splashFactory: NoSplash.splashFactory,
        splashColor: AppColors.darkerGrey.withAlpha((0.25 * 255).toInt()),
        highlightColor: AppColors.darkerGrey.withAlpha((0.15 * 255).toInt()),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(color: isSelected ? color.withAlpha((0.18 * 255).toInt()) : AppColors.transparent, borderRadius: BorderRadius.circular(12)),
          width: double.infinity,
          child: Padding(
            padding: padding ?? EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Row(
              children: [
                if (svgAsset != null)
                  SvgPicture.asset(svgAsset!, width: 22, height: 22, colorFilter: ColorFilter.mode(color, BlendMode.srcIn))
                else
                  Container(
                    width: 18,
                    height: 24,
                    decoration: BoxDecoration(color: color.withAlpha((0.15 * 255).toInt()), borderRadius: BorderRadius.circular(6)),
                    child: Align(alignment: Alignment.centerLeft, child: Container(width: 4, height: 24, color: color)),
                  ),
                SizedBox(width: 18),
                Expanded(child: Text(text, style: TextStyle(fontSize: AppSizes.fontSizeMd, fontWeight: FontWeight.w400))),
                trailing ?? const SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
