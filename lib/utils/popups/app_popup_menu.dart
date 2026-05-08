import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppPopupMenu {
  static Future<T?> show<T>({
    required BuildContext context,
    required RelativeRect position,
    required List<PopupMenuEntry<T>> items,
    double maxWidth = 220,
  }) {
    return showMenu<T>(
      context: context,
      position: position,
      color: AppColors.greySlate,
      elevation: 10,
      menuPadding: EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      constraints: BoxConstraints(minWidth: 0, maxWidth: maxWidth),
      items: items,
    );
  }
}
