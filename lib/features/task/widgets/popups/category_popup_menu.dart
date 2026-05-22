import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notes/utils/constants/app_vectors.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../note/models/category_item.dart';
import '../../../note/widgets/tiles/category_tile.dart';
import '../tiles/category_item_tile.dart';

class CategoryPopupMenu {
  static Future<Map<String, dynamic>?> show(BuildContext context, RelativeRect position, String? selectedCategory) {
    return showMenu<Map<String, dynamic>>(
      context: context,
      position: position,
      color: context.isDarkMode ? AppColors.greySlate : AppColors.softGrey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      menuPadding:EdgeInsets.symmetric(vertical: 4),
      items: [
        _buildPopupItem(context, 'Работа', AppColors.red, selectedCategory),
        const PopupMenuDivider(height: 0, indent: 55, endIndent: 16, color: AppColors.softNight),
        _buildPopupItem(context, 'Личное', AppColors.blueAccent, selectedCategory),
        const PopupMenuDivider(height: 0, indent: 55, endIndent: 16, color: AppColors.softNight),
        _buildPopupItem(context, 'Шоппинг', AppColors.secondary, selectedCategory),
        const PopupMenuDivider(height: 0, indent: 55, endIndent: 16, color: AppColors.softNight),
        _buildPopupItem(context, 'Без категории', AppColors.darkGrey, selectedCategory, svgAsset: AppVectors.bookmark),
        const PopupMenuDivider(height: 0, indent: 55, endIndent: 16, color: AppColors.softNight),
        PopupMenuItem(
          enabled: false,
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: CategoryTile(item: CategoryItem(title: 'Создать', color: AppColors.red, value: 999), isSelected: false, onTap: () {}),
        ),
      ],
    );
  }

  static PopupMenuItem<Map<String, dynamic>> _buildPopupItem(BuildContext context, String text, Color color, String? selectedCategory, {String? svgAsset}) {
    return PopupMenuItem(
      enabled: false,
      value: {'text': text, 'color': color},
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: CategoryItemTile(text: text, color: color, isSelected: selectedCategory == text, svgAsset: svgAsset, onTap: () => Navigator.pop(context, {'text': text, 'color': color})),
    );
  }
}
