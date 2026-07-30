import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';

class AppPopupMenu {
  static Future<T?> show<T>({required BuildContext context, required RelativeRect position, required List<PopupMenuEntry<T>> items, double maxWidth = 220}) {
    return showMenu<T>(
      context: context,
      position: position,
      color: context.isDarkMode ? AppColors.greySlate : AppColors.white,
      elevation: 4,
      menuPadding: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      constraints: BoxConstraints(minWidth: 0, maxWidth: maxWidth),
      items: items,
    );
  }

  static Future<T?> showAt<T>({
    required BuildContext context,
    required GlobalKey targetKey,
    required List<PopupMenuEntry<T>> items,
    double maxWidth = 220,
    Offset offset = Offset.zero,
    bool showAbove = true,
  }) {

    final RenderBox renderBox = targetKey.currentContext!.findRenderObject() as RenderBox;
    final Offset position = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;
    final screenSize = MediaQuery.of(context).size;
    final left = position.dx + offset.dx;
    final top = showAbove ? position.dy + offset.dy : position.dy + size.height + offset.dy;
    final rect = RelativeRect.fromLTRB(left, top, screenSize.width - left - size.width, screenSize.height - top);

    return show<T>(context: context, position: rect, items: items, maxWidth: maxWidth);
  }
}
